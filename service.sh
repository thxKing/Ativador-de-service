echo ""
echo ""
echo "========================================="
echo ""
echo "[+] eyes of god"
echo""
echo "[!] made by SavageGod"
echo ""
echo "========================================="
echo ""
echo ""
echo "[+] VERIFICAÇÃO DE ORIGEM DA INSTALAÇÃO"
echo ""

PKG_TARGET="com.dts.freefireth"
RAW_OUTPUT=$(pm list packages -i "$PKG_TARGET" 2>/dev/null)
INSTALLER_ID=$(echo "$RAW_OUTPUT" | awk -F'installer=' '{print $2}' | tr -d '\r\n')

get_installer_name() {
    case "$1" in
        "com.android.vending") echo "Google Play Store" ;;
        "com.sec.android.app.samsungapps") echo "Samsung Galaxy Store" ;;
        "com.huawei.appmarket") echo "Huawei AppGallery" ;;
        "com.xiaomi.market") echo "Xiaomi GetApps" ;;
        "com.android.packageinstaller") echo "Instalador do Sistema (APK Manual)" ;;
        "com.google.android.packageinstaller") echo "Instalador do Google (APK Manual)" ;;
        "com.apkpure.aegon") echo "APKPure" ;;
        "com.taptap") echo "TapTap Store" ;;
        "com.uptodown.installer") echo "Bypass Luxe 🤣" ;;
        "com.amazon.venezia") echo "Amazon Appstore" ;;
        "null") echo "Instalação Forçada/ADB/Backup (Sem registro)" ;;
        "") echo "Desconhecido/Backup Titanium" ;;
        *) echo "$1" ;; 
    esac
}

echo "[+] Analisando assinatura do instalador..."
echo ""

if [ -z "$RAW_OUTPUT" ]; then
    echo "[!] ERRO: Free Fire não encontrado no sistema."
else
    # Lógica de verificação
    if [ "$INSTALLER_ID" == "com.android.vending" ]; then
        echo "[+] App instalado via Google Play Store."
        echo""
        echo "[+] STATUS: ÍNTEGRO"
    else
        NOME_INSTALADOR=$(get_installer_name "$INSTALLER_ID")
        
        echo ""
        echo "[!] ALERTA CRÍTICO: FONTE DE INSTALAÇÃO NÃO OFICIAL"
        echo ""
        echo "[!] O jogo NÃO foi baixado da Play Store."
        echo ""
        echo "[!] INSTALADOR MALICIOSO DETECTADO: $NOME_INSTALADOR"
    fi
fi
echo ""


MOUNT_FAIL=0 
echo "[+] Verificando sobreposição de arquivos (Mount/Overlay)..."
if grep -q "com.dts.freefireth" /proc/mounts; then
  echo "[!] DETECTADO: Arquivos do jogo estão sendo sobrepostos via Mount!"
  MOUNT_FAIL=1
fi

echo ""
echo ""
echo "========================================="
echo ""
echo ""
echo "[+] Procurando por códigos injetados na memória..."
for pid in $(pidof com.dts.freefireth); do
    if grep -qE "Dobby|Substrate|Frida|Xposed|libvxp|Hook" /proc/$pid/maps 2>/dev/null; then
        echo "[!] INJEÇÃO DETECTADA NO PROCESSO $pid"
    fi
done

echo ""
echo ""
echo "========================================="
echo ""
echo ""
echo "[+] VERIFICANDO APPS ABERTOS PÓS-PARTIDA"
echo ""

APPS=0
LIMITE_MINUTOS=80   # ajuste para 30 se quiser

MONITOR_APPS="
ru.zdevs.zarchiver
bin.mt.plus
com.termux
com.android.vending
com.a0soft.gphone.uninstaller
com.rs.explorer.filemanager
com.ace.ex.filemanager
com.alphainventor.filemanager
com.rxfileexplorer
com.google.android.apps.docs
com.android.packageinstaller
com.google.android.packageinstaller
com.miui.securitycenter
"

