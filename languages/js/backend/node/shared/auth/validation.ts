import type { ZodObject } from "zod";

import type {
  AuthLoginUserValidation,
  AuthRegisterUserValidation,
} from "./types";

export function validateUserData(
  validationSchema: ZodObject,
  userData: AuthRegisterUserValidation | AuthLoginUserValidation,
) {
  const result = validationSchema.safeParse(userData);

  if (!result.success) {
    const errors = result.error.issues.map((issue) => issue.message)
    
    return {
      data: null,
      errors
    };
  }

  return {
    data: result.data,
    errors: null,
  };
}