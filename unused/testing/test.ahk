stdin  := FileOpen("*", "r `n")  ; Requires v1.1.17+
stdout := FileOpen("*", "w `n")
; For older versions:
;   stdin  := FileOpen(DllCall("GetStdHandle", "int", -10, "ptr"), "h `n")
;   stdout := FileOpen(DllCall("GetStdHandle", "int", -11, "ptr"), "h `n")
stdout.Write("2")   ;this is what you communicate from ahk to node
stdout.Read(0) ; Flush the write buffer.
#Persistent