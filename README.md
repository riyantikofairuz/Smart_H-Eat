<p align="center">
  <img src=".github/assets/Banner%20Smart%20Heat.png" alt="Smart H-EAT Banner" width="650" />
</p>

# H-EAT: Smart Heat Vending Machine

This repository contains the source code for the **H-EAT** project, a smart vending machine system. Developed as part of the PBL TRPL-313 program, the system integrates an IoT-ready backend API built with Laravel and a modern cross-platform mobile application built with Flutter.

---

## 🏛 Architecture Overview

The project is structured into three main components:

- **`backend/`**: A Laravel 13 RESTful API managing user authentication, catalog & menu variation, orders, payments, hardware device commands, and restock logs.
- **`mobile/`**: A Flutter application providing a seamless user interface for customers to browse menu items, customize variations, and complete transactions.
- **`docker/` & `docker-compose.yml`**: Fully containerized local development stack for the backend services.

### Tech Stack Details

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Backend API** | [Laravel 13](https://laravel.com/) | PHP 8.3, Laravel Sanctum for API token authentication |
| **Mobile App** | [Flutter](https://flutter.dev/) | Cross-platform (Android, iOS, Web, Desktop) |
| **Containerization** | [Docker](https://www.docker.com/) & Docker Compose | Multi-container environment for Nginx, PHP, MySQL, & phpMyAdmin |
| **Web Server** | Nginx (Alpine) | Reverse proxy routing requests to PHP-FPM on port `8080` |
| **Database** | MySQL 8.0 | Relational database mapped to port `3307` |
| **DB Management** | phpMyAdmin | Web-based database management interface on port `8081` |

---

## 🐳 Docker Services & Port Mapping

When running via Docker Compose, the following services and ports are exposed:

| Service | Container Name | Internal Port | Host Port | Access URL / Connection |
| :--- | :--- | :--- | :--- | :--- |
| **Nginx (Web/API)** | `smartheat_nginx` | `80` | `8080` | [http://localhost:8080](http://localhost:8080) |
| **PHP-FPM** | `smartheat_php` | `9000` | - | PHP 8.3 FPM + Composer 2 |
| **MySQL Database** | `smartheat_mysql` | `3306` | `3307` | `localhost:3307` |
| **phpMyAdmin** | `smartheat_phpmyadmin` | `80` | `8081` | [http://localhost:8081](http://localhost:8081) |

### Docker Default Database Credentials

- **Host (from container)**: `db`
- **Host (from host machine / tools)**: `127.0.0.1` (Port: `3307`)
- **Database**: `smartheat_db`
- **Username**: `smartheat_user`
- **Password**: `smartheat_pass`
- **Root Password**: `root`

---

## 🚀 Getting Started

Follow the instructions below to get your local environment running.

### Prerequisites

- **Docker & Docker Compose** (Recommended for Backend) or Native PHP >= 8.3, Composer, Node.js & npm
- **Flutter SDK** (for Mobile App)

---

### Backend Setup

You can run the backend either using **Docker (Option A - Recommended)** or **Native Local Setup (Option B)**.

#### Option A: Running with Docker (Recommended)

1. **Prepare Environment File**:
   Copy `.env.example` to `.env` inside the `backend` directory:

   ```sh
   cp backend/.env.example backend/.env
   ```

2. **Configure Database in `backend/.env`**:
   Adjust your database connection values to match Docker:

   ```env
   DB_CONNECTION=mysql
   DB_HOST=db
   DB_PORT=3306
   DB_DATABASE=smartheat_db
   DB_USERNAME=smartheat_user
   DB_PASSWORD=smartheat_pass
   ```

3. **Build and Start Containers**:
   Run Docker Compose from the root project directory:

   ```sh
   docker compose up -d --build
   ```

4. **Initialize Laravel Application**:
   Run key generation and database migrations inside the PHP container:

   ```sh
   # Install PHP dependencies (if vendor is not yet installed)
   docker compose exec php composer install

   # Generate application key
   docker compose exec php php artisan key:generate

   # Run database migrations
   docker compose exec php php artisan migrate
   ```

5. **Verify Running Services**:
   - Backend API: [http://localhost:8080](http://localhost:8080)
   - phpMyAdmin: [http://localhost:8081](http://localhost:8081)

6. **Useful Docker Commands**:

   ```sh
   # Stop all containers
   docker compose down

   # View container logs
   docker compose logs -f

   # Access PHP container shell
   docker compose exec php sh
   ```

---

#### Option B: Running Locally (Native / Laragon)

1. Navigate to the backend directory:

   ```sh
   cd backend
   ```

2. Install Composer dependencies:

   ```sh
   composer install
   ```

3. Set up the environment file:

   ```sh
   cp .env.example .env
   ```

4. Generate application key:

   ```sh
   php artisan key:generate
   ```

5. Configure your database in `.env` and run migrations:

   ```sh
   php artisan migrate
   ```

6. Install frontend assets and build:

   ```sh
   npm install
   npm run build
   ```

7. Start the local server:

   ```sh
   php artisan serve
   ```

---

### 📱 Mobile App Setup

1. Navigate to the mobile directory:

   ```sh
   cd mobile
   ```

2. Install Flutter packages:

   ```sh
   flutter pub get
   ```

3. Run on your connected device, emulator, or desktop:

   ```sh
   flutter run
   ```

---

## 👥 Team Members

- **Muhammad Akbar Fairuz Riyantiko** - 4342501090
- **Zakki Zakwan Adysti** - 4342501063
- **Kemas Muhammad Alif Bisyafa Basunjaya jump boad** - 4342501068
- **Faiz Annabil** - 4342501071
- **Faizal Kahfi Lubis** - 4342501077
- **Martunis Tks** - 4342501080
