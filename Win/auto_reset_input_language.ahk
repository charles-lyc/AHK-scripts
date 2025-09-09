; AutoHotkey v2.0.19 script to monitor keyboard input
; Switches to en-US input method after 10 seconds of inactivity

#Requires AutoHotkey v2.0.19

; Global variables
lastInputTime := A_TickCount
TIMEOUT_MS := 10000  ; 10 seconds in milliseconds

; English (US) keyboard layout identifier
EN_US_LAYOUT := 0x04090409

; Start monitoring immediately
SetTimer(CheckInactivity, 1000)  ; Check every second

; Install low-level keyboard hook to capture all keyboard input
OnMessage(0x0100, OnKeyDown)  ; WM_KEYDOWN
OnMessage(0x0101, OnKeyUp)    ; WM_KEYUP
OnMessage(0x0104, OnSysKeyDown)  ; WM_SYSKEYDOWN
OnMessage(0x0105, OnSysKeyUp)    ; WM_SYSKEYUP

; Also use a simpler input hook as backup
ih := InputHook("V L0")
ih.KeyOpt("{All}", "+")
ih.OnKeyDown := OnAnyKeyHook
ih.Start()

; Function called by input hook
OnAnyKeyHook(ih, VK, SC) {
    UpdateLastInputTime()
}

; Functions called by message hooks
OnKeyDown(wParam, lParam, msg, hwnd) {
    UpdateLastInputTime()
}

OnKeyUp(wParam, lParam, msg, hwnd) {
    UpdateLastInputTime()
}

OnSysKeyDown(wParam, lParam, msg, hwnd) {
    UpdateLastInputTime()
}

OnSysKeyUp(wParam, lParam, msg, hwnd) {
    UpdateLastInputTime()
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
    
    ; Optional: Show debug info (uncomment for testing)
    ; ToolTip("Time since input: " . Round(timeSinceLastInput/1000, 1) . "s", 0, 20, 3)
    
    ; Check if timeout period has passed
    if (timeSinceLastInput >= TIMEOUT_MS) {
        ; Switch to English (US) input method
        SwitchToEnglishUS()
        
        ; Reset timer to avoid repeated switching
        lastInputTime := A_TickCount
    }
}

; Function to switch input method to English (US)
SwitchToEnglishUS() {
    global EN_US_LAYOUT
    
    try {
        ; Get the current foreground window
        hwnd := WinGetID("A")
        
        ; Load the English (US) keyboard layout
        hkl := DllCall("LoadKeyboardLayout", "Str", "00000409", "UInt", 0, "Ptr")
        
        if (hkl != 0) {
            ; Post message to switch input method for the active window
            PostMessage(0x50, 0, hkl, hwnd)  ; WM_INPUTLANGCHANGEREQUEST
            
            ; Optional: Show a brief tooltip notification
            ToolTip("Switched to English (US)", , , 1)
            SetTimer(() => ToolTip("", , , 1), -2000)  ; Hide tooltip after 2 seconds
        }
    } catch Error as e {
        ; Silent error handling - you can uncomment the next line for debugging
        ; MsgBox("Error switching input method: " . e.Message)
    }
}

; Map Right Alt to Win+Space (input method switcher)
RAlt::Send("#" . Chr(32))

; Show startup notification
TrayTip("Script started. Monitoring keyboard input...", "Input Method Monitor")

; Keep script running