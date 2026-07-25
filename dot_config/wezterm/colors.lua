-- colors.lua — Paleta Everforest (medium) + variante clara automática.
--
-- Para cambiar de tema: edita `M.flavor` más abajo, o añade tu propia paleta
-- a la tabla `M.palettes` respetando las mismas claves.

local wezterm = require('wezterm')

local M = {}

-- ┌──────────────────────────────────────────────────────────────────────┐
-- │ CAMBIA EL TEMA AQUÍ                                                  │
-- │   'onedark' | 'everforest' | 'rose-pine' | 'gruvbox-material'        │
-- │   'catppuccin'                                                       │
-- └──────────────────────────────────────────────────────────────────────┘
M.flavor = 'onedark'

-- Sigue la apariencia del sistema (claro/oscuro). Ponlo en 'dark' o 'light'
-- para forzar una variante concreta.
M.appearance = 'auto'

-- Cada paleta define los colores de UI (bg*, fg, grey*, rojo/verde/…) y,
-- opcionalmente, `ansi` y `brights` explícitos. Merece la pena definirlos:
-- los TUIs (opencode, claude code, herdr, pi) construyen su jerarquía visual
-- con los 16 colores ANSI, así que conviene que sean los "de verdad" del tema
-- y no una derivación de los colores de UI.
M.palettes = {
  ['onedark'] = {
    dark = { -- One Dark Pro
      bg0 = '#282c34', bg1 = '#21252b', bg2 = '#2c313c', bg3 = '#3e4451',
      bg4 = '#4b5263', bg_visual = '#3e4451', bg_dim = '#1b1f27',
      fg = '#abb2bf', grey0 = '#5c6370', grey1 = '#828997', grey2 = '#9da5b4',
      red = '#e06c75', orange = '#d19a66', yellow = '#e5c07b',
      green = '#98c379', aqua = '#56b6c2', blue = '#61afef', purple = '#c678dd',
      -- Los 16 ANSI tal cual los define el tema de VS Code.
      ansi = {
        '#3f4451', '#e05561', '#8cc265', '#d18f52',
        '#4aa5f0', '#c162de', '#42b3c2', '#d7dae0',
      },
      brights = {
        '#4f5666', '#ff616e', '#a5e075', '#f0a45d',
        '#4dc4ff', '#de73ff', '#4cd1e0', '#e6e6e6',
      },
    },
    light = { -- One Light
      bg0 = '#fafafa', bg1 = '#f0f0f1', bg2 = '#eaeaeb', bg3 = '#dbdbdc',
      bg4 = '#c9c9ca', bg_visual = '#e5e5e6', bg_dim = '#eaeaeb',
      fg = '#383a42', grey0 = '#a0a1a7', grey1 = '#8b8c92', grey2 = '#696c77',
      red = '#e45649', orange = '#c18401', yellow = '#986801',
      green = '#50a14f', aqua = '#0184bc', blue = '#4078f2', purple = '#a626a4',
    },
  },

  ['everforest'] = {
    dark = {
      bg0 = '#2d353b', bg1 = '#343f44', bg2 = '#3d484d', bg3 = '#475258',
      bg4 = '#4f585e', bg_visual = '#4c3743', bg_dim = '#232a2e',
      fg = '#d3c6aa', grey0 = '#7a8478', grey1 = '#859289', grey2 = '#9da9a0',
      red = '#e67e80', orange = '#e69875', yellow = '#dbbc7f',
      green = '#a7c080', aqua = '#83c092', blue = '#7fbbb3', purple = '#d699b6',
    },
    light = {
      bg0 = '#fdf6e3', bg1 = '#f4f0d9', bg2 = '#efebd4', bg3 = '#e6e2cc',
      bg4 = '#e0dcc7', bg_visual = '#f0f2d4', bg_dim = '#f2efdf',
      fg = '#5c6a72', grey0 = '#a6b0a0', grey1 = '#939f91', grey2 = '#829181',
      red = '#f85552', orange = '#f57d26', yellow = '#dfa000',
      green = '#8da101', aqua = '#35a77c', blue = '#3a94c5', purple = '#df69ba',
    },
  },

  ['rose-pine'] = {
    dark = {
      bg0 = '#232136', bg1 = '#2a273f', bg2 = '#393552', bg3 = '#44415a',
      bg4 = '#56526e', bg_visual = '#44415a', bg_dim = '#1f1d2e',
      fg = '#e0def4', grey0 = '#6e6a86', grey1 = '#908caa', grey2 = '#b5b0d0',
      red = '#eb6f92', orange = '#ea9a97', yellow = '#f6c177',
      green = '#3e8fb0', aqua = '#9ccfd8', blue = '#9ccfd8', purple = '#c4a7e7',
    },
    light = {
      bg0 = '#faf4ed', bg1 = '#fffaf3', bg2 = '#f2e9e1', bg3 = '#dfdad9',
      bg4 = '#cecacd', bg_visual = '#dfdad9', bg_dim = '#f4ede8',
      fg = '#575279', grey0 = '#9893a5', grey1 = '#797593', grey2 = '#6e6a86',
      red = '#b4637a', orange = '#d7827e', yellow = '#ea9d34',
      green = '#286983', aqua = '#56949f', blue = '#56949f', purple = '#907aa9',
    },
  },

  ['gruvbox-material'] = {
    dark = {
      bg0 = '#282828', bg1 = '#32302f', bg2 = '#3c3836', bg3 = '#45403d',
      bg4 = '#504945', bg_visual = '#4c3432', bg_dim = '#1d2021',
      fg = '#d4be98', grey0 = '#7c6f64', grey1 = '#928374', grey2 = '#a89984',
      red = '#ea6962', orange = '#e78a4e', yellow = '#d8a657',
      green = '#a9b665', aqua = '#89b482', blue = '#7daea3', purple = '#d3869b',
    },
    light = {
      bg0 = '#fbf1c7', bg1 = '#f4e8be', bg2 = '#eee0b7', bg3 = '#ddccab',
      bg4 = '#d5c4a1', bg_visual = '#f1dbb1', bg_dim = '#f9f5d7',
      fg = '#654735', grey0 = '#a89984', grey1 = '#928374', grey2 = '#7c6f64',
      red = '#c14a4a', orange = '#c35e0a', yellow = '#b47109',
      green = '#6c782e', aqua = '#4c7a5d', blue = '#45707a', purple = '#945e80',
    },
  },

  ['catppuccin'] = {
    dark = { -- Macchiato
      bg0 = '#24273a', bg1 = '#1e2030', bg2 = '#363a4f', bg3 = '#494d64',
      bg4 = '#5b6078', bg_visual = '#494d64', bg_dim = '#181926',
      fg = '#cad3f5', grey0 = '#6e738d', grey1 = '#8087a2', grey2 = '#939ab7',
      red = '#ed8796', orange = '#f5a97f', yellow = '#eed49f',
      green = '#a6da95', aqua = '#8bd5ca', blue = '#8aadf4', purple = '#f5bde6',
    },
    light = { -- Latte
      bg0 = '#eff1f5', bg1 = '#e6e9ef', bg2 = '#ccd0da', bg3 = '#bcc0cc',
      bg4 = '#acb0be', bg_visual = '#ccd0da', bg_dim = '#dce0e8',
      fg = '#4c4f69', grey0 = '#9ca0b0', grey1 = '#8c8fa1', grey2 = '#7c7f93',
      red = '#d20f39', orange = '#fe640b', yellow = '#df8e1d',
      green = '#40a02b', aqua = '#179299', blue = '#1e66f5', purple = '#ea76cb',
    },
  },
}

