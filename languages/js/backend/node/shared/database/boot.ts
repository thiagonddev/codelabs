import { DatabaseSync } from "node:sqlite";

export function initDatabase(schema: any) {
  const db = new DatabaseSync("sqlite.db");

  try {
    db.exec(schema.createTable);
  } catch (error) {
    console.error("Error executing SQLite CREATE TABLE command:", error);
    process.exit(1);
  }

  return { db, schema };
}