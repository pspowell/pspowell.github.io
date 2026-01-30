---
layout: post
title: "NTLite Preset Checklist: Windows 11 25H2 (Privacy, No Ads, Minimal Telemetry)"
date: 2026-01-26 22:00:00 -0500
tags: [windows-11, ntlite, privacy, debloat, imaging]
---

This is a **practical, upgrade-safe NTLite checklist** for Windows 11 **25H2** that focuses on:
- **Removing advertising / consumer experience features**
- **Reducing telemetry**
- **Avoiding common “I broke Windows Update / Start / Settings” mistakes**

> ⚠️ **Rule of thumb:** Prefer **Disable** over **Remove** for anything tied to servicing (Windows Update, modern UI dependencies, platform components). Test in a VM before deploying to real hardware.

## Before you start {#before-you-start}

- [ ] Use the latest NTLite version that supports your image build (Windows 11 25H2).
- [ ] Mount and load the correct image index (e.g., Pro vs Home).
- [ ] Decide your goal up front:
  - [ ] **“No Ads / Less Telemetry”** (recommended baseline)
  - [ ] **“No Store / No UWP apps”** (more aggressive; higher break risk)
  - [ ] **“Offline Local Account only”** (Unattended tweaks + policy)

## Baseline safety settings {#baseline-safety-settings}

- [ ] **Keep Windows Update / Servicing Stack intact**
- [ ] **Keep Settings + Start Menu dependencies intact**
- [ ] **Keep WebView2** (many Windows UI surfaces rely on it now)

### Must-keep (do not remove) {#must-keep-do-not-remove}

These are the usual “preset killers” on Windows 11:

- [ ] Windows Update components / servicing
- [ ] Windows Security app + core Defender platform (you can change behavior later via policy)
- [ ] Microsoft Edge **WebView2 Runtime**
- [ ] Search / Shell experience dependencies (unless you knowingly accept a degraded Start/Search)
- [ ] Core networking components (DHCP, DNS client, NLA, etc.)

## Components: remove (recommended / low break risk) {#components-remove-recommended}

### Advertising / consumer features {#advertising-consumer-features}

- [ ] **Content Delivery Manager** (key for suggested/promoted content)
- [ ] **Consumer Experience** (suggested apps / “soft installs”)
- [ ] Windows Spotlight (lock screen / “fun facts” / ad-like content)
- [ ] Tips / “Get tips and suggestions” components (where present)

### Feedback and diagnostic UX {#feedback-and-diagnostic-ux}

- [ ] Feedback Hub
- [ ] Diagnostic Data Viewer
- [ ] “Windows Tips” / “Get Help” apps (optional)

### Preinstalled apps (safe picks) {#preinstalled-apps-safe-picks}

Remove what you don’t use. Common removals:

- [ ] Clipchamp
- [ ] Microsoft News
- [ ] Microsoft Teams (consumer)
- [ ] Xbox app(s) (if you don’t game)
- [ ] Mixed Reality (if not used)
- [ ] People, Movies & TV, etc. (as desired)

> Note: App lists change by build. Favor removing **apps** rather than platform components.

## Components: disable (prefer disable over remove) {#components-disable-prefer-disable}

This reduces telemetry while keeping servicing stable.

### Telemetry & diagnostics services (disable) {#telemetry-diagnostics-services-disable}

- [ ] Connected User Experiences and Telemetry (**DiagTrack**)
- [ ] dmwappushservice
- [ ] Windows Error Reporting (WER) (optional)
- [ ] Program Compatibility Assistant (optional)
- [ ] Retail Demo Service

## Settings tweaks (the “no ads” core) {#settings-tweaks-no-ads-core}

Apply these in NTLite **Settings** (or equivalent policies/registry tweaks):

### Disable ads & suggestions everywhere {#disable-ads-suggestions}

- [ ] Disable **Advertising ID**
- [ ] Disable **Tailored experiences**
- [ ] Disable **Consumer features**
- [ ] Disable **Start menu suggestions / recommendations**
- [ ] Disable **Lock screen Spotlight**
- [ ] Disable “Tips, tricks, and suggestions”

### Privacy defaults {#privacy-defaults}

- [ ] Disable activity history (if shown)
- [ ] Disable inking & typing personalization
- [ ] Disable diagnostic prompts / feedback frequency
- [ ] Set diagnostic data to the lowest available setting for your edition (Home/Pro have limits)

## Unattended (OOBE) settings {#unattended-oobe-settings}

In NTLite **Unattended**:

- [ ] Skip privacy/OOBE prompts where supported
- [ ] Set privacy toggles **OFF** by default
- [ ] Disable “Get tips and suggestions” during setup
- [ ] Configure local account flow (if that’s your goal)
- [ ] Preconfigure region/time/keyboard as needed

> Tip: Many “ads” and “suggestions” reappear when OOBE enables consumer settings. Setting defaults here helps a lot.

## Optional: OneDrive and cloud integration {#optional-onedrive-cloud-integration}

Choose one:

### Keep OneDrive {#keep-onedrive}

- [ ] Leave OneDrive in place
- [ ] Disable OneDrive auto-start / silent sign-in via policy later (recommended for most)

### Remove OneDrive {#remove-onedrive}

- [ ] Remove OneDrive package (if included)
- [ ] Remove OneDrive setup stub(s) (if present)
- [ ] Validate Explorer integration still behaves as expected

## Post-build validation checklist {#post-build-validation-checklist}

After installing your image (VM first), confirm:

- [ ] Windows Update works (check for cumulative updates)
- [ ] Start Menu opens and search behaves as expected
- [ ] Settings app opens and core pages load
- [ ] Microsoft Store behavior matches your intent (installed or removed)
- [ ] Lock screen has no Spotlight/sponsored content
- [ ] No “suggested apps” appear in Start
- [ ] Telemetry services you disabled remain disabled after reboot

## Suggested test plan (fast) {#suggested-test-plan-fast}

- [ ] Install in a VM (Hyper-V / VMware) first
- [ ] Run Windows Update fully
- [ ] Reboot 2–3 times (some components re-enable after first reboot)
- [ ] Snapshot, then try:
  - [ ] Installing a .NET desktop app
  - [ ] Connecting a printer
  - [ ] Joining Wi‑Fi and Ethernet
  - [ ] Optional: domain join / Entra join if you use it

## Notes and guardrails {#notes-and-guardrails}

- Removing “too much” often breaks:
  - Windows Update servicing
  - Modern Settings UI pages
  - Start/Search behavior
  - App installs that rely on modern frameworks
- If your goal is **privacy + stability**, the best results come from:
  - **Removing consumer/ads features**
  - **Disabling telemetry services**
  - **Using policy/settings tweaks**
  - **Keeping core platform dependencies**

---

If you want, tell me what you want to keep/remove (Store? Edge? OneDrive? Widgets?), and I’ll refine this into a **specific NTLite preset profile** aligned to your exact goals.
