Configuração Automática de IP Estático (Linux Mint 22)
Este script automatiza a transição de uma interface de rede de DHCP para IP Estático em sistemas Linux baseados em Debian/Ubuntu (focado no Linux Mint 22). Ele utiliza uma lógica de varredura para encontrar IPs vagos e aplica as configurações via nmcli.

🚀 Como Funciona a Lógica
Identificação: Detecta a interface ativa, gateway e máscara atuais via DHCP.

Varredura: Procura o primeiro IP livre na sub-rede (através de comandos de eco ICMP/Ping).

Cálculo (+100): Tenta fixar o IP somando 100 ao primeiro IP livre encontrado.

Se o IP resultante for > 254, ele retrocede até encontrar um vago.

Se o IP resultante estiver ocupado, ele avança até encontrar um vago.

Aplicação: Configura o IP, Gateway e DNS (Cloudflare: 1.1.1.1 e 1.0.0.1) de forma persistente no NetworkManager.

🛠 Instalação e Uso via Terminal
Siga os passos abaixo para baixar e executar o script diretamente do repositório:

Bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/nome-do-repositorio.git

# 2. Acesse o diretório
cd nome-do-repositorio

# 3. Dê permissão de execução ao script
chmod +x fixar_ip.sh

# 4. Execute com privilégios de superusuário (sudo)
sudo ./fixar_ip.sh
⚠️ Recomendações de Uso
Abaixo, uma matriz de decisão para ajudar a entender onde este script é um aliado e onde ele pode ser um problema:

✅ Ambientes Recomendados
Laboratórios de Teste: Ambientes controlados onde as máquinas são formatadas com frequência.

Manutenção de Emergência: Quando você precisa fixar um IP rapidamente em uma loja sem acesso à interface do roteador ou ao TI central.

Redes Simples sem Gerenciamento: Pequenos comércios que utilizam roteadores domésticos básicos sem suporte a "Static Lease" (Reserva de IP).

❌ Ambientes NÃO Recomendados (Cuidado!)
Automação Comercial Crítica (PDVs): Em lojas com muitos dispositivos (impressoras, balanças, pinpads), o risco de conflito de IP é alto se um dispositivo estiver desligado no momento da varredura.

Redes com Firewall Rígido: Se a rede bloqueia Pings (ICMP), o script pode identificar IPs ocupados como "livres", causando colisões de rede.

Grandes Corporações: Onde o controle de IP deve ser feito obrigatoriamente via Servidor DHCP/Windows Server para evitar duplicidade no inventário.

🚩 Possíveis Erros e Limitações
Dispositivos Offline: O script não detecta IPs de máquinas que estão desligadas. Se a máquina .110 estiver desligada, o script poderá assumir este IP, causando conflito quando a máquina original for ligada.

Dependência do NetworkManager: O script foi desenhado para sistemas que gerenciam a rede via nmcli. Não funcionará em servidores "Headless" que usam apenas netplan ou /etc/network/interfaces sem o serviço NetworkManager ativo.

Licença: MIT
Contribuições: Sinta-se à vontade para abrir uma Issue ou enviar um Pull Request com melhorias, especialmente na verificação de tabela ARP.
