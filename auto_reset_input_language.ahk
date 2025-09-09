; AutoHotkey v2.0.19 script to monitor keyboard input
; Switches to en-US input method after 10 seconds of inactivity

#Requires AutoHotkey v2.0.19

; Global variables
lastInputTime := A_TickCount
timerRunning := false
TIMEOUT_MS := 10000  ; 10 seconds in milliseconds

; English (US) keyboard layout identifier
EN_US_LAYOUT := 0x04090409

; Set up input hook to monitor all keyboard input
ih := InputHook("V")
ih.KeyOpt("{All}", "+")
ih.OnKeyDown := OnAnyKey
ih.Start()

; Function called on any key press
OnAnyKey(ih, VK, SC) {
    global lastInputTime, timerRunning
    
    ; Update last input time
    lastInputTime := A_TickCount
    
    ; Start timer if not already running
    if (!timerRunning) {
        SetTimer(CheckInactivity, 1000)  ; Check every second
        timerRunning := true
    }
}

; Function to check for inactivity
CheckInactivity() {
    global lastInputTime, timerRunning, TIMEOUT_MS
    
    currentTime := A_TickCount
    timeSinceLastInput := currentTime - lastInputTime
    
    ; Check if timeout period has passed
    if (timeSinceLastInput >= TIMEOUT_MS) {
        ; Switch to English (US) input method
        SwitchToEnglishUS()
        
        ; Stop the timer
        SetTimer(CheckInactivity, 0)
        timerRunning := false
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

; Optional hotkey to manually trigger the switch (Ctrl+Shift+E)
^+e:: {
    SwitchToEnglishUS()
}

; Optional hotkey to exit the script (Ctrl+Shift+Q)
^+q:: {
    ExitApp
}

; Show startup notification
TrayTip("Script started. Monitoring keyboard input...", "Input Method Monitor")

; Keep script running