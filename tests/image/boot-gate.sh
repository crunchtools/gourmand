#!/usr/bin/env bash
# Boot gate for the gourmand image; runs INSIDE it (sdlc `boot-gate` check).
# Fails when the binary does not start or cannot analyse a project, which is
# what every consumer (the fleet Gourmand gate, python-sdlc) does with it:
# `check --full` over a clean, minimal project must exit 0.
set -euo pipefail

gourmand --version

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
printf 'def add(a, b):\n    return a + b\n' > "$fixture/app.py"
cat > "$fixture/pyproject.toml" <<'TOML'
[project]
name = "fixture"
version = "0.1.0"

[tool.ruff.lint]
select = ["E", "F", "W", "C90"]

[tool.ruff.lint.mccabe]
max-complexity = 10
TOML
printf '.gourmand-cache/\n' > "$fixture/.gitignore"
cat > "$fixture/.pre-commit-config.yaml" <<'YAML'
repos:
  - repo: local
    hooks:
      - id: ruff-check
        name: ruff
        entry: ruff check --fix
        language: system
        files: \.py$
        stages: [pre-commit, pre-merge-commit]
YAML
gourmand check --full "$fixture" >/dev/null
echo "gourmand boot gate: ok"
