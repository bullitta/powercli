﻿get-volume|where-object {$_.DriveType -eq "Fixed" -and $_.filesystemlabel.length -lt 2 }|ft driveletter,sizeremaining