const axios = require('axios');

// Always use the known-good open-meteo URL
const WEATHER_API = 'https://api.open-meteo.com/v1';

const weatherController = {
  // Get current weather
  async getCurrentWeather(req, res, next) {
    try {
      const { latitude, longitude } = req.query;

      if (!latitude || !longitude) {
        return res.status(400).json({ message: 'Latitude and longitude required' });
      }

      const response = await axios.get(`${WEATHER_API}/forecast`, {
        params: {
          latitude,
          longitude,
          current_weather: true,
          hourly: 'precipitation,rain'
        }
      });

      res.json(response.data);
    } catch (error) {
      next(error);
    }
  },

  // Get forecast
  async getForecast(req, res, next) {
    try {
      const { latitude, longitude } = req.query;

      if (!latitude || !longitude) {
        return res.status(400).json({ message: 'Latitude and longitude required' });
      }

      const response = await axios.get(`${WEATHER_API}/forecast`, {
        params: {
          latitude,
          longitude,
          daily: 'precipitation_sum,rain_sum,precipitation_probability_max',
          timezone: 'auto'
        }
      });

      res.json(response.data);
    } catch (error) {
      next(error);
    }
  }
};

module.exports = weatherController;