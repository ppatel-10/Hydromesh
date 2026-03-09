const axios = require('axios');

const WEATHER_API = 'https://api.open-meteo.com/v1';

const weatherController = {
  async getCurrentWeather(req, res) {
    try {
      const { latitude, longitude } = req.query;
      if (!latitude || !longitude) {
        return res.status(400).json({ message: 'Latitude and longitude required' });
      }
      const response = await axios.get(`${WEATHER_API}/forecast`, {
        params: { latitude, longitude, current_weather: true, hourly: 'precipitation,rain' },
        timeout: 10000,
      });
      res.json(response.data);
    } catch (error) {
      console.error('Weather API error:', error.code || error.message);
      res.status(502).json({
        message: 'Weather service temporarily unavailable',
        current_weather: { temperature: null, windspeed: null, weathercode: 0 },
      });
    }
  },

  async getForecast(req, res) {
    try {
      const { latitude, longitude } = req.query;
      if (!latitude || !longitude) {
        return res.status(400).json({ message: 'Latitude and longitude required' });
      }
      const response = await axios.get(`${WEATHER_API}/forecast`, {
        params: { latitude, longitude, daily: 'precipitation_sum,rain_sum,precipitation_probability_max', timezone: 'auto' },
        timeout: 10000,
      });
      res.json(response.data);
    } catch (error) {
      console.error('Forecast API error:', error.code || error.message);
      res.status(502).json({ message: 'Forecast service temporarily unavailable' });
    }
  }
};

module.exports = weatherController;