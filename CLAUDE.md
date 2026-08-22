# sym

A "synthetic monorepo": separate GitHub repos joined by **git submodules** + **yarn 1 workspaces**.
Each `packages/*` is its own repository with its own history, remotes and release cadence. See
`README.md` for the pitch; this file is the operational detail.

## Node version — read this first

**The build only works on Node 18–21.** This is the single most likely thing to waste your time.

| Node | result |
|------|--------|
| 16   | ✗ `rollup` 4 requires `>=18` |
| 18   | ✓ builds (blocked by `engines`, see below) |
| 20   | ✓ builds — **this is what `.nvmrc` pins** |
| 22+  | ✗ `browserslist-generator` (via `rollup-plugin-ts`) uses the `assert { type: 'json' }` import syntax removed in Node 22 |

Only `packages/discojs` actually cares — everything else is fine on modern Node — but
`yarn discojs build` runs from the repo root, so it's the **root's** Node that governs the build,
not `packages/discojs/.nvmrc`. That's why root `.nvmrc` says `20` and not `lts/*`: `lts/*` now
resolves past the ceiling.

`discojs/package.json` declares `engines: { node: ">=20.0.0" }`, and **yarn 1 treats that as a hard
error**. Node 18 builds byte-identically in practice, so on an 18-only machine use:

```sh
yarn --ignore-engines discojs build
```

On macOS this repo uses [fnm](https://github.com/Schniz/fnm), which reads `.nvmrc` and switches on
`cd`. Note **nvm-windows ignores `.nvmrc` entirely** — on Windows the active version is whatever
was last `nvm use`d, and it persists globally.

## Running things

```sh
git submodule update --init --recursive
yarn                      # root install; hoists across all workspaces
yarn discojs build        # REQUIRED before Elephant will run — see below
yarn elephant start        # dev server on :3000/elephant
```

**On Windows use `yarn elephant start-rs` instead.** `start` is
`FORCE_COLOR=true yarn start-rs | cat`, and the inline env-var prefix is a shell-ism cmd
doesn't understand. `start-rs` is the same thing without it.

Root `package.json` defines a shortcut per package (`yarn elephant …` → `yarn workspace
@pyrogenic/elephant …`).

### Why discojs must be built by hand

`node_modules/discojs` is a symlink to `packages/discojs`, and its `package.json` points `main` /
`module` / `types` at **`dist/`, which is gitignored**. So a fresh clone has the source but no
build artifact, and Elephant fails to resolve the package until `yarn discojs build` has run. Any
change to discojs also needs a rebuild before Elephant sees it.

(Output moved `lib/` → `dist/` when we moved onto upstream 2.3.1 — old notes may say `lib/`.)

## Root `resolutions` are load-bearing

Root `package.json` flattens versions across every workspace. Two matter constantly:

- **`**/typescript: ~4.6.4`** — every package builds with TS 4.6.4 regardless of its own
  declaration. discojs declares `^5.5.4` but builds byte-identically under 4.6.4, so this is fine;
  don't "fix" it casually.
- **`**/jest: 27.4.3`** — discojs declares jest 29. Tests run under **27** in-tree. Anything
  relying on jest-29-only behaviour, or on Node globals that jest 27's sandbox doesn't expose
  (e.g. `Headers`), will pass in a standalone checkout and fail here.

Upgrading TypeScript repo-wide is **not** a small change: `toed`, `spelling-sea` and `testbed` are
still on **react-scripts 4.0.3**, which can't take TS 5 (its `eslint-config-react-app` pins
`@typescript-eslint@^4` — the other root resolution). `elephant` and `scooch` are on
react-scripts 5.0.1. Any TS modernisation has to deal with CRA 4 first.

react-scripts 4 also breaks on Node 17+ (`ERR_OSSL_EVP_UNSUPPORTED`, webpack 4 + OpenSSL 3), and
none of those packages carry an `--openssl-legacy-provider` workaround.

## Submodules

Submodules normally sit at a **detached HEAD** pinned by the superproject — that's expected, not
breakage. `.gitmodules` records which branch each tracks. Commit inside the submodule first, then
commit the moved pointer in `sym`.

**Push the submodule before committing its pointer.** A pointer to an unpushed commit makes
`git submodule update` fail on every other machine.

### packages/discojs is a fork

- `origin` → `github.com/pyrogenic/discojs` (our fork)
- `upstream` → `github.com/aknorw/discojs`
- tracked branch: **`sym`** = upstream `master` (2.3.1) + local fixes

Fixes intended for upstream are kept as separate branches based directly on `aknorw/master`, so
they stay independently mergeable — don't base them on `sym`. Keep the fork close to upstream:
prefer changes in `sym`-the-monorepo over divergence in the fork.

## Packages

Actively worked on: **elephant** (Discogs collection/store manager, CRA 5, mobx), **discojs**
(forked Discogs API client). Also present: asset, memo, perl, proon, scooch, slide-grid(+demo),
spelling-sea, testbed, toed, jsonpath — several are dormant and on much older toolchains.

## Machines

Developed across a Mac (arm64) and an older x86-64 Windows box, so **cross-platform matters** —
avoid shell-isms in npm scripts, prefer `cross-env`, quote globs with `"` not `'`.
