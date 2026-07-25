-- ui.lua — Tipografía, ventana, renderizado y barra de pestañas.
--
-- Criterio de diseño: que se vea bien y sea cómodo, sin sacrificar la
-- legibilidad de los TUIs (opencode, claude code, herdr, pi), que dependen
-- de que los 16 colores ANSI y el bold se rendericen con fuerza.

local wezterm = require('wezterm')
local colors = require('colors')

local M = {}

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │ AJUSTES RÁPIDOS                                                      │
-- └──────────────────────────────────────────────────────────────────────┘
M.font_size   = 11.5
M.font_weight = 'Regular'  -- 'Medium' si prefieres el texto con más cuerpo
M.blink       = true       -- cursor parpadeante

-- Opaco. Cualquier valor por debajo de 1.0 mezcla el escritorio con TODO lo
-- que pinta la terminal: el negro deja de ser negro y los colores de los
-- agentes dejan de ser los suyos. Súbelo/bájalo si quieres probar.
M.opacity = 1.0

-- Acrylic (Windows 11). Difumina bonito, pero es una capa de material por
-- encima del contenido: desatura los TUIs de forma muy visible.
M.blur = false

function M.apply(config)
  local p = colors.palette()

  -- ── Tipografía ────────────────────────────────────────────────────────
  config.font = wezterm.font_with_fallback({
    { family = 'JetBrainsMono Nerd Font', weight = M.font_weight },
    { family = 'Cascadia Mono' },
    -- WezTerm incluye Symbols Nerd Font Mono de serie: los iconos del prompt
    -- se ven aunque la fuente principal no esté parcheada.
    { family = 'Symbols Nerd Font Mono', scale = 0.9 },
    { family = 'Segoe UI Emoji' },
  })
  config.font_size = M.font_size

  -- Interlineado ligeramente abierto: el texto "respira" y cansa menos.
  config.line_height = 1.1
  config.cell_width = 1.0

  -- Antialiasing en escala de grises, con el hinting normal.
  -- 'Light' adelgazaba el trazo y 'HorizontalLcd' (subpíxel) produce franjas
  -- de color en cuanto la ventana tiene algo de transparencia.
  config.freetype_load_target = 'Normal'
  config.freetype_render_target = 'Normal'

  -- Los TUIs tipo agente usan bold sobre color como jerarquía visual.
  -- Con 'No' se aplanan y todo acaba pareciendo el mismo tono.
  config.bold_brightens_ansi_colors = 'BrightAndBold'

  config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }
  config.warn_about_missing_glyphs = false

  -- ── Ventana ───────────────────────────────────────────────────────────
  -- Sin barra de título del sistema: la de pestañas hace de título.
  config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
  config.integrated_title_button_style = 'Windows'
  config.integrated_title_button_alignment = 'Right'

  config.window_padding = { left = 18, right = 18, top = 12, bottom = 10 }
  config.initial_cols = 120
  config.initial_rows = 32
  config.window_close_confirmation = 'NeverPrompt'
  config.adjust_window_size_when_changing_font_size = false

  config.window_background_opacity = M.opacity
  if M.blur then
    config.win32_system_backdrop = 'Acrylic'
  end
  -- El fondo de cada celda sí es opaco: el texto de los TUIs se lee nítido
  -- aunque la ventana sea translúcida.
  config.text_background_opacity = 1.0

  -- ── Barra de pestañas ─────────────────────────────────────────────────
  config.use_fancy_tab_bar = true
  config.tab_bar_at_bottom = false
  config.hide_tab_bar_if_only_one_tab = false -- se necesita para los botones de ventana
  config.tab_max_width = 30
  config.show_new_tab_button_in_tab_bar = true
  config.show_tab_index_in_tab_bar = false
  config.switch_to_last_active_tab_when_closing_tab = true

  -- ── Paneles ───────────────────────────────────────────────────────────
  -- Atenuación suave del panel inactivo: marca el foco sin apagar la salida
  -- de un agente que siga trabajando al lado.
  config.inactive_pane_hsb = { saturation = 0.95, brightness = 0.85 }

  -- ── Cursor ────────────────────────────────────────────────────────────
  config.default_cursor_style = M.blink and 'BlinkingBlock' or 'SteadyBlock'
  config.cursor_blink_rate = M.blink and 600 or 0
  -- Parpadeo limpio, sin el fundido que deja el cursor a medio gas.
  config.cursor_blink_ease_in = 'Constant'
  config.cursor_blink_ease_out = 'Constant'
  config.cursor_thickness = 2
  config.force_reverse_video_cursor = false

  -- ── Comportamiento ────────────────────────────────────────────────────
  -- Scrollback generoso: una sesión larga de agente escupe mucha salida.
  config.scrollback_lines = 25000
  config.enable_scroll_bar = false
  config.audible_bell = 'Disabled' -- la campana la marca el visual_bell
  config.check_for_updates = false
  config.automatically_reload_config = true
  config.exit_behavior = 'Close'
  config.use_dead_keys = false
  config.send_composed_key_when_left_alt_is_pressed = false

  -- Protocolo de teclado de Kitty: permite a los TUIs distinguir
  -- Shift+Enter, Ctrl+Enter y demás combinaciones que un terminal clásico
  -- no sabe transmitir. Claude Code y opencode lo aprovechan.
  config.enable_kitty_keyboard = true
  config.enable_kitty_graphics = true

  -- ── Rendimiento ───────────────────────────────────────────────────────
  config.front_end = 'WebGpu'
  config.webgpu_power_preference = 'HighPerformance'
  config.max_fps = 120
  config.animation_fps = 60

  -- ── Selección con doble clic ──────────────────────────────────────────
  -- Rutas, flags y URLs se seleccionan enteras.
  config.selection_word_boundary = ' \t\n{}[]()"\'`,;:│'

  M.setup_events(p)
