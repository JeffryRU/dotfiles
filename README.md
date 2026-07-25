# dotfiles

Configuración de terminal para Windows, gestionada con [chezmoi](https://chezmoi.io).

**WezTerm** + **PowerShell 7** + **Starship**, con paleta **One Dark Pro**.
Diseño minimalista pero no monacal: transparencia con blur, cursor parpadeante y
los 16 colores ANSI del tema intactos, para que los TUIs de agentes
(opencode, claude code, herdr, pi) se vean como deben.

```
 ~/GitHub/dotfiles  main !2 ?1                             3s  14:32
❯
```

---

## Qué hay dentro

| Ruta en el repo | Destino en `$HOME` | Qué es |
| --- | --- | --- |
| `dot_config/wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` | Punto de entrada de WezTerm |
| `dot_config/wezterm/colors.lua` | `~/.config/wezterm/colors.lua` | Paletas (4 temas) y selección claro/oscuro |
| `dot_config/wezterm/ui.lua` | `~/.config/wezterm/ui.lua` | Tipografía, ventana, pestañas, rendimiento |
| `dot_config/wezterm/keys.lua` | `~/.config/wezterm/keys.lua` | Atajos de teclado y ratón |
| `dot_config/starship.toml` | `~/.config/starship.toml` | Prompt |
| `Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | `$PROFILE` | Perfil de PowerShell 7 |
| `.chezmoi.toml.tmpl` | `~/.config/chezmoi/chezmoi.toml` | Config de chezmoi |
| `.chezmoiscripts/…install-packages.ps1.tmpl` | — | Instala las herramientas en una máquina nueva |

---

## Máquina nueva

Con [winget](https://learn.microsoft.com/windows/package-manager/) disponible:

```powershell
winget install --id twpayne.chezmoi --source winget
chezmoi init --apply --source="$HOME\Documents\GitHub\dotfiles" https://github.com/<usuario>/dotfiles.git
```

Eso clona el repo, escribe la config de chezmoi, instala el resto de herramientas
(git, starship, JetBrainsMono Nerd Font, WezTerm) y deja los ficheros en su sitio.

Falta un paso manual: en **WezTerm → Configuration**, o directamente, seleccionar
`JetBrainsMono Nerd Font` si no se detecta. Con la config de este repo ya viene fijada.

---

## Uso diario

```powershell
czd      # chezmoi diff    -> qué cambiaría en ~
cza      # chezmoi apply   -> repo  ->  ~
czu      # chezmoi update  -> git pull + apply
czs      # chezmoi status
dotfiles # cd al repo
```

El ciclo normal para tocar algo:

```powershell
chezmoi edit ~/.config/starship.toml   # abre el fichero DEL REPO en VS Code
chezmoi apply -v                       # lo lleva a ~
dotfiles; git add -A; git commit -m "…"; git push
```

> **Importante:** no edites los ficheros de `~` a mano. La fuente de la verdad es
> el repo; `chezmoi apply` sobrescribe el destino.
> Si ya los tocaste, recupéralos con `chezmoi add ~/.config/starship.toml`.

---

## Cambiar el tema

Los cuatro temas vienen precargados. Edita una línea en
`dot_config/wezterm/colors.lua`:

```lua
M.flavor = 'onedark'   -- 'everforest' | 'rose-pine' | 'gruvbox-material' | 'catppuccin'
```

y aplica: `chezmoi apply -v`. WezTerm recarga solo.

Por defecto sigue la apariencia del sistema (claro de día, oscuro de noche).
Para forzar una: `M.appearance = 'dark'` o `'light'`.

Si cambias de tema, actualiza también la paleta de `dot_config/starship.toml`
(bloque `[palettes.onedark]`) y el hashtable `$Palette` del perfil de
PowerShell, para que las tres piezas sigan casando.

---

## Ajustes rápidos

En la cabecera de `dot_config/wezterm/ui.lua`:

```lua
M.font_size   = 11.5
M.font_weight = 'Regular'  -- 'Medium' para texto con más cuerpo
M.blink       = true       -- cursor parpadeante
M.opacity     = 0.97       -- 1.0 = opaco
M.blur        = false      -- Acrylic de Windows 11
```

Sobre la transparencia: cada punto que bajas `M.opacity` mezcla el escritorio con
**todo** lo que pinta la terminal, así que los colores que eligen los agentes
dejan de ser los suyos. `0.97` se nota sin desteñir nada. El Acrylic difumina el
fondo, pero desatura el contenido de forma muy visible en TUIs: por eso está
apagado por defecto.

---

## Decisiones de diseño

- **One Dark Pro** — la misma paleta que uso en VS Code, así el editor y la
  terminal no se pelean.
- **Los 16 ANSI son los del tema**, no una derivación de los colores de UI.
  Los TUIs de agentes construyen su jerarquía visual con esos 16 colores.
- **`bold_brightens_ansi_colors = 'BrightAndBold'`** — sin esto, un TUI que use
  bold sobre color se aplana y todo acaba pareciendo el mismo tono.
- **`enable_kitty_keyboard`** — deja que los TUIs distingan `Shift+Enter` y
  `Ctrl+Enter`, que un terminal clásico no sabe transmitir.
- **Transparencia con blur** (`opacity 0.92` + Acrylic) — el Acrylic difumina lo
  que hay detrás en vez de dejarlo pasar limpio, así que se lee bien.
  `text_background_opacity = 1.0` mantiene opaco el fondo de cada celda.
- **Scrollback de 25 000 líneas** — una sesión larga de agente escupe mucha salida.
- **Atenuación suave del panel inactivo** (`brightness 0.85`) — marca el foco sin
  apagar la salida de un agente que siga trabajando al lado.
- **Prompt de dos líneas** — el comando siempre empieza en la misma columna,
  independientemente de lo larga que sea la ruta.
- **Sin campana audible** — el aviso es el `visual_bell`, que hace un destello
  breve en el cursor.

---

## Atajos de WezTerm

`ALT` gestiona la terminal, de modo que `CTRL` queda libre para PSReadLine.

| Atajo | Acción |
| --- | --- |
| `ALT` + `\` / `-` | Dividir panel vertical / horizontal |
| `ALT` + `h j k l` | Moverse entre paneles |
| `ALT+SHIFT` + `h j k l` | Redimensionar panel |
| `ALT` + `z` / `w` | Zoom / cerrar panel |
| `ALT` + `t` / `q` | Nueva / cerrar pestaña |
| `ALT` + `1…9` | Ir a pestaña N |
| `ALT` + `Enter` | Pantalla completa |
| `CTRL` + `=` `-` `0` | Tamaño de fuente (útil cuando cansa la vista) |
| `CTRL+SHIFT` + `f` / `x` | Buscar / modo copia |
| `CTRL+SHIFT` + `p` | Paleta de comandos |
| `CTRL+ALT` + `Espacio` | Selección rápida de rutas y URLs |
| `CTRL+SHIFT` + `Espacio` | LEADER (`r` recargar, `n` renombrar pestaña, `l` lanzador) |

## Atajos de PowerShell

| Atajo | Acción |
| --- | --- |
| `Tab` | Menú de completado |
| `↑` / `↓` | Historial filtrado por lo ya escrito |
| `→` | Aceptar la sugerencia en gris |
| `CTRL` + `w` | Borrar palabra anterior |
| `CTRL` + `←` `→` | Saltar palabra |
