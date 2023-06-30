#!/bin/bash
#BY ALIF SIHAT

# Check if the system is Red Hat or Debian-based
if [ -f /etc/redhat-release ]; then
    LINUX_BASE="Red Hat"
    PACKAGE_MANAGER="yum"
elif [ -f /etc/debian_version ]; then
    LINUX_BASE="Debian"
    PACKAGE_MANAGER="apt"
else
    LINUX_BASE="Unknown"
    PACKAGE_MANAGER=""
fi

# Function to generate HTML table row
generate_row() {
    echo "<tr><td>$1</td><td>$2</td></tr>"
}

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to generate HTML report
generate_report() {
    echo "<html><body><h1>System Report</h1>"
    echo "<h2>Operating System</h2>"
    echo "<table>"
    generate_row "Linux Base" "$LINUX_BASE"
    generate_row "Hostname" "$(hostname)"
    generate_row "IP Address" "$(hostname -I)"
    echo "</table>"

    echo "<h2>System Status</h2>"
    echo "<table>"
    if [ "$LINUX_BASE" = "Red Hat" ]; then
        if command_exists "$PACKAGE_MANAGER"; then
            generate_row "Kernel Version" "$(uname -r)"
            generate_row "Service Pack Status" "$($PACKAGE_MANAGER check-update --security | grep -cE '^')"
            generate_row "Critical Updates Status" "$($PACKAGE_MANAGER list updates -q --security | grep -cE '^')"
            generate_row "Package Update Log" "$($PACKAGE_MANAGER history)"
            generate_row "Package Upgrade Log" "$($PACKAGE_MANAGER history | grep 'Upgrade:')"
        else
            generate_row "Service Pack Status" "Command not found"
            generate_row "Critical Updates Status" "Command not found"
        fi
    elif [ "$LINUX_BASE" = "Debian" ]; then
        if command_exists "$PACKAGE_MANAGER"; then
            generate_row "Kernel Version" "$(uname -r)"
            generate_row "Service Pack Status" "$($PACKAGE_MANAGER list --upgradable | grep -cE '^')"
            generate_row "Critical Updates Status" "$($PACKAGE_MANAGER list --upgradable | grep security | grep -cE '^')"
            generate_row "Package Update Log" "$($PACKAGE_MANAGER update 2>&1)"
            generate_row "Package Upgrade Log" "$($PACKAGE_MANAGER upgrade 2>&1)"
        else
            generate_row "Service Pack Status" "Command not found"
            generate_row "Critical Updates Status" "Command not found"
        fi
    fi
    generate_row "Service Status" "$(systemctl is-active <service-name>)"  # Replace <service-name> with the desired service
    generate_row "Date and Time" "$(date)"
    generate_row "System Uptime" "$(uptime -p)"
    generate_row "Hard Disk Space Usage" "$(df -h)"
    generate_row "CPU Utilization" "$(top -bn1 | awk '/%Cpu/ {print $2}')"
    generate_row "Memory Utilization" "$(free -h | awk '/Mem:/ {print $3}')"
    echo "</table>"

    echo "<h2>Network Status</h2>"
    echo "<table>"
    generate_row "Resolv.conf" "$(cat /etc/resolv.conf)"
    generate_row "Routing Table" "$(netstat -rn)"
    generate_row "Network Interfaces" "$(netstat -in)"
    echo "</table>"

    echo "<h2>Hard Disk Utilization</h2>"
    echo "<table>"
    generate_row "Disk Usage" "$(df -h)"
    echo "</table>"

    echo "<h2>CPU & RAM Utilization</h2>"
    echo "<table>"
    generate_row "CPU and RAM Utilization" "$(top -bn1 | head -n 20)"
    echo "</table>"

    echo "<h2>I/O Stats</h2>"
    echo "<table>"
    generate_row "I/O Statistics" "$(vmstat 5 10)"
    echo "</table>"

    echo "<h2>Last 10 Logins</h2>"
    echo "<table>"
    generate_row "Last 10 Logins" "$(last -n 10)"
    echo "</table>"

    echo "</body></html>"
}

# Generate the report and save it to a file
generate_report > system_report.html
