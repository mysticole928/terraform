# Add Logging to Terraform Scripts

Here are two options for automatically turning on Terraform logging using the command line. 

The log filename format: `terraform-yyyymmdd-hhmm.log`

This snippit does **not** clean up old logfiles.

There are two options to check for Terraform files.  The first one checks for `.tf` files and the second checks for a `.terraform` directory.

## Option 1: Check for `.tf` Files

When `.tf` files exist, it sets `TF_LOG` and `TF_LOG_PATH` values for local logging.

```zsh
log_terraform() {
    setopt local_options null_glob  # Prevents errors if no files match

    if ls *.tf >/dev/null 2>&1; then
    TIMESTAMP=$(date +"%Y%m%d-%H%M")  # Year, month, day, hour, minute
        export TF_LOG=INFO
        export TF_LOG_PATH="$(pwd)/terraform-$TIMESTAMP.log"
    else
        unset TF_LOG
        unset TF_LOG_PATH
    fi
}

# Ensure precmd hook is available
autoload -Uz add-zsh-hook
add-zsh-hook precmd log_terraform
```

## Option 2: Check for `.terraform` directory

Alternatively, check for the `.terraform` directory in the current directory.

When a `.terraform` directory is present, it sets `TF_LOG` and `TF_LOG_PATH` values for local logging.

After running `terraform init` the first time, exit the directory and re-enter it to activate logging.

```shell
log_terraform() {
    setopt local_options null_glob  # Prevents errors if no files match

    if [ -d ".terraform" ] || [ -n "$(ls *.tf 2>/dev/null)" ]; then
        TIMESTAMP=$(date +"%Y%m%d-%H%M")  # Year, month, day, hour, minute
        export TF_LOG=INFO
        export TF_LOG_PATH="$(pwd)/terraform-$TIMESTAMP.log"
    else
        unset TF_LOG
        unset TF_LOG_PATH
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd log_terraform
```
