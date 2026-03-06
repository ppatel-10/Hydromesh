const express = require('express');
const cors = require('cors');
const http = require('http');
const dotenv = require('dotenv');
const { initSocket } = require('./config/socket');
const { connectDB } = require('./config/database');

// Load environment variables
dotenv.config();

// Initialize Express
const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(express.json());

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
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
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