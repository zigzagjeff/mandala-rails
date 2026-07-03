#!/usr/bin/env bash
# PostToolUse hook — keep Claude's edits in omakase style automatically.
#
# Claude Code sends the tool call as JSON on stdin. We pull out the path of the
# file it just touched, and if it's Ruby, quietly autocorrect it with the
# project's omakase RuboCop rules *before* it ever reaches CI. Style stops being
# a gate the agent has to pass and becomes the water it swims in.

set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}"

# Parse the edited file path out of the hook payload (Ruby is already here; jq isn't).
file_path=$(ruby -rjson -e 'print (JSON.parse(STDIN.read)["tool_input"] || {})["file_path"].to_s' 2>/dev/null || true)

# Only touch Ruby-ish files; skip everything else silently.
case "$file_path" in
  *.rb|*.rake|*.gemspec|*Gemfile|*Rakefile) ;;
  *) exit 0 ;;
esac

[ -f "$file_path" ] || exit 0

# --force-exclusion respects .rubocop.yml excludes (db/schema.rb, vendor, etc.)
# even when the file is passed explicitly. Silent + never-fail so a hiccup in the
# linter can never block Claude's actual work.
bin/rubocop -a --force-exclusion "$file_path" >/dev/null 2>&1 || true

exit 0
