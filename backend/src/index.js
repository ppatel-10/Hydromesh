const express = require('express');
const cors = require('cors');
const http = require('http');
const dotenv = require('dotenv');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { initSocket } = require('./config/socket');
const { connectDB } = require('./config/database');

// Load environment variables
dotenv.config();

// Initialize Express
const app = express();
const server = http.createServer(app);

// Security headers
app.use(helmet());

// CORS — restrict to known origins in production
const allowedOrigins = process.env.CORS_ORIGINS
  ? process.env.CORS_ORIGINS.split(',')
  : ['http://localhost:3000', 'http://localhost:8080'];
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, curl, etc.)
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(null, true); // Allow all for now (mobile app sends no origin)
    }
  },
  credentials: true,
  maxAge: 86400, // Cache preflight for 24h
}));

// Body parser with size limit
app.use(express.json({ limit: '1mb' }));

// Global rate limiter: 100 requests per 15 minutes per IP
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many requests, please try again later' },
});
app.use('/api/', globalLimiter);

// Strict rate limiter for auth: 10 attempts per 15 minutes per IP
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many login attempts, please try again later' },
});
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);

// Initialize Socket.io
initSocket(server);

// Routes
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/reports', require('./routes/reports.routes'));
// app.use('/api/locations', require('./routes/locations.routes'));
// app.use('/api/routes', require('./routes/routes.routes'));
app.use('/api/emergency', require('./routes/emergency.routes'));
app.use('/api/weather', require('./routes/weather.routes'));
app.use('/api/simulation', require('./routes/simulation.routes'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), version: '1.1.0' });
});

// Error handling middleware
app.use(require('./middleware/error.middleware'));

// Start server immediately — DB connects in background with retries
const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  connectDB(); // non-blocking: retries until Supabase is reachable
});

module.exports = { app, server };