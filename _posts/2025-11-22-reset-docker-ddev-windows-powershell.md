---
layout: post
title: "How to Safely Reset Docker and DDEV on Windows (PowerShell-Friendly)"
date: 2025-11-22
tags: [docker, ddev, windows, powershell, webdev]
---

When you’re first learning Docker and DDEV, it’s really common to get into a weird state and think, *“I wish I could just start over without breaking anything.”*  

This guide shows you how to safely “reset”:

- Docker Desktop  
- DDEV (per project and globally)

…using **Windows PowerShell–friendly commands**, plus how to use Docker Desktop’s **Troubleshoot / Reset** options.

The goal: a clean slate **without** damaging your Windows system or “core” Docker/DDEV install.

---

## Mental Model: What We’re Resetting (and Not Touching)

**Docker Desktop** manages:

- Containers (running apps)
- Images (templates for containers)
- Volumes (persistent data: databases, caches, etc.)
- Networks (how containers talk to each other)

**DDEV** is a wrapper around Docker that:

- Lives in your project folder (mainly `.ddev/`)
- Spins up and tears down Docker containers for you
- Never needs registry hacks or manual OS-level cleanup

In this guide we reset **data and configs**, not **system binaries**:

- ✅ Safe to delete: containers, images, volumes, networks, `.ddev` folders  
- 🚫 Do **not** randomly delete: `C:\ProgramData\Docker`, WSL distros, or registry entries

---

## Part 1 – Soft-Reset Docker with PowerShell (Recommended)

This clears out **everything Docker has created** (containers / images / volumes / networks), but **does not uninstall Docker Desktop**.

All commands below are **PowerShell-friendly**.

### 1. Stop all running containers

    docker ps -q | ForEach-Object { docker stop $_ }

- **What:** Lists all running container IDs and stops each one.  
- **Why:** You can’t remove a running container; this freezes everything in place.

---

### 2. Remove all containers

    docker ps -aq | ForEach-Object { docker rm $_ }

- **What:** Lists *all* containers (running or stopped) and removes them.  
- **Why:** This wipes container runtime state so you’re not dragging old projects along.

---

### 3. Remove all images

    docker images -q | ForEach-Object { docker rmi -f $_ }

- **What:** Gets every image ID and force-removes it.  
- **Why:** Images are container templates; clearing them returns Docker to a nearly empty “just installed” feel.

---

### 4. Remove all volumes

    docker volume ls -q | ForEach-Object { docker volume rm $_ }

- **What:** Deletes every Docker-managed volume.  
- **Why:** Volumes hold persistent data (MySQL DBs, caches, etc.). Wiping them ensures there’s no leftover DDEV or project data hiding.

---

### 5. Remove unused networks

    docker network prune -f

- **What:** Deletes networks that are no longer used by any container.  
- **Why:** Cleans up old project networks and weird leftovers that can cause confusion.

---

### Result of the Soft Reset

After steps 1–5:

- No containers  
- No images  
- No user-created volumes  
- No stale networks  

Docker Desktop itself is still installed and healthy; you just removed its “stuff.”

---

## Part 2 – Using Docker Desktop’s Troubleshoot / Reset UI

If you prefer clicking over typing—or want a one-click “big reset”—you can use Docker Desktop’s built-in Troubleshoot / Reset area.

### 2.1 Finding “Troubleshoot” in Docker Desktop

Depending on your Docker Desktop version, you may **not** see “Settings → Troubleshooting” exactly as described in some docs. Here’s how to find it on Windows:

1. **Via the system tray (whale icon)**  
   - In the bottom-right tray, find the **Docker whale** icon.  
   - Right-click it.  
   - Look for a menu item named **Troubleshoot**.  
   - If it’s not there directly, click **Dashboard** to open the main Docker window.

2. **Inside Docker Desktop (Dashboard window)**  
   - Open **Docker Desktop** from the Start menu or tray.  
   - In the top/right area of the window, look for an icon labeled **Troubleshoot** (often a life preserver, wrench, or bug icon).  
   - Some versions put Troubleshoot directly in the top bar; others tuck it into a sidebar or menu.

3. **Within Settings (some versions)**  
   - In some Docker Desktop builds, you open **Settings** (gear icon).  
   - Then look for a **Troubleshoot** or **Troubleshooting** section/page.

Docker’s UI has shifted a bit between versions, but the keywords to look for are **“Troubleshoot”**, **“Clean / Purge data”**, and **“Reset to factory defaults.”**

---

### 2.2 The Important Buttons

Inside the Troubleshoot / Reset area you typically find:

- **Clean / Purge data**  
  - **What:** Deletes containers, images, volumes, and other runtime data Docker has created.  
  - **Why:** GUI equivalent of the command-line cleanup; good when you want a fresh Docker environment without changing Docker’s configuration.

