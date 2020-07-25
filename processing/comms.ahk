DetectHiddenWindows, On
stdin  := FileOpen("*", "r `n")
query := RTrim(stdin.ReadLine(), "`n")  ;'query' stores the string received from node ('some example' in this case)
SetTitleMatchMode RegEx ; My favorite...
goto, %query%
Return

etr:
{
    PostMessage, 5000,,,,getstuff
    return
}
logging:
{
    PostMessage, 5001,,,,getstuff
    return
}

defaults:
{
    PostMessage 5002,,,,getstuff
    return
}
stop:
{
    PostMessage, 5003,,,,getstuff
    return
}