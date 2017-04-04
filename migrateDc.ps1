<#
  IBPS AD DC Migration Automation

  This script automates changing the DNS resovlers on MS DC's in a domain,
  also changes the forwarders of the MS DNS service on the DC, and restarts
  the netlogin and DNS services.

  Run as Domain or Enterprise Admin
  Uses Invoke-Command

  v1 March 2017, Nathan Evans, nevans@showrunint.com

  This is free and unencumbered software released into the public domain.

  Anyone is free to copy, modify, publish, use, compile, sell, or
  distribute this software, either in source code form or as a compiled
  binary, for any purpose, commercial or non-commercial, and by any
  means.

  In jurisdictions that recognize copyright laws, the author or authors
  of this software dedicate any and all copyright interest in the
  software to the public domain. We make this dedication for the benefit
  of the public at large and to the detriment of our heirs and
  successors. We intend this dedication to be an overt act of
  relinquishment in perpetuity of all present and future rights to this
  software under copyright law.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.

  For more information, please refer to <http://unlicense.org/>

#>
##Begin Script
import-module activedirectory

    ##-domain "DC=example,DC=com"	#[required]	domain to perform operations on, yes "" required
    ##-dns1 127.0.0.1
    ##-dns2 127.0.0.1

param (
  [Parameter(Mandatory=$true)][string]$domain,
  [Parameter(Mandatory=$true)][string]$dns1,
  [Parameter(Mandatory=$true)][string]$dns2
)


$dcs = Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,$domain"



foreach ($dc in $dcs){

    Invoke-Command -ComputerName $dc.name -ScriptBlock {

        $interface = Get-NetIPInterface -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "Loopback*"}

        Set-DnsClientServerAddress -InterfaceAlias $interface.InterfaceAlias -ServerAddresses ("$dns1","$dns2")
        Set-DnsServerForwarder -IPAddress ("$dns1","$dns2") -PassThru
        Restart-Service -Name Netlogon
        Restart-Service -Name DNS
        Get-DnsClientServerAddress $interface.InterfaceAlias -AddressFamily IPv4
        Get-DnsSererForwarder

    }

}
##End Script
