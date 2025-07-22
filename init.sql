-- Initial database setup for Monolift
-- This file is executed when the PostgreSQL container starts for the first time

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create development database if it doesn't exist
-- (The main database is already created via POSTGRES_DB env var)

-- You can add initial seed data here if needed