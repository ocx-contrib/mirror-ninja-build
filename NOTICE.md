# NOTICE

This repository packages and redistributes upstream software published by the
[Ninja project](https://github.com/ninja-build/ninja). The Apache-2.0 license
in [`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — the redistributed bytes carry their
own license, recorded below.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `ninja` | `ghcr.io/ocx-contrib/ninja-build/ninja` | `Apache-2.0` |

---

## `ninja`

Upstream: <https://github.com/ninja-build/ninja>
Published to `ghcr.io/ocx-contrib/ninja-build/ninja`.

| Component | SPDX | Holder |
|---|---|---|
| Ninja (`ninja`) | **Apache-2.0** | Copyright 2011 Google Inc. and the Ninja contributors |

Permissive; Apache-2.0 grants redistribution of the compiled binary provided
the license and attribution are preserved. The id is upstream's own —
`gh api repos/ninja-build/ninja/license` answers `Apache-2.0`, matching
<https://github.com/ninja-build/ninja/blob/master/COPYING>. Upstream ships the
bare executable with no bundled license file, so the terms are those of that
file and upstream carries no `NOTICE` file to propagate.

The `logo.svg`/`logo.png` mark in this package is an original OCX-authored
lettermark drawn for catalog identification; it is not the upstream Ninja
project's official artwork. Ninja has no official logo — the maintainers have
declined to adopt one ([ninja-build/ninja#1847](https://github.com/ninja-build/ninja/issues/1847)).
The Ninja name is used for catalog identification under nominative fair use.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
