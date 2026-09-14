# workmux-config

Configuration de travail de Doriann autour de [workmux](https://workmux.raine.dev) : config globale, bindings tmux, touches du shell, extension de suivi de statut omp. De quoi reposer le meme poste ailleurs.

| Fichier | Destination |
| --- | --- |
| `config.yaml` | `${XDG_CONFIG_HOME:-~/.config}/workmux/config.yaml` |
| `shell/keys.fish` | `${XDG_CONFIG_HOME:-~/.config}/fish/conf.d/keys.fish` |
| `omp/workmux-status.ts` | `~/.omp/agent/extensions/workmux-status.ts` |
| `tmux/workmux.conf` | charge par une ligne `source-file` ajoutee a `~/.tmux.conf` |

## Installation

```bash
git clone https://github.com/DoriannX/workmux-config.git ~/projects/workmux-config
~/projects/workmux-config/install.sh          # liens symboliques (recommande)
~/projects/workmux-config/install.sh --copy   # copies simples
```

Avec des liens, un `git pull` ici met la machine a jour. Tout fichier deja present est sauvegarde en `<nom>.bak.<horodatage>` avant remplacement.

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
| `status_icons` | `●` jaune en cours, `▲` rouge attend une reponse, `✔` vert termine, dans la barre de fenetres et la sidebar. |
| `dashboard.close_on_jump` | Le dashboard est ouvert en popup `-E` : sans ca il reste au-dessus du pane vise. |
| `sidebar.sort: window` | Ordre des fenetres tmux, donc ordre de creation. Le defaut `recency` reclasse a chaque changement de statut et les lignes bougent sous le curseur. |
| `files.symlink` | Partage les releves de quota omp entre worktrees (`.omp/` est gitignore, donc absent d'un worktree neuf). Chemin absent d'un depot ? workmux l'ignore sans erreur. |

## Ctrl-Backspace supprime le mot precedent

Windows Terminal envoie l'octet `0x08` pour Ctrl-Backspace et `0x7F` pour Backspace seul. omp lie deja l'action `tui.editor.deleteWordBackward` a `Ctrl+W`, `Alt+Backspace` et `Ctrl+Backspace`, mais il ne traite `0x08` comme Ctrl-Backspace que **hors multiplexeur** — dans tmux il n'effacait donc qu'un caractere. `shell/keys.fish` pose `PI_TUI_RAW_BACKSPACE_IS_CTRL=1` (et `tmux/workmux.conf` le repose via `set-environment -g`, pour les panes qui ne passent pas par le shell), plus `bind \b backward-kill-word` parce que fish a le meme defaut.

## Extension de suivi de statut omp

`omp/workmux-status.ts` remplace celle que pose `workmux setup`. La version d'origine marquait `waiting` sur `message_end` : or un message d'assistant qui porte des appels d'outils se termine **au milieu** du tour, et workmux rend `waiting`/`done` collants jusqu'a ce qu'on focalise le pane. La fenetre restait donc marquee « attend une reponse » pendant tout le travail. Ici `waiting` ne vient plus que de l'outil `ask`, et `done` de `agent_end`.

## Prerequis par machine

- `workmux` dans le `PATH` (`workmux update` pour la suite).
- Le binaire `omp-fs`, sinon `agent: omp-fs` ne demarre rien : changer `agent:` pour l'agent reellement installe, ou installer le fork.
- Suivi de statut : `workmux setup` une fois par machine, sinon dashboard et sidebar restent vides.
- Une police nerd font dans le terminal, sinon passer `nerdfont` a `false`.

## Bindings tmux qui vont avec

Poses par `tmux/workmux.conf` : `Ctrl-b g` ouvre le dashboard en fenetre flottante, `Ctrl-b G` bascule la colonne d'etat des worktrees.
