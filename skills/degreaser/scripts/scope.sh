#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' 'Usage: bash scope.sh REPOSITORY worktree|repository' \
    '       bash scope.sh REPOSITORY branch BASE'
}

if [[ ${1-} == --help ]]; then usage; exit 0; fi
if [[ $# -lt 2 || $# -gt 3 ]]; then usage >&2; exit 2; fi
repo=$1
mode=$2
case "$mode:$#" in
  worktree:2|repository:2|branch:3) ;;
  *) usage >&2; exit 2 ;;
esac
if [[ -n ${GIT_INDEX_FILE-}${GIT_DIR-}${GIT_WORK_TREE-} ]]; then
  printf '%s\n' 'Unset GIT_INDEX_FILE, GIT_DIR and GIT_WORK_TREE before capturing scope.' >&2
  exit 2
fi

cd "$repo"
root=$(git rev-parse --show-toplevel)
cd "$root"
root=$(pwd -P)
head=$(git rev-parse --verify HEAD)
sparse=$(git config --bool --get core.sparseCheckout || test "$?" = 1)
if [[ $sparse == true ]]; then
  printf '%s\n' 'Sparse checkouts require manual scope collection.' >&2
  exit 2
fi
base=$head
if [[ $mode == branch ]]; then
  base_ref=$(git rev-parse --verify --end-of-options "$3^{commit}")
  base=$(git merge-base "$head" "$base_ref")
fi

umask 077
evidence=$(mktemp -d "${TMPDIR:-/tmp}/degreaser-scope.XXXXXXXX")
success=false
cleanup() {
  rm -f "$evidence/index" "$evidence/index.lock" "$evidence/tracked.z" "$evidence/conflicts.z"
  if [[ $success == false ]]; then rm -rf "$evidence"; fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
evidence=$(cd "$evidence" && pwd -P)
case "$evidence/" in
  "$root/"*)
    printf '%s\n' 'TMPDIR must be outside the repository being reviewed.' >&2
    exit 2
    ;;
esac

git ls-files --unmerged -z > "$evidence/conflicts.z"
if [[ -s $evidence/conflicts.z ]]; then
  printf '%s\n' 'Resolve index conflicts before capturing scope.' >&2
  exit 2
fi
index=$(git rev-parse --git-path index)
if [[ -f $index ]]; then cp "$index" "$evidence/index"; fi
export GIT_INDEX_FILE="$evidence/index"
git -c core.fsmonitor=false update-index --no-split-index
git ls-files --cached -z > "$evidence/tracked.z"
git update-index --no-assume-unchanged -z --stdin < "$evidence/tracked.z"
git update-index --no-skip-worktree -z --stdin < "$evidence/tracked.z"
git -c core.fsmonitor=false add --all -- .
tree=$(git write-tree)

if [[ $mode == repository ]]; then
  base=none
  git ls-tree -r --name-only -z "$tree" > "$evidence/paths.z"
  git -c core.quotePath=true ls-tree -r --name-only "$tree" > "$evidence/paths.txt"
else
  git diff --no-ext-diff --no-textconv --no-renames --ignore-submodules=none --name-only -z "$base" "$tree" -- > "$evidence/paths.z"
  git -c core.quotePath=true diff --no-ext-diff --no-textconv --no-renames --ignore-submodules=none --name-only "$base" "$tree" -- > "$evidence/paths.txt"
  git -c core.quotePath=true diff --no-ext-diff --no-textconv --no-renames --ignore-submodules=none --submodule=short --no-color "$base" "$tree" -- > "$evidence/patch.diff"
fi
printf 'root: %s\nmode: %s\nhead: %s\nbase: %s\ntree: %s\n' \
  "$root" "$mode" "$head" "$base" "$tree" > "$evidence/scope.txt"
success=true
printf '%s\n' "$evidence"
