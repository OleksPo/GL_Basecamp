FROM ubuntu:18.04

COPY ["page", "task_answer.sh"] .

EXPOSE 4321:4321

ENTRYPOINT [ "./task_answer.sh" ]

