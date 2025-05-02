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
REPORT_FILE="/home/karol-obr/Pulpit/DuzySkryptGitHub/System-Information-Manager/system_report.txt"
INTERVAL=3

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

# Funkcja do zbierania informacji o CPU
collect_cpu_info() {
    echo "==== Informacje o CPU ===="
    lscpu
}

# Funkcja do zbierania informacji o pamięci
collect_memory_info() {
    echo "==== Informacje o Pamięci ===="
    free -m
}

# Funkcja do zbierania informacji o dyskach
collect_disk_info() {
    echo "==== Informacje o Dyskach ===="
    df -h
}

# Funkcja do zbierania informacji o systemie
collect_system_info() {
    echo "==== Informacje o Systemie ===="
    uname -a
}

# Funkcja główna do zbierania wszystkich informacji
collect_info() {
    collect_cpu_info
    echo
    collect_memory_info
    echo
    collect_disk_info
    echo
    collect_system_info
    echo
}

dynamic_refresh() {
    while true; do
        clear
        echo "Dynamiczne odświeżanie co $INTERVAL sekund"
        echo "Czas: $(date)"
        collect_info
        sleep "$INTERVAL" &  # Uruchamiamy sleep w tle
        wait -n              # Czekamy na zakończenie sleep lub wciśnięcie klawisza
        read -t 0.1 -n 1 key # Odczytujemy klawisz z timeoutem
        if [[ $key == "q" ]]; then
            echo "Wyjście z trybu dynamicznego."
            break
        fi
    done
}

save_report() {
    local duration=$1
    local end_time=$((SECONDS + duration))
    echo "Zbieranie danych przez $duration sekund. Raport zostanie zapisany do $REPORT_FILE."
    > "$REPORT_FILE"  # Wyczyszczenie pliku raportu
    while [ $SECONDS -lt $end_time ]; do
        echo "Czas: $(date)" >> "$REPORT_FILE"
        collect_info >> "$REPORT_FILE"
        echo "-----------------------------" >> "$REPORT_FILE"
        sleep "$INTERVAL"
    done
    echo "Raport zapisany do $REPORT_FILE."
}

while getopts dhrvs: OPT; do
    case $OPT in
        h)
            help
            exit;;
        d)
            dynamic_refresh "$INTERVAL"
            exit;;
        r)
            read -p "Podaj czas trwania w sekundach: " duration
            save_report "$duration"
            exit;;
        v)
            show_version
            exit;;
        s)
            collect_info
            exit;;
        *)
            echo "Nieznana opcja."
            help
            exit 1;;
    esac
done