- **Reset to factory defaults**  
  - **What:** Resets Docker Desktop settings back to install-time defaults, and often clears data as well.  
  - **Why:** Use when Docker is misconfigured or flaky and you want Docker Desktop itself to behave as if just installed.

Both options:

- ✅ Leave Docker Desktop itself installed  
- ✅ Do **not** break Windows or remove system components  
- ⚠️ Will remove all your current containers, images, etc.

---

## Part 3 – Resetting DDEV (Per-Project and Global)

DDEV is safer to “reset” than you might think because:

- DDEV config for each project lives in a `.ddev` folder **inside that project**  
- DDEV’s global bits are just Docker resources and some simple settings  

You basically never need to “repair” DDEV at an OS level; you just clear its containers/volumes and delete `.ddev` when needed.

---

### 3.1 Project-Level DDEV Reset (One Site Only)

Use this when *one particular project* is messed up and you want to start fresh.

Run these **inside the project directory** (where `.ddev` exists).

#### 1. Stop the project and unlist it

    ddev stop --unlist

- **What:** Stops that project’s containers and removes it from `ddev list`.  
- **Why:** Avoids ghost entries and ensures DDEV no longer tracks it as an active project.

---

#### 2. Power off DDEV infrastructure

    ddev poweroff

- **What:** Stops global DDEV containers (router, bind mounts, etc.).  
- **Why:** Ensures DDEV has nothing running that might hold onto volumes or ports.

---

#### 3. Remove the project’s `.ddev` config folder

    Remove-Item -Recurse -Force .ddev

- **What:** Deletes the `.ddev` directory for this project.  
- **Why:** This directory holds project-specific DDEV config and metadata.  
- **Safe because:** It is local to your project. DDEV will recreate it from scratch.

---

#### 4. Reinitialize DDEV for this project

    ddev config
    ddev start

- **What:**  
  - `ddev config` guides you through setting up project type, docroot, etc.  
  - `ddev start` builds and runs fresh containers.  
- **Why:** Gives you a brand-new DDEV environment for that project.

---

### 3.2 Global DDEV Reset (All Projects)

Use this when you want to wipe all DDEV-managed containers and volumes on the machine, but **keep your project files**.

#### 1. Delete all DDEV projects’ containers and volumes

    ddev delete --all --omit-snapshot

- **What:** Removes all containers and volumes for every DDEV project.  
- **Why:** Clears all DDEV databases, caches, and runtime data.  
- **Safe:** Your Git repos / project code stay untouched on disk.

---

#### 2. Turn off all DDEV infrastructure

    ddev poweroff

- **What:** Shuts down DDEV’s global router and support containers.  
- **Why:** Leaves DDEV in a fully “off” state, ready to be cleanly restarted.

---

## Part 4 – Verifying That You’re Clean

It’s always nice to confirm that everything really is “back to zero.”

### Docker checks

    docker ps -a
    docker images
    docker volume ls

- **What:** Show containers, images, and volumes.  
- **Expected:** After a thorough cleanup, these should be empty or nearly empty.

### DDEV check

    ddev list

- **Expected:**  
  - After `ddev delete --all --omit-snapshot`, you should see no active projects.  
  - After `ddev poweroff`, no projects should be running.

---

## Part 5 – One-Shot “Nuke It and Start Fresh” Combo

If your goal is simply:

> “Blow away all DDEV stuff and all Docker data so I can start completely fresh.”

…then this is the compact, idiomatic sequence:

    # Stop and clear all DDEV stuff
    ddev poweroff
    ddev delete --all --omit-snapshot

    # Clean Docker: containers, images, volumes, networks, build cache
    docker system prune -a --volumes -f

- **`ddev poweroff`** – stops DDEV’s global containers  
- **`ddev delete --all --omit-snapshot`** – deletes all DDEV project containers/volumes  
- **`docker system prune -a --volumes -f`** – clears:
  - All stopped containers  
  - All unused images  
  - All unused networks  
  - All dangling build cache  
  - All Docker volumes  

Result: a machine that’s effectively “Day 1” again for Docker + DDEV, but with your **actual project folders and source code still sitting safely on disk**.

---

## Safety Recap

- You **don’t** need to reinstall Docker Desktop or DDEV to fix most problems.  
- You **don’t** need to touch Windows system folders or the registry.  
- Resetting via:
  - PowerShell commands  
  - Docker Desktop’s **Troubleshoot / Clean / Reset** UI  
  - DDEV’s own `delete` / `poweroff` / `.ddev` folder  

…is fully supported, repeatable, and safe.

Once you’re comfortable with this reset flow, Docker + DDEV become a lot less scary: worst case, you just wipe the sandbox and rebuild it.
