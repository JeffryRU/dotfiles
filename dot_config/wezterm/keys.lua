-- keys.lua — Atajos de teclado.
--
-- Filosofía: ALT para todo lo que gestiona la terminal (paneles, pestañas),
-- de modo que CTRL queda íntegro para PSReadLine y para las apps de consola.
-- Hay además un LEADER (CTRL+SHIFT+Espacio) para las acciones menos frecuentes.

local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

function M.apply(config)
  config.leader = { key = 'Space', mods = 'CTRL|SHIFT', timeout_milliseconds = 1500 }

  config.keys = {
    -- ── Paneles ─────────────────────────────────────────────────────────
    { key = '\\', mods = 'ALT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = '-',  mods = 'ALT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    { key = 'w',  mods = 'ALT', action = act.CloseCurrentPane({ confirm = false }) },
    { key = 'z',  mods = 'ALT', action = act.TogglePaneZoomState },

    -- Navegación entre paneles (hjkl y flechas)
    { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection('Left') },
    { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection('Down') },
    { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection('Up') },
    { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection('Right') },
    { key = 'LeftArrow',  mods = 'ALT', action = act.ActivatePaneDirection('Left') },
    { key = 'DownArrow',  mods = 'ALT', action = act.ActivatePaneDirection('Down') },
    { key = 'UpArrow',    mods = 'ALT', action = act.ActivatePaneDirection('Up') },
    { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection('Right') },

    -- Redimensionar
    { key = 'H', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Left', 3 }) },
    { key = 'J', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Down', 3 }) },
    { key = 'K', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Up', 3 }) },
    { key = 'L', mods = 'ALT|SHIFT', action = act.AdjustPaneSize({ 'Right', 3 }) },

    -- ── Pestañas ────────────────────────────────────────────────────────
    { key = 't', mods = 'ALT', action = act.SpawnTab('CurrentPaneDomain') },
    { key = 'q', mods = 'ALT', action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'Tab',   mods = 'CTRL',       action = act.ActivateTabRelative(1) },
    { key = 'Tab',   mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = 'PageUp',   mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
    { key = 'PageDown', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },

    -- ── Tamaño de fuente ────────────────────────────────────────────────
    -- Útil cuando la vista se cansa: sube un par de puntos y sigue.
    { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL', action = act.ResetFontSize },

    -- ── Ventana ─────────────────────────────────────────────────────────
    { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },

    -- ── Búsqueda, copiado y paleta ──────────────────────────────────────
    { key = 'f', mods = 'CTRL|SHIFT', action = act.Search({ CaseInSensitiveString = '' }) },
    { key = 'x', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },
    { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
    -- Selección rápida de rutas/hashes/URLs sin tocar el ratón.
    { key = ' ', mods = 'CTRL|ALT', action = act.QuickSelect },
    { key = 'u', mods = 'CTRL|SHIFT', action = act.CharSelect({ copy_on_select = true }) },

    -- ── Scroll ──────────────────────────────────────────────────────────
    { key = 'PageUp',   mods = 'SHIFT', action = act.ScrollByPage(-1) },
    { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(1) },
    { key = 'k', mods = 'CTRL|SHIFT', action = act.ClearScrollback('ScrollbackAndViewport') },

    -- ── LEADER (CTRL+SHIFT+Espacio) ─────────────────────────────────────
    { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
    { key = 'n', mods = 'LEADER', action = act.PromptInputLine({
        description = 'Nombre de la pestaña:',
        action = wezterm.action_callback(function(window, _, line)
          if line and #line > 0 then window:active_tab():set_title(line) end
        end),
      }),
    },
    { key = 'd', mods = 'LEADER', action = act.ShowDebugOverlay },
    { key = 'l', mods = 'LEADER', action = act.ShowLauncher },
  }

  -- ALT+1..9 salta directo a la pestaña N.
  for i = 1, 9 do
    table.insert(config.keys, {
      key = tostring(i),
      mods = 'ALT',
      action = act.ActivateTab(i - 1),
    })
  end

  -- ── Ratón ─────────────────────────────────────────────────────────────
  config.mouse_bindings = {
    -- CTRL+clic abre enlaces.
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
    },
    -- Clic derecho pega (costumbre de Windows Terminal).
    {
      event = { Down = { streak = 1, button = 'Right' } },
      mods = 'NONE',
      action = act.PasteFrom('Clipboard'),
    },
  }
end

return M
