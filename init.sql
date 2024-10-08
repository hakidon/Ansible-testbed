CREATE TABLE device (
    device_sn VARCHAR(50) PRIMARY KEY, 
    hostname VARCHAR(255) NOT NULL,
    ip INET NOT NULL,
    os_version VARCHAR(50),
    hardware_model VARCHAR(100),
    uptime VARCHAR(100),
    cpu_consumption NUMERIC(5, 2),
    memory_consumption NUMERIC(5, 2)
);


INSERT INTO device (device_sn, hostname, ip, os_version, hardware_model, uptime, cpu_consumption, memory_consumption) VALUES
('CD123456', 'sample_cisco_1', '192.168.0.1', 'IOS XE 17.3', 'Cisco ISR 4451', '120 days', 5.25, 30.50),
('CD123457', 'sample_cisco_2', '192.168.0.2', 'IOS 15.2', 'Cisco Catalyst 9300', '200 days', 3.50, 20.75),
('CD123458', 'sample_cisco_3', '192.168.0.3', 'ASA 9.8', 'Cisco ASA 5506-X', '150 days', 10.00, 40.00);
