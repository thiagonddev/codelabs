import type { DatabaseSync as DBConfigType } from "node:sqlite";
import type { BaseUser } from "../../../../../../../../../backend/node/shared/database/types";

import { DatabaseSync } from "node:sqlite";
import request from "supertest";

import { messageSchema } from "../../../../../../../../../backend/node/shared/database/sqlite/schema";

import createApp from "../../../../../../../../../backend/node/frameworks/express/commonjs/database/sqlite/native/app.cjs";

const userMocks: BaseUser[] = [
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

  const insertUser = (user: BaseUser) =>
    db.prepare(messageSchema.queries.insertMessage).run(user);

  const insertUsers = (users: BaseUser[] = userMocks) => users.map(insertUser);

  const getMessages = () =>
    db.prepare(messageSchema.queries.selectAllMessages).all();

  beforeEach(() => {
    jest.spyOn(console, "log").mockImplementation(() => {});
    jest.spyOn(console, "error").mockImplementation(() => {});

    db = new DatabaseSync(":memory:");
    db.exec(messageSchema.createTable);

    app = createApp(db, messageSchema);
  });

  afterEach(() => {
    jest.restoreAllMocks();
    db.close();
  });

  describe("GET /", () => {
    it("should return a text message when no messages exist", async () => {
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

    it("should return multiple messages in database order", async () => {
      insertUsers();

      const response = await request(app).get("/");

      expect(response.status).toBe(200);
      expect(response.body).toEqual(
        userMocks.map((user, index) => ({
          id: index + 1,
          ...user,
        })),
      );
    });

    it("should log the number of messages and their contents", async () => {
      insertUsers();

      await request(app).get("/");

      expect(console.log).toHaveBeenCalledWith(
        `There are ${userMocks.length} message(s) in this database`,
      );

      expect(console.log).toHaveBeenCalledWith(
        expect.arrayContaining([
          expect.objectContaining(userMocks[0]),
          expect.objectContaining(userMocks[1]),
        ]),
      );
    });

    it("should return 500 when the SELECT query cannot be prepared", async () => {
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

    it("should return 500 when the SELECT query fails during execution", async () => {
      const errorSpy = jest.spyOn(console, "error");

      jest.spyOn(db, "prepare").mockReturnValue({
        all: jest.fn().mockImplementation(() => {
          throw new Error("Database execution error");
        }),
      } as never);

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
    it("should insert a valid message successfully", async () => {
      const response = await request(app).post("/").send(userMocks[0]);

      expect(response.status).toBe(201);
      expect(response.body).toMatchObject({
        success: true,
        result: {
          changes: 1,
        },
      });

      expect(getMessages()).toEqual([expect.objectContaining(userMocks[0])]);
    });

    it("should insert multiple messages successfully", async () => {
      for (const user of userMocks) {
        const response = await request(app).post("/").send(user);

        expect(response.status).toBe(201);
        expect(response.body.success).toBe(true);
      }

      expect(getMessages()).toHaveLength(userMocks.length);
    });

    it("should insert trimmed values returned by the validation schema", async () => {
      const user = {
        username: "  Thiago Nogueira  ",
        email: "  thiagond360@gmail.com  ",
        message: "  This is a valid message!  ",
      };

      const response = await request(app).post("/").send(user);

      expect(response.status).toBe(201);

      expect(getMessages()).toEqual([
        expect.objectContaining({
          username: "Thiago Nogueira",
          email: "thiagond360@gmail.com",
          message: "This is a valid message!",
        }),
      ]);
    });

    it("should return 400 when the request contains malformed JSON", async () => {
      const response = await request(app)
        .post("/")
        .set("Content-Type", "application/json")
        .send('{"username":');

      expect(response.status).toBe(400);
      expect(getMessages()).toHaveLength(0);
    });

    it("should return 422 when the request body is empty", async () => {
      const response = await request(app).post("/").send({});

      expect(response.status).toBe(422);
      expect(response.body).toEqual(expect.any(Array));
      expect(response.body.length).toBeGreaterThan(0);

      expect(getMessages()).toHaveLength(0);
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
    ])("should return 422 for %s", async (_description, body) => {
      const response = await request(app).post("/").send(body);

      expect(response.status).toBe(422);
      expect(response.body).toEqual(expect.any(Array));
      expect(response.body.length).toBeGreaterThan(0);

      expect(getMessages()).toHaveLength(0);
    });

    it("should return validation issues as an array of messages", async () => {
      const response = await request(app).post("/").send({});

      expect(response.status).toBe(422);

      for (const error of response.body) {
        expect(typeof error).toBe("string");
      }
    });

    it("should return 500 when the INSERT query cannot be prepared", async () => {
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

      expect(getMessages()).toHaveLength(0);
    });
  });

  describe("DELETE /:id", () => {
    beforeEach(() => {
      insertUser(userMocks[0]);
    });

    it("should delete an existing message successfully", async () => {
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

    it("should log the successful deletion", async () => {
      await request(app).delete("/1");

      expect(console.log).toHaveBeenCalledWith(
        "The message with ID 1 was successfully deleted!",
      );
    });

    it.each([
      ["nonnumeric ID", "abc"],
      ["zero ID", "0"],
      ["negative ID", "-1"],
      ["decimal ID", "1.5"],
      ["unsafe integer ID", "9007199254740992"],
    ])("should return 400 for a %s", async (_description, id) => {
      const response = await request(app).delete(`/${id}`);

      expect(response.status).toBe(400);
      expect(response.text).toBe("Missing or invalid ID");

      expect(getMessages()).toHaveLength(1);
    });

    it("should not execute the DELETE query for an invalid ID", async () => {
      const prepareSpy = jest.spyOn(db, "prepare");

      const response = await request(app).delete("/abc");

      expect(response.status).toBe(400);
      expect(prepareSpy).not.toHaveBeenCalled();
    });

    it("should return 404 when the message does not exist", async () => {
      const response = await request(app).delete("/999");

      expect(response.status).toBe(404);
      expect(response.text).toBe("User not found");

      expect(getMessages()).toHaveLength(1);
    });

    it("should return 404 when the ID parameter is missing", async () => {
      const response = await request(app).delete("/");

      expect(response.status).toBe(404);
      expect(getMessages()).toHaveLength(1);
    });

    it("should return 404 when the DELETE query returns no result", async () => {
      jest.spyOn(db, "prepare").mockReturnValue({
        get: jest.fn().mockReturnValue(undefined),
      } as never);

      const response = await request(app).delete("/1");

      expect(response.status).toBe(404);
      expect(response.text).toBe("User not found");
    });

    it("should return the deleted message in the response", async () => {
      const response = await request(app).delete("/1");

      expect(response.body.deletedUser).toEqual({
        id: 1,
        ...userMocks[0],
      });
    });

    it("should return 500 when the DELETE query cannot be prepared", async () => {
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

      expect(getMessages()).toHaveLength(1);
    });

    it("should return 500 when the DELETE query fails during execution", async () => {
      const errorSpy = jest.spyOn(console, "error");

      const getMock = jest.fn().mockImplementation(() => {
        throw new Error("Database error");
      });

      jest.spyOn(db, "prepare").mockReturnValue({
        get: getMock,
      } as never);

      const response = await request(app).delete("/1");

      expect(response.status).toBe(500);
      expect(response.text).toBe("Something went wrong");

      expect(getMock).toHaveBeenCalledWith({ id: 1 });

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