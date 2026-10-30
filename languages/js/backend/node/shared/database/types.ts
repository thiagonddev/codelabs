import { z } from "zod";

export type Schema = {
  createTable: string;
  queries: {
    selectAllMessages: string;
    insertMessage: string;
    deleteMessage: string;
  };
};

export const UserSchema = z.object({
  username: z
    .string("Invalid username format")
    .trim()
    .min(3, "Username must be at least 3 characters long")
    .max(30, "Username must not exceed 30 characters long"),
  email: z.string().trim().pipe(z.email("E-mail must have the valid format")),
  message: z
    .string()
    .trim()
    .min(10, "Message must be at least 10 characters long")
    .max(2000, "Message must not exceed 2,000 characters long"),
});

export type User = z.infer<typeof UserSchema>;