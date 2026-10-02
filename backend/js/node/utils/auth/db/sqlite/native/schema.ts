import type { Schema } from "../../../types";

const createTableQuery = `
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL,
        password TEXT NOT NULL
    );
`;

const userRegisterMatchQuery = `
    SELECT id
    FROM users
    WHERE (username = :username) OR (email = :email)
`;

const insertUserQuery = `
    INSERT INTO users (username, email, password)
    VALUES (:username, :email, :password)
`;

const userLoginMatchQuery = `
    SELECT *
    FROM users
    WHERE (username = :username)
`;

const userPayloadQuery = `
    SELECT username, email
    FROM users
    WHERE id = :id
`;

const schema = {
  createTable: createTableQuery,
  queries: {
    userRegisterMatch: userRegisterMatchQuery,
    insertUser: insertUserQuery,
    userLoginMatch: userLoginMatchQuery,
    userPayload: userPayloadQuery,
  },
} satisfies Schema;

module.exports = { schema };
