-- Create the device table in PostgreSQL
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