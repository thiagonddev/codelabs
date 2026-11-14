const { initDatabase } = require("../../../../../../shared/database/boot.ts");

const {
  startServer,
} = require("../../../../../../shared/server/express/boot.ts");

const {
  DBUserMessageSchema,
} = require("../../../../../../shared/database/sqlite/user.message.schema.ts");

const createApp = require("./app.cts");

const bootDB = initDatabase(DBUserMessageSchema);

if (!bootDB.success) {
  bootDB.db?.close()
  throw new Error("Database couldn't be initialized", { cause: bootDB.error })
}

const { db, schema } = bootDB

const app = createApp(db, schema);

startServer(app);