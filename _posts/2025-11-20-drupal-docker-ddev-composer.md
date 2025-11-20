---
layout: post
title: "Complete Guide: Drupal 11 with Docker, DDEV, and Composer (Windows 11)"
date: 2025-11-20
tags: [drupal11, docker, ddev, composer, php, windows]
---

# 1. Docker and DDEV

## 1.1 Docker

Docker provides **containers**, which are lightweight, isolated environments for running applications.

**Key benefits:**

- Identical environment every time
- Isolation from the host OS (no polluting Windows with random PHP/MySQL setups)
- Reproducible, portable environments
- Clean separation of services (web, db, extras like Redis/Mailpit)

## 1.2 DDEV

DDEV is a developer tool built on top of Docker that hides most of Docker’s complexity behind a **simple CLI** tailored for web development (Drupal, WordPress, Laravel, etc.).

Instead of hand-writing `docker-compose.yml`, fighting ports, and remembering `docker run` incantations, you use:

- `ddev config` – configure a project
- `ddev start` / `ddev stop` / `ddev restart`
- `ddev ssh` – shell into the web container
- `ddev composer …` – run Composer inside the container
- `ddev drush …` – run Drush inside the container (once installed)

**Nice extras:**

- Automatic HTTPS with trusted certs for `*.ddev.site`
- Multiple projects at once (no port conflicts)
- Snapshots of the database (`ddev snapshot …`)
- Team-shareable config via the `.ddev/` directory

**How they fit:**

- Docker = engine that runs containers  
- DDEV = dashboard/driver’s seat that makes them easy for web dev  

---

# 2. Composer Basics (for Drupal 11)

Composer is the **package manager for PHP**, comparable to:

- `npm` for JavaScript  
- `pip` for Python  

Modern Drupal (including 11) assumes you’re using Composer.

## 2.1 What Composer does

- Installs PHP packages (Drupal core, contrib modules, themes, libraries)
- Resolves version constraints and dependencies
- Produces reproducible installs via `composer.lock`
- Generates an autoloader (`vendor/autoload.php`)

**Example:**

```bash
composer require drupal/pathauto
```

This downloads `drupal/pathauto`, adds it to `composer.json`, and updates `composer.lock`.

## 2.2 Why Drupal uses Composer

Drupal 11 uses Composer to:

- Install Drupal core from `drupal/recommended-project`
- Add contrib modules/themes
- Pull in Symfony, Guzzle, and other PHP libraries
- Apply security/bugfix updates in a controlled way

**Starting a new Drupal 11 project (bare Composer):**

```bash
composer create-project drupal/recommended-project mysite "^11"
```

**Inside DDEV:**

```bash
ddev composer create-project "drupal/recommended-project:^11" .
```

## 2.3 Common Composer commands

Run **inside** DDEV with `ddev composer …`:

```bash
# Install dependencies from composer.lock
composer install

# Add a new package
composer require drupal/token

# Update everything (within allowed version ranges)
composer update

# Update just Drupal core and related dependencies
composer update drupal/core --with-all-dependencies
```

With DDEV:

```bash
ddev composer install
ddev composer require drupal/token
ddev composer update drupal/core --with-all-dependencies
```

---

# 3. Step-by-Step: Drupal 11 + DDEV on Windows 11

These steps assume:

- Docker Desktop is installed and running  
- DDEV is installed and `ddev version` works  
- You’re using PowerShell (paths are Windows-style)

## 3.1 One-time checks

```powershell
docker version
ddev version
```

If `ddev version` fails, install via Chocolatey (PowerShell as Administrator):

```powershell
choco install ddev -y
```

Then open a new terminal and try again.

---

## 3.2 Create a project directory

```powershell
cd C:/Users/Preston/OneDrive/Documents
mkdir Drupal
cd Drupal
```

(Use a different path if you prefer, just be consistent.)

---

## 3.3 Configure DDEV for Drupal 11

```powershell
ddev config --project-name=drupal-ddev --project-type=drupal --docroot=web --create-docroot
```

This:

- Creates a `.ddev` directory with config
- Ensures `web/` exists as the docroot
- Sets the project name (`drupal-ddev`) which appears in the URL:
  - `https://drupal-ddev.ddev.site`

---

## 3.4 Start the DDEV environment

```powershell
ddev start
```

You may see:

```text
The index.php or index.html does not yet exist at this path:
.../Drupal/web/index.*
You may get 403 errors 'permission denied' from the browser until it does.
Ignore if a later action (like `ddev composer create-project`) will create it.
```

That’s expected **before** Drupal is installed.

DDEV will then:

- Build/start the web and db containers
- Set up the router and HTTPS
- Show a URL like:

```text
Project can be reached at https://drupal-ddev.ddev.site
```

