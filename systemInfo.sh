# Author           : Karol Obrycki
# Created On       : 29.04.2025
# Last Modified By : Karol Obrycki
# Last Modified On : 29.04.2025 
# Version          : 0.1
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

#!/bin/bash

VERSION="1.0"
AUTHOR="Karol Obrycki"
REPORT_FILE="/tmp/system_report.txt"
INTERVAL=5

help() {
    echo "Opcje:"
    echo "-d SEKUNDY    - dynamiczne odświeżanie co N sekund"
    echo "-r            - zapisanie danych do raportu"
    echo "-h            - pomoc"
    echo "-v            - wersja i autor"
}

show_version() {
    echo "Wersja: $VERSION"
    echo "Autor: $AUTHOR"
}

collect_info() {
    echo "==== Informacje o CPU ===="
    lscpu
    echo "==== Informacje o Pamięci ===="
    free -m
    echo "==== Informacje o Dyskach ===="
    df -h
    echo "==== Informacje o Systemie ===="
    uname -a
}

while getopts ad:hrv OPT; do
    case $OPT in
        h)
            help
            exit;;
        a)
            collect_info
            exit;;
        v)
            show_version
            exit;;
        ?)
            echo "Nieznana opcja."
            help
            exit 1;;
    esac
done
