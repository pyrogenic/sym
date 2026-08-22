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

`discojs` needs building by hand because `node_modules/discojs` is a symlink to
`packages/discojs`, whose `package.json` points `main`/`module`/`types` at `dist/` — and
`dist/` is gitignored. A fresh clone therefore has the source but no build artifact, so
Elephant can't resolve the package until you've built it. The same applies after any
change to `discojs`: rebuild, or Elephant keeps using the old `dist/`.

Note the build only works on **Node 18–21**, which is why the root `.nvmrc` pins 20 rather
than `lts/*`. See [CLAUDE.md](CLAUDE.md) for that and the other sharp edges.
