THX Service

Ferramenta em Bash para ativação e registro de serviço local em dispositivos Android via ADB (rodando no Termux), com foco em coleta e organização de logs para análise técnica.

---

📌 Objetivo

O THX Service foi desenvolvido para:

- Verificar o status de um serviço local
- Registrar data e hora de ativação
- Preparar o ambiente de logs ("logcat")
- Auxiliar na análise de comportamento do sistema

---

🧪 Logs e análise

O Android utiliza o sistema de logs ("logcat") para registrar eventos do sistema, incluindo:

- Execução de processos
- Eventos de apps
- Mensagens do sistema
- Erros e warnings

🔍 Por que isso importa?

Logs são fundamentais para:

- Diagnóstico de comportamento inesperado
- Debug de aplicações
- Análise de estabilidade
- Monitoramento de eventos em tempo real

«O THX Service facilita a preparação do ambiente para esse tipo de análise.»

---



---

🔐 Boas práticas

- Utilize apenas em dispositivos próprios
- Evite modificar arquivos críticos do sistema
- Não utilize logs para violar termos de uso de aplicativos

---

🚀 Requisitos

- Android com ADB ativado (USB ou Wireless)
- Termux instalado
- Pacote ADB:

pkg install android-tools

---

▶️ Uso

chmod +x thx_service.sh
./thx_service.sh

---

🧠 Observação

Este projeto é voltado para uso educacional e diagnóstico técnico.
Não garante compatibilidade com todos os dispositivos ou versões do Android.

---

📄 Licença

Uso livre para fins de estudo e modificação.