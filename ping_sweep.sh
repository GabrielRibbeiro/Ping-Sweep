#!/usr/bin/env bash

read -p "Informe a rede: " rede

if [[ -z "$rede" ]];then
    echo -e "\e[033m Erro: Não foi informado nenhuma rede \n Execute  o scritp novamente e  informe o parâmetro novamente \e[0m"
    echo -e "\e[033m Exemplo: $0 192.168.0 \e[0m"
    exit 1
fi
echo -e "\e[033m Realizando Ping Sweep na rede $rede \e[0m"


ping_sweep(){
    ping -c 1 -W 1 ${rede}.$ip | grep "64 bytes" | cut -d ":" -f 1 | cut -d " " -f 4 | tee -a host_ativos.txt &
}

echo -e "\e[033mHosts encontrados: \e[0m"
for ip in $(seq 1 254);do
    ping_sweep
done
wait
