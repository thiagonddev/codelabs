import type { ZodObject } from "zod";

import type z from "zod";

function validateUserData(
  validationSchema: ZodObject,
  userData: any,
) {
  const isValid = validationSchema.safeParse(userData);

  if (!isValid.success) {
    console.log(isValid.error.issues);

    const errors = isValid.error.issues.map(
      (error: z.core.$ZodIssue) => error.message,
    );

    return { errors }
  }
  
  return isValid;
}

module.exports = validateUserData