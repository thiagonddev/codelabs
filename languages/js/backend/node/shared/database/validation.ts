import z from 'zod'

export const baseUserValidationSchema = z.strictObject({
  username: z
    .string("Invalid username format")
    .trim()
    .min(3, "Username must be at least 3 characters long")
    .max(30, "Username must not exceed 30 characters long"),
  email: z.string().trim().pipe(z.email("E-mail must have the valid format"))
});