get_app_name() {
case "$1" in
ru.zdevs.zarchiver) echo "ZArchiver" ;;
com.miui.securitycenter) echo "Segurança (Xiaomi)" ;;
com.android.packageinstaller) echo "Instalador de Pacotes (Sistema)" ;;
com.google.android.packageinstaller) echo "Instalador de Pacotes (Google)" ;;
bin.mt.plus) echo "MT Manager" ;;
com.termux) echo "Termux" ;;
com.google.android.apps.docs) echo "Google Drive" ;;
com.android.vending) echo "Play Store" ;;
com.a0soft.gphone.uninstaller) echo "App Usage" ;;
com.rs.explorer.filemanager) echo "RS Gerenciador de Arquivos" ;;
com.ace.ex.filemanager) echo "EX Gerenciador de Arquivos" ;;
com.alphainventor.filemanager) echo "File Manager Plus" ;;
com.rxfileexplorer) echo "Rx File Explorer" ;;
*) echo "$1" ;;
esac
}

UPTIME=$(cut -d. -f1 /proc/uptime)
HZ=$(getconf CLK_TCK)

for PKG in $MONITOR_APPS; do
PID=$(pidof $PKG 2>/dev/null | awk '{print $1}')
[ -z "$PID" ] && continue

START_TICKS=$(awk '{print $22}' /proc/$PID/stat 2>/dev/null)
[ -z "$START_TICKS" ] && continue

START_SEC=$((START_TICKS / HZ))
DELTA_SEC=$((UPTIME - START_SEC))
DELTA_MIN=$((DELTA_SEC / 60))

if [ "$DELTA_MIN" -le "$LIMITE_MINUTOS" ]; then
APP_NAME=$(get_app_name "$PKG")
echo "[!] AVISO: Usuário abriu $APP_NAME há $DELTA_MIN minutos"
APPS=1
fi
done

if [ "$APPS" -eq 0 ]; then
echo "[+] Nenhum aplicativo aberto..."
fi
echo ""
echo ""

echo "========================================="
echo ""
echo ""
ROOT_DETECTED=0

alert() {
    echo "[!] ROOT DETECTADO: $1"
    ROOT_DETECTED=1
}

echo "[+] Iniciando verificação avançada de Root"
echo ""
# 1. Comando su acessível
command -v su >/dev/null 2>&1 && alert "Comando su acessível"

# 2. BusyBox acessível
command -v busybox >/dev/null 2>&1 && alert "BusyBox presente"

# 3. Propriedades críticas (rom/root adulterado)
getprop ro.debuggable | grep -q "^1$" && alert "ro.debuggable=1"
getprop ro.secure | grep -q "^0$" && alert "ro.secure=0"
getprop service.adb.root | grep -qi "1" && alert "ADB Root ativo"

# 4. Propriedades associadas a root oculto (sem regex complexo)
getprop | grep -qi magisk   && alert "Propriedade Magisk encontrada"
getprop | grep -qi zygisk   && alert "Propriedade Zygisk encontrada"
getprop | grep -qi kernelsu && alert "Propriedade KernelSU encontrada"
getprop | grep -qi lspd     && alert "Propriedade LSPosed encontrada"

# 5. Varredura ampla de pacotes suspeitos (string scan)
pm list packages | grep -qi magisk    && alert "Pacote relacionado a Magisk"
pm list packages | grep -qi kernelsu  && alert "Pacote relacionado a KernelSU"
pm list packages | grep -qi supersu   && alert "Pacote relacionado a SuperSU"
pm list packages | grep -qi superuser && alert "Pacote relacionado a Superuser"
pm list packages | grep -qi lsposed   && alert "Pacote relacionado a LSPosed"
pm list packages | grep -qi lspatch   && alert "Pacote relacionado a LSPatch"
pm list packages | grep -qi xposed    && alert "Pacote relacionado a Xposed"
pm list packages | grep -qi edxposed  && alert "Pacote relacionado a EdXposed"
pm list packages | grep -qi shizuku   && alert "Pacote relacionado a Shizuku"
pm list packages | grep -qi iadb      && alert "Pacote relacionado a iADB"
pm list packages | grep -qi frida     && alert "Pacote relacionado a Frida"

# 6. Checagem direta de pacotes críticos (redundância proposital)
for PKG in \
com.topjohnwu.magisk \
me.weishu.kernelsu \
eu.chainfire.supersu \
com.koushikdutta.superuser \
com.noshufou.android.su \
org.lsposed.manager \
org.lsposed.lspatch \
moe.shizuku.privileged.api \
com.github.iadb \
com.frida.server; do

    pm list packages | grep -q "$PKG" && alert "Pacote instalado: $PKG"
done

# Resultado final
if [ "$ROOT_DETECTED" -eq 1 ]; then
echo""
    echo "[!] ROOT / AMBIENTE ADULTERADO DETECTADO"
