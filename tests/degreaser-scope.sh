#!/usr/bin/env bash
set -eo pipefail

script=$(cd "$(dirname "$0")/../skills/degreaser/scripts" && pwd)/scope.sh
scratch=$(mktemp -d "${TMPDIR:-/tmp}/degreaser-test.XXXXXXXX")
trap 'rm -rf "$scratch"' EXIT
export TMPDIR="$scratch"
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
equal() { [[ $1 == "$2" ]] || fail "$3: expected [$2], got [$1]"; }
field() { awk -v key="$2:" '$1 == key { print $2 }' "$1/scope.txt"; }
capture() { evidence=$(bash "$script" "$repo" "$@"); }
reject() {
  local status=0
  bash "$script" "$repo" "$@" > "$scratch/rejected.out" 2> "$scratch/rejected.err" || status=$?
  [[ $status != 0 ]] || fail "accepted invalid scope: $*"
  [[ ! -s $scratch/rejected.out ]] || fail "failure published evidence"
}
new_repo() {
  repo="$scratch/$1"
  git init --quiet "$repo"
  printf 'base\n' > "$repo/tracked.txt"
  printf 'delete me\n' > "$repo/deleted.txt"
  printf 'hidden base\n' > "$repo/hidden.txt"
  printf '*.ignored\n' > "$repo/.gitignore"
  git -C "$repo" add .
  git -C "$repo" commit --quiet -m 'Create test baseline'
}

new_repo mixed
printf 'staged\n' > "$repo/tracked.txt"
git -C "$repo" add tracked.txt
printf 'final\n' > "$repo/tracked.txt"
git -C "$repo" update-index --assume-unchanged tracked.txt
git -C "$repo" update-index --skip-worktree hidden.txt
printf 'hidden final\n' > "$repo/hidden.txt"
printf 'new\n' > "$repo/new.txt"
git -C "$repo" add -N new.txt
printf 'staged ignored\n' > "$repo/staged.ignored"
git -C "$repo" add -f staged.ignored
printf 'final ignored\n' > "$repo/staged.ignored"
printf 'excluded\n' > "$repo/untracked.ignored"
odd=$'space\nname.txt'
printf 'odd\n' > "$repo/$odd"
printf 'outside secret\n' > "$scratch/outside"
ln -s "$scratch/outside" "$repo/link"
rm "$repo/deleted.txt"
cp "$repo/.git/index" "$scratch/index.before"
git -C "$repo" show-ref > "$scratch/refs.before"
capture worktree
tree=$(field "$evidence" tree)
equal "$(git -C "$repo" show "$tree:tracked.txt")" final 'unstaged content wins'
equal "$(git -C "$repo" show "$tree:hidden.txt")" 'hidden final' 'skip-worktree content captured'
equal "$(git -C "$repo" show "$tree:staged.ignored")" 'final ignored' 'tracked ignored content captured'
equal "$(git -C "$repo" show "$tree:link")" "$scratch/outside" 'symlink not followed'
equal "$(git -C "$repo" show "$tree:$odd")" odd 'newline path content'
equal "$(git -C "$repo" show "$tree:new.txt")" new 'intent-to-add content'
printf '%s\0' deleted.txt hidden.txt link new.txt "$odd" staged.ignored tracked.txt > "$scratch/expected.z"
cmp "$scratch/expected.z" "$evidence/paths.z" || fail 'exact changed paths'
cmp "$scratch/index.before" "$repo/.git/index" || fail 'user index changed'
git -C "$repo" show-ref > "$scratch/refs.after"
cmp "$scratch/refs.before" "$scratch/refs.after" || fail 'refs changed'
[[ ! -e $evidence/index ]] || fail 'temporary index retained'
git -C "$repo" apply --numstat "$evidence/patch.diff" > "$scratch/patch-stat"
capture repository
equal "$(field "$evidence" base)" none 'audit has no base'
[[ ! -e $evidence/patch.diff ]] || fail 'audit has patch'
printf '%s\0' .gitignore hidden.txt link new.txt "$odd" staged.ignored tracked.txt > "$scratch/expected.z"
cmp "$scratch/expected.z" "$evidence/paths.z" || fail 'exact audited paths'
printf 'PASS mixed index, final contents, exclusions, symlink, paths and audit\n'

new_repo branch
baseline=$(git -C "$repo" rev-parse HEAD)
git -C "$repo" checkout --quiet -b reference
printf 'reference\n' > "$repo/reference.txt"
git -C "$repo" add .
git -C "$repo" commit --quiet -m 'Reference branch change'
git -C "$repo" checkout --quiet -b feature "$baseline"
printf 'committed\n' > "$repo/committed.txt"
git -C "$repo" add .
git -C "$repo" commit --quiet -m 'Feature branch change'
printf 'local\n' > "$repo/local.txt"
capture branch reference
equal "$(field "$evidence" base)" "$baseline" 'merge-base used'
printf '%s\0' committed.txt local.txt > "$scratch/expected.z"
cmp "$scratch/expected.z" "$evidence/paths.z" || fail 'branch includes committed and local only'
reject branch
reject branch missing-ref
reject branch --help
reject worktree extra
reject unknown
printf 'PASS explicit merge-base, local changes and invalid requests\n'

new_repo clean
capture worktree
[[ ! -s $evidence/paths.z && ! -s $evidence/patch.diff ]] || fail 'clean scope not empty'
git -C "$repo" update-index --split-index
cp "$repo/.git/index" "$scratch/split.before"
printf 'split changed\n' > "$repo/tracked.txt"
capture worktree
equal "$(git -C "$repo" show "$(field "$evidence" tree):tracked.txt")" 'split changed' 'split index works'
cmp "$scratch/split.before" "$repo/.git/index" || fail 'split index changed'
git -C "$repo" config core.sparseCheckout true
reject worktree
grep -q 'Sparse checkouts' "$scratch/rejected.err" || fail 'wrong sparse failure'
printf 'PASS empty scope, split index and sparse refusal\n'

repo="$scratch/unborn"
git init --quiet "$repo"
reject worktree
new_repo conflict
baseline=$(git -C "$repo" rev-parse HEAD)
git -C "$repo" checkout --quiet -b left
printf 'left\n' > "$repo/tracked.txt"
git -C "$repo" commit --quiet -am 'Left edit'
git -C "$repo" checkout --quiet -b right "$baseline"
printf 'right\n' > "$repo/tracked.txt"
git -C "$repo" commit --quiet -am 'Right edit'
status=0
git -C "$repo" merge left > "$scratch/merge.out" 2>&1 || status=$?
equal "$status" 1 'fixture has merge conflict'
reject worktree
grep -q 'Resolve index conflicts' "$scratch/rejected.err" || fail 'wrong conflict failure'
printf 'PASS unborn HEAD and unresolved conflict refusal\n'

new_repo temp-root
TMPDIR="$repo" reject worktree
grep -q 'outside the repository' "$scratch/rejected.err" || fail 'wrong evidence-location failure'
printf 'PASS evidence cannot capture itself\n'

new_repo gitlink
git clone --quiet "$repo" "$repo/component"
git -C "$repo" -c advice.addEmbeddedRepo=false add component
git -C "$repo" commit --quiet -m 'Track component'
printf 'component change\n' > "$repo/component/tracked.txt"
git -C "$repo/component" commit --quiet -am 'Advance component'
git -C "$repo" config diff.ignoreSubmodules all
capture worktree
printf '%s\0' component > "$scratch/expected.z"
cmp "$scratch/expected.z" "$evidence/paths.z" || fail 'gitlink hidden by user diff preferences'
printf 'PASS changed gitlinks remain visible\n'
