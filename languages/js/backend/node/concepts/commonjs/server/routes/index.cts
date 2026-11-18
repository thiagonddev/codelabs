import type { IncomingMessage, ServerResponse } from "node:http";

const http = require("node:http");

const { StatusCodes } = require("../../../../shared/types.ts");
const { VALID_PORT } = require("../../../../shared/server/port.ts");

const server = http.createServer((req: IncomingMessage, res: ServerResponse) => {
  const host = req.headers.host ?? `localhost:${VALID_PORT}`;
  const url = new URL(req.url ?? "/", `http://${host}`);

  const { OK, NOT_FOUND_ERROR } = StatusCodes

  if (req.method === "GET" && url.pathname === "/") {
    res.writeHead(OK, {
      "Content-Type": "text/plain"
    });
    
    return res.end("Welcome! My name is Thiago.");
  }

  if (req.method === "GET" && url.pathname === "/about") {
    res.writeHead(OK, {
      "Content-Type": "text/plain"
    });
    
    return res.end(
      "I'm a software engineer with a passion for building scalable and efficient applications. I enjoy working with modern technologies and continuously learning new skills."
    );
  }

  if (req.method === "GET" && url.pathname === "/contact") {
    res.writeHead(OK, {
      "Content-Type": "text/plain"
    });

    return res.end("You can reach me at thiagond360@gmail.com");
  }

  res.writeHead(NOT_FOUND_ERROR, {
    "Content-Type": "text/plain"
  });

  res.end("Page not found");
});

server.listen(VALID_PORT, () => {
  console.log(`Server is running on port ${VALID_PORT}`);
});