# LocalCDN Tutorial

A step-by-step guide to building a local CDN simulation using Docker and Nginx on macOS (Apple Silicon).  
You’ll spin up:

1. **Origin** server (serves static files)
2. **Edge** cache servers (proxy/caching layer)

## Table of Contents

1. [Project Structure](#project-structure)
2. [Prerequisites](#prerequisites)
3. [Setup & Build](#setup--build)
   - [1. Create Docker Network](#1-create-docker-network)
   - [2. Build & Run Origin](#2-build--run-origin)
   - [3. Build & Run Edge](#3-build--run-edge)
   - [4. (Optional) Multiple Edge Nodes](#4-optional-multiple-edge-nodes)
   - [5. (Optional) Docker Compose](#5-optional-docker-compose)
4. [Testing & Verification](#testing--verification)
5. [Customizations](#customizations)
6. [Troubleshooting](#troubleshooting)

---

## Project Structure
