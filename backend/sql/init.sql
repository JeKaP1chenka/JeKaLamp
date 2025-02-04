CREATE DATABASE lampdb
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

\connect lampdb;

-- Таблица для ламп с временем последней проверки статуса
CREATE TABLE IF NOT EXISTS lamps (
    id SERIAL PRIMARY KEY,
    lamp_name VARCHAR UNIQUE NOT NULL,
    last_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Таблица для двусторонних связей между лампами
CREATE TABLE IF NOT EXISTS lamp_connections (
    id SERIAL PRIMARY KEY,
    lamp_id INT,
    target_lamp_id INT,
    FOREIGN KEY (lamp_id) REFERENCES lamps(id),
    FOREIGN KEY (target_lamp_id) REFERENCES lamps(id),
    UNIQUE(lamp_id)
);

-- Таблица для сообщений о сигнале между лампами с полем для направления сигнала
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    lamp_connection_id INT,
    is_read BOOLEAN,
    message_content TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lamp_connection_id) REFERENCES lamp_connections(id)
);
