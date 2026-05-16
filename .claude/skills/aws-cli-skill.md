# aws-cli-skill

Whenever you run an AWS CLI command, you must log that command and its output to the `documentation/aws-cli-commands/` directory at the project root.

## Steps

1. Run the AWS CLI command normally via the Bash tool.
2. Immediately after, write a new file to `documentation/aws-cli-commands/` using the Write tool.

## File naming

Use the format: `YYYY-MM-DD_HH-MM-SS_<short-description>.md`

- Date/time: when the command was run (use `date +%Y-%m-%d_%H-%M-%S` if unsure of current time)
- Short description: 2-4 word kebab-case summary of what the command did (e.g., `list-iam-roles`, `describe-s3-bucket`, `get-caller-identity`)

Example: `2026-05-15_17-30-00_list-iam-roles.md`

## File format

```markdown
# <Short description>

## Command

```
<the exact aws cli command that was run>
```

## Output

```
<the full stdout/stderr output of the command>
```

## Notes

- Profile: <aws profile used, if specified>
- Region: <region flag used, if specified>
- Exit code: <0 for success, non-zero for error>
```

## Rules

- Log every `aws ...` command — no exceptions, even if it fails.
- Write the log file immediately after the command completes, before taking any other action.
- Never overwrite an existing log file; always use a unique timestamp.
- If the output is very long (>200 lines), truncate to the first 200 lines and append `[truncated]`.
