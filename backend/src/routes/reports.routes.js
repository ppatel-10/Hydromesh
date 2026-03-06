const express = require('express');
const router = express.Router();
const reportsController = require('../controllers/reports.controller');
const authMiddleware = require('../middleware/auth.middleware');
const { validateCreateReport, validateNearbyQuery, validateIdParam } = require('../middleware/validate.middleware');

// Get all reports
router.get('/', reportsController.getAllReports);

// Get nearby reports
router.get('/nearby', validateNearbyQuery, reportsController.getNearbyReports);

// Get single report
router.get('/:id', validateIdParam, reportsController.getReportById);

// Create report (protected + validated)
router.post('/', authMiddleware, validateCreateReport, reportsController.createReport);

module.exports = router;