--- Devuelve la paleta activa según `M.flavor` y la apariencia del sistema.
function M.palette()
  local set = M.palettes[M.flavor] or M.palettes['everforest']

  local variant = M.appearance
  if variant == 'auto' then
    -- wezterm.gui no existe en el proceso mux; por eso el pcall.
    local ok, appearance = pcall(function() return wezterm.gui.get_appearance() end)
    variant = (ok and appearance and appearance:find('Light')) and 'light' or 'dark'
  end

  return set[variant] or set.dark, variant
end

--- Aplica los colores a la config de WezTerm.
function M.apply(config)
  local p, variant = M.palette()

  config.colors = {
    foreground = p.fg,
    background = p.bg0,

    cursor_bg = p.fg,
    cursor_fg = p.bg0,
    cursor_border = p.fg,

    selection_fg = p.fg,
    selection_bg = p.bg4,

    scrollbar_thumb = p.bg3,
    split = p.bg3,

    -- Si la paleta trae sus 16 ANSI propios se usan tal cual; si no, se
    -- derivan de los colores de UI.
    ansi = p.ansi or {
      p.bg2, p.red, p.green, p.yellow, p.blue, p.purple, p.aqua, p.fg,
    },
    brights = p.brights or {
      p.grey0, p.red, p.green, p.yellow, p.blue, p.purple, p.aqua, p.grey2,
    },

    compose_cursor = p.orange,
    copy_mode_active_highlight_bg = { Color = p.bg4 },
    copy_mode_active_highlight_fg = { Color = p.fg },
    copy_mode_inactive_highlight_bg = { Color = p.bg2 },
    copy_mode_inactive_highlight_fg = { Color = p.grey1 },
    quick_select_label_bg = { Color = p.orange },
    quick_select_label_fg = { Color = p.bg0 },
    quick_select_match_bg = { Color = p.bg3 },
    quick_select_match_fg = { Color = p.fg },

    -- La barra de pestañas se funde con el fondo: parece parte de la ventana.
    tab_bar = {
      background = p.bg0,
      active_tab = {
        bg_color = p.bg0,
        fg_color = p.green,
        intensity = 'Bold',
      },
      inactive_tab = {
        bg_color = p.bg0,
        fg_color = p.grey0,
      },
      inactive_tab_hover = {
        bg_color = p.bg1,
        fg_color = p.fg,
        italic = false,
      },
      new_tab = {
        bg_color = p.bg0,
        fg_color = p.grey0,
      },
      new_tab_hover = {
        bg_color = p.bg1,
        fg_color = p.fg,
      },
    },
  }

  -- La barra de pestañas no debe heredar la transparencia de la ventana:
  -- con fondo propio se lee bien encima de cualquier cosa.
  config.window_frame = {
    font = wezterm.font({ family = 'JetBrainsMono Nerd Font', weight = 'Medium' }),
    font_size = 10.0,
    active_titlebar_bg = p.bg0,
    inactive_titlebar_bg = p.bg0,
    active_titlebar_fg = p.fg,
    inactive_titlebar_fg = p.grey0,
    button_fg = p.grey1,
    button_bg = p.bg0,
    button_hover_fg = p.fg,
    button_hover_bg = p.bg2,
  }

  -- Un pelín de padding visual en el borde de la ventana.
  config.visual_bell = {
    fade_in_duration_ms = 60,
    fade_out_duration_ms = 60,
    target = 'CursorColor',
  }

  M.active = p
  M.variant = variant
end

return M
