#!/usr/bin/env bash

# Função para exibir ajuda do script
mostrar_ajuda() {
    echo -e "\e[33mUso: $0 [-r REDE] [-t TIMEOUT] [-c CONTAGEM] [-o ARQUIVO] [-v]\e[0m"
    echo -e "\e[33mParâmetros:\e[0m"
    echo -e "\t-r REDE\t\tInforme o bloco de rede no formato 192.168.0"
    echo -e "\t-t TIMEOUT\tDefina o tempo limite (em segundos) para cada resposta (padrão: 1)"
    echo -e "\t-c CONTAGEM\tNúmero de pacotes ICMP a serem enviados (padrão: 1)"
    echo -e "\t-o ARQUIVO\tSalve os resultados em um arquivo de log"
    echo -e "\t-v\t\tModo verbose: exibe detalhes adicionais no terminal"
    exit 0
}

# Variáveis padrão
timeout=1
contagem=1
arquivo_log=""
verbose=0

# Processa os parâmetros da linha de comando
while getopts "r:t:c:o:vh" opt; do
    case $opt in
        r) rede="$OPTARG" ;;
        t) timeout="$OPTARG" ;;
        c) contagem="$OPTARG" ;;
        o) arquivo_log="$OPTARG" ;;
        v) verbose=1 ;;
        h) mostrar_ajuda ;;
        *) mostrar_ajuda ;;
    esac
done

# Validações da entrada
if [[ -z "$rede" ]]; then
    echo -e "\e[31mErro: Nenhuma rede informada. Use a opção -r para especificar.\e[0m"
    mostrar_ajuda
fi

if ! [[ "$rede" =~ ^([0-9]{1,3}\.){2}[0-9]{1,3}$ ]]; then
    echo -e "\e[31mErro: O valor informado não é uma rede válida. Exemplo: 192.168.0\e[0m"
    exit 1
fi

echo -e "\e[32mIniciando Ping Sweep na rede $rede com timeout $timeout e $contagem pacote(s)...\e[0m"

# Valida a existência do comando ping
if ! command -v ping > /dev/null 2>&1; then
    echo -e "\e[31mErro: O comando 'ping' não está disponível no sistema.\e[0m"
    exit 1
fi

# Configura arquivo de log
if [[ -n "$arquivo_log" ]]; then
    echo -e "\e[33mResultados serão salvos em $arquivo_log\e[0m"
    echo "Ping Sweep iniciado em $(date)" > "$arquivo_log"
fi

# Função de Ping Sweep
ping_sweep() {
    local ip="${rede}.$1"
    resultado=$(ping -c "$contagem" -W "$timeout" "$ip" 2>/dev/null | grep "64 bytes")
    if [[ -n "$resultado" ]]; then
        host_ativo=$(echo "$resultado" | cut -d " " -f 4 | cut -d ":" -f 1)
        if [[ "$verbose" -eq 1 ]]; then
            echo -e "\e[32mHost ativo: $host_ativo\e[0m"
        else
            echo "$host_ativo"
        fi
        [[ -n "$arquivo_log" ]] && echo "$host_ativo" >> "$arquivo_log"
    fi
}

# Executa Ping Sweep com controle de processos
echo -e "\e[33mVarredura em andamento...\e[0m"
for ip in $(seq 1 254); do
    ping_sweep "$ip" &
    while [[ $(jobs -r | wc -l) -ge 50 ]]; do
        sleep 0.1
    done
done
wait

echo -e "\e[32mVarredura concluída! Resultados salvos em: ${arquivo_log:-'saída do terminal'}\e[0m"
