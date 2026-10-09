export type Schema = {
  createTable: string;
  queries: {
    userRegisterMatch: string;
    insertUser: string;
    userLoginMatch: string;
    userPayload: string;
  };
};

export type User = {
  id: number;
  username: string;
  email: string;
  password: string;
};

export type UserPayload = Omit<User, "id" | "password">;