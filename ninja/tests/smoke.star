# ninja/tests/smoke.star — stable across upstream releases.
# Assert on the contract (exit code, version shape, computed result), never on
# help/version prose. Ninja's banner, status lines and help text are upstream's
# to reword; the version digits and the bytes a build actually produces are the
# contract.
NINJA = "ninja.exe" if ocx.target_platform.os == ocx.os.Windows else "ninja"

# Tier 1 + 2: liveness + version SHAPE (ninja prints a bare semver to stdout).
r_version = ocx.run(NINJA, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: a real build, checked by its OUTPUT rather than its log. The rule
# writes a token to a declared output file; ninja must parse the manifest,
# schedule the edge and spawn the command for that file to exist. A stub that
# merely exits 0 leaves `token.txt` absent and reds on the read below.
#
# `echo OCXSMOKE>token.txt` — no space before `>` — is the one spelling that
# behaves identically under /bin/sh and cmd.exe (cmd would otherwise fold the
# space into the file, and a value ending in a digit would be read as a redirect
# handle; "OCXSMOKE" ends in a letter). The trailing newline differs per
# platform, hence `contains`, not `eq`.
TOKEN = "OCXSMOKE"
ocx.write_file(
    "build.ninja",
    "rule gen\n  command = echo " + TOKEN + ">token.txt\nbuild token.txt: gen\n",
)

r_build = ocx.run(NINJA, "token.txt")
expect.ok(r_build)
expect.true(ocx.exists("token.txt"))
expect.contains(ocx.read_file("token.txt"), TOKEN)

# Tier 4: PATH is the only env var this package declares, and Tier 1 already
# proved it — `ninja` resolved by bare name. Nothing further to wire.
