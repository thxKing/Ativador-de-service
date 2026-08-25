#!/system/bin/sh
# Scanner Full System - Usa todos os binários disponíveis
# ProcSpoofer - Scanner Completo

MODDIR=${0%/*}
LOG_FILE="$MODDIR/logs/scanner_full.log"
DATA=$(date '+%Y-%m-%d_%H-%M-%S')

mkdir -p "$MODDIR/logs"

echo "==========================================" | tee "$LOG_FILE"
echo "🔍 SCANNER FULL SYSTEM" | tee -a "$LOG_FILE"
echo "📅 Data: $(date)" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 1. SCANNER VIA /PROC/ (MAIS CONFIÁVEL)
# --------------------------------------------
echo "=== 1. SCANNER VIA /PROC/ ===" | tee -a "$LOG_FILE"
echo "🔍 Procurando processos com strings suspeitas..." | tee -a "$LOG_FILE"

for pid_dir in /proc/[0-9]*; do
    if [ -d "$pid_dir" ]; then
        pid=$(basename "$pid_dir")
        cmdline_file="$pid_dir/cmdline"
        
        if [ -f "$cmdline_file" ]; then
            current_cmd=$(cat "$cmdline_file" 2>/dev/null | tr '\0' ' ')
            
            # Filtra processos suspeitos
            if echo "$current_cmd" | grep -qE "magisk|ksu|apatch|zygisk|su |/data/adb/|zn-|TEESimulator|tricky|playintegrityfix|busybox|fantasma|remote_hs|brevent|resetprop"; then
                echo "📂 PID: $pid | CMD: $current_cmd" | tee -a "$LOG_FILE"
            fi
        fi
    fi
done
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 2. SCANNER VIA PS (BINÁRIO PS)
# --------------------------------------------
echo "=== 2. SCANNER VIA PS ===" | tee -a "$LOG_FILE"

if command -v ps >/dev/null 2>&1; then
    echo "🔍 Usando ps -A..." | tee -a "$LOG_FILE"
    ps -A 2>/dev/null | grep -E "magisk|ksu|apatch|zygisk|su |/data/adb/|zn-|TEESimulator|tricky|playintegrityfix|busybox|fantasma|remote_hs|brevent|resetprop|shell|root" | tee -a "$LOG_FILE"
else
    echo "⚠️ ps não disponível" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 3. SCANNER VIA TOOLBOX (SE DISPONÍVEL)
# --------------------------------------------
echo "=== 3. SCANNER VIA TOOLBOX ===" | tee -a "$LOG_FILE"

if command -v toolbox >/dev/null 2>&1; then
    echo "🔍 Usando toolbox ps..." | tee -a "$LOG_FILE"
    toolbox ps 2>/dev/null | grep -E "magisk|ksu|apatch|zygisk|su |/data/adb/|zn-|TEESimulator|tricky|playintegrityfix|busybox|fantasma|remote_hs|brevent|resetprop" | tee -a "$LOG_FILE"
else
    echo "⚠️ toolbox não disponível" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 4. SCANNER VIA DUMPSTATE
# --------------------------------------------
echo "=== 4. SCANNER VIA DUMPSTATE (apenas info) ===" | tee -a "$LOG_FILE"

if command -v dumpstate >/dev/null 2>&1; then
    echo "🔍 dumpstate disponível (não executado para não travar)" | tee -a "$LOG_FILE"
else
    echo "⚠️ dumpstate não disponível" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 5. SCANNER VIA TOP
# --------------------------------------------
echo "=== 5. SCANNER VIA TOP ===" | tee -a "$LOG_FILE"

if command -v top >/dev/null 2>&1; then
    echo "🔍 Usando top -n 1..." | tee -a "$LOG_FILE"
    top -n 1 -b 2>/dev/null | grep -E "magisk|ksu|apatch|zygisk|su |/data/adb/|zn-|TEESimulator|tricky|playintegrityfix|busybox|fantasma|remote_hs|brevent|resetprop" | tee -a "$LOG_FILE"
else
    echo "⚠️ top não disponível" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 6. SCANNER VIA PIDOF
# --------------------------------------------
echo "=== 6. SCANNER VIA PIDOF ===" | tee -a "$LOG_FILE"

if command -v pidof >/dev/null 2>&1; then
    echo "🔍 Usando pidof..." | tee -a "$LOG_FILE"
    
    for proc in magisk magiskd ksu ksud apatch apd zygisk zn-daemon zn-zygisk-companion64 playintegrityfix tricky_store TEESimulator busybox su resetprop brevent_server fantasma remote_hs; do
        pid=$(pidof "$proc" 2>/dev/null)
        if [ -n "$pid" ]; then
            echo "   $proc: PID $pid" | tee -a "$LOG_FILE"
        fi
    done
else
    echo "⚠️ pidof não disponível" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 7. SCANNER DE MÓDULOS (KERNELSU/APATCH/MAGISK)
# --------------------------------------------
echo "=== 7. SCANNER DE MÓDULOS ===" | tee -a "$LOG_FILE"

# KernelSU
if [ -d "/data/adb/ksu" ]; then
    echo "📂 KernelSU detectado" | tee -a "$LOG_FILE"
    ls -la /data/adb/ksu/ 2>/dev/null | tee -a "$LOG_FILE"
fi

# APatch
if [ -d "/data/adb/ap" ]; then
    echo "📂 APatch detectado" | tee -a "$LOG_FILE"
    ls -la /data/adb/ap/ 2>/dev/null | tee -a "$LOG_FILE"
fi

# Magisk
if [ -d "/data/adb/magisk" ]; then
    echo "📂 Magisk detectado" | tee -a "$LOG_FILE"
    ls -la /data/adb/magisk/ 2>/dev/null | tee -a "$LOG_FILE"
fi

# Módulos
if [ -d "/data/adb/modules" ]; then
    echo "📂 Módulos instalados:" | tee -a "$LOG_FILE"
    ls -la /data/adb/modules/ 2>/dev/null | grep -v "lost+found" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 8. SCANNER DE PROPRIEDADES (GETPROP)
# --------------------------------------------
echo "=== 8. SCANNER DE PROPRIEDADES ===" | tee -a "$LOG_FILE"

if command -v getprop >/dev/null 2>&1; then
    echo "🔍 Propriedades suspeitas:" | tee -a "$LOG_FILE"
    getprop | grep -E "magisk|ksu|apatch|zygisk|verifiedbootstate|permissive|warranty|bootloader|unlocked" 2>/dev/null | tee -a "$LOG_FILE"
else
    echo "⚠️ getprop não disponível" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 9. SCANNER DE ARQUIVOS (FIND)
# --------------------------------------------
echo "=== 9. SCANNER DE ARQUIVOS SUSPEITOS ===" | tee -a "$LOG_FILE"

echo "🔍 Procurando binários su..." | tee -a "$LOG_FILE"
find /system /vendor /sbin /data -name "su" -type f 2>/dev/null | tee -a "$LOG_FILE"

echo "🔍 Procurando módulos..." | tee -a "$LOG_FILE"
find /data/adb/modules -maxdepth 1 -type d 2>/dev/null | tee -a "$LOG_FILE"

echo "🔍 Procurando scripts service.sh..." | tee -a "$LOG_FILE"
find /data/adb/modules -name "service.sh" -type f 2>/dev/null | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 10. SCANNER DE PROCESSOS EM BACKGROUND
# --------------------------------------------
echo "=== 10. PROCESSOS EM BACKGROUND ===" | tee -a "$LOG_FILE"

jobs -l 2>/dev/null | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 11. SCANNER DE PORTAS (NETSTAT)
# --------------------------------------------
echo "=== 11. SCANNER DE PORTAS ===" | tee -a "$LOG_FILE"

if command -v netstat >/dev/null 2>&1; then
    echo "🔍 Portas abertas:" | tee -a "$LOG_FILE"
    netstat -tuln 2>/dev/null | head -20 | tee -a "$LOG_FILE"
else
    echo "⚠️ netstat não disponível" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 12. SCANNER DE LOGS (LOGCAT)
# --------------------------------------------
echo "=== 12. SCANNER DE LOGS (LOGCAT) ===" | tee -a "$LOG_FILE"

if command -v logcat >/dev/null 2>&1; then
    echo "🔍 Logs recentes com suspeitos:" | tee -a "$LOG_FILE"
    logcat -d | grep -E "magisk|ksu|apatch|zygisk|su |/data/adb/|zn-|TEESimulator|tricky|playintegrityfix|busybox|fantasma|remote_hs|brevent|resetprop" | tail -20 | tee -a "$LOG_FILE"
else
    echo "⚠️ logcat não disponível" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# 13. SCANNER DE KERNEL (DMESG)
# --------------------------------------------
echo "=== 13. SCANNER DE KERNEL (DMESG) ===" | tee -a "$LOG_FILE"

if command -v dmesg >/dev/null 2>&1; then
    echo "🔍 Kernel logs:" | tee -a "$LOG_FILE"
    dmesg | tail -20 | tee -a "$LOG_FILE"
else
    echo "⚠️ dmesg não disponível" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --------------------------------------------
# FINALIZAR
# --------------------------------------------
echo "==========================================" | tee -a "$LOG_FILE"
echo "✅ SCANNER CONCLUÍDO!" | tee -a "$LOG_FILE"
echo "📁 Log salvo em: $LOG_FILE" | tee -a "$LOG_FILE"
echo "📊 Tamanho: $(du -h "$LOG_FILE" 2>/dev/null | awk '{print $1}')" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"

exit 0