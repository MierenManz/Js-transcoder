localver = 1.7.0
localver := trim(localver)
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", "https://raw.githubusercontent.com/MierenManz/versiontest/master/README.md", true)
whr.Send()
whr.WaitForResponse()
onlinecheck := whr.ResponseText
onlinecheck := StrReplace(StrReplace(onlinecheck, "`n"), "`r")
msgbox %onlinecheck%
  if (localver == onlinecheck) {
      msgbox, they are the same picture
  } else {
      msgbox different
  }