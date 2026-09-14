# Menu d'options workmux — retenir / jeter

Faits du poste (vérifiés) : un seul projet suivi (`7pace-auto`, .NET 8, **pas de `dotnet`, `gh` ni `llm` dans WSL**), pas de `.workmux.yaml` projet donc le global fait tout, pas de docker/podman/lima donc **sandbox impossible**, 3 worktrees actifs en parallèle à l'instant, suivi de statut déjà branché (`~/.omp/agent/extensions/workmux-status.ts`), bindings tmux déjà posés (`Ctrl-b g` dashboard popup, `Ctrl-b G` sidebar), branches plates en kebab-case sans `/`.

Déjà dans ta config et à garder sans discuter : `nerdfont: true`, `agents.omp-fs`, `agent: omp-fs`, `base_branch: auto`, `merge_strategy: rebase`, pane unique `<agent>`.

---

## A. Ce qui te servira probablement — candidats forts

| # | Option | Ce que ça change | Pourquoi pour toi | Coût |
|---|---|---|---|---|
| A1 | `auto_name.command: "omp-fs -p"` + `auto_name.background: true` | `workmux add -A "ma tâche"` génère le nom de branche par LLM, en tâche de fond | Tu nommes tes branches à la main aujourd'hui ; `llm` n'est pas installé, et sans `command` explicite la résolution passe par ton profil nommé `omp-fs` (non garanti). Le fixer supprime l'ambiguïté | 2 lignes, et `-A` consomme un appel modèle |
| A2 | `auto_name.system_prompt` | Impose ta convention de nom (ex. `fix-32049-libelle`) | Tes branches suivent le ticket Azure ; sans prompt le LLM inventera son style | 1 ligne |
| A3 | `dashboard.commit` / `dashboard.merge` | Touches `c` et `m` du dashboard : `c` envoie une consigne de commit à l'agent, `m` lance une commande shell | **Conflit avec ta règle « jamais commiter ni pousser sans validation »** : à ne prendre que si tu veux un raccourci *explicite* que tu déclenches toi | 3 lignes, risque de commit involontaire d'une frappe |
| A4 | `dashboard.close_on_jump: true` | Le dashboard se ferme quand tu sautes sur un agent | Ton dashboard est une popup `-E` : sauter sans fermer laisse la popup au-dessus du pane visé | 1 ligne |
| A5 | `dashboard.preview_size` | Part de l'écran donnée à l'aperçu du pane agent vs le tableau | Avec 3-4 worktrees, le tableau n'a pas besoin de la moitié de l'écran ; ~65 privilégie la lecture de ce que dit l'agent | 1 ligne (réglable à chaud avec `+`/`-`) |
| A6 | `dashboard.agent_columns` réduites | Cache les colonnes inutiles (`pr`, `project`) | `gh` absent → colonne PR toujours vide ; un seul projet → colonne projet toujours identique | 1 ligne |
| A7 | `status_icons` colorées | Icônes de statut avec couleur tmux (`#[fg=#a6e3a1]`) | Tu repères « done » vs « working » du coin de l'œil dans la barre de fenêtres, sans lire | 3 lignes |
| A8 | `window_placement: rightmost` | Les nouvelles fenêtres vont au bout, pas juste après la courante | Avec plusieurs `add` d'affilée, l'ordre des fenêtres reste l'ordre de création : la position d'une fenêtre devient mémorisable | 1 ligne |
| A9 | `worktree_dir: ~/worktrees/{project}` | Sort les worktrees du dossier voisin `7pace-auto__worktrees/` | Chemins plus courts dans le prompt et les logs, `~/projects` ne contient plus que les vrais dépôts | 1 ligne, **casse le chemin des 3 worktrees existants** (à faire à vide) |
| A10 | `files.symlink: [.omp/agent/quota-samples]` | Partage les relevés de quota entre worktrees | `.omp/` est gitignoré donc absent d'un worktree neuf ; les échantillons de quota s'accumulent aujourd'hui par worktree et se perdent au `remove` | 2 lignes |

