import type { IncomingMessage, ServerResponse } from 'node:http'

const http = require('node:http')

const { PORT, isInvalid } = require('../../../../utils/server/config.ts')

if (isInvalid) {
  throw new Error('Environment variable does not contain a valid port number')
}

const server = http.createServer((_req: IncomingMessage, res: ServerResponse) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' })
    res.end('Hello, World!\n')
})

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`)
})