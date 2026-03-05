const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function checkUser() {
  const result = await pool.query('SELECT * FROM users WHERE email = $1', ['citizen@test.com']);
  console.log(result.rows);
  process.exit(0);
}
checkUser();
