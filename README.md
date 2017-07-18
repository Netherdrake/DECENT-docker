### Requirements
Make sure you have docker installed, and that your user is in the docker group.
```
usermod -aG docker $(whoami)
```


### Usage
```
% ./run.sh
Usage: ./run.sh COMMAND [DATA]

Commands:
    install - pulls latest docker image from server (no compiling)
    build - only builds DECENT container (from docker file)
    rebuild - builds DECENT container (from docker file), and then restarts it

    replay - starts DECENT container (in replay mode)

    start - starts DECENT container
    stop - stops DECENT container
    restart - restarts DECENT container

    wallet - open cli_wallet in the container
    enter - enter a bash session in the container

    status - show status of DECENT container
    logs - show all logs inc. docker logs, and DECENT logs
```


### Miner Setup
First, lets build the container.
```
./run.sh build
```

Add your miner-id and private-key to `config.ini`.
```
vim data/decentd/config.ini
```

Start the container.
```
./run.sh start
```

### Accessing the cli_wallet
After you've built your container, start it.
```
./run.sh start
```

To attach to the running container, and access the wallet, simply run:
```
./run.sh wallet
```

### Thank you
Pull Requests with fixes and improvements are welcome.  
If you found this tool useful, please consider voting for miner `furion`.
```
vote_for_miner <your-account-name> furion true true
```

### Credits
This project is based on someguy123's [peerplays-docker](https://github.com/Someguy123/peerplays-docker).
