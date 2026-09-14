# workmux-config

Configuration globale [workmux](https://workmux.raine.dev) de Doriann, pour la reposer telle quelle sur une autre machine.

## Installation

```bash
git clone https://github.com/DoriannX/workmux-config.git ~/projects/workmux-config
~/projects/workmux-config/install.sh          # lien symbolique (recommande)
~/projects/workmux-config/install.sh --copy   # copie simple
```

Le lien pointe `${XDG_CONFIG_HOME:-~/.config}/workmux/config.yaml` vers `config.yaml` du depot : un `git pull` met la machine a jour. Une config deja presente est sauvegardee en `config.yaml.bak.<horodatage>` avant remplacement.

## Ce que contient la config, et pourquoi

| Reglage | Effet |
| --- | --- |
| `nerdfont: true` | Glyphes nerd font dans les noms de fenetres tmux et le dashboard. |
| `agents.omp-fs` + `agent: omp-fs` | Agent par defaut : le build fullscreen du fork [DoriannX/oh-my-pi](https://github.com/DoriannX/oh-my-pi). `type: omp` conserve l'injection de prompt, `--continue`/`--resume` et le suivi de statut. |
| `base_branch: auto` | Les nouvelles branches partent de la branche principale, pas de celle qui se trouve sortie. |
| `merge_strategy: rebase` | `workmux merge` rebase : historique lineaire. |
| `panes` | Un seul pane, l'agent en pleine largeur. `Ctrl-b %` pour un shell ponctuel. |
| `window_placement: rightmost` | Les fenetres s'ajoutent au bout : leur position reste l'ordre de creation. |
| `auto_name.command` | `workmux add -A "<description>"` nomme la branche par LLM. La commande est ecrite en clair parce que la resolution automatique ne connait que l'agent `omp`, pas le profil nomme `omp-fs`, et retomberait sur le CLI `llm`. |
| `status_icons` | Jaune en cours, rouge attend une reponse, vert termine, dans la barre de fenetres et la sidebar. |
| `dashboard.close_on_jump` | Le dashboard est ouvert en popup `-E` : sans ca il reste au-dessus du pane vise. |
| `files.symlink` | Partage les releves de quota omp entre worktrees (`.omp/` est gitignore, donc absent d'un worktree neuf). Chemin absent d'un depot ? workmux l'ignore sans erreur. |

## Prerequis par machine

- `workmux` dans le `PATH` (`workmux update` pour la suite).
- Le binaire `omp-fs`, sinon `agent: omp-fs` ne demarre rien : changer `agent:` pour l'agent reellement installe, ou installer le fork.
- Suivi de statut : `workmux setup` une fois par machine, sinon dashboard et sidebar restent vides.
- Une police nerd font dans le terminal, sinon passer `nerdfont` a `false`.

## Bindings tmux qui vont avec

```tmux
# Ctrl-b g : dashboard en fenetre flottante par-dessus le pane courant.
bind-key g display-popup -E -w 90% -h 90% "$HOME/.local/bin/workmux dashboard"
# Ctrl-b G : colonne d'etat permanente des worktrees (bascule).
bind-key G run-shell "$HOME/.local/bin/workmux sidebar"
```
