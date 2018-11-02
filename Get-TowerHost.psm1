<#
GetAnsTowerHost

PowerShell module for manging tower inventory

Make a POST request to this resource with the following host
fields to create a new host associated with this
inventory.

name: Name of this host. (string, required)

description: Optional description of this host. (string, default="")

enabled: Is this host online and available for running jobs? (boolean, default=True)

instance_id: The value used by the remote inventory source to uniquely identify the host (string, default="")

variables: Host variables in JSON or YAML format. (string, default="")

Make a POST request to this resource with id and disassociate fields to
delete the associated host.

{ "id": 123, "disassociate": true }


#>

Class GetAnsTowerHost
{
    [String]$tower
    [String]$uri
    [String]$token
    [String]$response
    [System.Collections.Generic.Dictionary[String, String]]$headers

    GetAnsTowerHost( [string]$towerhost ) {
        $this.tower   = $towerhost
        $this.uri     = "https://{0}/api/v2" -f $this.tower
        $this.token   = $null
        $this.headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $this.headers.add( "Content-Type", "application/json" )
        $this.login()
    }

    [void]login() {
        $username = Read-host "Tower Username"
        $securepw = Read-host "Tower Password" -AsSecureString
        $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR( $securepw )
            )
        
        $body     = @{ username = $username; password = $password }
        $username = $null
        $password = $null

        $result = [pscustomobject]@{}
        try {
            $result = Invoke-RestMethod `
                -Method Post `
                -Uri "$($this.uri)/authtoken/" `
                -Body ( ConvertTo-Json $body ) `
                -Headers $this.headers `
                -SkipCertificateCheck
        }
        catch {
            Write-Host $_.Exception.Message
            Break
        }

        $body = $null

        if ( $result.psobject.properties.match( "token" ) ) {
            $this.token = $result.token
            $this.headers.add( "Authorization", "Token {0}" -f $this.token )
        } else {
            $this.token = $null
        }
    }

    [string]query( [string]$newhostname  ) {
        if ( [string]::IsNullOrEmpty( $this.token ) ) {
            $this.login()
        }

        $result = [pscustomobject]@{}
        try {
            $result = Invoke-RestMethod `
                -Method Get `
                -Uri "$($this.uri)/hosts/?search=$newhostname" `
                -Headers $this.headers `
                -SkipCertificateCheck | ConvertTo-Json #-Depth 4
        }
        catch {
            Write-Host $_.Exception.Message
            Break
        }

        #$result
        return $result
    }

}
function Get-TowerHost()
{
    Param(
        [String]$tower
    )
    return [GetAnsTowerHost]::new( $tower )
}

Export-ModuleMember -Function Get-TowerHost

