#!/usr/bin/env bash
# Installe ce depot sur la machine courante : config workmux, bindings tmux,
# touches du shell fish, extension de suivi de statut omp.
# Par defaut des liens symboliques : `git pull` ici suffit a tout mettre a jour.
# `--copy` copie les fichiers a la place, pour une machine ou le depot n'est pas garde.
set -euo pipefail

mode=link
case ${1:-} in
  --copy) mode=copy ;;
  --help | -h)
    sed -n '2,5p' "$0" | cut -c3-
    exit 0
    ;;
  "") ;;
  *)
    echo "Option inconnue : $1" >&2
    exit 2
    ;;
esac

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

# install <source relative au depot> <destination absolue>
install_file() {
  local src="$repo_dir/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [[ -L $dst && $(readlink -f "$dst") == "$src" ]]; then
    echo "deja en place : $dst"
    return
  fi

  if [[ -e $dst || -L $dst ]]; then
    local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    echo "sauvegarde    : $backup"
  fi

  if [[ $mode == link ]]; then
    ln -s "$src" "$dst"
    echo "lien          : $dst -> $src"
  else
    cp "$src" "$dst"
    echo "copie         : $dst"
  fi
}

install_file config.yaml "$config_home/workmux/config.yaml"
install_file shell/keys.fish "$config_home/fish/conf.d/keys.fish"
install_file omp/workmux-status.ts "$HOME/.omp/agent/extensions/workmux-status.ts"
install_file omp/skills/merge-wt/SKILL.md "$HOME/.omp/agent/skills/merge-wt/SKILL.md"

# tmux ne sait pas inclure un fragment tout seul : on ajoute la ligne source-file
# a ~/.tmux.conf si elle n'y est pas deja.
tmux_conf="$HOME/.tmux.conf"
source_line="source-file $repo_dir/tmux/workmux.conf"
if [[ -f $tmux_conf ]] && grep -qF "$source_line" "$tmux_conf"; then
  echo "deja en place : $tmux_conf (source-file)"
else
  printf '\n# Bindings workmux et touches, voir %s\n%s\n' "$repo_dir" "$source_line" >>"$tmux_conf"
  echo "ajoute        : $tmux_conf (source-file)"
fi

echo
echo "A faire une fois par machine :"
echo "  workmux setup            # hooks de suivi de statut, sinon dashboard et sidebar restent vides"
echo "  tmux source-file ~/.tmux.conf   # ou relancer tmux"
command -v workmux >/dev/null || echo "  installer workmux : il est absent du PATH"
command -v omp-fs >/dev/null || echo "  installer omp-fs, ou changer 'agent:' dans config.yaml"
