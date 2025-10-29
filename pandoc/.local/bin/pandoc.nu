#!/usr/bin/env nu

def --wrapped main [...rest] { pandoc --defaults=defaults ...$rest }