fi
echo""

echo "[+] Analisando integridade de diretórios do sistema..."
SISTEMA_LINKS="/system/bin/su /system/xbin/su /sbin/su /vendor/bin/su /system/sd/xbin/su"

for link in $SISTEMA_LINKS; do
    if [ -L "$link" ] || [ -e "$link" ]; then
        echo "[!] ROOT DETECTADO: Binário 'su' encontrado em: $link"
        ROOT_CONFIRMADO=1
    fi
done
echo""
echo "[+] Checando flags de depuração do sistema..."
DEBUG=$(getprop ro.debuggable)
TAGS=$(getprop ro.build.tags)

if [ "$DEBUG" == "1" ] || [[ "$TAGS" == *"test-keys"* ]]; then
    echo "[!] AMBIENTE INSEGURO: O Kernel deste aparelho foi modificado (Custom ROM/Root)."
    ROOT_CONFIRMADO=1
fi
echo""
echo "[+] Buscando diretórios residuais de frameworks..."
DIRS="/data/adb /data/magisk /data/adb/modules /data/adb/ksu"
for d in $DIRS; do
    ls "$d" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "[!] ROOT DETECTADO: Pasta de controle encontrada ($d)."
        ROOT_CONFIRMADO=1
    fi
done


echo ""

echo "[+] Verificando estado do SELinux..."
SE_STATUS=$(getenforce 2>/dev/null)
if [ "$SE_STATUS" = "Permissive" ] || [ "$SE_STATUS" = "Disabled" ]; then
    alert_root "SELinux adulterado (Estado: $SE_STATUS)"
    echo "    -> Um Android original deve estar sempre em 'Enforcing'."
fi
echo ""

echo "[+] Sondagem de KernelSU (KSU)..."

if cat /proc/version | grep -qiE "ksu|kernelsu"; then
    alert_root "KernelSU detetado na assinatura do Kernel!"
fi

if pm list packages | grep -q "me.weishu.kernelsu"; then
    alert_root "Gestor KernelSU instalado."
fi
echo ""

echo "[+] Verificando serviços de sistema..."
if service list | grep -iq "magisk"; then
    alert_root "Serviço do sistema 'magisk' detetado em execução!"
fi

echo ""
if [ "$ROOT_DETECTED" -eq 1 ]; then
    echo "[!] RESULTADO: ACESSO ROOT CONFIRMADO [!]"
    echo "[!] O ambiente não é seguro."
else
    echo "[+] NENHUM ROOT DETETADO (Scan Profundo Limpo)"
fi
echo ""
echo ""
echo "========================================="

echo""
echo ""
echo "[+] VERIFICANDO BOOTLOADER..."
BOOTLOADER_FLAG=0

echo""

alert2() {
    echo "[!] FALHA DETECTADA: $1"
    BOOTLOADER_FLAG=1
}

echo "[+] Iniciando verificação de Bootloader (Brevent)"
echo ""

# 1. Flash lock (muito forte)
getprop ro.boot.flash.locked | grep -q "^0$" && \
alert2 "Bootloader DESBLOQUEADO (flash.locked=0)"

# 2. Estado do dispositivo (vbmeta)
getprop ro.boot.vbmeta.device_state | grep -qi "unlocked" && \
alert2 "Bootloader DESBLOQUEADO (vbmeta.device_state)"

# 3. Verified Boot State
getprop ro.boot.verifiedbootstate | grep -qi "orange" && \
alert2 "Verified Boot ORANGE (bootloader desbloqueado)"

getprop ro.boot.verifiedbootstate | grep -qi "yellow" && \
alert2 "Verified Boot YELLOW (boot alterado)"

# 4. AVB desativado ou quebrado
getprop ro.boot.avb_version | grep -qi "^$" && \
alert2 "AVB ausente (possível bootloader desbloqueado)"

# 5. Warranty bit / tamper (Samsung e outros)
getprop ro.boot.warranty_bit | grep -q "^1$" && \
alert2 "Warranty Bit acionado (bootloader já desbloqueado)"

getprop ro.warranty_bit | grep -q "^1$" && \
alert2 "Warranty Bit acionado (sistema)"

# 6. Boot state genérico
getprop ro.boot.bootstate | grep -qi "orange" && \
alert2 "Bootstate ORANGE (bootloader desbloqueado)"

