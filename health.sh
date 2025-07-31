


#!/bin/bash



DISK_THRESHOLD=80
LOG_DIR="/tmp/syshealth"
BACKUP_SRC="/home/kali/Documents"
BACKUP_DEST="/tmp/backup_$(date).tar.gz"



mkdir -p "$LOG_DIR"



for f in disk_usage cpu_mem top_mem_processes system.updates backup summary; do
    > "$LOG_DIR/$f.log"
done



echo "[Disk Usage Check] - $(date)" >> "$LOG_DIR/disk_usage.log"
df -h / | tail -1 | awk '{print $5}' | sed 's/%//' | while read usage; do
    echo "Disk usage: $usage%" >> "$LOG_DIR/disk_usage.log"
    if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
        warning_msg="WARNING: Disk usage on $(hostname) is at ${usage}%, exceeding the threshold of ${DISK_THRESHOLD}%"
        echo "$warning_msg" >> "$LOG_DIR/disk_usage.log"
    fi
done



echo "[CPU & Memory Stats] - $(date)" >> "$LOG_DIR/cpu_mem.log"
echo "Uptime: $(uptime)" >> "$LOG_DIR/cpu_mem.log"
vmstat 1 5 >> "$LOG_DIR/cpu_mem.log"
free -h >> "$LOG_DIR/cpu_mem.log"



echo "[Top 5 Memory Processes] - $(date)" >> "$LOG_DIR/top_mem_processes.log"
ps aux --sort=-%mem | head -6 >> "$LOG_DIR/top_mem_processes.log"



echo "[System Update Check] - $(date)" >> "$LOG_DIR/system.updates.log"
if command -v journalctl >/dev/null 2>&1; then
    journalctl | grep -i "upgrade" | tail -5 >> "$LOG_DIR/system.updates.log"
else
    echo "journalctl not found!" >> "$LOG_DIR/system.updates.log"
fi



echo "[Backup] - $(date)" >> "$LOG_DIR/backup.log"
if [ -d "$BACKUP_SRC" ]; then
    tar -czf "$BACKUP_DEST" "$BACKUP_SRC"
    echo "Backup created at $BACKUP_DEST" >> "$LOG_DIR/backup.log"
else
    echo "Source directory $BACKUP_SRC not found" >> "$LOG_DIR/backup.log"
fi



echo "System check completed successfully on $(date)" >> "$LOG_DIR/summary.log"


echo
echo "System Health Check Completed. Logs are in: $LOG_DIR"
echo

echo "[Disk Usage]"
cat "$LOG_DIR/disk_usage.log"
echo

echo "[CPU & Memory]"
cat "$LOG_DIR/cpu_mem.log"
echo

echo "[Top 5 Memory-Consuming Processes]"
cat "$LOG_DIR/top_mem_processes.log"
echo

echo "[System Update Check]"
cat "$LOG_DIR/system.updates.log"
echo

echo "[Backup Status]"
cat "$LOG_DIR/backup.log"
echo

echo "[Summary]"
cat "$LOG_DIR/summary.log"
echo
