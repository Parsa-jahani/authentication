# Umix Authentication Service — API Documentation

Base URL: `http://localhost:8080`

---

## Authentication Flow

```
1. Register  →  Create a new account
2. Login     →  Get access_token + refresh_token
3. Use API   →  Send access_token in Authorization header
4. Refresh   →  Get a new access_token when it expires
5. Logout    →  Discard tokens
```

---

## Endpoints

### Health Check

```
GET /health
```

**Response** `200 OK`
```json
{
    "status": "ok"
}
```

---

### Register

Create a new user account.

```
POST /auth/register
```

**Headers**
| Key          | Value            |
|--------------|------------------|
| Content-Type | application/json |

**Body**
```json
{
    "name": "Amir",
    "email": "amir@gmail.com",
    "password": "mypass123"
}
```

| Field    | Type   | Required | Rules       |
|----------|--------|----------|-------------|
| name     | string | yes      |             |
| email    | string | yes      | valid email |
| password | string | yes      | min 6 chars |

**Response** `201 Created`
```json
{
    "message": "user created successfully",
    "user": {
        "id": 1,
        "name": "Amir",
        "email": "amir@gmail.com",
        "created_at": "2026-02-11T09:49:08.13752+03:30",
        "updated_at": "2026-02-11T09:49:08.13752+03:30"
    }
}
```

**Errors**
| Status | Message                  | Reason              |
|--------|--------------------------|---------------------|
| 400    | validation error         | missing/invalid fields |
| 409    | email already registered | duplicate email     |

---

### Login

Authenticate and receive JWT tokens.

```
POST /auth/login
```

**Headers**
| Key          | Value            |
|--------------|------------------|
| Content-Type | application/json |

**Body**
```json
{
    "email": "amir@gmail.com",
    "password": "mypass123"
}
```

**Response** `200 OK`
```json
{
    "access_token": "eyJhbGciOi...",
    "refresh_token": "eyJhbGciOi...",
    "expires_in": 3600
}
```

| Field         | Description                              |
|---------------|------------------------------------------|
| access_token  | Use in Authorization header for API calls |
| refresh_token | Use to get a new access_token when it expires |
| expires_in    | Token lifetime in seconds (3600 = 1 hour) |

**Errors**
| Status | Message                   | Reason                |
|--------|---------------------------|-----------------------|
| 400    | validation error          | missing/invalid fields |
| 401    | invalid email or password | wrong credentials     |

---

### Get Profile

Get the current authenticated user's info.

```
GET /auth/me
```

**Headers**
| Key           | Value                   |
|---------------|-------------------------|
| Authorization | Bearer {access_token}   |

**Response** `200 OK`
```json
{
    "user": {
        "id": 1,
        "name": "Amir",
        "email": "amir@gmail.com",
        "created_at": "2026-02-11T09:49:08.13752+03:30",
        "updated_at": "2026-02-11T09:49:08.13752+03:30"
    }
}
```

**Errors**
| Status | Message                      | Reason           |
|--------|------------------------------|------------------|
| 401    | authorization header required | no token sent    |
| 401    | invalid or expired token      | bad/expired token |

---

### Refresh Token

Get a new access token using a valid refresh token.

```
POST /auth/refresh
```

**Headers**
| Key          | Value            |
|--------------|------------------|
| Content-Type | application/json |

**Body**
```json
{
    "refresh_token": "eyJhbGciOi..."
}
```

> **Important:** Use the `refresh_token` from login, NOT the `access_token`. They are different!

**Response** `200 OK`
```json
{
    "access_token": "eyJhbGciOi...",
    "refresh_token": "eyJhbGciOi...",
    "expires_in": 3600
}
```

**Errors**
| Status | Message                            | Reason                    |
|--------|------------------------------------|---------------------------|
| 401    | invalid or expired refresh token   | wrong token or expired    |

---

### Logout

Log out the current user.

```
POST /auth/logout
```

**Headers**
| Key           | Value                   |
|---------------|-------------------------|
| Authorization | Bearer {access_token}   |

**Response** `200 OK`
```json
{
    "message": "logged out successfully"
}
```

> **Note:** With JWT, logout is client-side. The client should delete both tokens after calling this endpoint.

---

## Token Usage Guide

After login, you get two tokens:

| Token         | Lifetime | Purpose                                |
|---------------|----------|----------------------------------------|
| access_token  | 1 hour   | Send with every API request            |
| refresh_token | 7 days   | Use to get a new access_token silently |

**How to send the access token:**

```
GET /auth/me
Authorization: Bearer eyJhbGciOi...
```

**When access_token expires:**

```
POST /auth/refresh
Body: { "refresh_token": "eyJhbGciOi..." }
→ You get a fresh access_token
```

---

## Error Response Format

All errors follow this format:

```json
{
    "error": "description of what went wrong"
}
```

## Status Codes Summary

| Code | Meaning       |
|------|---------------|
| 200  | Success       |
| 201  | Created       |
| 400  | Bad Request   |
| 401  | Unauthorized  |
| 409  | Conflict      |
| 500  | Server Error  |
