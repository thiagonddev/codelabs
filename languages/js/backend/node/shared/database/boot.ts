import type { DatabaseSync as DBConfigType } from "node:sqlite";

import { DatabaseSync } from "node:sqlite";

export function initDatabase(schema: any) {
  let db: DBConfigType | null = null

  try {
    db = new DatabaseSync("sqlite.db");
    db.exec(schema.createTable);
  } catch (error) {
    console.error("Error executing SQLite CREATE TABLE command:", error);

    return { success: false, db, error };
  }

  return { success: true, db, schema, error: null };
}