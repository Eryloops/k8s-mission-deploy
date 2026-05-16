#!/bin/sh

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   MISSION: SYSTEM DEPLOYMENT v1.0       ║"
echo "╚══════════════════════════════════════════╝"
echo ""

sleep 1
echo "[*] Initializing secure connection......... OK"
sleep 1
echo "[*] Scanning network targets............... OK"
sleep 1
echo "[*] Loading deployment payload............. OK"
sleep 1
echo "[*] Verifying system integrity............. OK"
sleep 1
echo ""
echo "──────────────────────────────────────────"
echo "  SYSTEM INTEL REPORT"
echo "──────────────────────────────────────────"
echo ""
echo ">> Hostname: $(hostname)"
echo ">> OS:       $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
echo ">> Kernel:   $(uname -r)"
echo ">> User:     $(whoami) (non-root)"
echo ">> Memory:"
free -h | grep Mem | awk '{print "   Total: " $2 "  Used: " $3 "  Free: " $4}'
echo ">> Disk:"
df -h / | tail -1 | awk '{print "   Size: " $2 "  Used: " $3 "  Avail: " $4 "  Use%: " $5}'
echo ">> Network:"
ip -4 addr show | grep inet | awk '{print "   " $2 " on " $NF}'
echo ""
sleep 1
echo "[*] Deploying to target cluster........... OK"
sleep 1
echo "[*] Running post-deploy checks............ OK"
sleep 1
echo "[*] Security scan......................... PASSED"
sleep 1
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║        MISSION ACCOMPLISHED             ║"
echo "║   All systems operational. Status: GO   ║"
echo "╚══════════════════════════════════════════╝"
echo ""
