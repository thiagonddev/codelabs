const { DatabaseSync } = require("node:sqlite");

const { startServer } = require("../../../../../../shared/server/express/boot.ts");

const { schema } =
  require("../../../../../../shared/database/sqlite/schema.ts");

const createApp = require("./app.cts");

const db = new DatabaseSync("sqlite.db");

try {
  db.exec(schema.createTable);
} catch (error) {
  console.error("Error executing SQLite CREATE TABLE command:", error);
  process.exit(1);
}

const app = createApp(db, schema);

startServer(app)