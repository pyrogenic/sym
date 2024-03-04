# sym
The **SY**nthetic **M**onorepo for my React/TypeScript projects. Rather than a true monorepo, this is a collection of separate repositories (many of which can be used on their own) unified through a combination of git submodules and Yarn workspaces. This makes it _much_ easier to do something like upgrade the version of React or TypeScript across these related projects.

## Getting Started

- clone the repo
- `cd sym`
- `git submodule update --init --recursive`
- `yarn`

To run Elephant, for some reason you need to build `discojs` manually, then you can start Elephant:
- `yarn discojs build`
- `yarn elephant start`
