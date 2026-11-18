import type { BaseDBSchema } from "../database/types";

import z from "zod";

import {
  authRegisterUserValidationSchema,
  authLoginUserValidationSchema,
  authUserPayloadValidationSchema,
} from "./validation.schema";

export type AuthUserSchema = BaseDBSchema & {
  queries: {
    userRegisterMatch: string;
    userInsert: string;
    userLoginMatch: string;
    userPayload: string;
  };
};

export type AuthRegisterUserValidation = z.infer<
  typeof authRegisterUserValidationSchema
>;

export type AuthLoginUserValidation = z.infer<
  typeof authLoginUserValidationSchema
>;

export type AuthUserPayloadValidation = z.infer<typeof authUserPayloadValidationSchema>