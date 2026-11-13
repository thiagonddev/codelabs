import z from "zod";

import { userMessageValidationSchema } from "./user.message.validation";

export type UserMessageValidation = z.infer<typeof userMessageValidationSchema>;