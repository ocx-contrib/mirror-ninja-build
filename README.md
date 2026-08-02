# mirror-ninja-build

OCX mirror for [Ninja](https://github.com/ninja-build/ninja). One repository,
one spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [ninja](https://github.com/ninja-build/ninja) | [`ninja/mirror.yml`](ninja/mirror.yml) | `ghcr.io/ocx-contrib/ninja-build/ninja` | `ocx.sh/ninja-build/ninja` | `Apache-2.0` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/ninja`, as `mirror-ninja`. `ninja-build/ninja` is the grouped
> successor — the namespace is upstream's GitHub owner, which for Ninja is the
> project org rather than a personal handle.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
ninja/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

`ninja` publishes six platform entries: both Linux arches, both macOS arches
and both Windows arches. `ninja-mac.zip` is a Mach-O universal binary, so the
same asset backs both darwin keys.

Both Linux keys carry **`+libc.glibc`**. `os.features` states what an artifact
requires *of the host*, and upstream's Linux `ninja` is dynamically linked:
measured on v1.13.2 it carries a `PT_INTERP` naming the glibc loader
(`/lib64/ld-linux-x86-64.so.2` on amd64, `/lib/ld-linux-aarch64.so.1` on arm64)
plus `libstdc++`, `libm`, `libc` and `libgcc_s`. That is a hard host
requirement, so the bare keys this repo shipped before were a false claim of
libc universality — an empty `os.features` list means "demands nothing", which
matches musl hosts the binary cannot load on. Running the real amd64 binary
under `alpine:3.20` fails with `exec: no such file or directory` — the kernel
not finding the glibc loader. Upstream publishes **no musl or static asset**,
so there is no `+libc.musl` counterpart; the glibc keys are the entire Linux
surface. The measurement itself is recorded above the `assets:` block in
`ninja/mirror.yml`.

Container legs follow from the claim: `ubuntu:24.04` + `fedora:40` on each
Linux key, and **no alpine** — the renderer rejects an alpine leg on a glibc
key, and a glibc-linked binary genuinely cannot run there. The non-base
`DT_NEEDED`s are `libstdc++.so.6` and `libgcc_s.so.1`, both present in both
images, so neither leg installs anything.

The version floor is `1.12.0` — the first release carrying
`ninja-linux-aarch64.zip` and `ninja-winarm64.zip`. Below it two of the six
patterns match nothing, and a pattern matching zero is *silently skipped*, so
the run would publish four platforms and stay green.

## The binaries claim

Ninja ships as a bare `ninja` at the zip root — one file, no wrapper directory
— so the bundle's only PATH entry is a bare `${installPath}`: the executable
*is* the content root. `bin_scan` only looks *below* an `${installPath}/<dir>`
entry, so `auto`/`verify` is rejected at spec load with exit 65.
`mirror-base.yml` therefore sets `bin_scan: off` and `ninja/metadata.json`
hand-lists `binaries: ["ninja"]` — the blessed shape for this asset layout.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `ninja/mirror.yml` | hand | yes — see below |
| `ninja/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `ninja/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec ninja/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; the
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md).
