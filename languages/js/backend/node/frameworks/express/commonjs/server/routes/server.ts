const app = require('./app.ts')

const { PORT, isInvalid } = require("../../../../../shared/server/config.ts");

if (isInvalid) {
  throw new Error("Environment variable does not contain a valid port number");
}

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

export {}