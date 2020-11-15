ZSH_THEME_SVN_PROMPT_PREFIX=$ZSH_THEME_GIT_PROMPT_PREFIX
ZSH_THEME_SVN_PROMPT_SUFFIX=$ZSH_THEME_GIT_PROMPT_SUFFIX
ZSH_THEME_SVN_PROMPT_DIRTY=$ZSH_THEME_GIT_PROMPT_DIRTY
ZSH_THEME_SVN_PROMPT_CLEAN=$ZSH_THEME_GIT_PROMPT_CLEAN
ZSH_THEME_HG_PROMPT_PREFIX=$ZSH_THEME_GIT_PROMPT_PREFIX
ZSH_THEME_HG_PROMPT_SUFFIX=$ZSH_THEME_GIT_PROMPT_SUFFIX
ZSH_THEME_HG_PROMPT_DIRTY=$ZSH_THEME_GIT_PROMPT_DIRTY
ZSH_THEME_HG_PROMPT_CLEAN=$ZSH_THEME_GIT_PROMPT_CLEAN

## GIT PROMPT VARIABLES
ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[white]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[white]%}]%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_SEPARATOR="%{$reset_color%} | "
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[magenta]%}↑"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[green]%}↓"
ZSH_THEME_GIT_PROMPT_STAGED="%{$FG[002]%}+"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$FG[208]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}?"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$FG[021]%}✕ "

function my_vcs_status() {
  STATUS=""
  INDEX=$(git status --porcelain 2> /dev/null)

  if [[ $(whence in_svn) != "" ]] && in_svn; then
      svn_prompt_info
  elif [[ $(whence in_hg) != "" ]] && in_hg; then
      hg_prompt_info
  else
    tester=$(git rev-parse --git-dir 2> /dev/null) || return
    # branch ahead
    if $(echo "$(git log origin/$(git_current_branch)..HEAD 2> /dev/null)" | command grep '^commit' &> /dev/null); then
      NB=$(echo "$(git log origin/$(git_current_branch)..HEAD 2> /dev/null)" | command grep '^commit' &> /dev/null | command wc -l)
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD$NB%{$reset_color%}"
    fi
    # branch behind
    if $(echo "$(git log HEAD..origin/$(git_current_branch) 2> /dev/null)" | command grep '^commit' &> /dev/null); then
      NB=$(echo "$(git log HEAD..origin/$(git_current_branch) 2> /dev/null)" | grep '^commit' &> /dev/null | command wc -l)
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND$NB%{$reset_color%}"
    fi
    STATUS="$STATUS$(git_current_branch)"
    # staged
    if $(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &> /dev/null); then
      NB=$(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &> /dev/null | command wc -l)
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_STAGED$NB%{$reset_color%}"
    fi
    # unstaged
    if $(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' &> /dev/null); then
      NB=$(echo "$INDEX" | command grep -n '^[ MARC][MD] ' &> /dev/null | command wc -l )
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_UNSTAGED$NB%{$reset_color%}"
    fi
    # untracked
    if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
      NB=$(echo "$INDEX" | grep '^?? ' &> /dev/null | command wc -l)
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_UNTRACKED$NB%{$reset_color%}"
    fi
    # unmerged
    if $(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' &> /dev/null); then
      NB=$(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' &> /dev/null | command wc -l)
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR$ZSH_THEME_GIT_PROMPT_UNMERGED$NB%{$reset_color%}"
    fi
    if [[ -n $STATUS ]]; then
      STATUS="$STATUS"
    fi
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX$STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

function preexec() {
  timer=$(date +%s%3N)
}

function precmd() {
  if [ $timer ]; then
    now=$(date +%s%3N)
    elapsed=$(($now-$timer))

    export RPROMPT="%F{cyan}${elapsed}ms %{$reset_color%}"
    unset timer
  fi
}

PROMPT='%3~ $(my_vcs_status)%b%B%(?.%F{green}.%F{red})»%f%b '
