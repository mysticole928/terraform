# Bash: Automatically Activate Terraform Logging in the Current Directory

This function checks:

- The .terraform/ directory exists (Terraform has been initialized).
- `.tf` files are present (Terraform files exist).

If either condition is met, it sets `TF_LOG` to `INFO` and `TF_LOG_PATH` to the current directory.

Otherwise, it disables Terraform logging.

The function is assigned to PROMPT_COMMAND, which executes it automatically.

Add the following to `~/.bashrc`.  (`~/.bash_profile` on MacOS.)

```bash
log_terraform() {
    if [ -d ".terraform" ] || ls *.tf >/dev/null 2>&1; then
        export TF_LOG=INFO
        export TF_LOG_PATH="$(pwd)/terraform.log"
    else
        unset TF_LOG
        unset TF_LOG_PATH
    fi
}

# Append to PROMPT_COMMAND instead of overwriting it
PROMPT_COMMAND="log_terraform; ${PROMPT_COMMAND:-}"
```

