import z from "zod";

import { baseUserValidationSchema } from "../database/validation";

export const authRegisterUserValidationSchema = baseUserValidationSchema.extend(
  {
    password: z
      .string()
      .min(16, "Password must be at least 16 characters long")
      .max(72, "Password must not exceed 72 characters long"),
  },
);

export const authLoginUserValidationSchema =
  authRegisterUserValidationSchema.omit({ email: true });

export const authUserPayloadValidationSchema = authRegisterUserValidationSchema
  .extend({
    id: z.int().positive(),
  })
  .omit({
    email: true,
  });