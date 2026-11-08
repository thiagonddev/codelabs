const app = require('./app.cts')

const { startServer } = require('../../../../../shared/server/express/boot.ts')

startServer(app)