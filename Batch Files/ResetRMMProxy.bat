@echo off
netsh winhttp reset proxy
"C:\Program Files (x86)\Advanced Monitoring Agent\features\MSP_Connect.exe" /S /R
pause
