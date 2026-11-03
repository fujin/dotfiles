function count-compactions --description "Count Codex compaction events"
    if not type -q jq
        echo "count-compactions: jq is required" >&2
        return 127
    end

    set -l codex_home "$HOME/.codex"
    if set -q CODEX_HOME; and test -n "$CODEX_HOME"
        set codex_home "$CODEX_HOME"
    end

    set -l sessions_dir "$codex_home/sessions"
    if not test -d "$sessions_dir"
        echo "count-compactions: sessions directory not found: $sessions_dir" >&2
        return 1
    end

    set -l sid ""
    if test (count $argv) -gt 0
        set sid $argv[1]
    else if set -q CODEX_THREAD_ID; and test -n "$CODEX_THREAD_ID"
        set sid "$CODEX_THREAD_ID"
    end

    set -l name_pattern "*.jsonl"
    if test -n "$sid"
        set name_pattern "*$sid*.jsonl"
    end

    find "$sessions_dir" -type f -name "$name_pattern" -print0 \
        | xargs -0 jq -r 'select(.type == "compacted" or (.type == "event_msg" and .payload.type == "context_compacted")) | 1' \
        | wc -l \
        | string trim
end
