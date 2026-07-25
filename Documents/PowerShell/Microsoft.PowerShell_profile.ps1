#Requires -Version 7.0
# ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#
# Perfil de PowerShell 7 — gestionado con chezmoi.
# Edita el original con:  chezmoi edit $PROFILE
#
# Objetivos: arranque rápido (sin módulos pesados), colores Everforest
# coherentes con WezTerm, y cero ruido en pantalla.

# ── Codificación ─────────────────────────────────────────────────────────
# Sin esto, los iconos Nerd Font y los acentos salen rotos.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

# ── Entorno ──────────────────────────────────────────────────────────────
$env:STARSHIP_CONFIG               = Join-Path $HOME '.config' 'starship.toml'
$env:VIRTUAL_ENV_DISABLE_PROMPT    = '1'
$env:POWERSHELL_TELEMETRY_OPTOUT   = '1'
$env:POWERSHELL_UPDATECHECK        = 'Off'
$env:DOTNET_CLI_TELEMETRY_OPTOUT   = '1'
if (-not $env:EDITOR) { $env:EDITOR = 'code' }

# ── Colores ──────────────────────────────────────────────────────────────
# Códigos ANSI de las 16 ranuras, no valores hex. El perfil no impone una
# paleta: usa las ranuras que define la terminal en
# dot_config/wezterm/colors.lua. Terminal, prompt y shell comparten así una
# única fuente de verdad, y en una terminal ajena (SSH, VS Code, CI) todo
# adopta SU tema en vez de imponer unos hex que quizá no se lean allí.
$Palette = @{
    fg      = "`e[39m"    # primer plano por defecto
    grey    = "`e[90m"    # bright black
    red     = "`e[91m"
    green   = "`e[92m"
    yellow  = "`e[93m"
    blue    = "`e[94m"
    magenta = "`e[95m"
    cyan    = "`e[96m"
    orange  = "`e[33m"    # el yellow normal de One Dark tira a naranja
    selBg   = "`e[100m"   # fondo bright black
}

# ── Colores de la salida de PowerShell ($PSStyle) ────────────────────────
if ($PSStyle) {
    $PSStyle.Progress.View            = 'Minimal'
    $PSStyle.Formatting.Error         = $Palette.red
    $PSStyle.Formatting.ErrorAccent   = $Palette.cyan
    $PSStyle.Formatting.Warning       = $Palette.yellow
    $PSStyle.Formatting.Verbose       = $Palette.cyan
    $PSStyle.Formatting.Debug         = $Palette.magenta
    $PSStyle.Formatting.TableHeader   = $Palette.green
    $PSStyle.Formatting.FormatAccent  = $Palette.grey

    $PSStyle.FileInfo.Directory       = "`e[1;94m"   # azul brillante en negrita
    $PSStyle.FileInfo.SymbolicLink    = $Palette.cyan
    $PSStyle.FileInfo.Executable      = $Palette.green
    foreach ($ext in '.zip', '.tar', '.gz', '.7z', '.rar') {
        $PSStyle.FileInfo.Extension[$ext] = $Palette.magenta
    }
}

# ── PSReadLine ───────────────────────────────────────────────────────────
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -BellStyle None          # sin pitidos: entorno tranquilo
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -ShowToolTips

    # Las sugerencias predictivas necesitan una consola real con secuencias VT.
    # En sesiones redirigidas (`pwsh -Command …`, CI) fallan: por eso el guardia.
    if (-not [Console]::IsOutputRedirected) {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle ListView
    }

    Set-PSReadLineOption -Colors @{
        Command                = $Palette.green
        Comment                = $Palette.grey
        ContinuationPrompt     = $Palette.grey
        Default                = $Palette.fg
        Emphasis               = $Palette.cyan
        Error                  = $Palette.red
        InlinePrediction       = $Palette.grey
        Keyword                = $Palette.magenta
        ListPrediction         = $Palette.grey
        ListPredictionSelected = $Palette.selBg + $Palette.fg
        Member                 = $Palette.fg
        Number                 = $Palette.magenta
        Operator               = $Palette.cyan
        Parameter              = $Palette.blue
        Selection              = $Palette.selBg + $Palette.fg
        String                 = $Palette.yellow
        Type                   = $Palette.orange
        Variable               = $Palette.fg
    }

    # Tab abre el menú de completado en vez de ciclar a ciegas.
    Set-PSReadLineKeyHandler -Key Tab           -Function MenuComplete
    # Las flechas filtran el historial por lo ya escrito.
    Set-PSReadLineKeyHandler -Key UpArrow       -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow     -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+w        -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Key Alt+d         -Function KillWord
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow  -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Key F7            -Function HistorySearchBackward
    # Ctrl+D borra hacia delante y, en línea vacía, cierra la sesión.
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d'    -Function DeleteCharOrExit
}

# ── Navegación ───────────────────────────────────────────────────────────
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force -Hidden @args }

function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

function which {
    param([Parameter(Mandatory)][string]$Name)
    (Get-Command $Name -ErrorAction SilentlyContinue).Source
}

function touch {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-Path $Path) { (Get-Item $Path).LastWriteTime = Get-Date }
    else { New-Item -ItemType File -Path $Path | Out-Null }
}

function reload { . $PROFILE }

# ── Git ──────────────────────────────────────────────────────────────────
# Nota: no se usan los clásicos gc/gp/gl porque en PowerShell ya son alias
# de Get-Content, Get-ItemProperty y Get-Location, y los alias ganan a las
# funciones en la resolución de comandos.
function g    { git @args }
function gs   { git status --short --branch }
function ga   { git add @args }
function gaa  { git add --all }
function gcmt { git commit @args }
function gpsh { git push @args }
function gpl  { git pull --rebase @args }
function gd   { git diff @args }
function gco  { git checkout @args }
function gbr  { git branch @args }
function glg  { git log --oneline --graph --decorate -20 @args }

# ── chezmoi ──────────────────────────────────────────────────────────────
function cz  { chezmoi @args }
function czd { chezmoi diff @args }               # qué cambiaría en ~
function cza { chezmoi apply --verbose @args }    # aplicar repo -> ~
function czu { chezmoi update --verbose @args }   # git pull + apply
function czs { chezmoi status @args }
function dotfiles { Set-Location (chezmoi source-path) }

# ── Laravel / Herd ───────────────────────────────────────────────────────
function art { php artisan @args }
function pa  { php artisan @args }
function ti  { php artisan tinker @args }

# ── Extras opcionales (sólo si están instalados) ─────────────────────────
# -ErrorAction Ignore, no SilentlyContinue: así ni siquiera ensucian $Error.
if (Get-Command zoxide -ErrorAction Ignore) {
    Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
}
if (Get-Command fnm -ErrorAction Ignore) {
    fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression
}
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# ── Prompt (Starship) — siempre al final ─────────────────────────────────
if (Get-Command starship -ErrorAction Ignore) {
    Invoke-Expression (& starship init powershell)
} else {
    Write-Host "starship no está instalado: winget install --id Starship.Starship" -ForegroundColor DarkYellow
}
