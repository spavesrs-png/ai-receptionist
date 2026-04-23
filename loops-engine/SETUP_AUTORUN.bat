@echo off
schtasks /create /tn "LoopsEngine" /tr "python \"%~dp0run.py\"" /sc daily /st 08:00 /f
echo Scheduled task created successfully.
pause
