Execução manual em uma máquina

Passo 1 - Abra um terminal e execute o daemon

lua daemon-run-job-queue.lua 127.0.0.1 1111 daemon-code-job-queue.lua


Passo 2 - Abra outros terminais e crie workers

lua worker.lua 127.0.0.1 1111


Passo 3 - Abra mais um terminal e crie o job

lua searchtree-job-queue.lua 127.0.0.1 table-8.txt

