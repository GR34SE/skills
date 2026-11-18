#!/bin/sh
# Reminds the agent of the rip-van-winkle skill. It never blocks anything:
# it prints a note for the model, or nothing.
#   remind.sh start   SessionStart hook: one note, before the agent plans.
#   remind.sh         PreToolUse hook: a note when the agent installs a
#                     package, scaffolds a project or writes a manifest.

if [ "$1" = start ]; then
  echo "rip-van-winkle: the versions, packages and APIs you remember are out of date. Before you plan a new project, choose or add a dependency, write a manifest, a config, a Dockerfile or a CI workflow, or pick a version of anything, load the rip-van-winkle skill and follow it. Load it before you decide on the stack, not after."
  exit 0
fi

input=$(cat)

field() {
  printf '%s' "$input" | sed -n "s/.*\"$1\" *: *\"\([^\"]*\)\".*/\1/p" | head -n 1
}

matches() {
  printf '%s' "$input" | grep -Eq "$1"
}

kind=""
case "$(field tool_name)" in
  Bash)
    arg='( +-[^ ]*)* +[^-"\\ &;|>]'
    if matches '(npm|pnpm|yarn|bun) +(create|init)|(npx|bunx|dlx) +(-y +|--yes +)?create-|cargo +(new|init)|uv +init|poetry +(new|init)|go +mod +init|rails +new|django-admin +startproject|composer +create-project|dotnet +new|mix +new|flutter +create|ng +new|nest +new'; then
      kind=scaffold
    elif matches "(npm|pnpm|bun) +(i|install|add)$arg|yarn +add$arg|(uv|poetry|pdm|bundle) +add$arg|(cargo|go|gem|pipx) +install$arg|cargo +add$arg|go +get$arg|composer +require$arg|dotnet +add .*package"; then
      kind=install
    elif matches "pip3? +install$arg" && ! matches 'pip3? +install +(-r|-e|--requirement|--editable|\.)'; then
      kind=install
    fi
    ;;
  Write|Edit|MultiEdit)
    case "$(field file_path)" in
      */package.json|*/pyproject.toml|*/requirements*.txt|*/setup.py|*/Cargo.toml|*/go.mod|*/Gemfile|*/composer.json|*/pom.xml|*/build.gradle|*/build.gradle.kts|*.csproj|*/deno.json|*/tsconfig*.json|*/Dockerfile*|*/compose.y*ml|*/docker-compose*.y*ml|*/.nvmrc|*/.node-version|*/.python-version|*/.tool-versions|*/mise.toml|*/rust-toolchain*|*/.github/workflows/*|*/.gitlab-ci.yml)
        kind=manifest
        ;;
    esac
    ;;
esac

[ -n "$kind" ] || exit 0

# A manifest is edited many times in a session, so remind about it once.
if [ "$kind" = manifest ]; then
  marker="${TMPDIR:-/tmp}/rip-van-winkle-$(field session_id)"
  [ -e "$marker" ] && exit 0
  : > "$marker" 2>/dev/null
fi

case "$kind" in
  install)
    note="rip-van-winkle: you are installing a package. First check that the language, the runtime or a framework already in this project does not cover this job at the version the project targets. Then check that you looked the package version up in the registry instead of remembering it. If either check fails, undo the install."
    ;;
  scaffold)
    note="rip-van-winkle: you are scaffolding a project. Look up the current LTS or stable version of the runtime and the framework, and the current form of this scaffolding command, before you rely on the result."
    ;;
  manifest)
    note="rip-van-winkle: you are writing a manifest or a config. If you chose its contents from memory, they are a draft. For every dependency in it, check whether the platform now does that job by itself, and remove the ones it covers. Every version must come from a lookup or from an existing pin in this project. Use the config format that the current version of the tool documents."
    ;;
esac

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s If the rip-van-winkle skill is not loaded in this session, load it now."}}\n' "$note"
