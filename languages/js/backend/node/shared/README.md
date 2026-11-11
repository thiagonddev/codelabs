# Shared Backend Resources

<br />

This directory contains types, schemas & helpers that can be reused by related Node.js backend experiments.

<br />

The modules are grouped by responsibility.

<br />

They are available for experiments that benefit from a common implementation, but reuse is not mandatory.

<br />

## Modules

### Authentication

Path: [`auth/`](auth/)

<br />

- `types.ts` defines the authentication schema & user-related types.

<br />

- `jwt/middleware.ts` contains Express middleware for checking Bearer tokens and attaching the authenticated user ID to the request.

<br />

- `jwt/validation.ts` contains JWT secret validation and retrieval.

<br />

- `auth/.env.example` shows the expected JWT environment-variable name.

<br />

The JWT examples use `jsonwebtoken`; the password-hashing experiment also uses `bcrypt`.

<br />

Their dependencies are declared in the corresponding package directories.

<br />

### Database

Path: [`database/`](database/)

<br />

- `types.ts` defines database-related types and a Zod schema used to validate message input.

<br />

- `sqlite/schema.ts` contains the SQLite table definition & prepared-statement queries for message records.

<br />

- `boot.ts` initializes a database using Node.js's built-in `node:sqlite` API.

<br />

- `supabase/db.ts` creates a Supabase client after reading `SUPABASE_URL` & `SUPABASE_KEY` from the environment.

<br />

- `supabase/config/.env.example` documents the Supabase environment-variable names.

<br />

The SQLite and Supabase integrations are separate examples.

A project should use the schema & data-access approach appropriate to its experiment.

<br />

### Server

Path: [`server/`](server/)

<br />

- `port.ts` reads & validates `PORT`, falling back to port `3000` when the value is invalid.

- `express/boot.ts` starts an Express application on the validated port.

- `server/.env.example` provides the default port variable.

<br />

## Environment configuration

<br />

The current examples use these environment-variable names:

<br />

| Variable | Used for | Example location |
| --- | --- | --- |
| `PORT` | Express server port | [`server/.env.example`](server/.env.example) |
| `JWT_SECRET` | JWT signing & verification | [`auth/.env.example`](auth/.env.example) |
| `SUPABASE_URL` | Supabase project URL | [`database/supabase/config/.env.example`](database/supabase/config/.env.example) |
| `SUPABASE_KEY` | Supabase API key | [`database/supabase/config/.env.example`](database/supabase/config/.env.example) |

<br />

These files document configuration shape; they are not places to store real credentials.

<br />

The committed JWT example currently contains a weak sample value. Replace it for disposable local testing & do not use it as a production secret.

<br />

The JWT development package currently points directly to the tracked example file through its `dev` script.

<br />

Before using a real secret, change the local execution configuration to load a separate ignored `.env` file & keep that file out of source control.

<br />

For Supabase, use a project URL and an appropriate key for the experiment.

<br />

Never commit service-role keys or other privileged credentials.

<br />

## Reuse guidelines

<br />

- Import only the modules an experiment actually needs.

<br />

- Keep experiment-specific schemas and behavior close to the experiment unless multiple consumers genuinely share them.

<br />

- Avoid turning this directory into a general-purpose framework.

<br />

- Keep environment-variable requirements documented and validate required values at startup.

<br />

- Update this guide when a shared module's public interface or configuration changes.

<br />

These resources support learning experiments and have not been independently reviewed as a production-ready backend foundation.