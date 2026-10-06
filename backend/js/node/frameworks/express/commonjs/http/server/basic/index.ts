import type { Application } from "express";

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const {
  PORT,
  isInvalid,
} = require("../../../../../../shared/server/config.ts");

if (isInvalid) {
  throw new Error("Environment variable does not contain a valid port number");
}

const app: Application = express();

app.use(cors());
app.use(helmet());

app.all("/{*splat}", (_req, res) => {
  res.send("Hello, World!\n");
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});