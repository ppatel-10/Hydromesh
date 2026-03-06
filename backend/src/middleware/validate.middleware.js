const { body, param, query, validationResult } = require('express-validator');

// Run validation and return errors if any
const handleValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

// Sanitize string: trim + escape HTML entities
const sanitizeString = (value) => {
  if (typeof value !== 'string') return value;
  return value
    .trim()
    .replace(/[<>]/g, '') // Strip angle brackets (basic XSS prevention)
    .substring(0, 2000);  // Max length
};

// Report creation validators
const validateCreateReport = [
  body('latitude')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Latitude must be between -90 and 90'),
  body('longitude')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Longitude must be between -180 and 180'),
  body('waterLevel')
    .notEmpty()
    .withMessage('Water level is required')
    .isIn(['ankle', 'knee', 'waist', 'chest', 'above_head'])
    .withMessage('Water level must be: ankle, knee, waist, chest, or above_head'),
  body('description')
    .optional()
    .isString()
    .isLength({ max: 2000 })
    .customSanitizer(sanitizeString),
  body('photoUrl')
    .optional()
    .isURL()
    .withMessage('Photo URL must be a valid URL'),
  body('voiceUrl')
    .optional()
    .isURL()
    .withMessage('Voice URL must be a valid URL'),
  handleValidation,
];

// Nearby reports query validators
const validateNearbyQuery = [
  query('latitude')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Latitude must be between -90 and 90'),
  query('longitude')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Longitude must be between -180 and 180'),
  query('radius')
    .optional()
    .isFloat({ min: 0.1, max: 100 })
    .withMessage('Radius must be between 0.1 and 100 km'),
  handleValidation,
];

// Emergency creation validators
const validateCreateEmergency = [
  body('latitude')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Latitude must be between -90 and 90'),
  body('longitude')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Longitude must be between -180 and 180'),
  body('description')
    .optional()
    .isString()
    .isLength({ max: 2000 })
    .customSanitizer(sanitizeString),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high', 'critical'])
    .withMessage('Priority must be low, medium, high, or critical'),
  handleValidation,
];

// UUID param validator
const validateIdParam = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('ID must be a positive integer'),
  handleValidation,
];

module.exports = {
  validateCreateReport,
  validateNearbyQuery,
  validateCreateEmergency,
  validateIdParam,
  handleValidation,
};
