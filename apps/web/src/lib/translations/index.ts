/**
 * Centralized translation management
 * All translations in one place for easy maintenance
 */

export const translations = {
  common: {
    loading: "Loading...",
    saving: "Saving...",
    saved: "Saved",
    error: "Error",
    cancel: "Cancel",
    save: "Save",
    update: "Update",
    add: "Add",
    remove: "Remove",
    edit: "Edit",
    delete: "Delete",
    close: "Close",
    back: "Back",
    next: "Next",
    previous: "Previous",
    confirm: "Confirm",
    yes: "Yes",
    no: "No"
  },
  table: {
    title: "Title",
    description: "Description",
    rows: "Rows",
    columns: "Columns",
    column: "Column",
    row: "Row",
    header: "Header",
    width: "Width",
    format: "Format",
    date: "Date",
    text: "Text",
    fixedRows: "Fixed Rows",
    addNewRow: "Add new row",
    addNewColumn: "Add new column",
    columnNumber: "Column {{number}}",
    rowNumber: "Row {{number}}",
    dateFormat: "YYYY-MM-DD",
    today: "Today",
    insertToday: "Insert today's date",
    relativeDate: "{{description}}",
    dateFormatIcon: "📅"
  },
  admin: {
    settings: "Admin Settings",
    configuration: "Configuration",
    updateConfiguration: "Update Configuration",
    updating: "Updating...",
    tableSettings: "Table Settings",
    columnSettings: "Column Settings",
    addColumn: "Add Column",
    removeColumn: "Remove Column",
    columnWidth: "Column Width",
    columnWidthHelp: "50-800px or leave empty for auto",
    columnFormat: "Column Format",
    columnFormatHelp: "How values should be formatted",
    maxColumnsReached: "Cannot add more columns. Maximum is 64.",
    minColumnsReached: "Cannot remove the last column. Tables must have at least one column.",
    failedToAddRow: "Failed to add row",
    failedToAddColumn: "Failed to add column",
    failedToUpdateConfig: "Failed to update configuration"
  },
  status: {
    disconnected: "Disconnected",
    connecting: "Attempting to reconnect...",
    unsavedChanges: "Unsaved changes",
    updatingStructure: "Updating table structure...",
    connected: "Connected"
  },
  errors: {
    noAccessToken: "No access token provided",
    failedToCreateTable: "Failed to create table",
    tableCreatedSuccessfully: "Table Created Successfully!",
    genericError: "An error occurred. Please try again."
  },
  app: {
    title: "Online Tables Lite",
    description: "Collaborative table editing application",
    createTable: "Create Table",
    tableCreated: "Table Created Successfully!"
  }
} as const

export const translationsDE = {
  common: {
    loading: "Lädt...",
    saving: "Speichert...",
    saved: "Gespeichert",
    error: "Fehler",
    cancel: "Abbrechen",
    save: "Speichern",
    update: "Aktualisieren",
    add: "Hinzufügen",
    remove: "Entfernen",
    edit: "Bearbeiten",
    delete: "Löschen",
    close: "Schließen",
    back: "Zurück",
    next: "Weiter",
    previous: "Zurück",
    confirm: "Bestätigen",
    yes: "Ja",
    no: "Nein"
  },
  table: {
    title: "Titel",
    description: "Beschreibung",
    rows: "Zeilen",
    columns: "Spalten",
    column: "Spalte",
    row: "Zeile",
    header: "Überschrift",
    width: "Breite",
    format: "Format",
    date: "Datum",
    text: "Text",
    fixedRows: "Feste Zeilen",
    addNewRow: "Neue Zeile hinzufügen",
    addNewColumn: "Neue Spalte hinzufügen",
    columnNumber: "Spalte {{number}}",
    rowNumber: "Zeile {{number}}",
    dateFormat: "JJJJ-MM-TT",
    today: "Heute",
    insertToday: "Heutiges Datum einfügen",
    relativeDate: "{{description}}",
    dateFormatIcon: "📅"
  },
  admin: {
    settings: "Admin-Einstellungen",
    configuration: "Konfiguration",
    updateConfiguration: "Konfiguration aktualisieren",
    updating: "Aktualisiert...",
    tableSettings: "Tabellen-Einstellungen",
    columnSettings: "Spalten-Einstellungen",
    addColumn: "Spalte hinzufügen",
    removeColumn: "Spalte entfernen",
    columnWidth: "Spaltenbreite",
    columnWidthHelp: "50-800px oder leer lassen für automatisch",
    columnFormat: "Spaltenformat",
    columnFormatHelp: "Wie Werte formatiert werden sollen",
    maxColumnsReached: "Keine weiteren Spalten möglich. Maximum ist 64.",
    minColumnsReached: "Die letzte Spalte kann nicht entfernt werden. Tabellen müssen mindestens eine Spalte haben.",
    failedToAddRow: "Zeile konnte nicht hinzugefügt werden",
    failedToAddColumn: "Spalte konnte nicht hinzugefügt werden",
    failedToUpdateConfig: "Konfiguration konnte nicht aktualisiert werden"
  },
  status: {
    disconnected: "Getrennt",
    connecting: "Versuche erneut zu verbinden...",
    unsavedChanges: "Ungespeicherte Änderungen",
    updatingStructure: "Tabellenstruktur wird aktualisiert...",
    connected: "Verbunden"
  },
  errors: {
    noAccessToken: "Kein Zugriffstoken bereitgestellt",
    failedToCreateTable: "Tabelle konnte nicht erstellt werden",
    tableCreatedSuccessfully: "Tabelle erfolgreich erstellt!",
    genericError: "Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut."
  },
  app: {
    title: "Online Tabellen Lite",
    description: "Kollaborative Tabellenbearbeitungsanwendung",
    createTable: "Tabelle erstellen",
    tableCreated: "Tabelle erfolgreich erstellt!"
  }
} as const

// Type definitions for better IDE support
export type TranslationKeys = typeof translations
export type TranslationKeysDE = typeof translationsDE

// Helper function to get translations by locale
export function getTranslations(locale: 'en' | 'de') {
  return locale === 'de' ? translationsDE : translations
}
