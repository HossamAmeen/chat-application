# Chat System API

This is a Ruby on Rails API project for managing applications, chats, and messages. 
It uses MySQL for data storage, Redis for message counts, and Elasticsearch for searching messages. The project is containerized using Docker Compose.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/chat-system-api.git
cd chat-system-api

### 2. Set Up the Database

```bash
docker-compose run web bundle exec rails db:create
docker-compose run web bundle exec rails db:migrate

### 3. start project
docker-compose up --build -d

### 4. postman collection
Access the Postman collection for API testing https://documenter.getpostman.com/view/34569865/2sAXjF8uMh.
