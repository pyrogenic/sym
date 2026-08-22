# sym
The **SY**nthetic **M**onorepo for my React/TypeScript projects. Rather than a true monorepo, this is a collection of separate repositories (many of which can be used on their own) unified through a combination of git submodules and Yarn workspaces. This makes it _much_ easier to do something like upgrade the version of React or TypeScript across these related projects.

## Getting Started

- clone the repo
- `cd sym`
- `git submodule update --init --recursive`
- `yarn`

To run Elephant, build `discojs` first, then start Elephant:
- `yarn discojs build`
- `yarn elephant start` (on Windows, `yarn elephant start-rs`)

`discojs` is the only package you have to build yourself. Every other one either commits
its build output (`slide-grid`, `proon`) or rebuilds itself during `yarn` via a
`preinstall` script (`asset`, `memo` and `perl` all run `yarn tsc`). `discojs` does
neither: its `dist/` is gitignored like theirs, but its only install hook is
`prepare: husky`, which sets up git hooks rather than building. Upstream builds it from
`prepublishOnly`, which fires when publishing to npm and so never runs here.

The result is that a fresh clone has the source but no artifact, and since
`packages/discojs/package.json` points `main`/`module`/`types` into `dist/`, Elephant
can't resolve the package at all until you've built it. The same applies after any change
to `discojs` — rebuild, or Elephant silently keeps using the stale `dist/`.

Note the build only works on **Node 18–21**, which is why the root `.nvmrc` pins 20 rather
than `lts/*`. See [CLAUDE.md](CLAUDE.md) for that and the other sharp edges.
