export type User = {
    id: number,
    username: string,
    email: string,
    message: string
}

export type CreateUser = Omit<User, "id">