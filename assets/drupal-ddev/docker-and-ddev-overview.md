# Docker and DDEV: What They Bring to the Party

## Docker

Docker provides **containers**, which are lightweight, isolated environments for running applications.

### Key benefits

- **Identical environment every time**
  - Same OS layer
  - Same PHP version and extensions
  - Same webserver configuration
  - Same database engine and settings

- **Isolation from the host**
  - No polluting Windows with multiple PHP/MySQL installs
  - Docker containers hold:
    - PHP
    - Apache/Nginx
    - MariaDB/MySQL
    - Extra services (Redis, Solr, etc.)

- **Reproducibility**
  - Container images are versioned and repeatable
  - Move the project to another machine → same environment

- **Service separation**
  - One container for web
  - One container for database
  - Optional containers for extras (Redis, Solr, Mailpit, etc.)

---

## DDEV

DDEV is a **developer tool** that uses Docker under the hood but hides most of the complexity behind simple commands.

Instead of:
- Writing `docker-compose.yml` by hand
- Fighting with ports
- Remembering long `docker run` or `docker exec` commands

You use a small set of **friendly commands**.

### What DDEV does for web dev

- Creates and manages Docker containers for:
  - Web server + PHP
  - Database
  - Optional extra services
- Knows about common project types:
  - `drupal`, `drupal11`, `wordpress`, `laravel`, `typo3`, `craftcms`, etc.
- Automatically:
  - Sets up document root
  - Configures vhosts and HTTPS
  - Exposes a single project URL (e.g. `https://myproj.ddev.site`)

### Core commands

- `ddev config`  
  Set up the project (project name, type, docroot).

- `ddev start` / `ddev stop` / `ddev restart`  
  Bring the containers up and down.

- `ddev ssh`  
  Shell inside the web container.

- `ddev composer ...`  
  Run Composer inside the container.

- `ddev drush ...` (once Drush is installed)  
  Run Drupal CLI commands inside the container.

### Nice extras

- **Automatic HTTPS** with trusted certs for `*.ddev.site`
- **Multiple projects** at once without port conflicts
- **Snapshots** for quick database backups:
  - `ddev snapshot --name=before-update`
  - `ddev snapshot restore before-update`
- **Team-friendly configs**:
  - `.ddev/` directory can be committed to git
  - Everyone gets the same environment by running `ddev start`

---

## How they fit together

- Docker is the **engine** that actually runs containers.
- DDEV is the **driver’s seat and dashboard** that makes containers easy to control.

You rarely talk to `docker` directly when using DDEV; you let DDEV handle it.
