import z from "zod";

import { baseUserValidationSchema } from "./validation";

export const userMessageValidationSchema = baseUserValidationSchema.extend({
  message: z
    .string()
    .trim()
    .min(10, "Message must be at least 10 characters long")
    .max(2000, "Message must not exceed 2,000 characters long"),
});