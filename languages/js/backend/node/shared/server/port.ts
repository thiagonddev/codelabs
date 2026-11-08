const PORT = Number(process.env.PORT);

export const VALID_PORT = (!Number.isInteger(PORT) || PORT < 1 || PORT > 65535) ? 3000 : PORT;