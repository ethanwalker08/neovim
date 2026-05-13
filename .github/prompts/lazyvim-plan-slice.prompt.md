---
name: LazyVim Plan Slice
description: "Plan one LazyVim migration slice from nvim.bak without editing files. Use for classification, architecture review, and deciding whether LazyVim already covers the workflow."
agent: "LazyVim Migration"
argument-hint: "Describe the single workflow slice or old behavior to plan."
---
Plan exactly one LazyVim migration slice from `nvim.bak` into the current config.

Requirements:
- Do not edit files unless the user explicitly asks.
- Read the migration docs first.
- Classify the workflow.
- Identify the owning implementation surface.
- Prefer LazyVim defaults when they already cover the workflow.
- End with the smallest recommended next change and the cheapest focused validation.