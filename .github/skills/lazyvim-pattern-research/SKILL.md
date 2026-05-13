---
name: lazyvim-pattern-research
description: 'Research LazyVim-native patterns for old custom workflows. Use when behavior in nvim.bak depends on a plugin or custom module and you need the closest idiomatic LazyVim replacement.'
argument-hint: 'Describe the old workflow, plugin, or module and what behavior must be preserved.'
user-invocable: true
---

# LazyVim Pattern Research

## When to Use
- A behavior in `nvim.bak` depends on an old plugin implementation.
- You need to know whether LazyVim, Snacks, Trouble, Blink, Conform, Noice, Mason, or native Neovim already covers the workflow.

## Procedure
1. Inspect the old workflow in `nvim.bak`.
2. Inspect the current LazyVim stack in `lazy-lock.json`, `lua/config`, and `lua/plugins`.
3. Determine whether the workflow is already provided by LazyVim.
4. If not, recommend the smallest LazyVim-native adaptation.
5. Call out anti-patterns and maintenance risks before proposing custom code.

## Deliverable
- Recommended implementation direction.
- Why the old plugin code should or should not be migrated.
- Risks, tradeoffs, and fallback options.