write-host "Version 0.22a"
# Script fuer gestohlene Laptops
# Mit den AUsfÃƒÂ¼hren des Scripts wird die Lizenzbedingung von commandcam.exe akzeptiert
# acmeo GmbH & Co. KG weist jede Verantwortung oder Schaeden zurueck
# Alle Scripte von acmeo werden als Beta behandelt und die Nutzung und Ausfuehrung geschieht auf eigene Gefahr
# Die Nutzung ist ausschließlich fuer die Aufklarerung von Diebstaelen gedacht und darf nicht
# fuer die Ueberwachung oder Spionage oder andere Zwecke genutzt werden
# Wir lehnen jede Haftung oder Misbrauch und die Schaeden dazu ab

# Wenn Sie die Bedingungen akzeptieren bestaetigen Sie mit den Parameter "VERSTANDEN"

### Fuellen Sie die folgenden Felder aus
[string]$mailvon = "IHR EMAILABSENDER" 
[string]$mailan = "IHRE EMPFAENGERMAIL"
[string]$mailbetreff = "Webcam Picture" #Betreff
[string]$mailBenutzername = "IHR EMAILBENUTZERNAME"
[string]$mailPasswort = "IHR EMAILPASSWORT"
[string]$mailServer = "IHR EMAILSERVER"





############################### ab hoer nichts mehr ändern ##############################################
[int]$errorcount = 0
[string]$parameter = $args[0]
if($parameter -ne "VERSTANDEN")
{
write-host "Script fuer gestohlene Laptops"
write-host "Mit den Ausfuehren des Scripts wird die Lizenzbedingung von commandcam.exe und acmeo zur Nutzung von Scripten akzeptiert"
write-host "acmeo GmbH & Co. KG weist jede Verantwortung oder Schaeden zurueck"
write-host "Alle Scripte von acmeo werden als Beta behandelt und die Nutzung und Ausfuehrung geschieht auf eigene Gefahr"
write-host "Die Nutzung ist ausschließlich fuer die Aufklarerung von Diebstaelen gedacht und darf nicht"
write-host "fuer die Ueberwachung oder Spionage oder andere Zwecke genutzt werden"
write-host "Wir lehnen jede Haftung oder Misbrauch und die Schaeden dazu ab"
Write-Host 'Wenn Sie die Bedingungen akzeptieren bestaetigen Sie mit den Parameter "VERSTANDEN" mit Gaensefuesschen'
exit 0
}

if($parameter -eq "ICH AKZEPTIERE")
{
    Write-Host "Sie haben die Vereinbarung akzeptiert"
    write-host "Wenn Sie das zusenden stoppen wollen entfernen Sie den Parameter ICH AKZEPTIERE wieder"
}

if (Test-Path -Path "C:\Program Files (x86)\Advanced Monitoring Agent" -ErrorAction SilentlyContinue)
    {
    
    $pfad = "C:\Program Files (x86)\Advanced Monitoring Agent\"
  
    }


elseif (Test-Path -Path "C:\Program Files\Advanced Monitoring Agent" -ErrorAction SilentlyContinue)
    {
 
    $pfad = "C:\Program Files\Advanced Monitoring Agent\"
    
    }
elseif (Test-Path -Path "C:\Program Files (x86)\Advanced Monitoring Agent GP" -ErrorAction SilentlyContinue)
    {
    
    $pfad = "C:\Program Files (x86)\Advanced Monitoring Agent GP\"
    
    }
elseif (Test-Path -Path "C:\Program Files\Advanced Monitoring Agent GP" -ErrorAction SilentlyContinue)
    {
    
    $pfad = "C:\Program Files\Advanced Monitoring Agent GP\"
    
    }
else
    {
    
    Write-Host "Advanced Monitoring Agent Pfad konnte nicht ermittelt werden!";
    exit 1001;
    }
$exepfad = $pfad+"screen\CommandCam.exe"
$ziel = $pfad+"screen\"
$ziel = $ziel.Trim()
$url = "https://www.acmeo.eu/downloads/technik/acmeo/scriptdownloads/webcampicture/CommandCam.exe"

if(!(Test-Path -Path $exepfad -ErrorAction SilentlyContinue))
{
if(!(Test-Path $ziel)) 
{
    New-Item $ziel -ItemType directory 
    $filename = $ziel+"CommandCam.exe"
    if(!(Test-Path $filename -ErrorAction SilentlyContinue))
    {
        $shell_app=new-object -com shell.application
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $ziel+"CommandCam.exe")
    }
}
}
if(Test-Path -Path "c:\Pics.bmp" -ErrorAction SilentlyContinue)
{
    Remove-Item -Path "c:\Pics.bmp" -Recurse -Force
}

$arguments = "/filename c:\Pics.bmp"
Start-Process -FilePath $exepfad -ArgumentList $arguments -Wait 

function sendmail
{
$smtp = New-Object System.Net.Mail.SmtpClient 
$MailMessage = New-Object system.net.mail.mailmessage
$attfile = "c:\Pics.bmp"
$attatchment = New-Object System.Net.Mail.Attachment($attfile)
$smtp.Host = $mailServer
$MailMessage.From = $mailvon
$MailMessage.To.Add($mailan)
$MailMessage.Subject = $mailbetreff
$MailGetBody = "Picture von der Webcam"
$MailMessage.Body = $MailGetBody
$MailMessage.IsBodyHtml = $false
$MailMessage.Attachments.Add($attatchment)
$SmtpUser = New-Object System.Net.NetworkCredential
$SmtpUser.UserName = $mailBenutzername
$SmtpUser.Password = $mailPasswort
$smtp.Credentials = $SmtpUser
$smtp.Send($MailMessage)
$attatchment.Dispose()
$smtp.Dispose()
}
if($mailvon -ne "IHR EMAILABSENDER")
{
    sendmail
}
Remove-Item -Path "c:\Pics.bmp" -Recurse -Force
exit 0
