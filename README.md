# H-EAT: Smart Heat Vending Machine

This repository contains the source code for the H-EAT project, a smart vending machine system. This project was developed as part of the PBL TRPL-313 program. The system is composed of a backend API built with Laravel and a cross-platform mobile application built with Flutter.

## Architecture

The project is divided into two main components:

- **`backend/`**: A Laravel-based application that serves as the central API for the smart vending machine. It handles data management, user authentication, and business logic.
- **`mobile/`**: A Flutter application designed for users to interact with the H-EAT vending machine. It is built to be cross-platform, with support for Android, iOS, and desktop platforms.

### Backend (Laravel)

- **Framework**: [Laravel 13](https://laravel.com/)
- **Database**: Configured for SQLite, MySQL, MariaDB, PostgreSQL, and SQL Server.
- **API Authentication**: [Laravel Sanctum](https://laravel.com/docs/sanctum) for API token and session-based authentication.
- **Frontend Tooling**: [Vite](https://vitejs.dev/) with [Tailwind CSS](https://tailwindcss.com/) for asset bundling.

### Mobile (Flutter)

- **Framework**: [Flutter](https://flutter.dev/)
- **Platform Support**: The project is structured to support Android, iOS, Linux, macOS, Web, and Windows.
- **Functionality**: Provides the user interface for interacting with the vending machine services through the backend API.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- **Backend**:
  - PHP >= 8.3
  - [Composer](https://getcomposer.org/)
  - Node.js & npm
- **Mobile**:
  - [Flutter SDK](https://docs.flutter.dev/get-started/install)

### Backend Installation

1. Navigate to the backend directory:

    ```sh
    cd backend
    ```

2. Install Composer dependencies:

    ```sh
    composer install
    ```

3. Create your environment file from the example:

    ```sh
    cp .env.example .env
    ```

4. Generate a new application key:

    ```sh
    php artisan key:generate
    ```

5. Run the database migrations:

    ```sh
    php artisan migrate
    ```

6. Install NPM dependencies and build the frontend assets:

    ```sh
    npm install
    npm run build
    ```

7. Start the development server:

    ```sh
    php artisan serve
    ```

### Mobile App Installation

1. Navigate to the mobile directory:

    ```sh
    cd mobile
    ```

2. Install Flutter dependencies:

    ```sh
    flutter pub get
    ```

3. Run the application on a connected device or emulator:

    ```sh
    flutter run
    ```

## Team Members

- **Muhammad Akbar Fairuz Riyantiko** - 4342501090
- **Zakki Zakwan Adysti** - 4342501063
- **Kemas Muhammad Alif Bisyafa Basunjaya jump boad** - 4342501068
- **Faiz Annabil** - 4342501071
- **Faizal Kahfi Lubis** - 4342501077
- **Martunis Tks** - 4342501080