# 7. Flags comuns deixadas após unlock (pós-lock fake)
getprop ro.boot.force_normal_boot | grep -q "^0$" && \
alert2 "Force Normal Boot desativado"

# Resultado final
if [ "$BOOTLOADER_FLAG" -eq 1 ]; then
    echo "[!] BOOTLOADER DESBLOQUEADO OU JÁ DESBLOQUEADO"
else
    echo "[+] BOOTLOADER PADRÃO"
fi
echo""
echo""
echo "========================================="
echo ""
echo""
OBB_SHADERS=0
echo "[+] VERIFICANDO SHADERS"
echo ""
echo "[+] VERIFICANDO INTEGRIDADE DOS SHADERS..."
echo""
# Remova o asterisco da variável de caminho fixo para evitar confusão
DIR_PATH="/sdcard/Android/data/com.dts.freefireth/files/contentcache/Optional/android/gameassetbundles"

shader_flag=0

# wildcard fora das aspas
FILE=$(ls $DIR_PATH/shaders.* 2>/dev/null | head -n 1)

# tamanho esperado
TAMANHO_ORIGINAL=1333122

if [ -z "$FILE" ]; then
    echo "[?] MÓDULO SHADERS: ARQUIVO NÃO ENCONTRADO"

elif [ ! -f "$FILE" ]; then
    echo "[?] MÓDULO SHADERS: CAMINHO INVÁLIDO OU NÃO É ARQUIVO"

else
    TAMANHO_ATUAL=$(stat -c %s "$FILE" 2>/dev/null)

    if [ -z "$TAMANHO_ATUAL" ]; then
        echo "[?] MÓDULO SHADERS: FALHA AO OBTER TAMANHO DO ARQUIVO"

    elif [ "$TAMANHO_ATUAL" != "$TAMANHO_ORIGINAL" ]; then
        echo "[!] DETECTADO: ARQUIVO DE SHADER MODIFICADO (TAMANHO INVÁLIDO)"
        echo "    ESPERADO : $TAMANHO_ORIGINAL BYTES"
        echo "    ENCONTRADO: $TAMANHO_ATUAL BYTES"
        shader_flag=1

    else
        echo "[+] MÓDULO SHADERS: TAMANHO ÍNTEGRO"
    fi
fi

echo""
# caminhos
REPLAYS_DIR="/storage/emulated/0/Android/data/com.dts.freefireth/files/MReplays"
DIR_PATH="/storage/emulated/0/Android/data/com.dts.freefireth/files/contentcache/Optional/android/gameassetbundles"

# penúltimo replay
penultimate_replay=$(ls -t "$REPLAYS_DIR" 2>/dev/null | sed -n '2p')

# shader mais recente (qualquer nome que comece com shaders.)
latest_shader=$(ls $DIR_PATH/shaders.* 2>/dev/null | head -n 1)

[ -z "$penultimate_replay" ] 
[ -z "$latest_shader" ] 

replay_path="$REPLAYS_DIR/$penultimate_replay"

replay_sec=$(stat -c %Y "$replay_path" 2>/dev/null)
shader_sec=$(stat -c %Y "$latest_shader" 2>/dev/null)

[ -z "$replay_sec" ] 
[ -z "$shader_sec" ] 

diff=$(( shader_sec - replay_sec ))
abs_diff=$diff
[ "$abs_diff" -lt 0 ] && abs_diff=$(( -abs_diff ))

limite_30min=1800
limite_dia=86400

# ignora se for coisa muito antiga (dias)
[ "$abs_diff" -gt "$limite_dia" ] 

if [ "$shader_sec" -ge "$replay_sec" ]; then
    echo "[!] arquivo modificado pós-partida"
    echo "[!] bypass detectado"
else
    if [ "$abs_diff" -le "$limite_30min" ]; then
        echo "[!] shaders modificada antes de começar a partida"
        echo "[!] bypass detectado"
    fi
fi
echo ""
echo "========================================="
echo ""
echo ""
echo "[+] VERIFICANDO REPLAY"
echo ""

pkg="com.dts.freefireth"
mreplays_dir="/sdcard/Android/data/com.dts.freefireth/files/mreplays"
replay_flag=0

# tempo de instalação do app (segundos unix)
install_time_sec=$(dumpsys package "$pkg" 2>/dev/null \
    | grep firstInstallTime \
    | cut -d= -f2 \
    | xargs -I{} date -D "%Y-%m-%d %H:%M:%S" -d "{}" +%s 2>/dev/null)

