-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Users table
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'citizen' CHECK (role IN ('citizen', 'responder', 'coordinator', 'official')),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

-- User locations (for tracking responders)
CREATE TABLE user_locations (
    location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Flood reports
CREATE TABLE flood_reports (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    water_level VARCHAR(20) CHECK (water_level IN ('ankle', 'knee', 'waist', 'chest', 'above_head')),
    description TEXT,
    photo_url VARCHAR(500),
    voice_url VARCHAR(500),
    is_validated BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Emergency requests
CREATE TABLE emergency_requests (
    request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    citizen_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    responder_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    description TEXT,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'assigned', 'in_progress', 'resolved', 'cancelled')),
    created_at TIMESTAMP DEFAULT NOW(),
    assigned_at TIMESTAMP,
    resolved_at TIMESTAMP
);

-- Routes (cached safe routes)
CREATE TABLE routes (
    route_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    start_latitude DECIMAL(10, 8) NOT NULL,
    start_longitude DECIMAL(11, 8) NOT NULL,
    end_latitude DECIMAL(10, 8) NOT NULL,
    end_longitude DECIMAL(11, 8) NOT NULL,
    waypoints JSONB,
    distance_km DECIMAL(10, 2),
    duration_min INTEGER,
    is_safe BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Spatial indexes for performance
CREATE INDEX idx_flood_reports_location ON flood_reports USING GIST (
    (ST_MakePoint(longitude, latitude)::geography)
);

CREATE INDEX idx_emergency_requests_location ON emergency_requests USING GIST (
    (ST_MakePoint(longitude, latitude)::geography)
);

CREATE INDEX idx_user_locations_location ON user_locations USING GIST (
    (ST_MakePoint(longitude, latitude)::geography)
);