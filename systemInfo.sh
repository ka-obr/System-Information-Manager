# Author           : Karol Obrycki
# Created On       : 29.04.2025
# Last Modified By : Karol Obrycki
# Last Modified On : 03.05.2025 
# Version          : 0.1
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

#!/bin/bash

# Importowanie modułu info_collector.sh
source "/home/karol-obr/Pulpit/DuzySkryptGitHub/System-Information-Manager/infoCollector.sh"

VERSION="1.0"
AUTHOR="Karol Obrycki"
REPORT_FILE="/home/karol-obr/Pulpit/DuzySkryptGitHub/System-Information-Manager/system_report.txt"
INTERVAL=3

help() {
    echo "Opcje:"
    echo "-d            - dynamiczne odświeżanie co $INTERVAL sekund"
    echo "-r            - zapisanie danych do raportu"
    echo "-h            - pomoc"
    echo "-v            - wersja i autor"
    echo "-s            - zbieranie danych z systemu przez pewien czas"
    echo "-z            - interfejs graficzny z użyciem zenity"
}

show_version() {
    echo "Wersja: $VERSION"
    echo "Autor: $AUTHOR"
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

zenity_interface() {
    local choice=$(zenity --list \
        --title="System Information Manager" \
        --text="Wybierz opcję:" \
        --column="Opcja" --column="Opis" \
        "Dynamiczne odświeżanie" "Wyświetlanie danych w czasie rzeczywistym" \
        "Zapis raportu" "Zapis danych do pliku raportu" \
        "Pomoc" "Wyświetlenie dostępnych opcji" \
        "Wersja" "Informacje o wersji i autorze" \
        --width=600 --height=300)

    case $choice in
        "Dynamiczne odświeżanie")
            INTERVAL=$(zenity --entry --title="Dynamiczne odświeżanie" --text="Podaj interwał w sekundach:" --entry-text="3")
            dynamic_refresh "$INTERVAL"
            ;;
        "Zapis raportu")
            local duration=$(zenity --entry --title="Zapis raportu" --text="Podaj czas trwania w sekundach:" --entry-text="10")
            save_report "$duration"
            ;;
        "Pomoc")
            zenity --info --title="Pomoc" --text="$(help)"
            ;;
        "Wersja")
            zenity --info --title="Wersja" --text="$(show_version)"
            ;;
        *)
            zenity --error --title="Błąd" --text="Nieznana opcja lub anulowano wybór."
            ;;
    esac
}

while getopts dhrvsz OPT; do
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
        z)
            zenity_interface
            exit;;
        *)
            echo "Nieznana opcja."
            help
            exit 1;;
    esac
done
