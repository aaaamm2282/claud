# PHASE 0 — DISCOVERY & ENVIRONMENT INSPECTION

پروژه: KMM Management & Operations System — مؤسسه آموزشی کودک ماهر مانا
تاریخ: 2026-09-26
شاخه: `claude/kmm-management-operations-xyubyg`

## 1. Repository
- مخزن `aaaamm2282/claud` کاملاً خالی است (بدون Commit، بدون فایل، بدون کد موجود).
- هیچ کد Legacy، Schema یا تنظیماتی برای مهاجرت وجود ندارد → پروژه Greenfield است.

## 2. محیط توسعه (Cloud Container)
| ابزار | وضعیت |
|---|---|
| OS | Linux x86_64، ۴ هسته، ۱۵GB RAM، ~۳۰GB دیسک آزاد |
| Node.js | v22.22.2 |
| npm / pnpm | 10.9.7 / 10.33.0 |
| Git | 2.43.0 |
| PostgreSQL (محلی) | 16.13 — نصب است و راه‌اندازی شد (برای Dev/Test قابل استفاده) |
| MySQL client | نصب نیست |
| Python | 3.11 |
| Docker | Client موجود، Daemon در دسترس نیست |
| npm registry | در دسترس (نصب پکیج ممکن است) |
| Playwright + Chromium | از پیش نصب (برای E2E / PWA / Mobile Test) |

## 3. متغیرهای محیطی Hosting
- `DIRECTADMIN_URL`: تعریف شده — `https://app.dokkanzo.ir:2222/`
- `DIRECTADMIN_USERNAME`: تعریف شده
- `DIRECTADMIN_PASSWORD`: تعریف شده (مقدار نمایش/ثبت نشده)

نکته: دامنه پنل `dokkanzo.ir` است نه `mahermana.com`؛ رابطه این دو (همان سرور/اکانت؟) باید توسط کاربر تأیید شود.
DNS: `app.dokkanzo.ir → 212.23.201.172` و `mahermana.com → 185.252.31.58` (دو IP متفاوت). `app.mahermana.com` رکورد DNS ندارد.

## 4. نتیجه Hosting Inspection — مسدود (BLOCKED)
| مقصد | نتیجه |
|---|---|
| `app.dokkanzo.ir:2222` (DirectAdmin) | تونل Proxy باز شد ولی اتصال به سرور پس از ~۶ ثانیه بسته شد (Connection reset). ۴ تلاش، همه ناموفق |
| `app.dokkanzo.ir:443`, `dokkanzo.ir:443` | 403 — رد توسط Network Policy محیط Cloud |
| `mahermana.com:443`, `app.mahermana.com:443` | 403 — رد توسط Network Policy |
| اتصال مستقیم TCP به 22 / 2222 | ناموفق (خروج فقط از طریق Proxy مجاز است) |

دو علت محتمل برای 2222:
1. Egress Proxy محیط Cloud اتصال به مقصد را کامل نمی‌کند.
2. سرور/دیتاسنتر ایرانی ترافیک ورودی از IPهای خارج از ایران را (به‌ویژه روی پورت پنل) فیلتر می‌کند — در هاست‌های ایرانی رایج است.

در نتیجه هیچ‌یک از موارد زیر قابل بررسی نبود:
SSH، Node.js/Node Versions روی سرور، Node.js Selector/Passenger، PostgreSQL، MySQL/MariaDB، Cron، SSL، Subdomain، Reverse Proxy، Process Manager، WebSocket، Env Vars، File Storage، Resource Limits، Backup.
**هیچ فرضی درباره قابلیت‌های هاست ثبت نشده است.**

## 5. Stackهای ممکن (قطعی نشده — منوط به Hosting Inspection)
| سناریوی هاست | Stack پیشنهادی |
|---|---|
| A: SSH + Node.js (Passenger/Node Selector یا PM2) + PostgreSQL | Next.js (App Router) + TypeScript + PostgreSQL + ORM (Prisma یا Drizzle) + Zod — ترجیح اولیه پروژه |
| B: Node.js موجود ولی فقط MySQL/MariaDB | همان Stack با MariaDB؛ RLS دیتابیس در دسترس نیست → Authorization کامل در Service Layer + Query Scoping اجباری |
| C: بدون Node.js (فقط PHP/Apache — Shared Hosting کلاسیک) | Next.js به‌صورت Static Export برای Frontend/PWA + Backend مستقل (Laravel/PHP) روی هاست؛ یا انتقال App به VPS و نگه‌داشتن DirectAdmin برای وب‌سایت |
| D: VPS/SSH root | Next.js + PostgreSQL + Nginx Reverse Proxy + PM2/systemd — بهترین گزینه برای الزامات پروژه |

الزامات پروژه (RLS، Cron برای Escalation، Background Jobs، File Upload امن، Backup) با سناریو A یا D بهتر برآورده می‌شوند.

## 6. محدودیت‌ها و ریسک‌های شناسایی‌شده
1. دسترسی از محیط Cloud به هاست Production وجود ندارد → Deployment از این محیط فعلاً ممکن نیست.
2. ابهام دامنه: `dokkanzo.ir` در برابر `mahermana.com`.
3. اگر هاست فقط از IP ایران در دسترس باشد، Deploy باید یا توسط کاربر (Build Artifact + راهنما) یا از طریق CI/Runner داخل ایران انجام شود.
4. Docker Daemon در محیط Cloud فعال نیست (مانعی برای توسعه نیست؛ PostgreSQL محلی موجود است).
