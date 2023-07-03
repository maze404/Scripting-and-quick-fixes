if not exist "C:\kmaster\" mkdir C:\kmaster
net use B: "\\svrwawi1\connectflow2$\kmaster" /user:Administrator datecsoft
robocopy "B:\F3K31" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F3K32" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F3K33" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F1K1" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F1K2" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F1K3" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F1K4" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F2K21" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F2K22" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F2K23" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F2K24" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F2K25" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F2K26" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
robocopy "B:\F2K27" C:\kmaster\ /e /s /mir /NFL /NDL /NJH /NJS /nc /ns /np
net use /delete B:
