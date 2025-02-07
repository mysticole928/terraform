# Add Logging to Terraform Scripts

## Check for `.tf` Files

This snippet, when added to a `.zshrc` file checks for `.tf` files in the current directory.

When there are, it sets the `TF_LOG` and `TF_LOG_PATH` values for local logging.

```zsh
log_terraform() {
    if ls *.tf >/dev/null 2>&1; then
        export TF_LOG=INFO
        export TF_LOG_PATH="$(pwd)/terraform.log"
    else
        unset TF_LOG
        unset TF_LOG_PATH
    fi
}

# Ensure precmd hook is available
autoload -Uz add-zsh-hook
add-zsh-hook precmd log_terraform
```

## Check for `.terraform` directory

Alternatively, check for the `.terraform` directory in the current directory.

```shell
log_terraform() {
    if [ -d ".terraform" ]; then
        export TF_LOG=INFO
        export TF_LOG_PATH="$(pwd)/terraform.log"
    else
        unset TF_LOG
        unset TF_LOG_PATH
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd log_terraform
```

### Pros:

- Ensures that logging is enabled only when Terraform has been initialized.
- Prevents logging in directories with .tf files that haven’t been used yet.

### Cons:

- If you cd into a directory before running terraform init, logging won’t be enabled.
- Might miss logging if terraform init is not required (e.g., for terraform plan with a remote backend).
