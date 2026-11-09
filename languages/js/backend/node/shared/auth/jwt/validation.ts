export function getJWTSecret() {
  const JWT_SECRET = process.env.JWT_SECRET ?? "";

  if (!JWT_SECRET) {
    throw new Error("Environment variable does not contain a valid JWT secret");
  }

  return JWT_SECRET
}