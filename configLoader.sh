#!/bin/bash

if [[ -f "$CONFIG_FILE" ]]; then
    IFS=',' read -r REPORT_FILE INTERVAL < "$CONFIG_FILE"
    if [[ -z "$REPORT_FILE" && -z "$INTERVAL" ]]; then
        echo "Uwaga: plik konfiguracyjny '$CONFIG_FILE' jest pusty. Używam domyślnych wartości."
        REPORT_FILE="system_report.txt"
        INTERVAL=3
    else
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
    echo "Uwaga: plik konfiguracyjny '$CONFIG_FILE' nie znaleziony."
fi