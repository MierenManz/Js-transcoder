#NoTrayIcon
#SingleInstance, off
#include <talk>
query = %1%
comms := new talk("main")
comms.runlabel("stop")

exitapp