#!/usr/bin/env bash
# KMM — read-only host inspection. Run over SSH on the production server.
# Makes NO changes: no installs, no writes outside stdout, no restarts.
# Prints no passwords. Review output before sharing; redact anything private.
echo "== OS";        (cat /etc/os-release 2>/dev/null | head -3); uname -srm
echo "== USER";      id -un; echo "shell=$SHELL"; echo "home=$HOME"
echo "== NODE";      for b in node npm pnpm npx pm2 git php psql mysql mariadb nginx httpd apache2 openlitespeed lswsctrl crontab passenger systemctl; do printf '%-14s ' "$b"; command -v "$b" >/dev/null 2>&1 && echo "$(command -v $b)" || echo "-"; done
node -v 2>/dev/null; npm -v 2>/dev/null; pnpm -v 2>/dev/null; git --version 2>/dev/null; php -v 2>/dev/null | head -1
ls -d /opt/alt/alt-nodejs*/ /usr/local/nodejs* ~/.nvm 2>/dev/null
echo "== DB";        psql --version 2>/dev/null; mysql --version 2>/dev/null
echo "== WEB";       nginx -v 2>&1 | head -1; httpd -v 2>/dev/null | head -1; apache2 -v 2>/dev/null | head -1
ls /usr/local/directadmin/directadmin >/dev/null 2>&1 && /usr/local/directadmin/directadmin v 2>/dev/null | head -2
grep -E '^(webserver|php1_release|mysql_inst|mysql|nodejs)=' /usr/local/directadmin/custombuild/options.conf 2>/dev/null
echo "== LISTEN";    (ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null) | awk 'NR==1||/:(80|443|2222|3306|5432|3000)\b/'
echo "== DISK";      df -h "$HOME" 2>/dev/null; quota -s 2>/dev/null | tail -2
echo "== MEM/CPU";   free -h 2>/dev/null; nproc 2>/dev/null; ulimit -u -n 2>/dev/null
echo "== CRON";      crontab -l >/dev/null 2>&1 && echo "crontab usable" || echo "crontab: none/denied"
echo "== SUDO";      sudo -n true 2>/dev/null && echo "passwordless sudo: yes" || echo "passwordless sudo: no"
echo "== DONE"