---

## 3.5 Install Drupal 11 with Composer (inside DDEV)

Now that DDEV is running, install Drupal 11 into this directory:

```powershell
ddev composer create-project "drupal/recommended-project:^11" .
```

Notes:

- The trailing `.` means “install into the **current** directory”.
- This creates:
  - `composer.json`, `composer.lock`
  - `vendor/`
  - Populates `web/` with:
    - `index.php`
    - `core/`
    - `modules/`
    - `sites/`
    - `themes/`, etc.

When Composer finishes, restart DDEV so the web container sees the new files:

```powershell
ddev restart
```

---

## 3.6 Run the Drupal installer

Open in a browser:

```text
https://drupal-ddev.ddev.site
```

You should now see the **Drupal 11 installer**, not a 403.

### Database settings (DDEV defaults)

Use:

- Database type: MySQL or MariaDB  
- Database name: `db`  
- Database username: `db`  
- Database password: `db`  
- Host: `db`  

These are the standard DDEV credentials.

Let the installer run, then set:

- Site name  
- Site email (dev/testing is fine)  
- Admin username/password  

When it finishes, you’ll land on your new Drupal 11 front page.

---

## 3.7 Everyday commands

From the project root (`C:/Users/Preston/OneDrive/Documents/Drupal`):

```powershell
# Start environment
ddev start

# Stop environment
ddev stop

# Restart environment
ddev restart

# Shell into container
ddev ssh

# Run Composer inside container
ddev composer install
ddev composer require drupal/token

# Run Drush (after it’s installed via Composer)
ddev drush status
ddev drush cr
```

To completely tear down containers + DB (but keep your code):

```powershell
ddev delete -Oy
```

---

## 3.8 Optional: Make a simple homepage

1. Log into Drupal at `/user/login`.  
2. Go to **Content → Add content → Basic page** and create a “Home” page.  
3. Go to **Configuration → System → Basic site settings**.  
4. Set **Default front page** to the path of your page (e.g. `/home`).  
5. Save.

Now your site lands on that page instead of the default welcome page.

---

# 4. DDEV Command Cheatsheet

## 4.1 Project lifecycle

```bash
# Configure (once per project)
ddev config --project-name=myproj --project-type=drupal --docroot=web --create-docroot

# Start containers
ddev start

# Stop containers
ddev stop

# Restart containers
ddev restart

# Delete containers and database (keep code)
ddev delete -Oy
```

## 4.2 Inside the container

```bash
# Shell into web container
ddev ssh

# Composer inside container
ddev composer install
ddev composer require drupal/token
ddev composer update

# Drush inside container (after install)
ddev drush status
ddev drush cr
ddev drush uli
```

## 4.3 Database helpers

```bash
# Open DB in a GUI (varies by OS/tools)
ddev sequel

# Export DB
ddev export-db --file=./db.sql.gz

# Import DB
ddev import-db --src=./db.sql.gz
```

## 4.4 Snapshots

```bash
# Create a named snapshot
ddev snapshot --name=before-update

# List snapshots
ddev snapshot list

# Restore a snapshot
ddev snapshot restore before-update
```

## 4.5 Info and URLs

```bash
# Show project info, URLs, services
ddev describe
```

Look for:

```text
Project can be reached at https://myproj.ddev.site
```

---

# 5. Troubleshooting — 403 and Missing index.php

If you see a **403 Forbidden** when you visit `https://drupal-ddev.ddev.site`, and DDEV showed:

```text
The index.php or index.html does not yet exist at this path:
.../Drupal/web/index.*
You may get 403 errors 'permission denied' from the browser until it does.
Ignore if a later action (like `ddev composer create-project`) will create it.
```

…that means:

- DDEV is pointed at `web/` correctly  
- But Drupal has **not** been installed there yet (no `index.php`)  

### Fix

From the project root:

```powershell
ddev composer create-project "drupal/recommended-project:^11" .
ddev restart
```

Then reload:

```text
https://drupal-ddev.ddev.site
```

You should now see the Drupal 11 installer.

If you’re still stuck, check the `web/` folder:

```powershell
dir web
```

You should see at least:

- `index.php`
- `core/`
- `modules/`
- `sites/`
- `themes/`

If `index.php` is missing, the Composer step didn’t finish or ran in the wrong folder.

---

# 6. Big-picture summary

- **Docker** gives you clean, isolated containers for web + DB.  
- **DDEV** makes those containers easy to configure, start, stop, and share.  
- **Composer** installs and manages Drupal 11 and its dependencies.  

Together they give you:

- A local Drupal 11 site you can destroy and recreate in minutes.  
- A setup you can commit to Git and share with others.  
- Confidence that “if it works here, it will work elsewhere.”
