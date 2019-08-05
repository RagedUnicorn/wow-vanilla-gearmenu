if (GetLocale() == "deDE") then
  gm = gm or {}
  gm.L = {}

  gm.L["name"] = "GearMenu"

  -- console
  gm.L["help"] = "|cFFFFFF00(%s)|r: Benutze |cFFFFFF00/gm|r oder |cFFFFFF00/gearmenu|r für eine Liste der verfügbaren Optionen"
  gm.L["show"] = "|cFFFFFF00show|r - anzeigen GearMenu"
  gm.L["hide"] = "|cFFFFFF00hide|r - ausblenden GearMenu"
  gm.L["opt"] = "|cFFFFFF00opt|r - zeige Optionsmenu an"
  gm.L["reload"] = "|cFFFFFF00reload|r - UI neu laden"
  gm.L["info_title"] = "|cFFFFFF00GearMenu:|r"

  -- slot translations
  gm.L["slot_name_head"] = "Kopf"
  gm.L["slot_name_neck"] = "Hals"
  gm.L["slot_name_shoulder"] = "Schultern"
  gm.L["slot_name_chest"] = "Brust"
  gm.L["slot_name_waist"] = "Taille"
  gm.L["slot_name_legs"] = "Beine"
  gm.L["slot_name_feet"] = "Füße"
  gm.L["slot_name_wrist"] = "Handgelenke"
  gm.L["slot_name_hands"] = "Hände"
  gm.L["slot_name_upper_finger"] = "Oberer Finger"
  gm.L["slot_name_lower_finger"] = "Unterer Finger"
  gm.L["slot_name_finger"] = "Finger"
  gm.L["slot_name_upper_trinket"] = "Oberer Schmuck"
  gm.L["slot_name_lower_trinket"] = "Unterer Schmuck"
  gm.L["slot_name_trinket"] = "Schmuck"
  gm.L["slot_name_cloak"] = "Rücken"
  gm.L["slot_name_mainhand"] = "Waffenhand"
  gm.L["slot_name_offhand"] = "Schildhand"
  gm.L["slot_name_ranged"] = "Distanz"

  -- user errors
  gm.L["unequip_failed"] = "Kein freier Taschenplatz gefunden"
  gm.L["quick_change_item_select_missing"] = "Es muss ein Item von der Von und der Zu Liste ausgewählt werden"
  gm.L["quick_change_rule_select_missing"] = "Es muss eine Regel gewählt werden welche gelöscht werden soll"

  -- gui
  gm.L["navigation_slots"] = "Slots"
  gm.L["navigation_general"] = "Allgemein"
  gm.L["navigation_quickchange"] = "Schnellwechsel"
  gm.L["navigation_about"] = "Über"

  -- slots tab
  gm.L["titleslot1"] = "Slot 1:"
  gm.L["titleslot2"] = "Slot 2:"
  gm.L["titleslot3"] = "Slot 3:"
  gm.L["titleslot4"] = "Slot 4:"
  gm.L["titleslot5"] = "Slot 5:"
  gm.L["titleslot6"] = "Slot 6:"
  gm.L["titleslot7"] = "Slot 7:"
  gm.L["titleslot8"] = "Slot 8:"
  gm.L["titleslot9"] = "Slot 9:"
  gm.L["titleslot10"] = "Slot 10:"
  gm.L["slot_menu_slot_already_in_use"] = "Slot wird bereits benutzt"

  -- general tab
  gm.L["lock_window"] = "Sperre Fenster"
  gm.L["lock_window_tooltip"] = "Verhindert das bewegen des GearMenu Fensters."
  gm.L["show_cooldowns"] = "Zeige Abklingzeiten an"
  gm.L["show_cooldowns_tooltip"] = "Zeige Abklingzeiten für alle Slots an."
  gm.L["show_keybindings"] = "Zeige Tastaturkürzel an"
  gm.L["show_keybindings_tooltip"] = "Zeige Tastaturkürzel auf den ausgerüsteten Items an."
  gm.L["show_tooltips"] = "Deaktiviere Kurzinfo"
  gm.L["show_tooltips_tooltip"] = "Deaktiviere Kurzinfo für markierte Items."
  gm.L["small_tooltips"] = "Zeige kleine Kurzinfo"
  gm.L["small_tooltips_tooltip"] = "Zeige nur den Titel des markierten Items anstatt die ganze Kurzinfo."
  gm.L["disable_drag_and_drop"] = "Deaktiviere Drag and Drop"
  gm.L["disable_drag_and_drop_tooltip"] = "Deaktiviere Drag and Drop für Items."
  gm.L["filter_item_quality"] = "Filtere Gegenstandsqualität:"
  gm.L["item_quality_poor"] = "Arm (Grau)"
  gm.L["item_quality_common"] = "Gewöhnlich (Weiss)"
  gm.L["item_quality_uncommon"] = "Ungewöhnlich (Grün)"
  gm.L["item_quality_rare"] = "Selten (Blau)"
  gm.L["item_quality_epic"] = "Episch (Violet)"
  gm.L["item_quality_legendary"] = "Legendär (Orange)"

  -- quick change tab
  gm.L["rule_list_label"] = "Regeln:"
  gm.L["change_from_label"] = "Von:"
  gm.L["change_to_label"] = "Zu:"
  gm.L["delay_label"] = "Verzögerung: "
  gm.L["delay_unit_label"] = "Sek"
  gm.L["add_rule"] = "Erstelle Regel"
  gm.L["delete_rule"] = "Lösche Regel"

  -- about tab
  gm.L["author"] = "Autor: Michael Wiesendanger"
  gm.L["email"] = "E-Mail: michael.wiesendanger@gmail.com"
  gm.L["version"] = "Version: " .. GM_ENVIRONMENT.ADDON_VERSION
  gm.L["issues"] = "Probleme: https://github.com/RagedUnicorn/wow-vanilla-gearmenu/issues"
end
