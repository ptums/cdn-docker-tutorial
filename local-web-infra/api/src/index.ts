import express, { Request, Response, Router, RequestHandler } from "express";
import dotenv from "dotenv";
import cors from "cors";

import { createClient } from "redis";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

dotenv.config();

const client = createClient({
  url: process.env.REDIS_URL,
});

async function startServer() {
  const app = express();
  const router: Router = express.Router();

  // Configure CORS
  app.use(
    cors({
      origin: [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:8090",
        "https://edge-site-eu.local:8444",
        "http://edge-site-eu.local:8082",
        "https://edge-site-us.local:8443",
        "http://edge-site-us.local:8081",
      ],
      methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
      allowedHeaders: ["Content-Type", "Authorization"],
    })
  );

  app.use(express.json());

  await client.connect();

  // --- USER CRUD ---
  const getUsers: RequestHandler = async (req, res) => {
    // look for results in memory/redis cache
    const cacheKey = "users:all";
    const cached = await client.get(cacheKey);
    if (cached) {
      res.set("X-Cache", "HIT").json(JSON.parse(cached));
      return;
    }

    const users = await prisma.user.findMany({});
    await client.setEx(cacheKey, 300, JSON.stringify(users));
    res.set("X-Cache", "MISS").json(users);
  };

  const getUser: RequestHandler = async (req, res) => {
    // look for results in memory/redis cache
    const id = Number(req.params.id);
    const cacheKey = `users:${id}`;
    const cached = await client.get(cacheKey);
    if (cached) {
      res.set("X-Cache", "HIT").json(JSON.parse(cached));
      return;
    }

    const user = await prisma.user.findUnique({ where: { id } });
    await client.setEx(cacheKey, 300, JSON.stringify(user));
    res.set("X-Cache", "MISS").json(user);
  };

  router.get("/users", getUsers);
  router.get("/users/:id", getUser);

  // Mount the router with /api prefix
  app.use("/api", router);

  const PORT = process.env.PORT || 4000;
  app.listen(PORT, () => {
    console.log(`API listening on port ${PORT}`);
  });
}

startServer().catch((err) => {
  console.error("Failed to start:", err);
  process.exit(1);
});