end

--- Eventos de UI: título de pestaña compacto y estado derecho discreto.
function M.setup_events(p)
  -- Título de pestaña: nombre del proceso o del directorio, sin ruido.
  wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
    local title = tab.tab_title
    if not title or #title == 0 then
      local pane = tab.active_pane
      title = pane.foreground_process_name or ''
      title = title:gsub('^.*[/\\]', ''):gsub('%.exe$', '')
      if title == '' or title == 'pwsh' or title == 'powershell' then
        -- Para el shell mostramos el directorio, que es lo que de verdad ubica.
        local cwd = pane.current_working_dir
        if cwd then
          local path = cwd.file_path or tostring(cwd)
          title = path:gsub('[/\\]+$', ''):gsub('^.*[/\\]', '')
        end
      end
    end
    if title == '' then title = 'shell' end

    local idx = tostring(tab.tab_index + 1)
    local label = ' ' .. idx .. '  ' .. wezterm.truncate_right(title, max_width - 6) .. ' '

    if tab.is_active then
      return {
        { Background = { Color = p.bg0 } },
        { Foreground = { Color = p.green } },
        { Attribute = { Intensity = 'Bold' } },
        { Text = label },
      }
    end

    return {
      { Background = { Color = p.bg0 } },
      { Foreground = { Color = hover and p.fg or p.grey0 } },
      { Text = label },
    }
  end)

  -- Estado derecho: sólo el workspace cuando no es el por defecto, y el
  -- indicador de LEADER. Todo lo demás ya lo muestra Starship.
  wezterm.on('update-right-status', function(window, _)
    local cells = {}

    if window:leader_is_active() then
      table.insert(cells, { Foreground = { Color = p.orange } })
      table.insert(cells, { Text = '󰘴 LEADER  ' })
    end

    local ws = window:active_workspace()
    if ws and ws ~= 'default' then
      table.insert(cells, { Foreground = { Color = p.grey1 } })
      table.insert(cells, { Text = ws .. '  ' })
    end

    window:set_right_status(wezterm.format(cells))
  end)
end

return M
