# CLIMB Project

A mobile app and backend API for managing users and climbing walls, using a custom ELO-based scoring system. Built with **Flutter** (frontend) and **Flask** (backend).

---

## 🧗‍♂️ Overview

This project allows the creation of users and climbing walls, tracking scores based on climbing performance. The **Flask API** handles user and wall management, and the **Flutter mobile app** provides a clean interface for interaction.

---

## 🚀 Features

### Backend (Flask API)
- `POST /user/add`: Add a new user
- `GET /user/<name>`: Get a user by username
- `GET /user/users`: Get all users and scores
- `PUT /user/update/<name>/<wall_id>/<success>`: Update user score based on climb result
- `POST /wall/add`: Add a new climbing wall
- `GET /wall/<wall_id>`: Get wall by ID
- `GET /wall/walls`: Get all walls

### Frontend (Flutter App)
- List all users (scrollable)
- Add new users via input field
- Display all climbing walls
- Update scores after success/failure attempts
- Communicate with Flask API using `http` package

---

## 🛠️ Getting Started

### Backend (Flask)

1. Install Python and dependencies:
    ```bash
    pip install flask
    ```

2. Run the Flask server:
    ```bash
    python backend/app.py
    ```

3. The API runs by default on: `http://localhost:5000`

---

### Mobile App (Flutter)

1. Install Flutter: [flutter.dev/docs](https://flutter.dev/docs/get-started/install)

2. Navigate to the app folder:
    ```bash
    cd flutter_app/
    flutter pub get
    ```

3. Run the app on your device:
    ```bash
    flutter run
    ```

> 📱 Make sure your API URL in `main.dart` matches the actual backend IP (especially if testing on a real device).

---

> 🚫 Commercial use is not permitted without explicit permission.

---
