const { initDatabase } = require("../../../../../../shared/database/boot.ts");

const {
  startServer,
} = require("../../../../../../shared/server/express/boot.ts");

const {
  DBUserMessageSchema,
} = require("../../../../../../shared/database/sqlite/user.message.schema.ts");

const createApp = require("./app.cts");

const { db, schema } = initDatabase(DBUserMessageSchema);

const app = createApp(db, schema);

startServer(app);