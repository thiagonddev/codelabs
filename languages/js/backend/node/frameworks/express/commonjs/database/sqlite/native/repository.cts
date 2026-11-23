import type { DatabaseSync } from "node:sqlite";

import type { UserMessageSchema } from "../../../../../../shared/database/sqlite/user.message.types";

import type {
  UserMessageValidation,
  UserMessageRepository
} from "../../../../../../shared/database/user.message.types";

function createUserMessageRepository(
  db: DatabaseSync,
  schema: UserMessageSchema
): UserMessageRepository {
  function findAll() {
    return db.prepare(schema.queries.selectAllUserMessages).all();
  }

  function create(valid: { data: UserMessageValidation }) {
    return db.prepare(schema.queries.insertUserMessage).run(valid.data);
  }

  function deleteById(userId: number) {
    return db.prepare(schema.queries.deleteUserMessage).get({ id: userId });
  }

  return { findAll, create, deleteById };
}

module.exports = createUserMessageRepository