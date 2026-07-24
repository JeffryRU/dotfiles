-- ui.lua — Tipografía, ventana, renderizado y barra de pestañas.
--
-- Criterio de diseño: todo lo que reduzca fatiga visual gana a lo que "se ve
-- llamativo". Sin transparencias, sin cursor parpadeante, sin blancos puros,
-- interlineado generoso y padding amplio.

local wezterm = require('wezterm')
local colors = require('colors')

local M = {}

function M.apply(config)
  local p = colors.palette()

  -- ── Tipografía ────────────────────────────────────────────────────────
  config.font = wezterm.font_with_fallback({
    { family = 'JetBrainsMono Nerd Font', weight = 'Regular' },
    { family = 'Cascadia Mono' },
    -- WezTerm incluye Symbols Nerd Font Mono de serie: los iconos del prompt
    -- se ven aunque la fuente principal no esté parcheada.
    { family = 'Symbols Nerd Font Mono', scale = 0.9 },
    { family = 'Segoe UI Emoji' },
  })
  config.font_size = 11.5

  -- Interlineado ligeramente abierto: el texto "respira" y cansa menos.
  config.line_height = 1.15
  config.cell_width = 1.0

  -- Renderizado más suave y menos "grueso" en pantallas Windows.
  config.freetype_load_target = 'Light'
  config.freetype_render_target = 'HorizontalLcd'

  -- Que la negrita no dispare los colores brillantes: mantiene la paleta apagada.
  config.bold_brightens_ansi_colors = 'No'

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
  config.window_background_opacity = 1.0 -- opaco: la transparencia baja el contraste

  -- ── Barra de pestañas ─────────────────────────────────────────────────
  config.use_fancy_tab_bar = true
  config.tab_bar_at_bottom = false
  config.hide_tab_bar_if_only_one_tab = false -- se necesita para los botones de ventana
  config.tab_max_width = 30
  config.show_new_tab_button_in_tab_bar = true
  config.show_tab_index_in_tab_bar = false
  config.switch_to_last_active_tab_when_closing_tab = true

  -- ── Paneles ───────────────────────────────────────────────────────────
  -- El panel inactivo se atenúa: la vista sabe siempre dónde está el foco.
  config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.65 }

  -- ── Cursor ────────────────────────────────────────────────────────────
  -- Barra fija, sin parpadeo: el parpadeo es una fuente constante de fatiga.
  config.default_cursor_style = 'SteadyBar'
  config.cursor_blink_rate = 0
  config.cursor_thickness = 2
  config.force_reverse_video_cursor = false

  -- ── Comportamiento ────────────────────────────────────────────────────
  config.scrollback_lines = 10000
  config.enable_scroll_bar = false
  config.audible_bell = 'Disabled'
  config.check_for_updates = false
  config.automatically_reload_config = true
  config.exit_behavior = 'Close'
  config.use_dead_keys = false
  config.send_composed_key_when_left_alt_is_pressed = false

  -- ── Rendimiento ───────────────────────────────────────────────────────
  config.front_end = 'WebGpu'
  config.webgpu_power_preference = 'HighPerformance'
  config.max_fps = 120
  config.animation_fps = 1 -- animaciones al mínimo: menos movimiento en pantalla

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
