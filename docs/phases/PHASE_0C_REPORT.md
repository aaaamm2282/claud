# PHASE 0C — DIRECTADMIN HANDS-ON INSPECTION

تاریخ: 2026-09-26 — نتیجه: **BLOCKED (Network Policy)**. هیچ تغییری در Production ایجاد نشد.
دامنه‌های `mahermana.com` و `app.mahermana.com`: OUT OF SCOPE (Future Integration).

## شواهد (یک دور تست روی هر مسیر)
| مسیر | نتیجه |
|---|---|
| `https://app.dokkanzo.ir:2222/` (URL پنل) | تونل باز شد، TLS با `Connection reset` قطع شد (gateway تونل را بعد از ~۶ ثانیه بست) |
| `https://212.23.201.172:2222/` (IP مستقیم) | همان رفتار |
| `https://app.dokkanzo.ir/` | 403 روی CONNECT از Egress Gateway |
| `http://app.dokkanzo.ir/` | 403 با هدر `x-deny-reason: host_not_allowed` و متن: *"Host not in allowlist: app.dokkanzo.ir"* |
| مرجع: `portquiz.net:2222` | همان قطع تونل → پورت‌های غیر 443 در این Egress عبور نمی‌کنند |

**مانع دقیق:** Network Policy (Egress Allowlist) محیط Claude Cloud و محدودیت پورت غیراستاندارد 2222.
به TLS، Authentication یا خود DirectAdmin ربطی ندارد، چون درخواست هرگز به سرور نرسید.
Browser Automation (Chromium) هم از همین Proxy عبور می‌کند، پس نتیجه‌اش همین است.
Credential به هیچ سروری ارسال نشد.

## دو روش امن جایگزین
1. افزودن `app.dokkanzo.ir` به Allowed Domains محیط (Environment → Edit → Network access). بعد دوباره تست می‌شود.
   ممکن است پورت 443 باز شود ولی 2222 همچنان مسدود بماند.
2. بررسی دستی توسط کاربر: Screenshotهای پنل، به‌علاوه خروجی `docs/phases/host-inspect.sh` از SSH یا Terminal داخلی DirectAdmin.

## Scenario
**E — Still insufficient information.** هیچ معماری نهایی قفل نشده است.
