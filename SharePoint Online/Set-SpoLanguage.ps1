#Load SharePoint CSOM Assemblies
Add-Type -Path CProgram FilesCommon FilesMicrosoft SharedWeb Server Extensions16ISAPIMicrosoft.SharePoint.Client.dll
Add-Type -Path CProgram FilesCommon FilesMicrosoft SharedWeb Server Extensions16ISAPIMicrosoft.SharePoint.Client.Runtime.dll
  
#function to change Locale in regional settings of a SharePoint Online site
Function Set-SPOLocale([String]$SiteURL, [String]$LocaleID, [PSCredential]$Cred) { 
    Try {
        #Set up the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
    
        #Get Regional Settings of the Web
        $Web = $Ctx.Web
        $Ctx.Load($web)
        $Ctx.Load($Web.RegionalSettings)
        $ctx.ExecuteQuery()
  
        #Update the LocaleID of the site
        $Web.RegionalSettings.LocaleId = $LocaleID
        $Web.Update()
        $Ctx.ExecuteQuery()
  
        Write-host -f Green Locale has been updated for $Web.Url
  
        #Get all subsites of the web
        $Ctx.Load($Web.Webs)
        $Ctx.executeQuery() 
        #Iterate through each subsites and call the function recursively
        Foreach ($Subweb in $Web.Webs) {
            #Call the function to set Locale for the web
            Set-SPOLocale -SiteURL $Subweb.URL -LocaleID $LocaleID -Cred $Cred
        }
    }
    Catch [System.Exception] {
        Write-Host -f Red Error$_.Exception.Message
    }
} 
