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
# copies a source file the test wrote to a declared output; ninja must parse the
# manifest, schedule the edge and spawn the command for that output to exist. A
# stub that merely exits 0 leaves `token.txt` absent and reds below.
#
# A COPY, not a shell redirect. The previous spelling used
# `echo OCXSMOKE>token.txt`, chosen to behave the same under /bin/sh and
# cmd.exe — it did not: both Windows legs built green yet produced no file, so
# `ocx.exists` reded while `expect.ok` passed. Copying sidesteps shell quoting
# and redirection entirely; the command differs per platform because there is no
# single spelling that copies on both.
TOKEN = "OCXSMOKE"
ocx.write_file("source.txt", TOKEN + "\n")

COPY = "cmd /c copy /y $in $out" if ocx.target_platform.os == ocx.os.Windows else "cp $in $out"
ocx.write_file(
    "build.ninja",
    "rule gen\n  command = " + COPY + "\nbuild token.txt: gen source.txt\n",
)

r_build = ocx.run(NINJA, "token.txt")
expect.ok(r_build)
expect.true(ocx.exists("token.txt"))
expect.contains(ocx.read_file("token.txt"), TOKEN)

# Tier 4: PATH is the only env var this package declares, and Tier 1 already
# proved it — `ninja` resolved by bare name. Nothing further to wire.
