const {
  initDatabase,
} = require("../../../../../../../../shared/database/boot.ts");

const {
  authSchema,
} = require("../../../../../../../../shared/auth/database/sqlite/native/schema.ts");

const createApp = require("./app.cts");

const {
  startServer,
} = require("../../../../../../../../shared/server/express/boot.ts");

const bootDB = initDatabase(authSchema);

if (!bootDB.success) {
  bootDB.db?.close()
  throw new Error("Database couldn't be initialized", { cause: bootDB.error });
}

const { db, schema } = bootDB

const app = createApp(db, schema);

startServer(app);