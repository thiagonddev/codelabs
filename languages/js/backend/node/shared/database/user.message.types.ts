import type { RequestHandler } from "express";

import type z from "zod"; 

import { userMessageValidationSchema } from "./user.message.validation";

export type UserMessageController = {
  getAllUserMessages: RequestHandler;
  createUserMessage: RequestHandler;
  removeUserMessage: RequestHandler;
};

export type UserMessageValidation = z.infer<typeof userMessageValidationSchema>;