; AutoHotkey v2.0.19 script to monitor keyboard input
; Switches to en-US input method after 10 seconds of inactivity

#Requires AutoHotkey v2.0.19

; Global variables
lastInputTime := A_TickCount
TIMEOUT_MS := 30000

; English (US) keyboard layout identifier
EN_US_LAYOUT := 0x04090409

; Start monitoring immediately
SetTimer(CheckInactivity, 2000)  ; Check every second

; Set up keyboard monitoring using hotkeys
SetupKeyboardMonitoring()

; Function to set up keyboard monitoring using hotkeys
SetupKeyboardMonitoring() {
    ; Create hotkeys for all keys (letters, numbers, symbols, function keys, etc.)
    ; This approach is more reliable than low-level hooks
    
    ; Letters A-Z
    Loop 26 {
        char := Chr(64 + A_Index)  ; A=65, B=66, etc.
        Hotkey("~" . char, (*) => UpdateLastInputTime())
        Hotkey("~" . char . " Up", (*) => UpdateLastInputTime())
    }
    
    ; ; Numbers 0-9
    ; Loop 10 {
    ;     Hotkey("~" . A_Index - 1, (*) => UpdateLastInputTime())
    ;     Hotkey("~" . A_Index - 1 . " Up", (*) => UpdateLastInputTime())
    ; }
    
    ; Common symbols and special keys
    symbols := ["Space", "Enter", "Tab", "Backspace", "Delete", "Insert", "Home", "End", "PgUp", "PgDn", "Up", "Down", "Left", "Right", "Esc", "CapsLock", "NumLock", "ScrollLock", "PrintScreen", "Pause"]
    for symbol in symbols {
        Hotkey("~" . symbol, (*) => UpdateLastInputTime())
        Hotkey("~" . symbol . " Up", (*) => UpdateLastInputTime())
    }
    
    ; ; Function keys F1-F24
    ; Loop 24 {
    ;     Hotkey("~F" . A_Index, (*) => UpdateLastInputTime())
    ;     Hotkey("~F" . A_Index . " Up", (*) => UpdateLastInputTime())
    ; }
    
    ; Modifier keys
    modifiers := ["LWin", "RWin", "LAlt", "LCtrl", "RCtrl", "LShift", "RShift"]
    for modifier in modifiers {
        Hotkey("~" . modifier, (*) => UpdateLastInputTime())
        Hotkey("~" . modifier . " Up", (*) => UpdateLastInputTime())
    }
    
    ; ; Numpad keys
    ; Loop 9 {
    ;     Hotkey("~Numpad" . A_Index, (*) => UpdateLastInputTime())
    ;     Hotkey("~Numpad" . A_Index . " Up", (*) => UpdateLastInputTime())
    ; }
    ; numpadKeys := ["NumpadDot", "NumpadDiv", "NumpadMult", "NumpadAdd", "NumpadSub", "NumpadEnter", "NumpadIns", "NumpadDel", "NumpadClear", "NumpadUp", "NumpadDown", "NumpadLeft", "NumpadRight", "NumpadHome", "NumpadEnd", "NumpadPgUp", "NumpadPgDn"]
    ; for key in numpadKeys {
    ;     Hotkey("~" . key, (*) => UpdateLastInputTime())
    ;     Hotkey("~" . key . " Up", (*) => UpdateLastInputTime())
    ; }
    
    ; Mouse buttons (optional - uncomment if you want to include mouse activity)
    ; Hotkey("~LButton", UpdateLastInputTime)
    ; Hotkey("~RButton", UpdateLastInputTime)
    ; Hotkey("~MButton", UpdateLastInputTime)
    ; Hotkey("~XButton1", UpdateLastInputTime)
    ; Hotkey("~XButton2", UpdateLastInputTime)
}

; Centralized function to update input time
UpdateLastInputTime() {
    global lastInputTime
    lastInputTime := A_TickCount
    ; Optional: Show debug info (uncomment for testing)
    ; ToolTip("Key detected: " . A_TickCount, 0, 0, 2)
    ; SetTimer(() => ToolTip("", 0, 0, 2), -1000)
}

