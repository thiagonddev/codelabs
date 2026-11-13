import z from "zod";

import { baseUserValidationSchema } from "./validation";

export type BaseDBSchema = {
  createTable: string;
};

export type BaseUserValidation = z.infer<typeof baseUserValidationSchema>;