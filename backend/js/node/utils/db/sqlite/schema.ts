export type Schema = {
    createTable: string
    queries: {
        selectAllMessages: string
        insertMessage: string,
        deleteMessage: string
    }
}

export type Message = {
    id: number,
    username: string,
    email: string,
    message: string
}

const createTableQuery = `
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        message TEXT NOT NULL
    );
`

const selectAllMessagesQuery = `
    SELECT * FROM messages;
`

const insertMessageQuery = `
    INSERT INTO messages (username, email, message)
    VALUES (:username, :email, :message);
`

const deleteMessageQuery = `
    DELETE FROM messages
    WHERE (id = :id)
    RETURNING id, username, email, message
`

const schema = {
    createTable: createTableQuery,
    queries: {
        selectAllMessages: selectAllMessagesQuery,
        insertMessage: insertMessageQuery,
        deleteMessage: deleteMessageQuery
    }
} satisfies Schema

module.exports = { schema }