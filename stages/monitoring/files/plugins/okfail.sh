DESCRIPTION=$2
ENVIRONMENT=$3

function ok() {
    echo -n $1
    exit 0
}

function warning() {
    echo -n $1
    exit 1
}

function fail() {
    echo -n $1
    exit 2
}
