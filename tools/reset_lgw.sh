#!/bin/sh

# This script is intended to be used on SX1302 CoreCell platform, it performs
# the following actions:
#       - export/unpexort GPIO23 and GPIO18 used to reset the SX1302 chip and to enable the LDOs
#       - export/unexport GPIO22 used to reset the optional SX1261 radio used for LBT/Spectral Scan
#
# Usage examples:
#       ./reset_lgw.sh stop
#       ./reset_lgw.sh start

# GPIO mapping has to be adapted with HW
#

SX1302_GPIO_CHIP=2      # GPIO chip name
SX1261_GPIO_CHIP=0      # GPIO chip name

SX1302_RESET_LINE=9              # SX1302 reset - line offset 12 (was GPIO309 = 1*256 + 12)
SX1261_RESET_LINE=98              # SX1261 reset - line offset 63 (was GPIO446 = 1*256 + 63)

WAIT_GPIO() {
    sleep 0.1
}

# Check if gpiod tools are available
check_gpiod() {
    if ! command -v gpioset >/dev/null 2>&1; then
        echo "Error: gpiod tools not found. Please install libgpiod."
        exit 1
    fi
}

reset_sx1302() {
    echo "Resetting SX1302 through ${SX1302_GPIO_CHIP} line ${SX1302_RESET_LINE}..."
    
    # Set reset line high, then low to create reset pulse
    gpioset "${SX1302_GPIO_CHIP}" "${SX1302_RESET_LINE}=1"
    WAIT_GPIO
    gpioset "${SX1302_GPIO_CHIP}" "${SX1302_RESET_LINE}=0"
    WAIT_GPIO
    
    echo "SX1302 reset complete"
}

reset_sx1261() {
    echo "Resetting SX1261 through ${SX1261_GPIO_CHIP} line ${SX1261_RESET_LINE}..."
    
    # Set reset line low, then high to create reset pulse
    gpioset "${SX1261_GPIO_CHIP}" "${SX1261_RESET_LINE}=0"
    WAIT_GPIO
    gpioset "${SX1261_GPIO_CHIP}" "${SX1261_RESET_LINE}=1"
    WAIT_GPIO
    
    echo "SX1261 reset complete"
}

reset() {
    check_gpiod
    
    # Reset both devices
    reset_sx1302
    reset_sx1261
}

case "$1" in
    start)
    reset
    ;;
    stop)
    reset
    ;;
    *)
    echo "Usage: $0 {start|stop}"
    echo "Note: This script requires gpiod tools (gpioset, etc.)"
    exit 1
    ;;
esac