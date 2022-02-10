# ckjudgedumper

A efficient dumper that written in shell script download all problems and submitted code from NCKU CSIE program design I judge server - [CKJudge](https://ckj.csie.ncku.edu.tw/#/).

## requirement

before using this script you need to install several package

+ ubuntu 
```bash
sudo apt install pandoc curl jq
```

## usage

run the command below and all data will save at ``$(pwd)/ckjudge/``

``` bash
bash ckjudgedumper.sh <ckjudge cookie>
```

here is how to get cookies

+ first open your browser and login into [CKJudge](https://ckj.csie.ncku.edu.tw/#/)

![](https://i.imgur.com/KzJb3M6.png)

+ after logged in, press F12 on keyboard or right click on webpage choose `檢查`

![](https://i.imgur.com/GvpLukM.png)

+ then choose tab `應用程式` from the navbar

![](https://i.imgur.com/fCorfA9.png)

+ double click at the value which 名稱 column is `connect.sid` and copy that value

![](https://i.imgur.com/ImYXxa1.png)

+ Last but not least, open a Terminal and type (or copy / paste) the following command (with your own cookies fill in) in , then press Enter.

```bash
./ckjudgedumper.sh connect.sid=<your cookies which copied to clipboard previously>
```