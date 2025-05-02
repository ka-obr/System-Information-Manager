#!/bin/bash

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