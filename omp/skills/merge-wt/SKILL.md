---
name: merge-wt
description: Merge le worktree courant dans sa branche de base avec workmux, puis nettoie worktree, fenêtre tmux et branche. À utiliser quand Doriann dit de merger, de fusionner, de clore le worktree ou la branche courante. Ne commite rien et ne pousse rien.
disable-model-invocation: true
allowed-tools: Bash
---

# /merge-wt

Merge le worktree depuis lequel la commande est lancée. `workmux merge` sans nom prend le worktree courant, applique la stratégie configurée (`rebase`), puis supprime worktree, fenêtre tmux et branche.

Arguments : `$ARGUMENTS` — passer `--keep` tel quel s'il est présent (garde worktree, fenêtre et branche après le merge).

1. `git status --porcelain`. Si l'arbre n'est pas propre, **s'arrêter** : lister les fichiers et demander à Doriann s'il veut commiter d'abord. Ne jamais commiter d'initiative.
2. `workmux merge` (plus `--keep` si demandé).
3. Rendre compte en une phrase : branche mergée, cible, et si `main` est en avance sur `origin` — sans pousser.
