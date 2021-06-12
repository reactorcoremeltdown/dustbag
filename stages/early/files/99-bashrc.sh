# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${STAT}]"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo "${bits}"
	else
		echo ""
	fi
}

function delimiter() {
	if [[ ${COLUMNS} -lt 60 ]]; then
		printf "\n• "
	else
		echo "• "
	fi
}

function usercolor() {
    if [[ $(whoami) = 'root' ]]; then
        printf '\[\e[31m\]'
    else
        printf '\[\e[36m\]'
    fi
}

export PS1="[$(usercolor)\A\[\e[m\]][\[\e[33m\]\h\[\e[m\]::\[\e[34m\]\W\[\e[m\]]\[\e[33m\]\`parse_git_branch\`\[\e[m\]\`delimiter\`"


alias ls='ls --color'
alias ll='ls -l'
alias l='ls -l'

# $PATH, the most important thing
# Supporting termux as well
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games:/data/data/com.termux/files/usr/bin:${HOME}/bin"

if [[ `whoami` = 'root' || `uname -s` = 'Darwin' ]]; then
  export PATH="${PATH}:/sbin:/usr/sbin"
fi

# Locale, another important thing
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# EDITOR, always set to vim
export EDITOR='vim'

# Golang and everything related
export GOPATH="$HOME/dev/golibs"
export GOBIN="$HOME/dev/gobins"

# Aliases, the most useful thing that saves life
alias cdgit='cd $(git rev-parse --show-cdup)'
alias shell='ansible-console'
alias bank='ssh ledger@buster.rcmd.space'
alias t='tracker'
alias orca='orca --strict-timing'
alias gs='git status'
alias gc='git commit'
alias gu='git push origin $(git rev-parse --abbrev-ref --symbolic-full-name @)'
alias gd='git diff'
alias gp='git pull'

# Shell history management
function forget() {
   history -d $(expr $(history | tail -n 1 | grep -oP '^ \d+') - 1);
}
export HISTCONTROL=ignorespace

# Setting up ssh agent
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

# macOS specific configs

if [[ `uname -s` = 'Darwin' ]]; then
    alias chores='todo list chores --due 24 --sort due --no-reverse'
    alias mvim='/usr/local/bin/mvim --remote-tab-silent'
    alias tasksync='vdirsyncer sync'

    # Time-based desktop aliases
    alias today_morning='gdate --date "today 08:30" "+%Y-%m-%d %H:%M"'
    alias today_afternoon='gdate --date "today 13:30" "+%Y-%m-%d %H:%M"'
    alias today_evening='gdate --date "today 18:00" "+%Y-%m-%d %H:%M"'
    alias today_night='gdate --date "today 20:30" "+%Y-%m-%d %H:%M"'
    alias tomorrow_morning='gdate --date "tomorrow 08:30" "+%Y-%m-%d %H:%M"'
    alias tomorrow_afternoon='gdate --date "tomorrow 13:30" "+%Y-%m-%d %H:%M"'
    alias tomorrow_evening='gdate --date "tomorrow 18:00" "+%Y-%m-%d %H:%M"'
    alias tomorrow_night='gdate --date "tomorrow 20:30" "+%Y-%m-%d %H:%M"'

    # Terraform
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C /usr/local/bin/terraform terraform

    # Node
    export NODE_PATH=$NODE_PATH:$(npm root -g)

    # AWS
    export AWS_REGION="eu-central-1"

    # Minikube
    source "${HOME}/.kube/kube_zsh"
fi

unset MAILCHECK

source ${HOME}/.bashrc
