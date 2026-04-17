## Security Rules (Non-Negotiable)
- NEVER read, write, modify, or expose .env or .env.* files under any circumstances
- NEVER execute destructive commands: rm -rf, del /f, format, rd /s, DROP TABLE, shutdown
- Script execution is allowed for: git, node, npm, npx, python, pip, mkdir, copy, echo
- If a command is blocked by the safety hook, stop and tell me — do not try to work around it

## Hooks (Automatic, Always Active)
- Formatter runs automatically after every file edit (prettier) — do not skip or disable
- Safety hook runs before every terminal command — do not try to bypass
- Test hook: before marking any task complete, confirm tests pass or tell me they don't exist yet

## MCP Tools
- MCP tools are available but only use them when strictly necessary for the task
- Context mode is structured — when calling MCP tools, pass and receive structured context
- Obsidian MCP is available for writing session summaries and logs directly to the vault

## Obsidian Vault (Persistent Memory)
- Vault path: C:\Users\simon\marketingskills\ai-receptionist (update after Step 1 above)
- At end of every session, save summary to vault using Obsidian MCP tool
- Save location inside vault: 01-businesses/AI Receptionist/session-logs/
- File naming: YYYY-MM-DD-session.md
- New folders and files may be created inside the vault as needed
- Content to save every session:
  1. What was completed (task name, file, lines)
  2. Key decisions made and why
  3. Next task with file and line reference
  4. Any blockers