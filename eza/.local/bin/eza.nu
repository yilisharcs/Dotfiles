#!/usr/bin/env nu

$env.config.display_errors.termination_signal = false

def --wrapped main [...rest] {
        eza --color=always --group-directories-first --tree ...$rest
}