; Function to check for inactivity
CheckInactivity() {
    global lastInputTime, TIMEOUT_MS
    
    currentTime := A_TickCount
    timeSinceLastInput := currentTime - lastInputTime
    
    ; Optional debug: uncomment to see countdown
    ; ToolTip("Inactive for: " . Round(timeSinceLastInput/1000, 1) . "s", 0, 20, 2)
    
    ; Check if timeout period has passed
    if (timeSinceLastInput >= TIMEOUT_MS) {
        ; Switch to English (US) input method
        SwitchToEnglishUS()
        
        ; Reset timer to avoid repeated switching
        lastInputTime := A_TickCount
    }
}

; Cleanup on exit
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    ; No special cleanup needed for hotkey-based monitoring
}

; Function to switch input method to English (US)
SwitchToEnglishUS() {
    global EN_US_LAYOUT
    
    hwnd := WinGetID("A")
    hkl := DllCall("LoadKeyboardLayout", "Str", "00000409", "UInt", 0, "Ptr")
    try {
        ; Try the standard way first (may fail with ERROR_ACCESS_DENIED when targeting elevated/UWP windows)
        PostMessage(0x50, 0, hkl, hwnd)
        return
    } catch Error {
        ; Fallback below
    }

    ; Fallback 1: safer synchronous send with timeout (won't throw on hung windows)
    ; SMTO_ABORTIFHUNG (0x0002) | SMTO_BLOCK (0x0001)
    resultPtr := 0
    sendOk := DllCall(
        "SendMessageTimeout",
        "Ptr", hwnd,
        "UInt", 0x50,
        "Ptr", 0,
        "Ptr", hkl,
        "UInt", 0x0003,
        "UInt", 100,
        "Ptr*", &resultPtr,
        "UInt"
    )
    if (sendOk)
        return

    ; Fallback 2: attach to the target thread and activate layout directly
    pid := 0
    targetTid := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", &pid, "UInt")
    if (targetTid) {
        currentTid := DllCall("GetCurrentThreadId", "UInt")
        if (DllCall("AttachThreadInput", "UInt", currentTid, "UInt", targetTid, "Int", true)) {
            DllCall("ActivateKeyboardLayout", "Ptr", hkl, "UInt", 0)
            DllCall("AttachThreadInput", "UInt", currentTid, "UInt", targetTid, "Int", false)
            return
        }
    }

    ; debug
    ; ToolTip("Switched to English (US)", , , 1)
    ; SetTimer(() => ToolTip("", , , 1), -2000)
    
}

; Map Right Alt to Win+Space (input method switcher)
RAlt::{
    UpdateLastInputTime()
    Send("#" . Chr(32))
}

; Map F15 to Left Ctrl+Left Alt+Left Shift+`
F15::{
    UpdateLastInputTime()
    Send("^!+``")
}

; F15 Up - no action (empty)
F15 Up::{
    ; No action on key release
}

; Map F13 to switch to Firefox browser or minimize if already Firefox
F13::{
    UpdateLastInputTime()
    
    ; Get the current active window
    try {
        currentWindow := WinGetID("A")
        currentProcess := WinGetProcessName("A")
        
        ; Check if current window is Firefox
        if (currentProcess = "firefox.exe" && WinGetMinMax("A") != -1) {
            ; If current window is Firefox, minimize it
            WinMinimize("A")
        } else {
            ; If current window is not Firefox, try to activate Firefox
            try {
                WinActivate("ahk_exe firefox.exe")
            } catch Error {
                ; If Firefox is not running, try to start it
                try {
                    Run("firefox.exe")
                } catch Error {
                    ; Show error message if Firefox cannot be started
                    TrayTip("无法找到或启动Firefox", "F13键错误")
                }
            }
        }
    } catch Error {
        ; Fallback: try to activate Firefox if we can't get current window info
        try {
            WinActivate("ahk_exe firefox.exe")
        } catch Error {
            try {
                Run("firefox.exe")
            } catch Error {
                TrayTip("无法找到或启动Firefox", "F13键错误")
            }
        }
    }
}

; F13 Up - no action (empty)
F13 Up::{
    ; No action on key release
}

; Show startup notification
TrayTip("Script started. Monitoring keyboard input...", "Input Method Monitor")

; Keep script running