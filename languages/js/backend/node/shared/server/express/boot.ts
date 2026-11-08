import type { Application } from 'express'

import { VALID_PORT } from '../port'

export function startServer(app: Application) {
    app.listen(VALID_PORT, () =>
      console.log(`Server is running on port ${VALID_PORT}`),
    );
}