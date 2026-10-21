const request = require("supertest");

const app = require("../../../../../../../../backend/node/frameworks/express/commonjs/server/routes/app.ts");

describe("Express app", () => {
  describe("GET /", () => {
    it("should return a welcome message", async () => {
      const response = await request(app).get("/");

      expect(response.status).toBe(200);
      expect(response.text).toBe("Welcome! My name is Thiago.");
    });
  });

  describe("GET /about", () => {
    it("should return information about the developer", async () => {
      const response = await request(app).get("/about");

      expect(response.status).toBe(200);
      expect(response.text).toContain(
        "I'm a software engineer with a passion for building scalable and efficient applications. I enjoy working with modern technologies and continuously learning new skills.",
      );
    });

    describe("GET /contact", () => {
      it("should return the contact email", async () => {
        const response = await request(app).get("/contact");

        expect(response.status).toBe(200);
        expect(response.text).toBe("You can reach me at thiagond360@gmail.com");
      });
    });

    describe("GET unknown routes", () => {
      it("should return 404 for an unknown route", async () => {
        const response = await request(app).get("/unknown");

        expect(response.status).toBe(404);
      });
    });
  });
});