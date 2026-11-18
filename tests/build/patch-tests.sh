#!/bin/sh
# Run the carried patches' tests (every one is named pattern_scoped_*) in the
# builder stage. A filter that matches nothing passes with "0 passed", which is
# what would happen if a patch were dropped and its tests went with it, so
# each test binary must report at least one pass and all four must report.
set -eu
log="$(mktemp)"
trap 'rm -f "$log"' EXIT

export CARGO_PROFILE_TEST_DEBUG=0
cargo test --locked --lib -j 2 --manifest-path gourmand/Cargo.toml \
    -p gourmand-core -p gourmand-checks -- pattern_scoped >>"$log" 2>&1 \
    || { cat "$log"; exit 1; }
cargo test --locked -j 2 --manifest-path gourmand/Cargo.toml \
    -p gourmand --bin gourmand --test migrate_format -- pattern_scoped >>"$log" 2>&1 \
    || { cat "$log"; exit 1; }
cat "$log"

results="$(grep -c '^test result: ok\.' "$log" || true)"
empty="$(grep -c '^test result: ok\. 0 passed' "$log" || true)"
if [ "$results" -ne 4 ] || [ "$empty" -ne 0 ]; then
    echo "patch tests: expected 4 test binaries each passing at least one pattern_scoped test; got $results results, $empty empty" >&2
    exit 1
fi
