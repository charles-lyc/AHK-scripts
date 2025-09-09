# AHK-scripts

Personal AutoHotKey useful scripts.

# How to use

- Use AHK to generate .exe from .ahk

- Right click and drag .exe to create a short cut

- Put it in Win Startup folder

# Prompt

### switch_input_language

Give me a AHK (v2.0.19) script in Windows. Switch my input method as I want. In my case, ctrl+shift+1 for en-US; ctrl+shift+2 for zh-Hans-CN; ctrl+shift+3 for ja. Double check your result.

This is my testing by using "Get-WinUserLanguageList" :
LanguageTag : en-US
Autonym : English (United States)
EnglishName : English
LocalizedName : English (United States)
ScriptName : Latin
InputMethodTips : {0409:00000409}
Spellchecking : True
Handwriting : False

LanguageTag : zh-Hans-CN
Autonym : 中文(中华人民共和国)
EnglishName : Chinese
LocalizedName : Chinese (Simplified, Mainland China)
ScriptName : Chinese (Simplified)
InputMethodTips : {0804:{81D4E9C9-1D3B-41BC-9E6C-4B40BF79E35E}{FA550B04-5AD7-411F-A5AC-CA038EC515D7}}
Spellchecking : True
Handwriting : True

LanguageTag : ja
Autonym : 日本語
EnglishName : Japanese
LocalizedName : Japanese
ScriptName : Japanese
InputMethodTips : {0411:{03B5835F-F03C-411B-9CE2-AA23E1171E36}{A76C93D9-5523-4E90-AAFA-4DB112F9AC76}}
Spellchecking : True
Handwriting : True



### auto_reset_input_language

monitor the keyboard input. if >10sec without any input, then set the input method as en-US.
