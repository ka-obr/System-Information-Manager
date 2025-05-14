# Author           : Imie Nazwisko (karol.obrycki11@gmail.com)
# Created On       : 29.04.2025
# Last Modified By : Imie Nazwisko (karol.obrycki11@gmail.com)
# Last Modified On : 14.05.2025
# Version          : 1.0
#
# Description      : System Information Manager
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

#!/bin/bash

# Importowanie modułu info_collector.sh, który zawiera funkcje do zbierania informacji o systemie
source "infoCollector.sh"

VERSION="1.0"
AUTHOR="Karol Obrycki"
CONFIG_FILE="config.txt"  # Domyślny plik konfiguracyjny
REPORT_FILE=""  # Plik raportu (wartość zostanie załadowana z konfiguracji)
INTERVAL=0  # Interwał odświeżania (wartość zostanie załadowana z konfiguracji)

# Importowanie konfiguracji z pliku
source "configLoader.sh"

# Funkcja wyświetlająca dostępne opcje skryptu
help() {
    echo "Opcje:"
    echo "-d <interwał>     - dynamiczne odświeżanie co n sekund"
    echo "-r <okres>        - zapisanie danych do raportu"
    echo "-h                - pomoc"
    echo "-v                - wersja i autor"
    echo "-s                - zbieranie danych z systemu przez pewien czas"
    echo "-z                - interfejs graficzny z użyciem zenity"
}

# Funkcja wyświetlająca wersję i autora skryptu
show_version() {
    echo "Wersja: $VERSION"
    echo "Autor: $AUTHOR"
}

# Funkcja do dynamicznego odświeżania danych co określony interwał czasu
dynamic_refresh() {
    while true; do
        clear
        echo "Dynamiczne odświeżanie co $INTERVAL sekund"
        echo "Czas: $(date)"
        collect_info 
        sleep "$INTERVAL"  # Czeka przez określony interwał czasu
        read -t 0.1 -n 1 key  # Sprawdza, czy użytkownik nacisnął klawisz
        if [[ $key == "q" ]]; then  # Jeśli naciśnięto "q", wychodzi z pętli
            echo "Wyjście z trybu dynamicznego."
            break
        fi
    done
}

# Funkcja zapisująca raport z danymi systemowymi przez określony czas
save_report() {
    local duration=$1  # Czas trwania zbierania danych (local - tylko w tej funkcji)
    local end_time=$((SECONDS + duration))  # Oblicza czas zakończenia
    echo "Zbieranie danych przez $duration sekund. Raport zostanie zapisany do $REPORT_FILE."
    > "$REPORT_FILE"  # Czyści plik raportu
    while [ $SECONDS -lt $end_time ]; do # dopóki SECONDS (wbudowane w bash) jest mniejsze od end_time
        echo "Czas: $(date)" >> "$REPORT_FILE"
        collect_info >> "$REPORT_FILE"
        echo "-----------------------------" >> "$REPORT_FILE"
        sleep "$INTERVAL"
    done
    echo "Raport zapisany do $REPORT_FILE."
}

# Funkcja obsługująca interfejs graficzny z użyciem Zenity
zenity_interface() {
    local choice=$(zenity --list \
        --title="System Information Manager" \
        --text="Wybierz opcję:" \
        --column="Opcja" --column="Opis" \
        "Dynamiczne odświeżanie" "Wyświetlanie danych w czasie rzeczywistym" \
        "Zapis raportu" "Zapis danych do pliku raportu" \
        "Wyświetl dane" "Wyświetlenie aktualnych danych o systemie" \
        "Pomoc" "Wyświetlenie dostępnych opcji" \
        "Wersja" "Informacje o wersji i autorze" \
        --width=600 --height=300)

    # Obsługa wyboru użytkownika
    case $choice in
        "Dynamiczne odświeżanie")
            INTERVAL=$(zenity --entry --title="Dynamiczne odświeżanie" --text="Podaj interwał w sekundach:" --entry-text="3")
            if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then  # Walidacja, czy interwał jest liczbą
                zenity --error --title="Błąd" --text="Interwał musi być liczbą całkowitą."
                return
            fi
            dynamic_refresh
            ;;
        "Zapis raportu")
            local duration=$(zenity --entry --title="Zapis raportu" --text="Podaj czas trwania w sekundach:" --entry-text="10")
            if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
                zenity --error --title="Błąd" --text="Czas trwania musi być liczbą całkowitą."
                return
            fi
            save_report "$duration"
            ;;
        "Wyświetl dane")
            collect_info
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

# Sprawdzenie, czy podano jakiekolwiek opcje
if [[ $# -eq 0 ]]; then
    help
    exit
fi

while getopts d:hr:vsz OPT 2>/dev/null; do
    case $OPT in
        h)
            help
            exit;;
        d)
            INTERVAL=$OPTARG
            if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
                echo "Błąd: Interwał musi być liczbą całkowitą."
                exit 1
            fi

            dynamic_refresh 
            exit;;
        r)
            duration=$OPTARG
            if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
                echo "Błąd: Czas trwania musi być liczbą całkowitą."
                exit 1
            fi

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
        ?)
            echo "Nieznana opcja."
            help
            exit 1;;
    esac
done