# tempo de acesso da pasta mreplays
if [ -d "$mreplays_dir" ]; then
    mreplays_access_sec=$(stat -c %X "$mreplays_dir" 2>/dev/null)
else
    mreplays_access_sec=""
fi

latest_bin=$(ls -t "$mreplays_dir"/*.bin 2>/dev/null | head -1)
latest_json=$(ls -t "$mreplays_dir"/*.json 2>/dev/null | head -1)

if [ -n "$latest_bin" ] && [ -n "$latest_json" ]; then

    # timestamps completos (com nanos)
    bin_access=$(stat -c %x "$latest_bin" 2>/dev/null)
    bin_modify=$(stat -c %y "$latest_bin" 2>/dev/null)
    bin_change=$(stat -c %z "$latest_bin" 2>/dev/null)

    json_access=$(stat -c %x "$latest_json" 2>/dev/null)
    json_modify=$(stat -c %y "$latest_json" 2>/dev/null)
    json_change=$(stat -c %z "$latest_json" 2>/dev/null)

    # detecção 1: replay copiado (timestamps exatamente iguais)
    if [ "$bin_access" = "$bin_modify" ] && \
       [ "$bin_modify" = "$bin_change" ] && \
       [ "$json_access" = "$json_modify" ] && \
       [ "$json_modify" = "$json_change" ]; then

        echo "[!] PASSADOR DE REPLAY DETECTADO"
        echo "[!] ACCESS, MODIFY, E CHANGE IGUAIS"
        replay_flag=1
    fi

    # detecção 2: pasta mreplays acessada após instalação
    if [ -n "$install_time_sec" ] && [ -n "$mreplays_access_sec" ]; then
        if [ "$mreplays_access_sec" -gt "$install_time_sec" ]; then
            echo "[!] PASSADOR DE REPLAY DETECTADO"
            echo "[!] PASTA MREPLAYS ACESSADA APÓS A INSTALAÇÃO"
            replay_flag=1
        fi
    fi
fi

if [ "$replay_flag" -eq 0 ]; then
    echo "[+] NENHUMA ALTERAÇÃO SUSPEITA DETECTADA"
fi
echo""
echo""
echo "=========================================="
echo ""
echo ""
echo "[+] Verificando data/hora..."
TIME_TAMPER=0
BOOT_TIME=$(cut -d. -f1 /proc/stat | grep btime | awk '{print $2}')
NOW_TIME=$(date +%s)

DELTA=$((NOW_TIME - BOOT_TIME))
UPTIME_SEC=$(cut -d. -f1 /proc/uptime)

# se a diferença for absurda, houve ajuste manual
if [ $DELTA -lt $UPTIME_SEC ] || [ $DELTA -gt $((UPTIME_SEC + 300)) ]; then
  echo "[!] POSSÍVEL ALTERAÇÃO MANUAL DE DATA/HORA"
  TIME_TAMPER=1
fi

AUTO_TIME=$(settings get global auto_time 2>/dev/null)
AUTO_TZ=$(settings get global auto_time_zone 2>/dev/null)

if [ "$AUTO_TIME" = "0" ] || [ "$AUTO_TZ" = "0" ]; then
  echo "[!] DATA/HORA AUTOMÁTICA DESATIVADA"
  TIME_TAMPER=1
fi
echo""
echo ""
echo "========================================="
VPN_DETECTED=0
echo ""
echo ""
echo "[+] VERIFICANDO APPS DE VPN INSTALADOS"
echo ""

VPN_APPS="
com.nordvpn.android
com.expressvpn.vpn
com.protonvpn.android
ch.protonvpn.android
com.surfshark.vpnclient.android
com.cyberghostvpn.android
com.privateinternetaccess.android
net.mullvad.mullvadvpn
com.windscribe.vpn
com.tunnelbear.android
com.ivacy
com.gaditek.purevpnics
com.goldenfrog.vyprvpn.app
com.strongvpn
com.keepsolid.vpnunlimited
com.speedify.speedifyandroid
com.zoogvpn.android
com.atlasvpn.android
com.urbanvpn.android
com.totalvpn
com.fsecure.freedome.android
com.cloudflare.onedotonedotonedotonedot
com.cloudflare.onedotonedotonedotonedot.dev
com.cloudflare.warp
com.opera.max.global
net.openvpn.openvpn
net.openvpn.openvpn3
com.wireguard.android
org.torproject.android
org.torproject.orbot
org.torproject.torbrowser
com.pandasecurity.pandaav
com.norton.secure.vpn
com.free.vpn.unblock.supervpn
com.free.vpn.unblock.superunlimited
com.free.vpn.unblock.secure.vpn
com.free.vpn.unblock.masters
com.fast.free.unblock.thunder.vpn
free.vpn.unblock.turbo
com.vpnify
com.free.vpn.unblock.betternet
com.ultrasurf.ultravpn
com.psiphon3
com.psiphon3.subscription
org.getlantern.lantern
com.tachyonvpn.android
com.free.vpn.unblock.snapvpn
com.free.vpn.unblock.melon
com.dewvpn.android
com.leafvpn.free
com.free.vpn.unblock.pandavpn
com.octohide.vpn
com.melonvpn.free
com.secure.vpn
com.fastvpn.unblock
com.snap.vpn.free
com.master.vpn.unblock
com.unblock.vpn.free
com.vpn.super.fast
com.v2ray.ang
com.v2ray.v2fly
com.github.kr328.clash
com.github.kr328.clash.foss
io.nekohasekai.sagernet
io.nekohasekai.sagernet.plugin
com.shadowrocket.android
com.shadowsocks.android
com.shadowsocksr.android
com.outline.vpn
org.outline.android.client
com.brook.app
com.ssr.android
com.ssrplus.android
com.intra
dnschanger.vpn
dnschanger.fast
dnschanger.secure
com.cloudflare.dns
com.adguard.android
com.blokada.origin.alarm
com.blokada.sex
com.blokada.five
com.anonymox.vpn
com.proxy.unblock.vpn
com.vpn.unblock.android
com.secure.fast.vpn
com.shadow.vpn.unblock
com.rocket.vpn
com.dragon.vpn
com.turbo.master.vpn
com.flash.vpn
com.lightning.vpn
com.go.vpn
com.easy.vpn
com.best.vpn.unblock
com.king.vpn
com.super.fast.vpn.free
se.leap.riseupvpn
com.vpn.lat
"

for VPN in $VPN_APPS; do
  if pm list packages | grep -q "$VPN"; then
    echo "[!] APP VPN INSTALADO: $VPN"
    VPN_DETECTED=1
  fi
done

if [ "$VPN_DETECTED" -eq 0 ]; then
  echo "[+] Nenhum app de VPN detectado"
fi

echo ""


echo""
echo "========================================="
echo ""
echo""
echo "[+] Verificando reinicialização recente do sistema"
echo ""

REBOOT_FLAG=0

# uptime em segundos (primeiro valor do /proc/uptime)
uptime_seconds=$(cut -d'.' -f1 /proc/uptime 2>/dev/null)

if [ -n "$uptime_seconds" ]; then

    # 60 minutos = 3600 segundos
    LIMITE_SEG=3600

    if [ "$uptime_seconds" -lt "$LIMITE_SEG" ]; then
        echo "[!] DISPOSITIVO REINICIADO RECENTEMENTE"
        REBOOT_FLAG=1
    fi

fi

if [ "$REBOOT_FLAG" -eq 0 ]; then
    echo "[+] Nenhuma reinicialização recente detectada."
fi
echo ""
echo ""
echo "========================================="
echo""
echo ""
echo "[+] Verificando alterações recentes em diretórios sensíveis"
echo ""

DIR1="/storage/emulated/0/Android/data/com.dts.freefireth/files/contentcache/Optional/android/optionalavatarres"
DIR2="/storage/emulated/0/Android/data/com.dts.freefireth/files/contentcache/Optional/android/gameassetbundles"

LIMITE_MIN=30
AGORA=$(date +%s)
ALTERACAO_DETECTADA=0

check_dir_activity() {
    DIR_PATH="$1"
    DIR_NAME="$2"

    if [ -d "$DIR_PATH" ]; then
        STAT_OUT=$(stat "$DIR_PATH" 2>/dev/null)

        ACCESS_TIME=$(echo "$STAT_OUT" | grep "Access:" | head -1 | cut -d' ' -f2-)
        MODIFY_TIME=$(echo "$STAT_OUT" | grep "Modify:" | cut -d' ' -f2-)
        CHANGE_TIME=$(echo "$STAT_OUT" | grep "Change:" | cut -d' ' -f2-)

        for TIPO in ACCESS MODIFY CHANGE; do
            TIME_VAR=$(eval echo \${${TIPO}_TIME})

            if [ -n "$TIME_VAR" ]; then
                TIME_SEC=$(date -d "$TIME_VAR" +%s 2>/dev/null)
                DELTA_MIN=$(( (AGORA - TIME_SEC) / 60 ))

                if [ "$DELTA_MIN" -ge 0 ] && [ "$DELTA_MIN" -le "$LIMITE_MIN" ]; then
                    echo "[!] Alteração recente detectada em $DIR_NAME"
                    echo "[!] Tipo: $TIPO"
                    echo "[+] Hora atual: $(date)"
                    echo "[+] Hora da alteração: $TIME_VAR"
                    echo ""
                    ALTERACAO_DETECTADA=1
                    break
                fi
            fi
        done
    fi
}

check_dir_activity "$DIR1" "optionalavatarres"
check_dir_activity "$DIR2" "gameassetbundles"

if [ "$ALTERACAO_DETECTADA" -eq 0 ]; then
    echo "[+] Nenhuma alteração recente detectada."
fi
echo ""
echo ""
echo "========================================="
echo ""
echo ""
echo "[+] VARREDURA DO SISTEMA (ARQUIVOS SUSPEITOS)"
echo ""

FILE_SCAN=0
WHITELIST="/storage/emulated/0/Download/savagegod.apk"
# Diretórios acessíveis sem root (REAIS)
SEARCH_PATHS="
/storage/emulated/0
"

# Palavras-chave suspeitas
KEYS2="modmenu|wallhack|holograma|ffh4x|painel|headtracking|headtrick|headtrack|bypass|\.7z$|\.apk$|\.zip$|\.rar$"

for DIR in $SEARCH_PATHS; do
  [ ! -d "$DIR" ] && continue

  echo "[*] Escaneando: $DIR"
  echo ""

RESULT=$(find "$DIR" -type f 2>/dev/null \
  | grep -i -E "$KEYS2" \
  | grep -v -F "$WHITELIST")

  if [ -n "$RESULT" ]; then
    echo "[!] ARQUIVOS SUSPEITOS DETECTADOS:"
    echo "$RESULT"
    FILE_SCAN=1
  fi
done

# Scan avançado apenas se ROOT estiver ativo
if [ "$ROOT_DETECTED" -eq 1 ]; then
  echo ""
  echo "[+] ROOT DETECTADO — VARREDURA AVANÇADA (/data)"
  echo ""

  RESULT=$(find /data -type f 2>/dev/null | grep -i -E "$KEYS2")

  if [ -n "$RESULT" ]; then
    echo "[!] ARQUIVOS SUSPEITOS (ROOT):"
    echo "$RESULT"
    FILE_SCAN=1
  fi
fi

if [ "$FILE_SCAN" -eq 0 ]; then
  echo ""
  echo "[+] Nenhum arquivo suspeito encontrado no sistema."
else
  echo ""
  echo "[!] VARREDURA FINALIZADA COM DETECÇÕES"
fi
echo""
echo ""
echo "========================================="
echo ""
echo ""
echo "[+] Verificando presença de HOOKs no sistema"
HOOK_FLAG=0
echo ""
# lista de pacotes conhecidos de hook/frameworks
HOOK_APPS=(
"org.lsposed.manager"
"org.lsposed.lspatch"
"de.robv.android.xposed.installer"
"com.saurik.substrate"
"com.revanced.manager"
"com.virtualxposed"
"moe.shizuku.privileged.api"
)

for PKG in "${HOOK_APPS[@]}"; do
    if pm list packages | grep -q "$PKG"; then
        echo "[!] HOOK DETECTADO: app instalado ($PKG)"
        HOOK_FLAG=1
        echo ""
    fi
done

# diretórios de módulos hook
HOOK_DIRS=(
"/data/adb/modules"
"/data/adb/lspd"
"/data/adb/modules/zygisk_lsposed"
)

for DIR in "${HOOK_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "[!] HOOK DETECTADO: módulo ou estrutura hook encontrada ($DIR)"
        HOOK_FLAG=1
    fi
done

if [ "$HOOK_FLAG" -eq 0 ]; then
    echo "[+] Nenhum HOOK detectado. Sistema aparentemente limpo."
fi
echo""
echo""
echo "========================================="
echo ""
echo ""
echo "[!] Made by SavageGod"
echo ""
echo ""
echo "========================================="

rm -rf "sdcard/Download/scannersavage2.sh"
exit