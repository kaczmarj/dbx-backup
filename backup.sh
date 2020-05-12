#!/usr/bin/env bash
#
# Script to backup dropbox to a local filesystem.
#
# Use with the flag --dry-run to see what will be downloaded.

set -eu

# The directory in which this script is located.
here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Where the dropbox content should be stored on the local filesystem.
destination_dir="${here}/backup"

# Look at `--backup-dir` option in rsync. Any files that are moved or removed from
# the remote (i.e., dropbox) will go into this directory. This way, files should
# not be lost, ever.
backup_dir="${destination_dir}-$(date -I)"

# Path to the rclone binary. This can be downloaded from the internet.
rclone_bin="${here}/rclone"
# Path to the rclone configuration file. This is created when running `rclone config --config rclone.conf`
rclone_config="${here}/rclone.conf"
# Name of the remote to the dropbox.
rclone_remote="dbx"

function print_red {
  echo -e "\e[31m${1}\e[0m"
}

function print_green {
  echo -e "\e[32m${1}\e[0m"
}

if [ ! -f "$rclone_bin" ]; then
  print_red "ERROR program 'rclone' cannot be found. Please download it into the same directory as this script."
  exit 1
fi

if [ ! -x "$rclone_bin" ]; then
  print_red "ERROR: program 'rclone' is not executable. In a terminal, run `chmod +x ${rclone_bin}` in this directory."
  exit 1
fi

# Run `rclone config` to set up a new remote to dropbox.
if [ ! -f  "$rclone_config" ]; then
  print_red "ERROR: rclone not set up. Run `./rclone config --config ${rclone_config}` and create a remote named `$rclone_remote`."
  exit 1
fi

cmd=""$rclone_bin" sync ${rclone_remote}:/ "$destination_dir" --config=$rclone_config --backup-dir="$backup_dir" --progress"

# Add --dry-run option.
if [ "$#" -ne "0" ]; then
  if [ "$1" == "--dry-run" ]; then
    cmd="$cmd --dry-run"
  else
    print_red "ERROR: unknown argument $1. Only --dry-run is allowed."
    exit 1
  fi
fi

echo ""
echo "Will run command:"
echo ""
echo "$cmd"
echo ""

read -p "Continue? (y/[n]): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Run the command.
eval "$cmd"

echo ""
print_green "Finished."
