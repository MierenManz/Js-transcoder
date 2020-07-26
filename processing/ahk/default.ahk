#NoTrayIcon
#SingleInstance, off
#include <talk>
query = %1%
comms := new talk("main")
comms.setvar("def", query, false)
comms.runlabel("def")
exitapp