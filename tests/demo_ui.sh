#!/usr/bin/env bash

# Incluimos nuestra librería UI
source "$(dirname "$0")/../libs/helpers.sh"

# Limpieza inicial
clear

title "Terminal UI Framework (Demo)"
subtitle "Demostración de las capacidades tipográficas y componentes estilo Bootstrap"

hr

# --- TEXTO ---
paragraph "Puedes usar modificadores dentro de párrafos para destacar cosas. Por ejemplo:
  $(fw_bold "Este texto es importante"), mientras que $(fw_italic "este otro es aclaratorio"). 
  También puedes $(fw_underline "subrayar una ruta") o simplemente tachar $(fw_strike "un error cometido")."

paragraph "La composición de estilos permite resultados increíbles:
  $(text_primary "$(fw_bold "Azul Negrita")") • $(text_danger "$(fw_italic "Rojo Itálica")") • $(bg_success "$(text_dark "$(fw_bold " Fondo Verde ")")")"

hr

# --- COLORES SEMÁNTICOS ---
subtitle "1. Colores de Texto Semánticos"
paragraph "$(text_primary "text_primary") • $(text_secondary "text_secondary") • $(text_success "text_success") • $(text_danger "text_danger")
  $(text_warning "text_warning") • $(text_info "text_info") • $(text_light "$(bg_dark "text_light")") • text_dark • $(text_muted "text_muted")"

# --- PALETA EXTENDIDA ---
subtitle "1.b Paleta Extendida (Estilo Bootstrap)"
paragraph "$(text_blue "text_blue") • $(text_indigo "text_indigo") • $(text_purple "text_purple") • $(text_pink "text_pink")
  $(text_red "text_red") • $(text_orange "text_orange") • $(text_yellow "text_yellow") • $(text_green "text_green")
  $(text_teal "text_teal") • $(text_cyan "text_cyan") • $(text_white "$(bg_dark "text_white")") • $(text_gray "text_gray")"

paragraph "$(bg_blue "$(text_light " bg_blue ")") $(bg_indigo "$(text_light " bg_indigo ")") $(bg_purple "$(text_light " bg_purple ")") $(bg_pink "$(text_light " bg_pink ")") $(bg_red "$(text_light " bg_red ")") $(bg_orange "$(text_light " bg_orange ")")
  $(bg_yellow "$(text_dark " bg_yellow ")") $(bg_green "$(text_light " bg_green ")") $(bg_teal "$(text_dark " bg_teal ")") $(bg_cyan "$(text_dark " bg_cyan ")") $(bg_white "$(text_dark " bg_white ")") $(bg_gray "$(text_light " bg_gray ")")"

# --- BADGES ---
subtitle "2. Badges (Etiquetas)"
paragraph "Los badges son geniales para indicar el estado de un proceso o tags.
  $(badge_primary "PRIMARY") $(badge_secondary "SECONDARY") $(badge_success "SUCCESS") $(badge_danger "DANGER") $(badge_warning "WARNING") $(badge_info "INFO") $(badge_dark "DARK")"

# --- ALERTAS ---
subtitle "3. Alertas / Callouts"
alert_info "El sistema se ha conectado correctamente a la base de datos local."
alert_success "Los 1,540 archivos fueron procesados sin problemas en 2.3s."
alert_warning "Cuidado, se detectó un alto uso de memoria en tus configuraciones."
alert_danger "Fallo al compilar. Revisa la sintaxis en la línea 42 del archivo host."

# --- EJEMPLO REAL ---
hr
title "Ejemplo de uso Real: Script de Instalación"
paragraph "Descargando dependencias del proyecto..."
paragraph "[1/3] $(text_muted "Obteniendo paquetes generales...") $(badge_success " DONE ")"
paragraph "[2/3] $(text_muted "Configurando ambiente de red...") $(badge_success " DONE ")"
paragraph "[3/3] $(text_muted "Construyendo binarios...") $(badge_danger " FAIL ")"

alert_danger "Abortado por código de error interno 13."

echo ""
