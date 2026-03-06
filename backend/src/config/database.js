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

const connectDB = async () => {
  try {
    const client = await pool.connect();
    console.log('✅ Connected to Supabase PostgreSQL');
    client.release();
  } catch (error) {
    console.error('❌ Database connection error:', error.message);
    console.error('   Hostname attempted:', error.hostname ?? '(unknown)');
    process.exit(1);
  }
};

const query = (text, params) => pool.query(text, params);
module.exports = { connectDB, query, pool };
