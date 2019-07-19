# GreenTea Supply Chain

### How to deploy GreenTea SupplyChain to the local blockchain.
```
npm install
cd ./truffle-project
./1_start_ganache-cli.sh
./truffle-compile.sh
./truffle-migrate.sh
cd ..
npm run packaging # this copies all needed files to truffle-project/dist
npm start # this launches an instance of lite-server listening on 8080.
open http://localhost:8080 with your favorite browser.
```

### project write-up
check-out ./project-write-up.md
