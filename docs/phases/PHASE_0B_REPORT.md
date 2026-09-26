# PHASE 0B — PRODUCTION HOSTING VERIFICATION

تاریخ: 2026-09-26 — فقط بررسی (READ-ONLY). هیچ تغییری در Production ایجاد نشد.

## SCOPE UPDATE (2026-09-26 — دستور کاربر)
- `mahermana.com` و `app.mahermana.com` **OUT OF SCOPE** هستند و فقط Future Integration محسوب می‌شوند، نه Current Deployment Target.
- هیچ DNS Record، Subdomain یا تغییری برای `mahermana.com` پیشنهاد یا اعمال نمی‌شود.
- Production و Staging فقط روی سرور DirectAdmin `app.dokkanzo.ir` و فقط با Domain/Subdomainهای موجود در همان اکانت اجرا می‌شوند.
- ساخت Subdomain جدید فقط بعد از گزارش گزینه‌ها و تأیید کاربر انجام می‌شود.
- PHASE 0B باز است تا مشخصات واقعی هاست معلوم شود.

## 1. دسترسی شبکه (یک تلاش هدفمند)
| مرحله | نتیجه |
|---|---|
| DNS `app.dokkanzo.ir` | Pass → `212.23.201.172` |
| CONNECT به Proxy محلی برای `:2222` | Pass (200) |
| TLS handshake با `:2222` | **Fail**: `Connection reset by peer` بعد از Client Hello |
| HTTP / DirectAdmin API | انجام نشد (TLS برقرار نشد) |
| `:443` روی `dokkanzo.ir` و `mahermana.com` | **Fail**: 403 از Egress Policy |

**تشخیص علت:** سرویس عمومی `portquiz.net:2222` هم (که عمداً به همه پورت‌ها جواب می‌دهد) دقیقاً با همین الگو شکست خورد (تونل بعد از ۶ ثانیه بسته شد). پس مشکل در **Egress محیط Cloud** است و احتمالاً به سرور DirectAdmin مربوط نیست. Retry بیشتر فایده‌ای ندارد.

## 2. شواهد DNS عمومی (فقط خواندنی)
| دامنه | NS | A | ملاحظه |
|---|---|---|---|
| `dokkanzo.ir` / `app.dokkanzo.ir` | `rock/alluvium.parspack.net` (پارس‌پک) | `212.23.201.172` | PTR ندارد |
| `mahermana.com` | `irdns1/irdns2.mrservers.net` | `185.252.31.58` | PTR = `bahram.mrservers.net`؛ MX = `mail.mahermana.com`؛ SPF روی همان IP |
| `app.mahermana.com` | — | **NXDOMAIN** | یعنی رکوردش وجود ندارد (نه اینکه فقط resolve نشود) |

**نتیجه‌گیری:**
- `mahermana.com` (وب‌سایت و ایمیل) روی سرور جداگانه‌ای با نام `bahram.mrservers.net` در ارائه‌دهنده MrServers میزبانی می‌شود. DNS آن هم **External** و روی MrServers است.
- پنل DirectAdmin روی `app.dokkanzo.ir` روی IP دیگری است که DNS آن در پارس‌پک قرار دارد؛ به احتمال زیاد یک VPS یا سرور جداگانه است.
- پس به احتمال زیاد `mahermana.com` **داخل این اکانت DirectAdmin نیست**. تأیید قطعی فقط با دیدن پنل ممکن است.

## 3. سناریوی تشخیص‌داده‌شده
**E — اطلاعات کافی نیست.** سناریوی محتمل D (VPS) است، و اگر اکانت `app` فقط User-level باشد A/B.

## 4. MANUAL HOST CHECK REQUIRED
موارد اضافه: در Domain Setup، **فهرست همه Domainها و Subdomainهای موجود در همین اکانت DirectAdmin** و اینکه DNS آن‌ها در پنل (Local) مدیریت می‌شود یا در پارس‌پک (External).

به گزارش اصلی در گفت‌وگو مراجعه کنید (لیست Screenshotها و Command Block امن).

Command Block امن: `docs/phases/host-inspect.sh` (فقط خواندنی؛ نصب، نوشتن یا Restart انجام نمی‌دهد).
