#!/usr/bin/env bash

set -u

failures=0

version_at_least() {
    local actual_version="$1" minimum_version="$2" position actual_part minimum_part
    local -a actual_parts minimum_parts
    IFS=. read -r -a actual_parts <<< "$actual_version"
    IFS=. read -r -a minimum_parts <<< "$minimum_version"
    for position in 0 1 2; do
        actual_part="${actual_parts[$position]:-0}"
        minimum_part="${minimum_parts[$position]:-0}"
        if (( 10#$actual_part > 10#$minimum_part )); then
            return 0
        elif (( 10#$actual_part < 10#$minimum_part )); then
            return 1
        fi
    done
    return 0
}

check_tool() {
    local tool="$1" minimum_version="$2" output actual_version
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'MISSING: %s (minimum %s)\n' "$tool" "$minimum_version"
        failures=$((failures + 1))
        return
    fi
    if ! output=$("$tool" --version 2>&1); then
        printf 'FAIL: %s --version could not run\n' "$tool"
        failures=$((failures + 1))
        return
    fi
    if [[ "$output" =~ ([0-9]+\.[0-9]+(\.[0-9]+)?) ]]; then
        actual_version="${BASH_REMATCH[1]}"
        if version_at_least "$actual_version" "$minimum_version"; then
            printf 'OK: %s %s (minimum %s)\n' "$tool" "$actual_version" "$minimum_version"
        else
            printf 'FAIL: %s %s is below minimum %s\n' "$tool" "$actual_version" "$minimum_version"
            failures=$((failures + 1))
        fi
    else
        printf 'FAIL: cannot determine %s version\n' "$tool"
        failures=$((failures + 1))
    fi
}

check_tool git 2.34.0
check_tool python3 3.10.0
check_tool terraform 1.5.0
check_tool tflint 0.50.0
check_tool ansible 2.16.0
check_tool ansible-lint 24.0.0
check_tool gcloud 450.0.0
check_tool jq 1.6.0

if command -v python3 >/dev/null 2>&1; then
    if python3 -m venv --help >/dev/null 2>&1; then
        printf 'OK: Python venv module loads (environment creation not tested)\n'
    else
        printf 'FAIL: Python venv module cannot load\n'
        failures=$((failures + 1))
    fi
fi

if (( failures > 0 )); then
    printf '\nTool check failed: %s requirement(s) unmet. No tools were installed.\n' "$failures"
    exit 1
fi

printf '\nTool checks passed. Authentication and actual venv creation are not tested.\n'