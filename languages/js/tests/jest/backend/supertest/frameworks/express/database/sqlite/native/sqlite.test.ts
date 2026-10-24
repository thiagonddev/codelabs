import type { DatabaseSync as DBConfigType } from "node:sqlite";
import type {
  Schema,
  Message,
} from "../../../../../../../../../backend/node/shared/database/types";

const { DatabaseSync } = require("node:sqlite");
const request = require("supertest");

const createApp = require("../../../../../../../../../backend/node/frameworks/express/commonjs/database/sqlite/native/app.ts");

const schema =
  require("../../../../../../../../../backend/node/shared/database/sqlite/schema.ts") as Schema;

const userMock = {
  id: 1,
  name: "Thiago Nogueira",
  email: "thiagond360@gmail.com",
  message: "This is a INSERT SQL statement!",
};

describe("Express app", () => {
  let db: DBConfigType;
  let app: ReturnType<typeof createApp>;

  beforeEach(() => {
    db = new DatabaseSync(":memory:");

    db.exec(schema.createTable);

    app = createApp(db);
  });

  afterEach(() => {
    db.close();
  });

  describe("GET /", () => {
    it("should return a message when the database is empty", async () => {
      const response = await request(app).get("/");

      expect(response.status).toBe(200);
      expect(response.text).toBe("No messages were found");
    });

    it("should return all messages as JSON", async () => {
      db.prepare(schema.queries.insertMessage).run({
        username: "Thiago Nogueira",
        email: "thiagond360@gmail.com",
        message: "This is a INSERT SQL statement!",
      });

      const response = await request(app).get("/");

      expect(response.status).toBe(200);
      expect(response.body).toEqual([userMock]);
    });
  });

  describe("POST /", () => {
    it("should insert a message successfully", async () => {
      const response = await request(app).post("/");

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);

      const messages = db
        .prepare(schema.queries.selectAllMessages)
        .all() as Message[];

      expect(messages).toHaveLength(1);
      expect(messages[0].username).toBe("Thiago Nogueira");
    });
  });

  describe("DELETE /:id", () => {
    it("should delete the last message", async () => {
      db.prepare(schema.queries.insertMessage).run({
        username: "Thiago Nogueira",
        email: "thiagond360@gmail.com",
        message: "This is a DELETE SQL statement!",
      });

      const response = await request(app).delete("/1");

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.deletedUser).toEqual({
        id: 1,
        username: "Thiago Nogueira",
        email: "thiagond360@gmail.com",
        message: "This is a DELETE SQL statement!",
      });

      const messagesList = db.prepare(schema.queries.selectAllMessages).all();

      expect(messagesList).toHaveLength(0);
    });
  });
});

export {};