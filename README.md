# Git History Viewer — Cribl App

View, filter and export commit history inside Cribl:

- **Cribl (this org)** — config commit history for every Stream and Edge worker group, with per-commit diffs.
- **GitHub** — commits, branches and file changes for a repository you configure.

## Layout

The repo root is the installable package, so it also works with **App Platform → Add App → Import from Git**.

```
package.json            app id, display name, version
default/proxies.yml     external domains the app may call (api.github.com)
default/policies.yml    Cribl API paths the app reads (GET only)
static/                 prebuilt UI (index.html + hashed assets)
scripts/package.sh      builds dist/<name>-<version>.tgz
dist/                   build output (git-ignored)
```

## Install

1. Download `git-history-viewer-<version>.tgz` from the [latest release](https://github.com/dmaislin-cribl/git-history-viewer/releases/latest).
2. In Cribl, go to **App Platform → Add App → Upload** and select the `.tgz`.

## Build and release

```bash
npm run package        # or: bash scripts/package.sh → dist/git-history-viewer-<version>.tgz
```

To publish, bump `version` in `package.json`, commit, then:

```bash
gh release create v<version> dist/git-history-viewer-<version>.tgz --title "v<version>" --notes "..."
```

## Configure

Open the app, click **Settings**:

- **Cribl** needs nothing. It uses the signed-in user's access to `/master/groups`, `/products/edge/groups` and `/m/:gid/version*`.
- **GitHub**: enter owner, repo, branch and a PAT (`repo` scope for private repos). The token is stored encrypted in the app's KV store as `githubToken` and injected server-side by the proxy; the browser never reads it back.

## Source code

The React/Vite source is **not in this repo** — only the compiled bundle in `static/`. Changes in 0.8.1 were patched directly into the bundle:

- GitHub calls went to `/proxy/https/api.github.com/…`; the platform route is `/proxy/<domain>/…`.
- `proxies.yml` was rewritten to the platform schema (domain keys, `headers.inject` expressions, timeout in ms, path allowlist).
- KV writes now use `Content-Type: text/plain`, and the encrypted token is stored raw so `kv.githubToken` injects cleanly.
- The GitLab option was removed: it had no implementation and called the GitHub API.
- `policies.yml` now declares the Cribl endpoints the app uses.

Commit the original source here before making further changes.
