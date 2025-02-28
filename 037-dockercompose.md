### **NGINX + Node.js + Redis with Docker Compose**
This setup uses **NGINX** as a reverse proxy, **Node.js** as the backend, and **Redis** as a caching layer, all managed with **Docker Compose**.

## 🚀 **Getting Started**
Follow these steps to clone and run the project:

### **1️⃣ Clone the Repository**
```bash
git clone https://github.com/docker/awesome-compose.git
```

### **2️⃣ Navigate to the Project Directory**
```bash
cd awesome-compose/nginx-nodejs-redis
```

### **3️⃣ Start the Containers**
To run in the foreground (**logs visible in the terminal**):  
```bash
docker compose up
```
or  
```bash
docker-compose up
```

To run in the background (**detached mode**):  
```bash
docker compose up -d
```
or  
```bash
docker-compose up -d
```

### **4️⃣ Verify Running Containers**
```bash
docker ps
```

### **5️⃣ Stop the Containers**
To stop containers while running in the foreground, press:
```
Ctrl + C
```
If running in the background:
```bash
docker compose down
```
or  
```bash
docker-compose down
```

---

### 🛠 **Make Changes & Restart**
If you make changes to the project, rebuild the containers:
```bash
docker compose up --build -d
```

---

# Docker Setup Guide

