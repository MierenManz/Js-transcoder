#NoTrayIcon
#SingleInstance, off
#include <talk>
query = %1%
comms := new talk("main")
comms.setvar("etr", query, false)
comms.runlabel("etr")
exitapp