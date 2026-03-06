const { Pool } = require('pg');
require('dotenv').config();

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error('❌ DATABASE_URL is not set. Exiting.');
  process.exit(1);
}

// Robust parser: splits on the LAST @ so passwords containing @ work correctly
// regardless of whether the @ is raw or %40-encoded.
function parsePostgresUrl(raw) {
  const withoutProto = raw.replace(/^[^:]+:\/\//, '');
  const lastAt = withoutProto.lastIndexOf('@');
  const userInfo = withoutProto.slice(0, lastAt);
  const rest = withoutProto.slice(lastAt + 1);

  const colonIdx = userInfo.indexOf(':');
  const user = userInfo.slice(0, colonIdx);
  const password = decodeURIComponent(userInfo.slice(colonIdx + 1));

  const [hostPart, ...pathParts] = rest.split('/');
  const [host, portStr] = hostPart.split(':');
  const database = pathParts.join('/').split('?')[0];

  return { user, password, host, port: portStr ? parseInt(portStr, 10) : 5432, database };
}

const { user, password, host, port, database } = parsePostgresUrl(connectionString);
console.log(`🔗 Connecting to: ${host}:${port}/${database} as ${user}`);

const pool = new Pool({
  user,
  password,
  host,
  port,
  database,
  ssl: { rejectUnauthorized: false },
});

// Retry DB connection with exponential backoff — never crashes the server.
// Render won't restart-loop; the service stays alive and heals automatically.
const connectDB = async (attempt = 1) => {
  try {
    const client = await pool.connect();
    console.log('✅ Connected to Supabase PostgreSQL');
    client.release();
  } catch (error) {
    const delay = Math.min(attempt * 5000, 60000); // 5s, 10s, …, max 60s
    console.error(`❌ DB connection failed (attempt ${attempt}): ${error.message}`);
    console.error(`   Retrying in ${delay / 1000}s…`);
    setTimeout(() => connectDB(attempt + 1), delay);
  }
};

const query = (text, params) => pool.query(text, params);
module.exports = { connectDB, query, pool };
