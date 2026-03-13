#!/bin/bash

# 1. Identificar interface ativa e dados do DHCP
INTERFACE=$(nmcli -t -f DEVICE,STATE device | grep ":connected" | cut -d: -f1 | head -n1)
GATEWAY=$(ip route | grep default | awk '{print $3}')
MASK_CIDR=$(ip -o -f inet addr show "$INTERFACE" | awk '{print $4}' | cut -d/ -f2)
NETWORK_PREFIX=$(echo "$GATEWAY" | cut -d. -f1-3)

echo "Interface: $INTERFACE | Gateway: $GATEWAY | Prefixo: $NETWORK_PREFIX"

# 2. Achar o primeiro IP livre na rede (usando fping para rapidez)
echo "Buscando primeiro IP livre..."
FIRST_FREE=""
for i in {2..254}; do
    IP_TEST="$NETWORK_PREFIX.$i"
    if ! ping -c 1 -W 1 "$IP_TEST" > /dev/null 2>&1; then
        FIRST_FREE=$i
        break
    fi
done

echo "Primeiro IP livre base encontrado: . $FIRST_FREE"

# 3. Lógica do IP Alvo (+100)
TARGET_LAST_OCTET=$((FIRST_FREE + 100))

# Se ultrapassar 254, desce até achar vago
if [ $TARGET_LAST_OCTET -gt 254 ]; then
    echo "Soma ultrapassou 254. Buscando para baixo..."
    while [ $TARGET_LAST_OCTET -gt 1 ]; do
        TARGET_IP="$NETWORK_PREFIX.$TARGET_LAST_OCTET"
        if ! ping -c 1 -W 1 "$TARGET_IP" > /dev/null 2>&1; then
            break
        fi
        ((TARGET_LAST_OCTET--))
    done
else
    # Se estiver em uso, sobe até achar vago
    echo "Verificando disponibilidade do IP alvo: $NETWORK_PREFIX.$TARGET_LAST_OCTET"
    while [ $TARGET_LAST_OCTET -lt 255 ]; do
        TARGET_IP="$NETWORK_PREFIX.$TARGET_LAST_OCTET"
        if ! ping -c 1 -W 1 "$TARGET_IP" > /dev/null 2>&1; then
            break
        fi
        ((TARGET_LAST_OCTET++))
    done
fi

FINAL_IP="$NETWORK_PREFIX.$TARGET_LAST_OCTET"
echo "IP Final definido: $FINAL_IP"

# 4. Aplicar as configurações no NetworkManager
CON_NAME=$(nmcli -t -f NAME,DEVICE connection show --active | grep "$INTERFACE" | cut -d: -f1)

nmcli connection modify "$CON_NAME" \
    ipv4.addresses "$FINAL_IP/$MASK_CIDR" \
    ipv4.gateway "$GATEWAY" \
    ipv4.dns "1.1.1.1,1.0.0.1" \
    ipv4.method manual

# Reiniciar a conexão para aplicar
nmcli connection up "$CON_NAME"

echo "Configuração concluída com sucesso!"
