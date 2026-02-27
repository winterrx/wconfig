Set-PSReadlineKeyHandler -Key "Escape" -Function AcceptSuggestion
oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/iterm2.omp.json | Invoke-Expression
remove-item alias:curl
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

function nrd { npm run dev }
function nrs { npm run start }
function nrb { npm run build }
function brd { bun run dev }
function brs { bun run start }
function brb { bun run build }
function pushdb { npx prisma db push }
function newdb { npx prisma generate db }
function list-npm-aliases {
    $aliases = @{
        "nrd" = "npm run dev"
        "nrs" = "npm run start"
        "nrb" = "npm run build"
        "brd" = "bun run dev"
        "brs" = "bun run start"
        "brb" = "bun run build"
        "pushdb" = "npx prisma db push"
        "newdb" = "npx prisma generate db"
    }
    $aliases.GetEnumerator() | Sort-Object Name | Format-Table Name,Value -AutoSize
}
Set-Alias lna list-npm-aliases

# Evan Hahn-inspired utility functions

# Clipboard utilities
function copy {
    if ($args.Count -eq 0) {
        $input | Set-Clipboard
    } else {
        Get-Content $args[0] | Set-Clipboard
    }
}

function pasta { Get-Clipboard }

function pastas {
    $last = Get-Clipboard
    Write-Output $last
    while ($true) {
        Start-Sleep -Milliseconds 500
        $current = Get-Clipboard
        if ($current -ne $last) {
            Write-Output $current
            $last = $current
        }
    }
}

# Directory utilities
function mkcd {
    param([string]$path)
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Set-Location $path
}

function tempe {
    $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
    Set-Location $tempDir
    Write-Host "Temporary directory: $tempDir"
}

# Internet/Media
function getsong {
    param([string]$url)
    if (Get-Command yt-dlp -ErrorAction SilentlyContinue) {
        yt-dlp -x --audio-quality 0 $url
    } else {
        Write-Error "yt-dlp not installed. Install with: winget install yt-dlp"
    }
}

function url {
    param([string]$urlString)
    $uri = [System.Uri]$urlString
    [PSCustomObject]@{
        Protocol = $uri.Scheme
        Host = $uri.Host
        Port = $uri.Port
        Path = $uri.AbsolutePath
        Query = $uri.Query
        Fragment = $uri.Fragment
        UserInfo = $uri.UserInfo
    } | Format-List
}

# Text utilities
function scratch {
    $tempFile = New-TemporaryFile
    $editor = if ($env:EDITOR) { $env:EDITOR } else { "notepad" }
    & $editor $tempFile.FullName
}

function length {
    param([Parameter(ValueFromPipeline=$true)][string]$text)
    process {
        if ($text) { $text.Length } else { ($input | Out-String).Length }
    }
}

function nato {
    param([Parameter(ValueFromPipeline=$true)][string]$text)
    $natoMap = @{
        'a'='Alfa'; 'b'='Bravo'; 'c'='Charlie'; 'd'='Delta'; 'e'='Echo'
        'f'='Foxtrot'; 'g'='Golf'; 'h'='Hotel'; 'i'='India'; 'j'='Juliett'
        'k'='Kilo'; 'l'='Lima'; 'm'='Mike'; 'n'='November'; 'o'='Oscar'
        'p'='Papa'; 'q'='Quebec'; 'r'='Romeo'; 's'='Sierra'; 't'='Tango'
        'u'='Uniform'; 'v'='Victor'; 'w'='Whiskey'; 'x'='X-ray'; 'y'='Yankee'
        'z'='Zulu'; '0'='Zero'; '1'='One'; '2'='Two'; '3'='Three'; '4'='Four'
        '5'='Five'; '6'='Six'; '7'='Seven'; '8'='Eight'; '9'='Nine'
    }
    ($text.ToLower().ToCharArray() | ForEach-Object {
        if ($natoMap.ContainsKey([string]$_)) { $natoMap[[string]$_] } else { $_ }
    }) -join ' '
}

# Date/Time utilities
function hoy { Get-Date -Format "yyyy-MM-dd" }

function timer {
    param(
        [int]$seconds = 60,
        [string]$message = "Timer finished!"
    )
    Write-Host "Timer started for $seconds seconds..."
    Start-Sleep -Seconds $seconds
    Write-Host "`a$message" -ForegroundColor Green
    if (Get-Command New-BurntToastNotification -ErrorAction SilentlyContinue) {
        New-BurntToastNotification -Text $message
    }
}

function rn {
    Get-Date
    Write-Host ""
    if (Get-Command cal -ErrorAction SilentlyContinue) { cal }
    else { Write-Host "Calendar not available. Consider installing ncal via scoop or chocolatey." }
}

# Video utility
function shrinkvid {
    param(
        [string]$input,
        [string]$output = "compressed_video.mp4"
    )
    if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
        ffmpeg -i $input -c:v libx264 -crf 28 -c:a aac -b:a 128k $output
    } else {
        Write-Error "ffmpeg not installed. Install with: winget install FFmpeg"
    }
}

# Reference utilities
function httpstatus {
    param([int]$code)
    $statuses = @{
        200='OK'; 201='Created'; 204='No Content'; 301='Moved Permanently'
        302='Found'; 304='Not Modified'; 400='Bad Request'; 401='Unauthorized'
        403='Forbidden'; 404='Not Found'; 500='Internal Server Error'
        502='Bad Gateway'; 503='Service Unavailable'
    }
    if ($statuses.ContainsKey($code)) {
        "$code $($statuses[$code])"
    } else {
        "Status code $code"
    }
}

function alphabet {
    Write-Host "abcdefghijklmnopqrstuvwxyz"
    Write-Host "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
}

function emoji {
    param([string]$search)
    $emojiMap = @{
        'cool'=[char]::ConvertFromUtf32(0x1F60E)
        'fire'=[char]::ConvertFromUtf32(0x1F525)
        'heart'=[char]::ConvertFromUtf32(0x2764)
        'smile'=[char]::ConvertFromUtf32(0x1F60A)
        'laugh'=[char]::ConvertFromUtf32(0x1F602)
        'think'=[char]::ConvertFromUtf32(0x1F914)
        'rocket'=[char]::ConvertFromUtf32(0x1F680)
        'star'=[char]::ConvertFromUtf32(0x2B50)
        'check'=[char]::ConvertFromUtf32(0x2705)
        'cross'=[char]::ConvertFromUtf32(0x274C)
        'wave'=[char]::ConvertFromUtf32(0x1F44B)
        'thumbsup'=[char]::ConvertFromUtf32(0x1F44D)
        'party'=[char]::ConvertFromUtf32(0x1F389)
        'eyes'=[char]::ConvertFromUtf32(0x1F440)
        'coffee'=[char]::ConvertFromUtf32(0x2615)
    }
    if ($emojiMap.ContainsKey($search.ToLower())) {
        $emojiMap[$search.ToLower()]
    } else {
        "No emoji found for '$search'. Try: $($emojiMap.Keys -join ', ')"
    }
}

function uuid { [guid]::NewGuid().ToString() }

# CLI tool aliases
function oc { opencode @args }
function cc { claude @args }