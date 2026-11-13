export type BaseDBUserSchema = {
    createTable: string
}

const createTableQuery = `
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        message TEXT NOT NULL
    );
`;

export const baseDBUserSchema: BaseDBUserSchema = {
  createTable: createTableQuery,
};