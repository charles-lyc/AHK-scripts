; AutoHotkey v2.0.19 Script for Input Method Switching
; Ctrl+Shift+1: English (US)
; Ctrl+Shift+2: Chinese (Simplified, China)
; Ctrl+Shift+3: Japanese

; Language and input method identifiers
EN_US := 0x0409          ; English (US) language ID
ZH_CN := 0x0804          ; Chinese (Simplified) language ID  
JA_JP := 0x0411          ; Japanese language ID

; Input Method Editor (IME) identifiers
EN_US_IME := 0x00000409  ; English keyboard layout
ZH_CN_IME := 0x81D4E9C9  ; Chinese IME GUID (first part)
JA_JP_IME := 0x03B5835F  ; Japanese IME GUID (first part)

; Function to switch input method
SwitchInputMethod(languageID, imeID := 0) {
    ; Get the current active window
    hwnd := WinGetID("A")
    
    ; Method 1: Try using PostMessage with WM_INPUTLANGCHANGEREQUEST
    WM_INPUTLANGCHANGEREQUEST := 0x0050
    
    ; Construct HKL (input locale identifier)
    if (imeID != 0) {
        ; For IME languages, combine language ID with IME ID
        hkl := (imeID << 16) | languageID
    } else {
        ; For simple keyboard layouts
        hkl := languageID
    }
    
    ; Try to switch using PostMessage
    result1 := PostMessage(WM_INPUTLANGCHANGEREQUEST, 0, hkl, , hwnd)
    
    ; Method 2: Alternative approach using ActivateKeyboardLayout
    DllCall("ActivateKeyboardLayout", "Ptr", hkl, "UInt", 0)
    
    ; Method 3: Fallback - Load and activate keyboard layout
    if (!result1) {
        ; Load the keyboard layout if not already loaded
        hklLoaded := DllCall("LoadKeyboardLayout", "Str", Format("{:08X}", hkl), "UInt", 0x00000001, "Ptr")
        if (hklLoaded) {
            DllCall("ActivateKeyboardLayout", "Ptr", hklLoaded, "UInt", 0)
        }
    }
    
    ; Show notification with actual hotkey used
    switch languageID {
        case EN_US:
            ToolTip("Switched to English (US) - Hotkey: Ctrl+Win+Alt+1", , , 1)
        case ZH_CN:
            ToolTip("Switched to 中文 (Chinese Simplified) - Hotkey: Ctrl+Win+Alt+2", , , 1)
        case JA_JP:
            ToolTip("Switched to 日本語 (Japanese) - Hotkey: Ctrl+Win+Alt+3", , , 1)
    }
    
    ; Clear tooltip after 2 seconds
    SetTimer(() => ToolTip(, , , 1), -2000)
}

; Alternative method using Windows API for IME switching
SwitchToIME(languageTag) {
    ; Get all available input methods
    try {
        ; Use PowerShell to switch input method (more reliable for complex IMEs)
        psScript := ""
        
        switch languageTag {
            case "en-US":
                psScript := 'Set-WinUserLanguageList -LanguageList "en-US" -Force'
            case "zh-Hans-CN":
                psScript := '$list = Get-WinUserLanguageList; $list[0].LanguageTag = "zh-Hans-CN"; Set-WinUserLanguageList -LanguageList $list -Force'
            case "ja":
                psScript := '$list = Get-WinUserLanguageList; $list[0].LanguageTag = "ja"; Set-WinUserLanguageList -LanguageList $list -Force'
        }
        
        ; Execute PowerShell command (commented out as it requires admin rights)
        ; RunWait('powershell.exe -Command "' . psScript . '"', , "Hide")
        
    } catch Error as e {
        ; Fallback to regular method
    }
}

; Hotkey definitions
^+1:: {  ; Ctrl+Shift+1 - Switch to English (US)
    SwitchInputMethod(EN_US)
    return
}

^+2:: {  ; Ctrl+Shift+2 - Switch to Chinese (Simplified)
    ; For Chinese IME, we need to use a different approach
    ; Try multiple methods to ensure compatibility
    
    ; Method 1: Direct language switch
    SwitchInputMethod(ZH_CN)
    
    ; Method 2: Send Alt+Shift to cycle through languages (if above fails)
    ; Uncomment the lines below if the direct method doesn't work
    ; Sleep(100)
    ; Send("{Alt down}{Shift down}{Shift up}{Alt up}")
    
    return
}

^+3:: {  ; Ctrl+Shift+3 - Switch to Japanese
    SwitchInputMethod(JA_JP)
    return
}

; Additional hotkeys for debugging (optional)
^+F1:: {  ; Ctrl+Shift+F1 - Show current input method info
    ; Get current keyboard layout
    hwnd := WinGetID("A")
    threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "UInt*", &processId := 0, "UInt")
    hkl := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
    
    ; Extract language ID
    langId := hkl & 0xFFFF
    
    ; Show info
    MsgBox("Current Keyboard Layout: 0x" . Format("{:08X}", hkl) . "`nLanguage ID: 0x" . Format("{:04X}", langId), "Input Method Info")
    return
}

; Status bar notification on startup
TrayTip("Hotkeys:`nCtrl+Win+Alt+1: English`nCtrl+Win+Alt+2: Chinese`nCtrl+Win+Alt+3: Japanese", "Input Method Switcher")

; Auto-execute section ends here