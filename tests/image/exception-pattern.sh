#!/usr/bin/env bash
# Pattern-scoped exceptions (patches/0001). One file, two lint suppressions,
# one exception whose `pattern` names only the first: the second must still be
# reported. Stock v0.16.5 drops `pattern` and suppresses both, which is the bug
# this guards against coming back on an UPSTREAM_VERSION bump.
# Runs INSIDE the image (sdlc `exception-pattern` check).
set -euo pipefail

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
cat > "$fixture/app.py" <<'PY'
import os  # noqa: F401


def add(a, b):
    return a + b  # type: ignore[operator]
PY
printf '[project]\nname = "fixture"\nversion = "0.1.0"\n' > "$fixture/pyproject.toml"
printf '.gourmand-cache/\n' > "$fixture/.gitignore"
# Gourmand reads gourmand-exceptions.toml only from a project that has a
# gourmand.toml; without one the exception is never loaded and both findings
# fire whatever the matcher does.
printf '# Gourmand Configuration\n' > "$fixture/gourmand.toml"
cat > "$fixture/gourmand-exceptions.toml" <<'TOML'
[[exceptions]]
check = "EV001-lint_suppression"
path = "app.py"
pattern = "noqa: F401"
justification = "Re-export kept for the public import path"
classification = "by_design"
TOML

# `check` exits 1 when it reports a finding, which this test expects to happen.
status=0
report="$(gourmand check --full --filter EV001 --format json "$fixture")" || status=$?
if [ "$status" -gt 1 ]; then
    echo "exception pattern: gourmand exited $status" >&2
    exit "$status"
fi

if grep -q 'noqa: F401' <<<"$report"; then
    echo "exception pattern: the finding the pattern names was not suppressed" >&2
    exit 1
fi
if ! grep -q 'type: ignore\[operator\]' <<<"$report"; then
    echo "exception pattern: a finding the pattern does not name was suppressed" >&2
    exit 1
fi
echo "gourmand exception pattern: ok"
