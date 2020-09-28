# task_answers
answer for #50 of selection quiz to GlobalLogic Kharkiv BaseCamp
One-line web server was packed to docker image.
Docker container works on port 4321.

Please run the command `docker pull olekspo/task_answer:latest`
then `docker run -d olekspo/task_answer:latest`

In your browser on port 4321 you might see some like this:

```
************PRINT SOME TEXT***************
Hello World!!!

Resources:
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 7  0      2    292    142   1085    0    0   121    59  561 1000 10  4 84  1  0

Addresses:
br-11976e2b5f5e: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.18.0.1  netmask 255.255.0.0  broadcast 172.18.255.255
        ether 02:42:10:bf:4e:5b  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:1dff:fe2c:2563  prefixlen 64  scopeid 0x20<link>
        ether 02:42:1d:2c:25:63  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 5  bytes 550 (550.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 9001
        inet 192.168.21.180  netmask 255.255.255.128  broadcast 192.168.21.255
        inet6 fe80::89a:3fff:fe09:38c0  prefixlen 64  scopeid 0x20<link>
        ether 0a:9a:3f:09:38:c0  txqueuelen 1000  (Ethernet)
        RX packets 10887  bytes 3868981 (3.8 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 7477  bytes 1365092 (1.3 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 888  bytes 88244 (88.2 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 888  bytes 88244 (88.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

Mon Sep 28 08:36:30 UTC 2020
```
