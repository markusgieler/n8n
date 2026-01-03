# N8N Docker infrastructure

This repository provides a complete, production-ready infrastructure to run **n8n** using Docker Compose.
It features a PostgreSQL database and secure data persistence.

This project was designed as a **Universal Template**.
You can easily adapt this structure to any other service (App + DB) by simply adjusting the environment variables.

## 🛠️ Technology Stack
* **Docker & Docker Compose**: Container orchestration.
* **n8n**: Workflow automation tool.
* **PostgreSQL**: Relational database for persistent storage.
* **Nginx Proxy Manager**: (Recommended) For SSL management and Reverse Proxy.

## 📂 Project Structure
```text
.
├── data/               # Persistent data (Git-ignored)
│   ├── n8n_data/       # n8n configurations and local database
│   ├── n8n_files/      # Processed binary files
│   └── postgres_data/  # PostgreSQL database files
├── db/                 # Database Dockerfile and custom configs
├── n8n/                # n8n Dockerfile and custom configs
├── .env.example        # Environment variables template
├── .gitignore          # Sensitive file protection
└── docker-compose.yml  # Service definitions
