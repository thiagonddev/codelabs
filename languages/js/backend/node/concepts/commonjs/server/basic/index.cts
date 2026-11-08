import type { IncomingMessage, ServerResponse } from 'node:http'

const http = require('node:http')

const { VALID_PORT } = require("../../../../shared/server/port.ts");

const server = http.createServer((_req: IncomingMessage, res: ServerResponse) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' })
    res.end('Hello, World!\n')
})

server.listen(VALID_PORT, () => {
  console.log(`Server is running on port ${VALID_PORT}`)
})