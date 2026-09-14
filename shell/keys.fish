# Ctrl-Backspace = supprimer le mot precedent.
#
# Windows Terminal envoie l'octet 0x08 (\b) pour Ctrl-Backspace, et 0x7F pour
# Backspace seul. omp ne traite 0x08 comme Ctrl-Backspace que hors multiplexeur,
# sauf si cette variable est posee : dans tmux il le lisait comme un Backspace
# ordinaire et n'effacait qu'un caractere.
set -gx PI_TUI_RAW_BACKSPACE_IS_CTRL 1

# Meme touche dans le shell : fish lit \b comme un Backspace simple par defaut.
if status is-interactive
    bind \b backward-kill-word
end
