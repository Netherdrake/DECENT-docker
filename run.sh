#!/bin/bash
#
# DECENT node manager
# Based on Someguy123's Peerplays-in-a-box
# Modified for DECENT by @furion

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_DIR="$DIR/dkr"
DATADIR="$DIR/data"
DATADIRD="/root/.decent/data"
DOCKER_NAME="decent"

BOLD="$(tput bold)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"
RESET="$(tput sgr0)"

# default. override in .env
PORTS="2001"

if [[ -f .env ]]; then
    source .env
fi

if [[ ! -f data/decentd/config.ini ]]; then
    echo "config.ini not found. copying example (seed)";
    cp data/decentd/config.ini.example data/decentd/config.ini
fi

IFS=","
DPORTS=""
for i in $PORTS; do
    if [[ $i != "" ]]; then
         if [[ $DPORTS == "" ]]; then
            DPORTS="-p0.0.0.0:$i:$i"
        else
            DPORTS="$DPORTS -p0.0.0.0:$i:$i"
        fi
    fi
done

help() {
    echo "Usage: $0 COMMAND [DATA]"
    echo
    echo "Commands: "
    echo "    start - starts DECENT container"
    echo "    replay - starts DECENT container (in replay mode)"
    echo "    shm_size - resizes /dev/shm to size given, e.g. ./run.sh shm_size 10G "
    echo "    stop - stops DECENT container"
    echo "    status - show status of DECENT container"
    echo "    restart - restarts DECENT container"
    echo "    install - pulls latest docker image from server (no compiling)"
    echo "    rebuild - builds DECENT container (from docker file), and then restarts it"
    echo "    build - only builds DECENT container (from docker file)"
    echo "    deploy - push the latest docker image to dockerhub"
    echo "    logs - show all logs inc. docker logs, and DECENT logs"
    echo "    wallet - open cli_wallet in the container"
    echo "    enter - enter a bash session in the container"
    echo
    exit
}


build() {
    echo $GREEN"Building docker container"$RESET
    cd $DOCKER_DIR
    docker build -t $DOCKER_NAME .
}

install() {
    # step 1, get rid of old DECENT
    echo "Stopping and removing any existing DECENT containers"
    docker stop decent
    echo "Loading image from furion/decent"
    docker pull furion/decent
    echo "Tagging as DECENT"
    docker tag furion/decent decent
    echo "Installation completed. You may now configure or run the server"
}

deploy() {
    docker tag decent furion/decent
    docker push furion/decent
    echo "Deployment completed."
}

seed_exists() {
    seedcount=$(docker ps -a -f name="^/"$DOCKER_NAME"$" | wc -l)
    if [[ $seedcount -eq 2 ]]; then
        return 0
    else
        return -1
    fi
}

seed_running() {
    seedcount=$(docker ps -f 'status=running' -f name=$DOCKER_NAME | wc -l)
    if [[ $seedcount -eq 2 ]]; then
        return 0
    else
        return -1
    fi
}

start() {
    echo $GREEN"Starting container..."$RESET
    echo "docker run $DPORTS -v /dev/shm:/shm -v "$DATADIR":"$DATADIRD" -d --name $DOCKER_NAME -t decent"
    seed_exists
    if [[ $? == 0 ]]; then
        docker start $DOCKER_NAME
    else

        docker run $DPORTS -v /dev/shm:/shm -v "$DATADIR":"$DATADIRD" -d \
            --name $DOCKER_NAME -t decent
    fi
}

replay() {
    echo "Removing old container"
    docker rm $DOCKER_NAME
    echo "Running DECENT with replay..."
    docker run $DPORTS -v /dev/shm:/shm -v "$DATADIR":"$DATADIRD" -d \
        --name $DOCKER_NAME -t decent decentd --replay
    echo "Started."
}

shm_size() {
    echo "Setting SHM to $1"
    mount -o remount,size=$1 /dev/shm
}

stop() {
    echo $RED"Stopping container..."$RESET
    docker stop $DOCKER_NAME
    docker rm $DOCKER_NAME
}

enter() {
    docker exec -it $DOCKER_NAME bash
}

wallet() {
    docker exec -it $DOCKER_NAME /decent-bin/cli_wallet
}

logs() {
    echo $BLUE"DOCKER LOGS: "$RESET
    docker logs --tail=30 $DOCKER_NAME
    #echo $RED"INFO AND DEBUG LOGS: "$RESET
    #tail -n 30 $DATADIR/{info.log,debug.log}
}

status() {

    seed_exists
    if [[ $? == 0 ]]; then
        echo "Container exists?: "$GREEN"YES"$RESET
    else
        echo "Container exists?: "$RED"NO (!)"$RESET 
        echo "Container doesn't exist, thus it is NOT running. Run $0 build && $0 start"$RESET
        return
    fi

    seed_running
    if [[ $? == 0 ]]; then
        echo "Container running?: "$GREEN"YES"$RESET
    else
        echo "Container running?: "$RED"NO (!)"$RESET
        echo "Container isn't running. Start it with $0 start"$RESET
        return
    fi

}

if [ "$#" -lt 1 ]; then
    help
fi

case $1 in
    build)
        echo "You may want to use '$0 install' for a binary image instead, it's faster."
        build
        ;;
    install)
        install
        ;;
    deploy)
        deploy
        ;;
    start)
        start
        ;;
    replay)
        replay
        ;;
    shm_size)
        shm_size $2
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        sleep 5
        start
        ;;
    rebuild)
        stop
        sleep 5
        build
        start
        ;;
    optimize)
        echo "Applying recommended dirty write settings..."
        optimize
        ;;
    status)
        status
        ;;
    wallet)
        wallet
        ;;
    enter)
        enter
        ;;
    logs)
        logs
        ;;
    *)
        echo "Invalid cmd"
        help
        ;;
esac
