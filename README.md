# Umix Authentication Service

A JWT-based authentication microservice built with Go. Provides user registration, login, token refresh, profile retrieval, and logout functionality.

## Tech Stack

- **Go** + **Gin** — HTTP framework
- **GORM** + **SQLite** — ORM and database
- **JWT** — Stateless authentication (access + refresh tokens)
- **bcrypt** — Password hashing

## Quick Start

```bash
make deps       # download dependencies (first time only)
make dev        # start server in background
make status     # check server status
make test-all   # test all endpoints
make logs       # watch live logs
make stop       # stop server
```

Run `make` to see all available commands.

## API Endpoints

| Method | Path             | Auth | Description         |
|--------|------------------|------|---------------------|
| GET    | /health          | No   | Health check        |
| POST   | /auth/register   | No   | Register new user   |
| POST   | /auth/login      | No   | Login & get tokens  |
| POST   | /auth/refresh    | No   | Refresh tokens      |
| GET    | /auth/me         | Yes  | Get user profile    |
| POST   | /auth/logout     | Yes  | Logout              |

Full API documentation: [`docs/API.md`](docs/API.md)

## Configuration

Environment variables (or `.env` file):

| Variable    | Default                | Description     |
|-------------|------------------------|-----------------|
| PORT        | 8080                   | Server port     |
| DB_PATH     | ./database/auth.db     | SQLite file path |
| JWT_SECRET  | (change in production) | JWT signing key |

---

<div dir="rtl">

# سرویس احراز هویت Umix

یک میکروسرویس احراز هویت مبتنی بر JWT که با Go ساخته شده. شامل ثبت‌نام، ورود، تمدید توکن، مشاهده پروفایل و خروج.

## فناوری‌ها

- **Go** + **Gin** — فریم‌ورک HTTP
- **GORM** + **SQLite** — دیتابیس
- **JWT** — احراز هویت با توکن (access + refresh)
- **bcrypt** — هش کردن رمز عبور

## شروع سریع

<div dir="ltr">

```bash
make deps       # دانلود پکیج‌ها (فقط بار اول)
make dev        # اجرای سرور در بک‌گراند
make status     # وضعیت سرور
make test-all   # تست همه endpoint ها
make logs       # مشاهده لاگ‌ها
make stop       # توقف سرور
```

</div>

دستور `make` رو بدون آرگومان بزنید تا لیست کامل دستورات رو ببینید.

## نقاط دسترسی API

| متد    | مسیر             | نیاز به توکن | توضیح              |
|--------|------------------|---------------|---------------------|
| GET    | /health          | خیر           | بررسی سلامت سرور   |
| POST   | /auth/register   | خیر           | ثبت‌نام کاربر جدید  |
| POST   | /auth/login      | خیر           | ورود و دریافت توکن |
| POST   | /auth/refresh    | خیر           | تمدید توکن          |
| GET    | /auth/me         | بله           | مشاهده پروفایل     |
| POST   | /auth/logout     | بله           | خروج                |

مستندات کامل API: [`docs/API.md`](docs/API.md)

</div>
