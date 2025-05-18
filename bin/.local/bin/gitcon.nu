#!/usr/bin/env nu

git log --pretty=%h»¦«%aN»¦«%s»¦«%aD
| lines
| split column "»¦«" sha1 committer desc merged_at
| histogram committer merger
| sort-by count # merger
| reverse
