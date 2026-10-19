-- Runs once, on first start of an empty pgdata volume.
-- One database per task: no task reads another task's tables.
CREATE DATABASE kb;
CREATE DATABASE inbox;
CREATE DATABASE scope;

\c kb
CREATE EXTENSION IF NOT EXISTS vector;
