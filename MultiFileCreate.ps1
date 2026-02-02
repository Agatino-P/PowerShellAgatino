1..$n | ForEach-Object { New-Item -Path "test$($_.ToString('000')).txt" }
