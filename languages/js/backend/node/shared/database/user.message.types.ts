import type { DatabaseSync } from "node:sqlite";
import type { RequestHandler } from "express";

import type z from "zod";

import { userMessageValidationSchema } from "./user.message.validation";

type StatementMethod<T extends "all" | "get" | "run"> = ReturnType<
  ReturnType<DatabaseSync["prepare"]>[T]
>;

export type UserMessageRepository = {
  findAll(): StatementMethod<"all">
  create(valid: {
    data: UserMessageValidation;
  }): StatementMethod<"run">;
  deleteById(
    userId: number,
  ): StatementMethod<"get">;
};

export type UserMessageController = {
  indexUserMessages: RequestHandler;
  storeUserMessage: RequestHandler;
  deleteUserMessage: RequestHandler;
};

export type UserMessageValidation = z.infer<typeof userMessageValidationSchema>;