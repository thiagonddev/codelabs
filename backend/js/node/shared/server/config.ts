const PORT = Number(process.env.PORT ?? 3000);

const isInvalid = !Number.isInteger(PORT) || PORT < 1 || PORT > 65535;

module.exports = { PORT, isInvalid }