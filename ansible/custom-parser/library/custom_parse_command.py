#!/usr/bin/python

from __future__ import absolute_import, division, print_function
__metaclass__ = type

ANSIBLE_METADATA = {'metadata_version': '1.1', 'status': ['preview'], 'supported_by': 'community'}

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.connection import Connection, ConnectionError
from ansible.module_utils.six import PY3
import json
import re

def process_run_conf(response):    
    lines = response.splitlines()
    vlan_count = sum(1 for line in lines if 'interface Vl' in line)
    return vlan_count

def process_version(response):
    lines = response.splitlines()

    def extract_info(keyword, prefix):
        for line in lines:
            if keyword in line:
                return line.replace(prefix, '').strip()
        return None

    return {
        'hostname': extract_info('Device name:', 'Device name: '),
        'serial_number': extract_info('Processor Board ID', 'Processor Board ID '),
        'nxos_version': extract_info('NXOS: version', 'NXOS: version '),
        'hardware_model': extract_info('cisco ', 'cisco ').split()[0],
        'uptime': extract_info('Kernel uptime is', 'Kernel uptime is ')
    }

def process_resources(response):
    lines = response.splitlines()

    def extract_cpu_metrics():
        for line in lines:
            if 'CPU states' in line:
                idle_percentage = float(line.split(',')[-1].split('%')[0].strip())
                return round(idle_percentage, 2), round(100.0 - idle_percentage, 2)
        return None, None

    def extract_memory_metrics():
        for line in lines:
            if 'Memory usage' in line:
                memory_info = line.split(',')
                total_memory = float(memory_info[0].split(':')[-1].split('K')[0].strip())
                used_memory = float(memory_info[1].split('K')[0].strip())
                return used_memory, total_memory
        return None, None

    cpu_idle, cpu_usage = extract_cpu_metrics()
    memory_used, memory_total = extract_memory_metrics()

    memory_usage = round((memory_used / memory_total * 100.0), 2) if memory_total > 0 else None

    return {
        'cpu_usage': cpu_usage,
        'memory_usage': memory_usage,
    }

def process_cpu_memory(response, extra_response):
    cpu_match = re.search(r'five minutes:\s*(\d+\.?\d*)%', response)
    total_memory_match = re.search(r'Processor Pool Total:\s*(\d+)', extra_response)
    used_memory_match = re.search(r'Used:\s*(\d+)', extra_response)
    
    cpu_usage_five_min = float(cpu_match.group(1)) if cpu_match else None
    total_memory = float(total_memory_match.group(1)) if total_memory_match else None
    used_memory = float(used_memory_match.group(1)) if used_memory_match else None

    memory_usage = round((used_memory / total_memory) * 100.0, 2)

    return {
        'cpu_usage': cpu_usage_five_min,
        'memory_usage': memory_usage,
    }

def process_environment_fan(response):
    lines = response.splitlines()
    temp_str = []
    pattern = re.compile(r"^(Fan\d+|Fan_in_PS\d+)") 

    for line in lines:
        if match := pattern.match(line):
            name = line.split()[0]
            status = line.split()[-1].strip()  
            temp_str.append(f"{name} = {status}")  

    return ', '.join(temp_str)

def process_environment_power(response):
    lines = response.splitlines()
    temp_str = []

    for line in lines:
        if line.strip() and line[0].isdigit():  
            num = line.split()[0]
            status = line.split()[-1].strip()  
            temp_str.append(f"{num} = {status}")  
        elif temp_str:  
            break

    return ', '.join(temp_str)

def process_env_fan(response): # for cisco ios
    lines = response.splitlines()
    temp_str = []

    for line in lines:
        line = line.split()
        name = line[0] + '-' + line[1]
        status = line[-1] 
        if (line[-2] == 'NOT'):
            status = line[-2] + ' ' + line[-1]
        temp_str.append(f"{name} = {status}")  

    return ', '.join(temp_str)

def process_env_power(response):  # for cisco ios
    lines = response.splitlines()[2:]  
    temp_str = []

    for i, line in enumerate(lines):  
        parts = line.split()
        name = i + 1  
        if len(parts) > 3: 
            status = parts[3]  
        else:
            status = "Not Present"  
        temp_str.append(f"{name} = {status}")  

    return ', '.join(temp_str)

def process_inventory(response):    
    lines = response.split('\n\n')
    devices = []
    pattern = re.compile(r'NAME:\s*"(?P<name>.*?)",\s*DESCR:\s*"(?P<descr>.*?)"\s*PID:\s*(?P<pid>.*?),\s*VID:\s*(?P<vid>.*?),\s*SN:\s*(?P<sn>.*)')

    for line in lines:
        match = pattern.search(line)
        if match:
            device = {
                'name': match.group('name'),
                'description': match.group('descr'),
                'pid': match.group('pid').strip(),
                'vid': match.group('vid').strip(),
                'sn': match.group('sn').strip(),
            }
            devices.append(device)

    return devices

def main():
    argument_spec = dict(
        command=dict(type='str', required=True),
    )
    
    module = AnsibleModule(argument_spec=argument_spec, supports_check_mode=True)

    if not PY3:
        module.fail_json(msg="This module requires Python 3")

    connection = Connection(module._socket_path)
    command_input = module.params['command']
    response = ""
    extra_response = ""

    try:
        response = connection.get(command=command_input)
    except ConnectionError as exc:
        extra_command = "" # if there is need for getting other command
        if command_input == "show environment fan" or command_input == "show environment power":
            command_input = command_input.replace('environment', 'env')  
        if command_input == "show system resources":
            command_input = "show processes cpu"
            extra_command = "show processes memory"
        try:
            response = connection.get(command=command_input)
            if extra_command:
                extra_response = connection.get(command=extra_command) 
        except ConnectionError as retry_exc:
            module.fail_json(msg=str(retry_exc))
        
    result = {
            'changed': False,
            # 'stdout': response,
        }

    if command_input == "show run":
        processed_response = process_run_conf(response)
        result['vlan_count'] = processed_response
    if command_input == "show version":
        processed_response = process_version(response)
        result['hostname'] = processed_response['hostname'] 
        result['serial_number'] = processed_response['serial_number']
        result['nxos_version'] = processed_response['nxos_version']
        result['hardware_model'] = processed_response['hardware_model']
        result['uptime'] = processed_response['uptime']
    if command_input == "show system resources":
        processed_response = process_resources(response)     
        result['cpu_usage'] = processed_response['cpu_usage']
        result['memory_usage'] = processed_response['memory_usage']
    if command_input == "show environment fan":
        processed_response = process_environment_fan(response)
        result['fan'] = processed_response 
    if command_input == "show environment power":
        processed_response = process_environment_power(response)
        result['power'] = processed_response 
    if command_input == "show inventory":
        processed_response = process_inventory(response)
        result['inventory'] = processed_response 

    # for cisco ios
    if command_input == "show env fan":
        processed_response = process_env_fan(response)
        result['fan'] = processed_response 

    if command_input == "show env power":
        processed_response = process_env_power(response)
        result['power'] = processed_response 
    
    if command_input == "show processes cpu":
        processed_response = process_cpu_memory(response, extra_response)
        result['cpu_usage'] = processed_response['cpu_usage']
        result['memory_usage'] = processed_response['memory_usage']

    module.exit_json(**result)

if __name__ == '__main__':
    main()