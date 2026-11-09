const {
  initDatabase,
} = require("../../../../../../../../shared/database/boot.ts");

const {
  authSchema,
} = require("../../../../../../../../shared/auth/jwt/database/sqlite/native/schema.ts");

const createApp = require("./app.cts");

const {
  startServer,
} = require("../../../../../../../../shared/server/express/boot.ts");

const { db, schema } = initDatabase(authSchema);

const app = createApp(db, schema);

startServer(app);