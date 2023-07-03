###################################################################################
##                                                                               ##
##    Die acmeo cloud-distribution GmbH & Co. KG uebernimmt keine Haftung        ##
##    fuer unmittelbare und mittelbare Schaeden aus der Benutzung von            ##
##    durch acmeo selbst erstelltem Programmcode (bspw. Skripte,                 ##
##    Bibliotheken, Programmteile, Programme). Die Benutzung des als             ##
##    Beta-Version herausgegebenen Programmcodes geschieht auf eigene Gefahr.    ##
##                                                                               ##
##    Erstellt von: Sebastian-Nicolae Matei                                      ##
##    Fragen an: support@acmeo.eu                                                ##
##                                                                               ##
##    Kann einzelne Patches oder saemtliche Patches eines Produktes sperren.     ##
##                                                                               ##
##    BEARBEITEN: Im oberen Teil ist ein Abschnitt gelistet in dem der           ##
##    API-Schluessel des Dashboards hinterlegt werden muss.                      ##
##                                                                               ##
###################################################################################
##                                                                               ##
##    Beispiele fuer moeglich Parameter aus der Befehlszeile                     ##
##                                                                               ##
##    Befehlszeile:                                                              ##
##    Java Adobe								 ##
##    Sperrt saemtliche Patches zu Java und Adobe Produkten.                     ##
##                                                                               ##
###################################################################################

###################################################################################
##                                                                               ##
##    API-Schluessel. Im Dashboard gelistet unter:                               ##
##    "Einstellungen" -> "Allgemeine Eisntellungen" -> "API"                     ##
##                                                                               ##
###################################################################################

[string[]]$global:arrstrLockedPatches = @($args);
[string]$global:strAgentPath = "";
[string]$global:strDeviceID = "";

function fQueryAPI([string]$strAPIUrl)
{
    [xml]$xmlResult = New-Object System.Xml.XmlDocument;
    do
    {
        $xmlResult.Load("https://wwwgermany1.systemmonitor.eu.com/api/?apikey=bbWORccGYBRtQURqjsGnYhLEZItTK9V4" + $strAPIUrl);
    }while (($xmlResult -eq $NULL) -or ($xmlResult -eq 0) -or ($xmlResult -eq ""))
    return $xmlResult;
}

function fGetDeviceID()
{
    $global:strAgentPath = $env:ProgramFiles + "\Advanced Monitoring Agent\";
    if (Test-Path $global:strAgentPath)
    {
        fReadDeviceID;
        return;
    }
    $global:strAgentPath = ${env:ProgramFiles(x86)} + "\Advanced Monitoring Agent\";
    if(Test-Path $global:strAgentPath)
    {
        fReadDeviceID;
        return;
    }
    $global:strAgentPath = ${env:ProgramFiles} + "\Advanced Monitoring Agent GP\";
    if(Test-Path $global:strAgentPath)
    {
        fReadDeviceID;
        return;
    }
    $global:strAgentPath = ${env:ProgramFiles(x86)} + "\Advanced Monitoring Agent GP\";
    if(Test-Path $global:strAgentPath)
    {
        fReadDeviceID;
        return;
    }
    if ($global:strDeviceID -EQ "")
    {
        Write-Host "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
        Write-Host "Der Installationspfad des MAX RM Agenten konnte nicht ermittelt werden. Bitte pruefen!";
        Write-Host "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
    }
}

function fReadDeviceID()
{
    foreach($strEntry in Get-Content $global:strAgentPath"settings.ini")
    {
        if ($strEntry.Split("=")[0] -eq "DEVICEID")
        {
            $global:strDeviceID = $strEntry.Split("=")[1].Trim();
            break;
        }
    }
}

function fGetCheckID()
{
    [xml]$xml247Config = Get-Content $global:strAgentPath "247_Config.xml";
    [xml]$xmlAPIConfig = fQueryAPI("&service=list_checks&deviceid=" + $global:strDeviceID);
    foreach ($xmlConfigEntry in $xml247Config.checks.ChildNodes)
    {
        foreach($xmlsubConfigEntry in $xmlConfigEntry.ChildNodes)
        {
            $strFilename = $MyInvocation.ScriptName.Split('\')[$MyInvocation.ScriptName.Split('\').Length - 1];
            if ($xmlsubConfigEntry.InnerText.ToString() -eq $strFilename)
            {
                foreach($xmlsubAPIConfig in $xmlAPIConfig.result.items.ChildNodes)
                {
                    if ($xmlsubAPIConfig.uid.ToString() -eq  $xmlsubConfigEntry.ParentNode.Attributes[0].Value.ToString())
                    {
                        return $xmlsubAPIConfig.checkid.ToString();
                    }
                }
            }
        }
    }
}

function fSetIgnore()
{
    fGetDeviceID;
    [xml]$xmlPatches = fQueryAPI("&service=patch_list_all&deviceid=" + $global:strDeviceID);
    foreach($strLockedPatch in $global:arrstrLockedPatches)
    {
        foreach($xmlPatch in $xmlPatches.patches.patch)
        {
            if ($xmlPatch.patchTitle.InnerText -ne $null)
            {
                if(($xmlPatch.status -eq 1) -or ($xmlPatch.status -eq 2) -or ($xmlPatch.status -eq 4))
                {
                    if ($xmlPatch.patchTitle.InnerText.Contains($strLockedPatch))
                    {
                        fLockPatch $xmlPatch.patchid.ToString() $xmlPatch.product.InnerText $xmlPatch.patchTitle.InnerText $xmlPatch.releaseDateText.InnerText;
                    }
                    elseif ($xmlPatch.product.InnerText.Contains($strLockedPatch))
                    {
                        fLockPatch $xmlPatch.patchid.ToString() $xmlPatch.product.InnerText $xmlPatch.patchTitle.InnerText $xmlPatch.releaseDateText.InnerText;
                    }
                }
            }
            if(($xmlPatch.status -eq 32))
            {
                Write-Host "||||||||||||||||||||||||||||||||||||||||-GESPERRT-||||||||||||||||||||||||||||||||||||||||||||||||||";
                Write-Host "Produkt: " $xmlPatch.product.InnerText;
                Write-Host "Patch: " $xmlPatch.patchTitle.InnerText;
                Write-Host "Datum: " $xmlPatch.releaseDateText.InnerText;
                Write-Host "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
            }
        }
    }
}

function fLockPatch([string]$strPatchID, [string]$strPatchProduct, [string]$strPatchTitle, [string]$strPatchRelease)
{
    [string]$strCheckID = fGetCheckID;
    fQueryAPI("&service=patch_ignore&deviceid=" + $global:strDeviceID + "&patchids=" + $strPatchID);
    Write-Host "|||||||||||||||||||||||||||||||||||||||-WIRD GESPERRT-|||||||||||||||||||||||||||||||||||||||||||";
    Write-Host "Produkt: " $strPatchProduct;
    Write-Host "Patch: " $strPatchTitle;
    Write-Host "Datum: " $strPatchRelease;
    Write-Host "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
    [string]$strLockedText = "Wird gesperrt: " + $strPatchProduct + " | Patch: " + $strPatchTitle + " | Datum: " + (Get-Date).ToShortDateString() + " - " + (Get-Date).ToShortTimeString() + " Uhr";
    fQueryAPI("&service=add_check_note&checkid=" + $strCheckID + "&public_note=" + $strLockedText.Replace(" ", "%20") + "&private_note=" + $strLockedText.Replace(" ", "%20"));
}

fSetIgnore;
