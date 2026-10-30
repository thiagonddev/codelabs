import type { DatabaseSync as DBConfigType } from "node:sqlite";
import type {
  Schema,
  User
} from "../../../../../../../../../backend/node/shared/database/types";

const { DatabaseSync } = require("node:sqlite");
const request = require("supertest");

const createApp = require("../../../../../../../../../backend/node/frameworks/express/commonjs/database/sqlite/native/app.ts");

const schema =
  require("../../../../../../../../../backend/node/shared/database/sqlite/schema.ts") as Schema;

const userMock: User = {
  username: "Thiago Nogueira",
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
    jest.restoreAllMocks();
    db.close();
  });

  describe("GET /", () => {
    it("should return a message when the database is empty", async () => {
      const response = await request(app).get("/");

      expect(response.status).toBe(200);
      expect(response.text).toBe("No messages were found");
    });

    it("should return all messages as JSON", async () => {
      db.prepare(schema.queries.insertMessage).run(userMock);

      const response = await request(app).get("/");

      expect(response.status).toBe(200);
      expect(response.body).toEqual([{ id: 1, ...userMock }]);
    });

    it("should return 500 when the SELECT * query fails", async () => {
      const errorSpy = jest
        .spyOn(console, "error")
        .mockImplementation(() => {});

      jest.spyOn(db, "prepare").mockImplementationOnce(() => {
        throw new Error("Database error");
      });

      const response = await request(app).get("/");

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");
      
      expect(errorSpy).toHaveBeenCalledWith(
        "Error executing SQLite SELECT * query:",
        expect.any(Error),
      );
    });
  });

  describe("POST /", () => {
    it("should insert a message successfully", async () => {
      const response = await request(app).post("/");

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);

      const messages = db
        .prepare(schema.queries.selectAllMessages)
        .all() as User[];

      expect(messages).toHaveLength(1);
      expect(messages[0].username).toBe("Thiago Nogueira");
    });

    it("should return 500 when preparing the INSERT query fails", async () => {
      const errorSpy = jest
        .spyOn(console, "error")
        .mockImplementation(() => {});

      jest.spyOn(db, "prepare").mockImplementationOnce(() => {
        throw new Error("Database error");
      });

      const response = await request(app).post("/");

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");
      
      expect(errorSpy).toHaveBeenCalledWith(
        "Error executing SQLite INSERT query:",
        expect.any(Error),
      );
    });

    it("should return 500 when the INSERT makes no changes", async () => {
      const errorSpy = jest
        .spyOn(console, "error")
        .mockImplementation(() => {});

      const runMock = jest.fn().mockReturnValue({
        changes: 0,
      });

      jest.spyOn(db, "prepare").mockReturnValue({
        run: runMock,
      } as never);

      const response = await request(app).post("/");

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");
      
      expect(runMock).toHaveBeenCalledWith(userMock);
      expect(errorSpy).toHaveBeenCalledWith(
        "Error executing SQLite INSERT query:",
        expect.any(Error),
      );
    });
  });

  describe("DELETE /:id", () => {
    beforeEach(() => {
      db.prepare(schema.queries.insertMessage).run(userMock);
    });

    it("should delete the message successfully", async () => {
      const response = await request(app).delete("/1");

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.deletedUser).toEqual({ id: 1, ...userMock });

      const messages = db.prepare(schema.queries.selectAllMessages).all();

      expect(messages).toHaveLength(0);
    });

    it.each([
      ["nonnumeric ID", "abc"],
      ["zero ID", "0"],
      ["negative ID", "-1"],
      ["decimal ID", "1.5"],
    ])("should reject a %s", async (_description, id) => {
      const response = await request(app).delete(`/${id}`);

      expect(response.status).toBe(400);
      expect(response.text).toBe("Missing or invalid ID");
    });

    it("should return 404 when the message does not exist", async () => {
      const response = await request(app).delete("/999");

      expect(response.status).toBe(404);
      expect(response.text).toBe("User not found");
    });

    it("should return 500 when preparing the DELETE query fails", async () => {
      const errorSpy = jest
        .spyOn(console, "error")
        .mockImplementation(() => {});

      jest.spyOn(db, "prepare").mockImplementationOnce(() => {
        throw new Error("Database error");
      });

      const response = await request(app).delete("/1");

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");
      
      expect(errorSpy).toHaveBeenCalledWith(
        "Error executing SQLite DELETE query:",
        expect.any(Error),
      );
    });
  });
});

export {};