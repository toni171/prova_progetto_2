function hostup () {
    docker-compose -f "${FILE_NAME}" up -d
}

function hostdown () {
    docker-compose -f "${FILE_NAME}" down -v
    docker rm $(docker ps -aq)
    docker rmi $(docker images dev-* -q)
}

MODE=$1
WHICH=$2
FILE_NAME="host${WHICH}.yaml"

# if [ "${WHICH}" == "1" ]; then
# elif [ "${WHICH}" == "2" ]
# fi

if [ "${MODE}" == "hostup" ]; then
    hostup
elif [ "${MODE}" == "hostdown" ]; then
    hostdown
fi
