const express = require('express');
const router = express.Router();
const emergencyController = require('../controllers/emergency.controller');
const authMiddleware = require('../middleware/auth.middleware');
const { validateCreateEmergency, validateIdParam } = require('../middleware/validate.middleware');

// Create emergency request (protected + validated)
router.post('/', authMiddleware, validateCreateEmergency, emergencyController.createRequest);

// Get pending requests (for responders)
router.get('/pending', authMiddleware, emergencyController.getPendingRequests);

// Accept request
router.post('/:id/accept', authMiddleware, validateIdParam, emergencyController.acceptRequest);

// Resolve request
router.post('/:id/resolve', authMiddleware, validateIdParam, emergencyController.resolveRequest);

module.exports = router;