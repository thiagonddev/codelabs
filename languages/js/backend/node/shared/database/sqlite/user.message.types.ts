import type { BaseDBSchema } from "../types";

export type UserMessageSchema = BaseDBSchema & {
  queries: {
    selectAllUserMessages: string;
    insertUserMessage: string;
    deleteUserMessage: string;
  };
};