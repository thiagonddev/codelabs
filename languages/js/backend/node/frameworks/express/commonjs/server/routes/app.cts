import type { Application } from "express";

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const app: Application = express();

app.use(cors());
app.use(helmet());

app.get("/", (_req, res) => {
  return res.send("Welcome! My name is Thiago.");
});

app.get("/about", (_req, res) => {
  return res.send(
    "I'm a software engineer with a passion for building scalable and efficient applications. I enjoy working with modern technologies and continuously learning new skills."
  );
});

app.get("/contact", (_req, res) => {
  return res.send("You can reach me at thiagond360@gmail.com");
});

module.exports = app