## B. Dépend d'une décision de flux de travail

| # | Option | Le compromis |
|---|---|---|
| B1 | `mode: session` | Une session tmux par worktree au lieu d'une fenêtre. Gagnant si tu veux plusieurs fenêtres par tâche (agent / shell / logs) et un `Ctrl-b s` qui liste tes tâches. Perdant : tu perds la barre de fenêtres comme vue d'ensemble, et tes deux bindings deviennent des sauts inter-sessions |
| B2 | `windows:` (au lieu de `panes:`) | Uniquement en `mode: session`. Ex. fenêtre `agent` + fenêtre `shell`. Remplace ton pane unique |
| B3 | `layouts:` nommés (`-l duo`, `-l review`) | Permet `workmux add refacto -l duo` avec deux agents côte à côte (omp-fs + un autre) sur la même tâche. Utile seulement si tu fais réellement tourner deux modèles sur un même sujet |
| B4 | `merge_keep: true` | `workmux merge` garde worktree, fenêtre et branche. Utile si tu veux vérifier le résultat sur `main` avant de tout perdre ; sinon c'est du ménage manuel en plus à chaque fois |
| B5 | `pre_remove` de sauvegarde | Copie des fichiers gitignorés (`artifacts/`, captures `.png` à la racine) vers le dépôt principal avant suppression du worktree. Utile si tu produis des preuves de PR dans le worktree et que tu les as déjà perdues une fois |
| B6 | `sidebar.layout` / `width` / `position` | Ta sidebar est en 25 colonnes persistées. `position: top` + `height: 3` donne un bandeau au lieu d'une colonne : moins de largeur volée à l'agent, moins de détail |
| B7 | `theme: <schéma>` | Purement esthétique, persiste tout seul quand tu appuies `T` dans le dashboard — donc inutile de l'écrire à la main |

## C. À écarter, avec la raison

| # | Option | Raison |
|---|---|---|
| C1 | `sandbox:` | Ni docker, ni podman, ni lima sur ce poste. Non applicable |
| C2 | `pre_merge: [dotnet build]` | `dotnet` n'existe pas dans WSL : le hook échouerait et **bloquerait tous tes merges**. Le projet se construit sur Windows / CI |
| C3 | `main_branch` | Auto-détecté correctement (`origin/HEAD` → `main`) |
| C4 | `worktree_naming: basename` | Tes branches n'ont pas de `/` : aucun effet |
| C5 | `worktree_prefix` / `window_prefix` | Un seul projet : rien à désambiguïser. Le préfixe icône nerdfont suffit |
| C6 | `hook_shell` | Le défaut `["bash","-c"]` est correct ici (c'est un contournement macOS/Homebrew) |
| C7 | `status_format: false` | À prendre seulement si tu veux écrire toi-même le format de fenêtre dans `.tmux.conf`. Tu ne le fais pas |
| C8 | `prompt_file_only` | Pour les éditeurs à agent embarqué (neovim). Tu lances l'agent dans le pane |
| C9 | `files.copy: [.env]` | Pas de `.env` dans ce projet |
| C10 | `post_create` | Rien à installer : pas de `npm install`, pas de restore possible sans `dotnet` |
| C11 | `panes` multiples par défaut | Tu as choisi le pane unique pleine largeur exprès ; `Ctrl-b %` couvre le shell ponctuel |

## D. Hors config, mais c'est le vrai gain (à mettre dans `.tmux.conf`)

| # | Binding | Effet |
|---|---|---|
| D1 | `bind-key L run-shell "workmux last-done"` | Saute directement sur l'agent qui vient de finir ou qui attend une réponse ; rappuyer cycle vers le suivant. C'est ce qui remplace « aller voir dans le dashboard » |
| D2 | `bind Tab run-shell "workmux last-agent"` | Bascule entre les deux derniers agents visités, comme `Ctrl-^` de vim |
| D3 | `workmux reap-agents --hours 24` | Commande d'entretien : tue les agents dont l'état ne bouge plus. À lancer à la main, pas de config |
