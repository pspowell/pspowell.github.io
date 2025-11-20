# Step-by-Step: Simple Drupal Site with DDEV (Drupal 11)

These steps assume:

- Docker Desktop is installed and running.
- DDEV is installed (`ddev version` works in your terminal).
- You are on Windows (PowerShell examples), but the commands are similar on macOS/Linux.

---

## 1. One-time checks

### Docker

```powershell
docker version
```

You should see client and server info (no errors).

### DDEV

```powershell
ddev version
```

If it fails, install via Chocolatey (PowerShell as Administrator):

```powershell
choco install ddev -y
```

Then open a new terminal and try `ddev version` again.

---

## 2. Create a project directory

Example:

```powershell
cd C:\Users\Preston\OneDrive\Documents
mkdir Drupal
cd Drupal
```

Adjust the path if you prefer a different location.

---

## 3. Configure DDEV for Drupal 11

From `C:\Users\Preston\OneDrive\Documents\Drupal`:

```powershell
ddev config --project-name=drupal-ddev --project-type=drupal --docroot=web --create-docroot
```

- `--project-name=drupal-ddev`  
  Name for this project (also used in the URL like `https://drupal-ddev.ddev.site`).

- `--project-type=drupal`  
  Tells DDEV this is a Drupal project (it will detect current major = 11 when we install).

- `--docroot=web`  
  The webroot folder inside the project (Drupal’s default for recommended-project).

- `--create-docroot`  
  Creates the `web` folder if it does not already exist.

This command creates a `.ddev` directory with configuration files.

---

## 4. Start the DDEV environment

```powershell
ddev start
```

DDEV will:

- Pull necessary Docker images (first time only)
- Start the web and database containers
- Show you a project URL, e.g.:

```text
Project can be reached at https://drupal-ddev.ddev.site
```

The exact hostname depends on the `--project-name` you used.

You may see a warning about `index.php` not existing yet; that’s expected before we install Drupal.

---

## 5. Install Drupal 11 via Composer *inside* DDEV

Now we populate the project with Drupal 11 code using Composer, but **inside** the DDEV container:

```powershell
ddev composer create-project "drupal/recommended-project:^11" .
```

Notes:

- The trailing `.` means “install into the current directory”.
- This will:
  - Create/confirm the `web/` docroot
  - Add `composer.json`, `composer.lock`, and `vendor/`
  - Populate `web/` with `index.php`, `core/`, `modules/`, `sites/`, `themes/`, etc.

When this finishes, restart DDEV so it picks everything up:

```powershell
ddev restart
```

---

## 6. Run Drupal’s installer in the browser

1. Open the project URL from the `ddev start` output, e.g.:  
   `https://drupal-ddev.ddev.site`

2. You should see the Drupal 11 install screen.
3. Choose **Standard** installation and continue.
4. On the **Database configuration** screen, use DDEV’s defaults:

   - **Database type:** MySQL or MariaDB
   - **Database name:** `db`
   - **Database username:** `db`
   - **Database password:** `db`
   - **Advanced options → Host:** `db`

5. Click **Save and continue** and wait for the installer to complete.

6. Configure the site:

   - Site name (anything you like)
   - Site email (dev-only)
   - Admin username/password (remember this for logging in)

After that, you should land on your new Drupal 11 front page.

---

## 7. Daily usage

From the project root (`C:\Users\Preston\OneDrive\Documents\Drupal`):

- Start containers:

  ```powershell
  ddev start
  ```

- Stop containers:

  ```powershell
  ddev stop
  ```

- Remove containers, DB, etc. (but keep code):

  ```powershell
  ddev delete -Oy
  ```

- Shell inside container:

  ```powershell
  ddev ssh
  ```

- Run Composer inside container:

  ```powershell
  ddev composer install
  ddev composer require drupal/token
  ```

- Drush (once installed through Composer):

  ```powershell
  ddev drush status
  ddev drush cr
  ```

---

## 8. Optional: Simple homepage setup

1. Log into Drupal at `/user/login`.
2. Go to **Content → Add content → Basic page** and create a "Home" page.
3. Go to **Configuration → System → Basic site settings**.
4. Set **Default front page** to the path of your page (e.g. `/home`).
5. Save.

Now you have a minimal local Drupal 11 site running on Docker + DDEV.
