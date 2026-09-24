import type { IncomingMessage, ServerResponse } from "node:http";
import type { DatabaseSync as DBConfigType } from "node:sqlite";

import type { Message } from "../../../../../utils/db/sqlite/schema.js";

const { DatabaseSync } = require("node:sqlite");
const http = require("node:http");

const { schema } = require("../../../../../utils/db/sqlite/schema.ts");

const PORT = Number(process.env.PORT ?? 3000);

const db: DBConfigType = new DatabaseSync("sqlite.db");

try {
  db.exec(schema.createTable);
} catch (error) {
  console.error("Error executing SQLite CREATE TABLE command:", error);
  process.exit(1);
}

const server = http.createServer(
  (req: IncomingMessage, res: ServerResponse) => {
    let parsedURL: URL;
    try {
      parsedURL = new URL(req.url ?? "/", "http://localhost");
    } catch (error) {
      res.writeHead(400, { "Content-Type": "text/plain" });
      return res.end("Invalid request URL");
    }

    // GET /
    if (req.method === "GET" && parsedURL.pathname === "/") {
      try {
        const query = db.prepare(schema.queries.selectAllMessages);
        const messages = query.all() as Message[];

        if (messages.length === 0) {
          res.writeHead(200, { "Content-Type": "text/plain" });
          return res.end("No messages were found");
        }

        const usersList = messages.map((message) => ({
          id: message.id,
          name: message.username,
          email: message.email,
          message: message.message,
        }));

        console.log(`There are ${messages.length} message(s) in this database`);
        console.log(usersList);

        res.writeHead(200, { "Content-Type": "application/json" });
        return res.end(JSON.stringify(usersList));
      } catch (error) {
        console.error("Error executing SQLite SELECT query:", error);

        res.writeHead(500, { "Content-Type": "text/plain" });
        return res.end('Something went wrong');
      }
    }

    // POST /
    else if (req.method === "POST" && parsedURL.pathname === "/") {
      try {
        const query = db.prepare(schema.queries.insertMessage);

        const result = query.run({
          username: "Thiago Nogueira",
          email: "thiagond360@gmail.com",
          message: "This is a INSERT SQL statement!",
        });

        if (result.changes === 0) {
          throw new Error("No changes were made");
        }

        console.log(`${result.changes} message was successfully added!`);

        res.writeHead(201, { "Content-Type": "application/json" });
        return res.end(JSON.stringify({ success: true, result }));
      } catch (error) {
        console.error("Error executing SQLite INSERT query:", error);

        res.writeHead(500, { "Content-Type": "text/plain" });
        return res.end('Something went wrong');
      }
    }

    // DELETE /
    else if (req.method === "DELETE" && parsedURL.pathname === "/") {
      const id = parsedURL.searchParams.get("id");

      const userId = Number(id);

      if (!id || Number.isNaN(userId)) {
        res.writeHead(400, { "Content-Type": "text/plain" });
        return res.end("Missing or invalid ID");
      }

      try {
        const query = db.prepare(schema.queries.deleteMessage);

        const result = query.get({ id: userId });

        if (!result) {
          res.writeHead(404, { "Content-Type": "text/plain" });
          return res.end("User not found");
        }

        console.log(`The message with ID ${userId} was successfully deleted!`);

        res.writeHead(200, { "Content-Type": "application/json" });
        return res.end(
          JSON.stringify({
            success: true,
            deletedUser: result,
          }),
        );
      } catch (error) {
        console.error("Error executing SQLite DELETE query:", error);

        res.writeHead(500, { "Content-Type": "text/plain" });
        return res.end('Something went wrong');
      }
    }

    res.writeHead(404, { "Content-Type": "text/plain" });
    res.end("Route not found");
  },
);

server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});