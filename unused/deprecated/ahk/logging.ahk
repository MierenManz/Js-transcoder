#NoTrayIcon
#SingleInstance, force
#include <talk>
query = %1%
comms := new talk("main")
comms.setvar("lgs", query)
comms.runlabel("lgs")
exitapp