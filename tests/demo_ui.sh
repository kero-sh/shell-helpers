#!/usr/bin/env bash

# Include our UI library
source "$(dirname "$0")/../libs/helpers.sh"

# Initial cleanup
clear

title "Terminal UI Framework (Demo)"
subtitle "Demonstration of typographic capabilities and Bootstrap-style components"

hr

# --- TEXT ---
paragraph "You can use modifiers within paragraphs to highlight things. For example:
  $(fw_bold "This text is important"), while $(fw_italic "this other is explanatory"). 
  You can also $(fw_underline "underline a path") or simply strike through $(fw_strike "a mistake made")."

paragraph "Style composition allows incredible results:
  $(text_primary "$(fw_bold "Blue Bold")") · $(text_danger "$(fw_italic "Red Italic")") · $(bg_success "$(text_dark "$(fw_bold " Green Background ")")")"

hr

# --- SEMANTIC COLORS ---
subtitle "1. Semantic Text Colors"
paragraph "$(text_primary "text_primary") · $(text_secondary "text_secondary") · $(text_success "text_success") · $(text_danger "text_danger")
  $(text_warning "text_warning") · $(text_info "text_info") · $(text_light "$(bg_dark "text_light")") · text_dark · $(text_muted "text_muted")"

# --- EXTENDED PALETTE ---
subtitle "1.b Extended Palette (Bootstrap Style)"
paragraph "$(text_blue "text_blue") · $(text_indigo "text_indigo") · $(text_purple "text_purple") · $(text_pink "text_pink")
  $(text_red "text_red") · $(text_orange "text_orange") · $(text_yellow "text_yellow") · $(text_green "text_green")
  $(text_teal "text_teal") · $(text_cyan "text_cyan") · $(text_white "$(bg_dark "text_white")") · $(text_gray "text_gray")"

paragraph "$(bg_blue "$(text_light " bg_blue ")") $(bg_indigo "$(text_light " bg_indigo ")") $(bg_purple "$(text_light " bg_purple ")") $(bg_pink "$(text_light " bg_pink ")") $(bg_red "$(text_light " bg_red ")") $(bg_orange "$(text_light " bg_orange ")")
  $(bg_yellow "$(text_dark " bg_yellow ")") $(bg_green "$(text_light " bg_green ")") $(bg_teal "$(text_dark " bg_teal ")") $(bg_cyan "$(text_dark " bg_cyan ")") $(bg_white "$(text_dark " bg_white ")") $(bg_gray "$(text_light " bg_gray ")")"

# --- BADGES ---
subtitle "2. Badges (Tags)"
paragraph "Badges are great for indicating process status or tags.
  $(badge_primary "PRIMARY") $(badge_secondary "SECONDARY") $(badge_success "SUCCESS") $(badge_danger "DANGER") $(badge_warning "WARNING") $(badge_info "INFO") $(badge_dark "DARK")"

# --- ALERTS ---
subtitle "3. Alerts / Callouts"
alert_info "The system has successfully connected to the local database."
alert_success "The 1,540 files were processed without issues in 2.3s."
alert_warning "Careful, high memory usage detected in your configurations."
alert_danger "Compilation failed. Check the syntax on line 42 of the host file."

# --- REAL EXAMPLE ---
hr
title "Real Usage Example: Installation Script"
paragraph "Downloading project dependencies..."
paragraph "[1/3] $(text_muted "Getting general packages...") $(badge_success " DONE ")"
paragraph "[2/3] $(text_muted "Configuring network environment...") $(badge_success " DONE ")"
paragraph "[3/3] $(text_muted "Building binaries...") $(badge_danger " FAIL ")"

alert_danger "Aborted due to internal error code 13."

echo ""
