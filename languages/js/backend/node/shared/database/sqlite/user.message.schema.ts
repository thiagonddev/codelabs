import type { UserMessageSchema as UserMessage } from "./user.message.types";

import { baseDBUserSchema } from "./schema";

const selectAllUserMessagesQuery = `
    SELECT * FROM messages;
`;

const insertUserMessageQuery = `
    INSERT INTO messages (username, email, message)
    VALUES (:username, :email, :message);
`;

const deleteUserMessageQuery = `
    DELETE FROM messages
    WHERE (id = :id)
    RETURNING id, username, email, message
`;

export const DBUserMessageSchema: UserMessage = {
  ...baseDBUserSchema,
  queries: {
    selectAllUserMessages: selectAllUserMessagesQuery,
    insertUserMessage: insertUserMessageQuery,
    deleteUserMessage: deleteUserMessageQuery,
  },
};