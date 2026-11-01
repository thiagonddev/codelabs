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

const userMocks: User[] = [
  {
    username: "Thiago Nogueira",
    email: "thiagond360@gmail.com",
    message: "This is an INSERT SQL statement!",
  },
  {
    username: "John Doe",
    email: "johndoe@gmail.com",
    message: "It worked twice in a row!",
  },
];

describe("Express SQLite app", () => {
  let db: DBConfigType;
  let app: ReturnType<typeof createApp>;

  const insertUser = (user: User) => {
    return db.prepare(schema.queries.insertMessage).run(user);
  };

  const insertUsers = (users: User[] = userMocks) => {
    return users.map(insertUser);
  };

  const getMessages = () => {
    return db.prepare(schema.queries.selectAllMessages).all();
  };

  beforeEach(() => {
    jest.spyOn(console, "log").mockImplementation(() => {});
    jest.spyOn(console, "error").mockImplementation(() => {});

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
      insertUser(userMocks[0]);

      const response = await request(app).get("/");

      expect(response.status).toBe(200);
      expect(response.body).toEqual([
        {
          id: 1,
          ...userMocks[0],
        },
      ]);
    });

    it("should return multiple messages in the correct order", async () => {
      insertUsers();

      const response = await request(app).get("/");

      expect(response.status).toBe(200);
      expect(response.body).toHaveLength(userMocks.length);

      expect(response.body).toEqual(
        userMocks.map((user, index) => ({
          id: index + 1,
          ...user,
        })),
      );
    });

    it("should return 500 when preparing the SELECT query fails", async () => {
      const errorSpy = jest.spyOn(console, "error");

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

    it("should not expose database errors to the client", async () => {
      jest.spyOn(db, "prepare").mockImplementationOnce(() => {
        throw new Error("Sensitive database information");
      });

      const response = await request(app).get("/");

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");

      expect(response.text).not.toContain("Sensitive database information");
    });
  });

  describe("POST /", () => {
    it("should insert a message successfully", async () => {
      const response = await request(app).post("/").send(userMocks[0]);

      expect(response.status).toBe(201);
      expect(response.body).toMatchObject({
        success: true,
        result: {
          changes: 1,
        },
      });

      const messages = getMessages();

      expect(messages).toHaveLength(1);
      expect(messages[0]).toMatchObject(userMocks[0]);
    });

    it("should trim whitespace from user fields before inserting", async () => {
      const response = await request(app).post("/").send({
        username: "  Thiago Nogueira  ",
        email: "  thiagond360@gmail.com  ",
        message: "  This is a valid message!  ",
      });

      expect(response.status).toBe(201);

      const messages = getMessages();

      expect(messages).toHaveLength(1);

      expect(messages[0]).toMatchObject({
        username: "Thiago Nogueira",
        email: "thiagond360@gmail.com",
        message: "This is a valid message!",
      });
    });

    it("should return 422 when the request body is empty", async () => {
      const response = await request(app).post("/").send({});

      expect(response.status).toBe(422);
      expect(response.body).toEqual(expect.any(Array));
      expect(response.body.length).toBeGreaterThan(0);
    });

    it.each([
      ["invalid username type", { ...userMocks[0], username: 123 }],
      [
        "username shorter than 3 characters",
        { ...userMocks[0], username: "TN" },
      ],
      [
        "username longer than 30 characters",
        { ...userMocks[0], username: "T".repeat(31) },
      ],
      ["empty username", { ...userMocks[0], username: "" }],
      ["invalid email type", { ...userMocks[0], email: 123 }],
      ["invalid email format", { ...userMocks[0], email: "invalid-email" }],
      ["empty email", { ...userMocks[0], email: "" }],
      ["invalid message type", { ...userMocks[0], message: null }],
      [
        "message shorter than 10 characters",
        { ...userMocks[0], message: "Too short" },
      ],
      [
        "message longer than 2000 characters",
        { ...userMocks[0], message: "T".repeat(2001) },
      ],
      ["empty message", { ...userMocks[0], message: "" }],
      [
        "missing username",
        {
          email: userMocks[0].email,
          message: userMocks[0].message,
        },
      ],
      [
        "missing email",
        {
          username: userMocks[0].username,
          message: userMocks[0].message,
        },
      ],
      [
        "missing message",
        {
          username: userMocks[0].username,
          email: userMocks[0].email,
        },
      ],
      ["unexpected ID field", { ...userMocks[0], id: 1 }],
      ["unexpected additional field", { ...userMocks[0], isAdmin: true }],
    ])(
      "should return 422 when the request has %s",
      async (_description, body) => {
        const response = await request(app).post("/").send(body);

        expect(response.status).toBe(422);
        expect(response.body).toEqual(expect.any(Array));
        expect(response.body.length).toBeGreaterThan(0);

        expect(getMessages()).toHaveLength(0);
      },
    );

    it("should return 500 when preparing the INSERT query fails", async () => {
      const errorSpy = jest.spyOn(console, "error");

      jest.spyOn(db, "prepare").mockImplementationOnce(() => {
        throw new Error("Database error");
      });

      const response = await request(app).post("/").send(userMocks[0]);

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");

      expect(errorSpy).toHaveBeenCalledWith(
        "Error executing SQLite INSERT query:",
        expect.any(Error),
      );
    });

    it("should return 500 when the INSERT query makes no changes", async () => {
      const errorSpy = jest.spyOn(console, "error");

      const runMock = jest.fn().mockReturnValue({
        changes: 0,
      });

      jest.spyOn(db, "prepare").mockReturnValue({
        run: runMock,
      } as never);

      const response = await request(app).post("/").send(userMocks[0]);

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");

      expect(runMock).toHaveBeenCalledWith(userMocks[0]);

      expect(errorSpy).toHaveBeenCalledWith(
        "Error executing SQLite INSERT query:",
        expect.any(Error),
      );
    });

    it("should not expose database errors to the client", async () => {
      jest.spyOn(db, "prepare").mockImplementationOnce(() => {
        throw new Error("Sensitive database information");
      });

      const response = await request(app).post("/").send(userMocks[0]);

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");

      expect(response.text).not.toContain("Sensitive database information");
    });
  });

  describe("DELETE /:id", () => {
    beforeEach(() => {
      insertUser(userMocks[0]);
    });

    it("should delete the message successfully", async () => {
      const response = await request(app).delete("/1");

      expect(response.status).toBe(200);

      expect(response.body).toEqual({
        success: true,
        deletedUser: {
          id: 1,
          ...userMocks[0],
        },
      });

      expect(getMessages()).toHaveLength(0);
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

      expect(getMessages()).toHaveLength(1);
    });

    it("should return 404 when the ID parameter is missing", async () => {
      const response = await request(app).delete("/");

      expect(response.status).toBe(404);
    });

    it("should return 404 when the message does not exist", async () => {
      const response = await request(app).delete("/999");

      expect(response.status).toBe(404);
      expect(response.text).toBe("User not found");
    });

    it("should preserve the database when the requested ID does not exist", async () => {
      await request(app).delete("/999");

      expect(getMessages()).toHaveLength(1);
    });

    it("should return 500 when preparing the DELETE query fails", async () => {
      const errorSpy = jest.spyOn(console, "error");

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

    it("should not expose database errors to the client", async () => {
      jest.spyOn(db, "prepare").mockImplementationOnce(() => {
        throw new Error("Sensitive database information");
      });

      const response = await request(app).delete("/1");

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");

      expect(response.text).not.toContain("Sensitive database information");

      expect(getMessages()).toHaveLength(1);
    });
  });
});

export {};