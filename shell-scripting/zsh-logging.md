# Zsh: Automatically Activate Terraform Logging in the Current Directory

This function, when added to `.zshrc`, automatically turns on logging in the local directory.

It checks for either a `.terraform` directory or `.tf` file(s), then sets `TF_LOG` and `TF_LOG_PATH` values to the current directory.

The log filename format: `terraform-yyyymmdd-hhmm.log`

It does **not** clean up old logfiles.

Note: After running `terraform init` the first time, exit the directory and re-enter it to activate logging.

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
