const request = require("supertest") as typeof import('supertest');

const app = require("../../../../../../../../backend/node/frameworks/express/commonjs/server/basic/app.ts");

describe("Express app", () => {
  const expectedBody = "Hello, World!\n";

  const methods = [
    "get",
    "post",
    "put",
    "patch",
    "delete",
    "options",
    "head",
  ] as const;

  it.each(methods)("should handle %s requests", async (method) => {
    const response = await request(app)[method]("/test");

    expect(response.status).toBe(200);

    if (method === "head") {
      expect(response.text).toBeUndefined();
    } else {
      expect(response.text).toBe(expectedBody);
    }
  });

  it("should include Helmet security headers", async () => {
    const response = await request(app).get("/");

    expect(response.headers["x-content-type-options"]).toBe("nosniff");
    expect(response.headers["x-frame-options"]).toBeDefined();
  });

  it("should include the CORS header", async () => {
    const response = await request(app).get("/");

    expect(response.headers["access-control-allow-origin"]).toBe("*");
  });
});

export {}