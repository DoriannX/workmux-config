#!/usr/bin/env bash
# Installe ce depot comme configuration globale workmux.
# Par defaut un lien symbolique : `git pull` ici suffit a mettre la machine a jour.
# `--copy` copie le fichier a la place, pour une machine ou le depot n'est pas garde.
set -euo pipefail

mode=link
[[ ${1:-} == --copy ]] && mode=copy
[[ ${1:-} == --help || ${1:-} == -h ]] && { sed -n '2,4p' "$0" | cut -c3-; exit 0; }

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/workmux"
target="$config_dir/config.yaml"

mkdir -p "$config_dir"

if [[ -e $target || -L $target ]]; then
  if [[ -L $target && $(readlink -f "$target") == "$repo_dir/config.yaml" ]]; then
    echo "Deja installe : $target"
    exit 0
  fi
  backup="$target.bak.$(date +%Y%m%d%H%M%S)"
  mv "$target" "$backup"
  echo "Config existante sauvegardee : $backup"
fi

if [[ $mode == link ]]; then
  ln -s "$repo_dir/config.yaml" "$target"
  echo "Lien cree : $target -> $repo_dir/config.yaml"
else
  cp "$repo_dir/config.yaml" "$target"
  echo "Config copiee : $target"
fi

command -v workmux >/dev/null || {
  echo "workmux absent du PATH : installe-le avant de t'en servir." >&2
  exit 0
}
workmux config path
