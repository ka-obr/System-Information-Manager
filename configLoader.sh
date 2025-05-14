#!/bin/bash

# Sprawdza, czy plik konfiguracyjny istnieje
if [[ -f "$CONFIG_FILE" ]]; then
    # Wczytuje wartości z pliku konfiguracyjnego (oddzielone przecinkami)
    IFS=',' read -r REPORT_FILE INTERVAL < "$CONFIG_FILE"
    if [[ -z "$REPORT_FILE" && -z "$INTERVAL" ]]; then
        # Jeśli plik jest pusty, ustawia wartości domyślne
        echo "Uwaga: plik konfiguracyjny '$CONFIG_FILE' jest pusty. Używam domyślnych wartości."
        REPORT_FILE="system_report.txt"
        INTERVAL=3
    else
        # Jeśli wartości są obecne, przypisuje je do zmiennych
        if [[ -n "$REPORT_FILE" ]]; then
            echo "pobrano plik wyjściowy: $REPORT_FILE"
        else
            REPORT_FILE="system_report.txt"
        fi
        if [[ -n "$INTERVAL" ]]; then
            echo "pobrano interwał: $INTERVAL"
        else
            INTERVAL=3
        fi
    fi
else
    # Jeśli plik nie istnieje, wyświetla ostrzeżenie
    echo "Uwaga: plik konfiguracyjny '$CONFIG_FILE' nie znaleziony."
fi