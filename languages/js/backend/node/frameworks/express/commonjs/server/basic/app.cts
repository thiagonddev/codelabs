import type { Application } from "express";

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const app: Application = express();

app.use(cors({ preflightContinue: true }));
app.use(helmet());

app.all("/{*splat}", (_req, res) => {
  res.send("Hello, World!\n");
});

module.exports = app