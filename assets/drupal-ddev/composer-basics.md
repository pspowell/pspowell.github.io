# Composer Basics for Drupal and PHP

Composer is the **package manager for PHP**, similar to:

- `npm` for JavaScript
- `pip` for Python

Modern Drupal (and most serious PHP projects) assume you are using Composer.

---

## What Composer does

### 1. Installs PHP packages (libraries, modules, themes)

Packages live on **Packagist.org**, the main Composer repository.

Example:

```bash
composer require drupal/pathauto
```

This:

- Downloads the `drupal/pathauto` module
- Adds it to `composer.json` under `"require"`
- Updates `composer.lock` with the exact version used

### 2. Manages versions and dependencies

Composer reads `composer.json` and figures out:

- Which versions of each package are allowed
- Requirements like:
  - Minimum PHP version
  - Compatible versions of Symfony, Guzzle, etc.
- Conflicts between packages

It then chooses a compatible set of versions and records them in `composer.lock`.

### 3. Reproducible installs

Two key files:

- `composer.json` — High-level requirements.
- `composer.lock` — Exact versions installed.

Anyone who clones the project and runs:

```bash
composer install
```

gets **the exact same vendor code**, as defined by `composer.lock`.

### 4. Autoloading classes

Composer generates `vendor/autoload.php`, which wires up **PSR-4 autoloading**.

This means no more manual `require`/`include` for each PHP file:

```php
require 'vendor/autoload.php';

// Use classes directly by namespace
use Drupal\Core\Logger\LoggerChannelFactory;
```

---

## Why Drupal uses Composer

In the modern world (Drupal 8+), Composer is used to:

- Download Drupal core (`drupal/recommended-project`)
- Install contrib modules and themes
- Install and manage:
  - Symfony components
  - Guzzle
  - Other PHP libraries Drupal depends on
- Control security and bugfix updates

Example: starting a new Drupal project:

```bash
composer create-project drupal/recommended-project mysite "^11"
```

Inside DDEV, you usually run this as:

```bash
ddev composer create-project "drupal/recommended-project:^11" .
```

---

## Common Composer commands

All of these are typically run **inside** the DDEV container using `ddev composer`:

```bash
# Install dependencies listed in composer.json/composer.lock
composer install

# Add a new package
composer require drupal/token

# Update everything (within version constraints)
composer update

# Update just core (and related deps)
composer update drupal/core --with-all-dependencies
```

With DDEV:

```bash
ddev composer install
ddev composer require drupal/token
ddev composer update drupal/core --with-all-dependencies
```

---

## TL;DR

- Composer is the **dependency manager** for PHP.
- It is essentially required for modern Drupal projects.
- DDEV provides a clean environment to run Composer commands, so you do not have to install PHP/Composer natively on Windows.
