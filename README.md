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
./task_answer.sh: line 12: ifconfig: command not found


Mon Sep 28 08:36:30 UTC 2020
```
