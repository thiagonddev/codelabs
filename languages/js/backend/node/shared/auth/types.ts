import type { BaseDBSchema } from "../database/types";

import z from "zod";

import {
  authRegisterUserValidationSchema,
  authLoginUserValidationSchema,
  authUserPayloadValidationSchema,
} from "./validation";

export type AuthSchema = BaseDBSchema & {
  queries: {
    userRegisterMatch: string;
    insertUser: string;
    userLoginMatch: string;
    userPayload: string;
  };
};

export type User = {
  id: number;
  username: string;
  email: string;
  password: string;
};

export type AuthRegisterUserValidation = z.infer<
  typeof authRegisterUserValidationSchema
>;

export type AuthLoginUserValidation = z.infer<
  typeof authLoginUserValidationSchema
>;

export type AuthUserPayload = z.infer<typeof authUserPayloadValidationSchema>