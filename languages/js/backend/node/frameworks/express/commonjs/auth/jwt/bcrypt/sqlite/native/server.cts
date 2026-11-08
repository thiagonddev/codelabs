const createApp = require('./index.cts')

const {
  startServer,
} = require("../../../../../../../../shared/server/express/boot.ts");

const app = createApp()

startServer(app)