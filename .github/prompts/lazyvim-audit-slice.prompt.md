---
name: LazyVim Audit Slice
description: "Audit one migration slice by comparing nvim.bak with the current LazyVim config. Use for workflow mismatch reviews, muscle-memory risks, and alias recommendations."
agent: "LazyVim Migration"
argument-hint: "Describe the single workflow slice or file area to audit."
---
Audit exactly one LazyVim migration slice.

Requirements:
- Compare the relevant behavior in `nvim.bak` and the current config.
- Report workflow mismatches and muscle-memory risks.
- Recommend whether LazyVim defaults should win, an alias is enough, or a real adaptation is needed.
- Update migration docs only if new findings materially change the migration record.