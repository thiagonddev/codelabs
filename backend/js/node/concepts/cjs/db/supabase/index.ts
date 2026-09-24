import type { IncomingMessage, ServerResponse } from "node:http";
import type { CreateUser } from "../../../../utils/db/supabase/config/types";

const http = require("node:http");
const supabase = require("../../../../utils/db/supabase/config/db.ts");

const PORT = Number(process.env.PORT ?? 3000);

const isInvalid = !Number.isInteger(PORT) || PORT < 1 || PORT > 65535;

if (isInvalid) {
  throw new Error("Invalid port");
}

const server = http.createServer(
  async (req: IncomingMessage, res: ServerResponse) => {
    try {
      if (req.method === "GET" && req.url === "/") {
        const { data, error } = await supabase
          .from("supabase")
          .select("id, username, email, message");

        if (error) {
          console.error("Error fetching data:", error);

          res.writeHead(500, {
            "Content-Type": "application/json",
          });

          return res.end(
            JSON.stringify({
              success: false,
              error: "Error fetching data",
            }),
          );
        }

        console.log(data);

        res.writeHead(200, {
          "Content-Type": "application/json",
        });

        return res.end(
          JSON.stringify({
            success: true,
            data,
          }),
        );
      }

      if (req.method === "POST" && req.url === "/") {
        const newUser: CreateUser = {
          username: "thiagond",
          email: "thiagond@example.com",
          message: "User created with POST",
        };

        const { data, error } = await supabase
          .from("supabase")
          .insert([newUser])
          .select("id, username, email, message")
          .single();

        if (error) {
          console.error("Error inserting data:", error);

          res.writeHead(500, {
            "Content-Type": "application/json",
          });

          return res.end(
            JSON.stringify({
              success: false,
              error: "Error adding user",
            }),
          );
        }

        console.log("User added:", data);

        res.writeHead(201, {
          "Content-Type": "application/json",
        });

        return res.end(
          JSON.stringify({
            success: true,
            message: "User added successfully",
            data,
          }),
        );
      }

      if (req.method === "DELETE" && req.url === "/") {
        const { data: lastUser, error: findError } = await supabase
          .from("supabase")
          .select("id, username, email, message")
          .order("id", { ascending: false })
          .limit(1)
          .single();

        if (findError) {
          console.error("Error finding last user:", findError);

          res.writeHead(404, {
            "Content-Type": "application/json",
          });

          return res.end(
            JSON.stringify({
              success: false,
              error: "No user found",
            }),
          );
        }

        const { data: deletedUser, error: deleteError } = await supabase
          .from("supabase")
          .delete()
          .eq("id", lastUser.id)
          .select("id, username, email, message")
          .maybeSingle();

        if (deleteError) {
          console.error("Error deleting user:", deleteError);

          res.writeHead(500, {
            "Content-Type": "application/json",
          });

          return res.end(
            JSON.stringify({
              success: false,
              error: "Error deleting user",
            }),
          );
        }

        if (!deletedUser) {
          res.writeHead(404, {
            "Content-Type": "application/json",
          });

          return res.end(
            JSON.stringify({
              success: false,
              error: "User was already deleted",
            }),
          );
        }

        console.log("User deleted:", lastUser);

        res.writeHead(200, {
          "Content-Type": "application/json",
        });

        return res.end(
          JSON.stringify({
            success: true,
            message: "Last user removed successfully",
            data: lastUser,
          }),
        );
      }

      res.writeHead(404, {
        "Content-Type": "application/json",
      });

      return res.end(
        JSON.stringify({
          success: false,
          error: "Route not found",
        }),
      );
    } catch (error) {
      console.error("Server error:", error);

      res.writeHead(500, {
        "Content-Type": "application/json",
      });

      return res.end(
        JSON.stringify({
          success: false,
          error: "Server internal error",
        }),
      );
    }
  },
);

server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
