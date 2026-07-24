-- ~/.config/wezterm/wezterm.lua
--
-- Configuración de WezTerm — minimalista y pensada para sesiones largas.
-- Gestionada con chezmoi: no edites la copia de ~, edita la del repo
-- (`chezmoi edit ~/.config/wezterm/wezterm.lua`).
--
-- Estructura:
--   colors.lua  paletas y tema activo
--   ui.lua      tipografía, ventana, barra de pestañas, rendimiento
--   keys.lua    atajos de teclado y ratón

local wezterm = require('wezterm')

local colors = require('colors')
local ui = require('ui')
local keys = require('keys')

local config = wezterm.config_builder()
config:set_strict_mode(true)

colors.apply(config)
ui.apply(config)
keys.apply(config)

-- ── Shell por defecto ───────────────────────────────────────────────────
-- PowerShell 7 sin banner de copyright: la terminal arranca limpia.
config.default_prog = { 'pwsh.exe', '-NoLogo' }
config.default_cwd = wezterm.home_dir

-- Menú del lanzador (CTRL+SHIFT+Espacio, luego `l`).
config.launch_menu = {
  { label = 'PowerShell 7', args = { 'pwsh.exe', '-NoLogo' } },
  { label = 'Windows PowerShell', args = { 'powershell.exe', '-NoLogo' } },
  { label = 'Command Prompt', args = { 'cmd.exe' } },
}

-- ── Enlaces detectados en la salida ─────────────────────────────────────
config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- "owner/repo" entrecomillado -> enlace a GitHub.
-- Nota: hace falta [==[ ]==] porque el patrón contiene ']]'.
table.insert(config.hyperlink_rules, {
  regex = [==[["']([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["']]==],
  format = 'https://www.github.com/$1/$3',
})

return config
