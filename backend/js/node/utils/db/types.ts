export type Schema = {
  createTable: string;
  queries: {
    selectAllMessages: string;
    insertMessage: string;
    deleteMessage: string;
  };
};

export type Message = {
  id: number;
  username: string;
  email: string;
  message: string;
};

export type User = {
  id: number;
  username: string;
  email: string;
  message: string;
};

export type CreateUser = Omit<User, "id">;