## Table of Contents
- [Introduction](#introduction)
- [Understanding `docker-compose.yml`](#understanding-docker-composeyml)
- [Step-by-Step Execution of `docker-compose up`](#step-by-step-execution-of-docker-compose-up)
- [Port Binding Explanation](#port-binding-explanation)
- [Manual Docker Commands (Without Docker Compose)](#manual-docker-commands-without-docker-compose)
- [Automation Scripts](#automation-scripts)
- [Stopping & Cleaning Up](#stopping--cleaning-up)

---

## Introduction
This guide explains how to set up and run a multi-container application using Docker and Docker Compose. It covers how Docker Compose works internally, how port binding happens, and how to achieve the same setup manually using plain Docker commands.

---

## Understanding `docker-compose.yml`
The provided `docker-compose.yml` file defines four services:

```yaml
services:
  redis:
    image: 'redislabs/redismod'
    ports:
      - '6379:6379'
  
  web1:
    restart: on-failure
    build: ./web
    hostname: web1
    ports:
      - '81:5000'
  
  web2:
    restart: on-failure
    build: ./web
    hostname: web2
    ports:
      - '82:5000'
  
  nginx:
    build: ./nginx
    ports:
      - '80:80'
    depends_on:
      - web1
      - web2
```

### **Components Explained**
- **`redis`** → Runs Redis (`redislabs/redismod`) on port `6379`.
- **`web1` & `web2`** → Two identical web servers, built from `./web`.
- **`nginx`** → Reverse proxy/load balancer, forwarding traffic to `web1` and `web2`.

### **Key Directives**
- `restart: on-failure` → Restart container if it crashes.
- `depends_on` → Ensures `nginx` starts only after `web1` and `web2`.
- `ports` → Defines host-to-container port mappings.

---

## Step-by-Step Execution of `docker-compose up`
When you run:
```sh
docker-compose up
```
Docker Compose executes the following steps:

1. **Create a Docker network** (default bridge network).
2. **Pull or build images** for each service.
3. **Create and run containers** inside the network.
4. **Map ports** between the host machine and containers.
5. **Start services** (`web1`, `web2`, `nginx`, and `redis`).

---

## Port Binding Explanation
Port mapping follows the **host:container** format:

| Service | Host Port | Container Port |
|---------|----------|---------------|
| Redis   | 6379     | 6379          |
| Web1    | 81       | 5000          |
| Web2    | 82       | 5000          |
| Nginx   | 80       | 80            |

**Note:** Both `web1` and `web2` expose `5000`, but they are separate containers, so there is no conflict.

---

## Manual Docker Commands (Without Docker Compose)
To achieve the same setup without using `docker-compose`, run the following commands:

### **1️⃣ Create a Docker Network**
```sh
docker network create my_network
```

### **2️⃣ Run Redis**
```sh
docker run -d --name redis --network my_network -p 6379:6379 redislabs/redismod
```

### **3️⃣ Build and Run Web Containers**
```sh
docker build -t web_image ./web

docker run -d --name web1 --network my_network -p 81:5000 web_image

docker run -d --name web2 --network my_network -p 82:5000 web_image
```

### **4️⃣ Build and Run NGINX**
```sh
docker build -t nginx_image ./nginx

docker run -d --name nginx --network my_network -p 80:80 nginx_image
```

### **5️⃣ Verify Running Containers**
```sh
docker ps
```

---

## Automation Scripts
### **`run_containers.sh`** (Automates everything)
```sh
#!/bin/bash

NETWORK_NAME="my_network"
docker network create $NETWORK_NAME

docker run -d --name redis --network $NETWORK_NAME -p 6379:6379 redislabs/redismod

docker build -t web_image ./web

docker run -d --name web1 --network $NETWORK_NAME -p 81:5000 web_image

docker run -d --name web2 --network $NETWORK_NAME -p 82:5000 web_image

docker build -t nginx_image ./nginx

docker run -d --name nginx --network $NETWORK_NAME -p 80:80 nginx_image

echo "All containers are running. Use 'docker ps' to check."
docker ps
```

This script does **not** have `depends_on` like in **Docker Compose**.  

### **📌 Why Doesn't the Script Have `depends_on`?**
- **In `docker-compose.yml`**, `depends_on` ensures that one container starts only after another starts.  
- **In this script**, containers **start immediately** without waiting for dependencies.  

---

### **🛠 How to Handle Dependencies in Bash?**
Since Docker CLI **does not** have `depends_on`, we must manually ensure **services are ready before starting dependent ones**.

#### **📝 Solution: Add a Wait Mechanism**
Modify the script to **wait** for Redis and Web services to be fully available before starting NGINX:

```sh
#!/bin/bash

NETWORK_NAME="my_network"
docker network create $NETWORK_NAME

# Start Redis
docker run -d --name redis --network $NETWORK_NAME -p 6379:6379 redislabs/redismod

# Wait for Redis to be ready
echo "Waiting for Redis to start..."
until docker exec redis redis-cli ping | grep -q "PONG"; do
  sleep 2
done
echo "Redis is ready!"

# Build and Start Web Services
docker build -t web_image ./web

docker run -d --name web1 --network $NETWORK_NAME -p 81:5000 web_image
docker run -d --name web2 --network $NETWORK_NAME -p 82:5000 web_image

# Wait for Web Services to be ready
echo "Waiting for web services to start..."
until curl -s http://localhost:81/ &> /dev/null && curl -s http://localhost:82/ &> /dev/null; do
  sleep 2
done
echo "Web services are ready!"

# Build and Start NGINX
docker build -t nginx_image ./nginx
docker run -d --name nginx --network $NETWORK_NAME -p 80:80 nginx_image

echo "All containers are running. Use 'docker ps' to check."
docker ps
```

### **🚀 Why Use Docker Compose Instead of Scripts?**

| Feature             | Docker Compose (`docker-compose.yml`) | Bash Script (`run_containers.sh`) |
|--------------------|-----------------------------------|----------------------------------|
| **Readability**    | Easy YAML format, well-structured | Harder to maintain, long commands |
| **Reusability**    | Works across different environments | Needs manual tweaks per system |
| **Dependencies**   | `depends_on` ensures order | You must handle ordering manually |
| **Scaling**        | `docker-compose up --scale web=5` | Need to write looping logic in script |
| **Environment Handling** | Supports `.env` files | Need to manually export variables |
| **Networking**     | Automatically creates a network | Must create a network manually |
| **Logging**        | Centralized logs (`docker-compose logs`) | Individual `docker logs` per container |
| **Shutdown & Cleanup** | `docker-compose down` | Requires a separate cleanup script |


### **`cleanup.sh`** (Stops & removes all containers + network)
```sh
#!/bin/bash

docker stop nginx web1 web2 redis
docker rm nginx web1 web2 redis
docker network rm my_network

echo "Cleanup complete!"
```

#### **Usage**
- To start everything:
  ```sh
  chmod +x run_containers.sh
  ./run_containers.sh
  ```
- To stop and clean up:
  ```sh
  chmod +x cleanup.sh
  ./cleanup.sh
  ```

---

## Stopping & Cleaning Up
To manually stop and remove all containers:
```sh
docker stop nginx web1 web2 redis
docker rm nginx web1 web2 redis
docker network rm my_network
```

---

## 🎯 Summary
- **Docker Compose automates multi-container setups**.
- **Port mappings (host:container) ensure proper access**.
- **Docker CLI can replace `docker-compose` with manual commands**.
- **Bash scripts simplify setup and cleanup**.

🚀 Now your entire project setup is well-documented and easy to manage!

