const { initDatabase } = require("../../../../../../shared/database/boot.ts");

const {
  startServer,
} = require("../../../../../../shared/server/express/boot.ts");

const {
  messageSchema,
} = require("../../../../../../shared/database/sqlite/schema.ts");

const createApp = require("./app.cts");

const { db, schema } = initDatabase(messageSchema);

const app = createApp(db, schema);

startServer(app);