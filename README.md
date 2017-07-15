### Usage
```
% ./run.sh
Usage: ./run.sh COMMAND [DATA]

Commands: 
    start - starts DECENT container
    replay - starts DECENT container (in replay mode)
    shm_size - resizes /dev/shm to size given, e.g. ./run.sh shm_size 10G 
    stop - stops DECENT container
    status - show status of DECENT container
    restart - restarts DECENT container
    install - pulls latest docker image from server (no compiling)
    rebuild - builds DECENT container (from docker file), and then restarts it
    build - only builds DECENT container (from docker file)
    logs - show all logs inc. docker logs, and DECENT logs
    wallet - open cli_wallet in the container
    enter - enter a bash session in the container
```

### Credits
This project is based on someguy123's [peerplays-docker](https://github.com/Someguy123/peerplays-docker).
