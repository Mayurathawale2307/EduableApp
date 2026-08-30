# EduAble Backend

A Node.js + Express.js backend for EduAble with JWT authentication, MongoDB persistence, and modular architecture.

## Features

- User registration with `name`, `email`, `password`, and `userType` (`student` or `kid`)
- Secure password hashing with `bcryptjs`
- JWT-based authentication for protected routes
- MongoDB persistence with Mongoose schemas and validation
- Modular structure: routes, controllers, models, middleware
- Error handling with status codes for validation, authentication, and server errors
- CORS support and JSON body parsing for frontend integration

## Setup

1. Install dependencies:

```bash
cd EduAble_Backend
npm install
```

2. Copy `.env.example` to `.env` and configure values:

```bash
cp .env.example .env
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

3. Set your MongoDB connection string and JWT secret:

```env
MONGO_URI=mongodb+srv://user:password@cluster0.mongodb.net/eduable?retryWrites=true&w=majority
JWT_SECRET=supersecretvalue
PORT=5000
NODE_ENV=development
```

4. Start the server:

```bash
npm run dev
```

## API Endpoints

### POST `/api/auth/signup`
Register a new user.

Body:

```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "securePassword123",
  "userType": "student"
}
```

Response:

- `201 Created` on success
- `400 Bad Request` for validation errors

### POST `/api/auth/login`
Authenticate an existing user.

Body:

```json
{
  "email": "jane@example.com",
  "password": "securePassword123"
}
```

Response:

- `200 OK` with JWT token
- `401 Unauthorized` for invalid credentials

### GET `/api/user/profile`
Fetch authenticated user details.

Headers:

```http
Authorization: Bearer <token>
```

Response:

- `200 OK` with user profile
- `401 Unauthorized` if token is missing or invalid

### PUT `/api/user/update-profile`
Update user profile fields.

Headers:

```http
Authorization: Bearer <token>
```

Body (any of these):

```json
{
  "name": "Jane Updated",
  "email": "jane.new@example.com",
  "userType": "kid"
}
```

Response:

- `200 OK` with updated user details
- `400 Bad Request` for validation issues
- `401 Unauthorized` for missing or invalid token

## Frontend Integration

From Flutter or React Native:

- Use `axios` or `fetch` to send JSON to `/api/auth/signup` and `/api/auth/login`
- Store tokens securely in `AsyncStorage` or secure storage
- Attach `Authorization: Bearer <token>` for protected routes

Example Axios header:

```js
axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
```

## Notes

- Passwords are never returned in responses.
- Email must be unique and valid.
- The backend is intended as a foundation for further features like chatbot support, progress tracking, and user personalization.
