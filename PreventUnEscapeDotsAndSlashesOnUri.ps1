﻿if (-not $UnEscapeDotsAndSlashes) { Set-Variable -Option ReadOnly -Scope Script -name UnEscapeDotsAndSlashes -value 0x2000000 }

function GetUriParserFlags
{

    $getSyntax = [System.UriParser].GetMethod("GetSyntax", 40)
    $flags = [System.UriParser].GetField("m_Flags", 36)

    $parser = $getSyntax.Invoke($null, "http")
    return $flags.GetValue($parser)
}

function SetUriParserFlags([int]$newValue)
{
    $getSyntax = [System.UriParser].GetMethod("GetSyntax", 40)
    $flags = [System.UriParser].GetField("m_Flags", 36)
    
    $parser = $getSyntax.Invoke($null, "http")
    $flags.SetValue($parser, $newValue)
}

function PreventUnEscapeDotsAndSlashesOnUri
{
    if (-not $uriUnEscapesDotsAndSlashes) { return }

    Write-Verbose "Switching off UnEscapesDotsAndSlashes flag on UriParser."

    $newValue = $defaultUriParserFlagsValue -bxor $UnEscapeDotsAndSlashes
    
    SetUriParserFlags $newValue
}

function RestoreUriParserFlags
{
    if (-not $uriUnEscapesDotsAndSlashes) { return }

    Write-Verbose "Restoring UriParser flags - switching on UnEscapesDotsAndSlashes flag."

    try
    {
        SetUriParserFlags $defaultUriParserFlagsValue
    }
    catch [System.Exception]
    {
        Write-Error "Failed to restore UriParser flags. This may cause your scripts to behave unexpectedly. You can find more at get-help about_UnEsapingDotsAndSlashes."
        throw
    }
}

if (-not $defaultUriParserFlagsValue) { Set-Variable -Option ReadOnly -Scope Script -name defaultUriParserFlagsValue -value (GetUriParserFlags) }
if (-not $uriUnEscapesDotsAndSlashes) { Set-Variable -Option ReadOnly -Scope Script -name uriUnEscapesDotsAndSlashes -value (($defaultUriParserFlagsValue -band $UnEscapeDotsAndSlashes) -eq $UnEscapeDotsAndSlashes) }


if ($uriUnEscapesDotsAndSlashes)
{
    Write-Host -ForegroundColor Red "The default URI behaviour is to un-escape dots and slahes which may prevent module from working correctly. The behaviour will be overriden on some cases. To learn more please read get-help about_UnEsapingDotsAndSlashes."
}
