# DDEV Command Cheatsheet

Quick reference for common DDEV commands for a Drupal project.

---

## Project lifecycle

```bash
# Initialize config (run once per project)
ddev config --project-name=myproj --project-type=drupal --docroot=web --create-docroot

# Start containers
ddev start

# Stop containers (project stays on disk)
ddev stop

# Restart containers
ddev restart

# Delete containers and database (keep code)
ddev delete -Oy
```

---

## Working inside the container

```bash
# Shell into the web container
ddev ssh

# Run Composer inside the container
ddev composer install
ddev composer require drupal/token
ddev composer update

# Run Drush inside the container (once installed)
ddev drush status
ddev drush cr
ddev drush uli
```

---

## Database helpers

```bash
# Open DB in a GUI (depends on your OS/tools)
ddev sequel

# Export database
ddev export-db --file=./db.sql.gz

# Import database
ddev import-db --src=./db.sql.gz
```

---

## Snapshots

```bash
# Create a named snapshot
ddev snapshot --name=before-update

# List snapshots
ddev snapshot list

# Restore a snapshot
ddev snapshot restore before-update
```

---

## URLs and info

```bash
# Show project info, including URLs
ddev describe
```

Watch for lines like:

```text
https://myproj.ddev.site
```

which is the main HTTPS URL for your local site.
