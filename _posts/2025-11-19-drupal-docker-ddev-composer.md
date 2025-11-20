---
layout: post
title: "Simple Drupal 11 Site with Docker, DDEV, and Composer"
date: 2025-11-19
tags: [drupal, docker, ddev, composer, php]
---

I wanted a clean way to spin up a **local Drupal 11 site** using modern tools without trashing my Windows install with random PHP, Apache, and MySQL versions. The solution:

- **Docker** for isolated containers  
- **DDEV** for developer-friendly orchestration on top of Docker  
- **Composer** as the PHP package manager that drives modern Drupal

This post is the "hub" that links out to a small set of Markdown assets:

- [Docker vs. DDEV overview](/assets/drupal-ddev/docker-and-ddev-overview.md)
- [Composer basics for Drupal and PHP](/assets/drupal-ddev/composer-basics.md)
- [Step-by-step: Simple Drupal 11 site with DDEV](/assets/drupal-ddev/drupal-ddev-setup.md)
- [DDEV command cheatsheet](/assets/drupal-ddev/ddev-cheatsheet.md)

---

## Big picture

### Docker

Docker gives me **containers**: tiny, isolated environments with their own OS, PHP, webserver, and database. That means:

- No polluting my host with conflicting PHP installs.
- No “it works on my machine” nonsense.
- I can run multiple dev sites without port hell.

(Full write-up: [Docker vs. DDEV overview](/assets/drupal-ddev/docker-and-ddev-overview.md))

### DDEV

DDEV sits on top of Docker and makes it **human-friendly** for web dev:

- `ddev config` to initialize a project
- `ddev start` to bring up web + db + HTTPS
- `ddev ssh` to drop into the container
- Built-in support for Drupal, WordPress, Laravel, etc.

No hand-editing `docker-compose.yml`, no memorizing long `docker` commands.

Again, more detail here:  
[Docker vs. DDEV overview](/assets/drupal-ddev/docker-and-ddev-overview.md)

### Composer

Composer is the **package manager for PHP**, just like:

- `npm` for JavaScript  
- `pip` for Python  

Modern Drupal (including Drupal 11) uses Composer for:

- Installing Drupal core
- Installing contrib modules and themes
- Managing dependencies like Symfony components
- Getting reproducible installs via `composer.lock`

More here:  
[Composer basics for Drupal and PHP](/assets/drupal-ddev/composer-basics.md)

---

## How I spin up a simple Drupal 11 site

Here’s the high-level flow; the full, step-by-step version (with exact commands) lives in:

👉 [Step-by-step: Simple Drupal 11 site with DDEV](/assets/drupal-ddev/drupal-ddev-setup.md)

1. **Create a project folder** (e.g. `C:\Users\Preston\OneDrive\Documents\Drupal`).
2. Run `ddev config` to set project type to `drupal` and docroot to `web`.
3. Run `ddev start` to bring up the containers and get an HTTPS URL.
4. Use `ddev composer create-project "drupal/recommended-project:^11" .`  
   to pull in Drupal 11 with Composer inside the container.
5. Visit the DDEV URL in a browser, run Drupal’s installer, and use the default
   DDEV database credentials (`db`/`db`/host `db`).
6. Optionally, use Drush and other tooling inside the container.

If I forget commands, I have a little crib sheet:

👉 [DDEV command cheatsheet](/assets/drupal-ddev/ddev-cheatsheet.md)

---

## Why bother with this stack?

Short version:

- **Docker** gives me a clean, isolated Linux/PHP/MySQL environment.
- **DDEV** makes that environment easy to configure, start, and share.
- **Composer** keeps Drupal’s dependencies sane and reproducible.

Together, this gives me:

- A Drupal dev site I can nuke and recreate in minutes.
- Config I can commit to Git and share with others.
- Confidence that if it works here, it will work elsewhere.

Check out the linked assets above for the deep dives and copy-pasteable commands.
