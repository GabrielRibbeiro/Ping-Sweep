#!/bin/bash

# Definir o endereço da rede, definia a  faixa de  rede .
network="172.30.0"

# Função de ping individual
ping_sweep() {
    ip=$1
    # Usando o parâmetro -W para definir o timeout de espera do ping
    ping -c 1 -W 1 ${network}.$ip | grep "64 bytes" & # Coloca o ping em paralelo
}

# Executando o ping sweep para os IPs de 1 a 254
for ip in $(seq 1 254); do
    ping_sweep $ip
done

# Espera todos os pings terminarem
wait
