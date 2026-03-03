# DatabaseApplications Playbook (User-specific)

Purpose: Persist a repeatable workflow for ISYS1102/3479 labs, SQL practice, and common troubleshooting.

> This is a study aid. Do not paste credentials into chat.

## 1) Connection checklist (VS Code + MSSQL)
- Install extension: **SQL Server (mssql)** by Microsoft
- Add connection (Parameters):
  - Server: `santha26.cn2ems8y2mfe.ap-southeast-2.rds.amazonaws.com`
  - Auth: SQL Login
  - Username: `s4112600`
  - Database: `s4112600`
  - Encrypt: **Mandatory**
  - Trust Server Certificate: **On**
- Verify:
  - `SELECT DB_NAME() AS current_db;` → should be `s4112600`

### First-login password change
- If you get `Login failed. The password must be changed before logging on the first time.`
  - Change the password once (Azure Data Studio often works), then reconnect in VS Code.

## 2) Running .sql files
- Open `.sql` file → click inside editor (must have focus)
- Ensure correct connection selected
- Run all, or run in sections

## 3) Movies lab workflow
1) Run `movies-ddl.sql` (creates tables + PK/FK)
2) Run `movies-populate.sql` (inserts sample data)
3) Verify:
   - `SELECT name FROM sys.tables ORDER BY name;`
   - `SELECT COUNT(*) FROM MOVIE;`

## 4) Common errors → fixes
- **FK constraint violation**
  - Run inserts in the correct order; ensure parent rows exist
- **Wrong database**
  - `SELECT DB_NAME();` and switch connection/database
- **VS Code Connect button does nothing**
  - SQL Tools Service is still initializing; reload window / restart VS Code / reinstall SQL Tools Service

## 5) SQL exam traps (high value)
- AND/OR precedence (use parentheses)
- JOIN keys (join on correct PK/FK)
- Many-to-many needs a bridge table (e.g., MOVSTAR)
