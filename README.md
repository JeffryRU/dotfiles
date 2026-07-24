# dotfiles

Configuración de terminal para Windows, gestionada con [chezmoi](https://chezmoi.io).

**WezTerm** + **PowerShell 7** + **Starship**, con paleta **Everforest** (medium).
Diseño minimalista y de bajo contraste, pensado para sesiones largas sin cansar la vista.

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
M.flavor = 'everforest'   -- 'rose-pine' | 'gruvbox-material' | 'catppuccin'
```

y aplica: `chezmoi apply -v`. WezTerm recarga solo.

Por defecto sigue la apariencia del sistema (claro de día, oscuro de noche).
Para forzar una: `M.appearance = 'dark'` o `'light'`.

Si cambias de tema, actualiza también la paleta de `dot_config/starship.toml`
(bloque `[palettes.everforest]`) y el hashtable `$Everforest` del perfil de
PowerShell, para que las tres piezas sigan casando.

---

## Decisiones de diseño

Todo lo que sigue está elegido para reducir fatiga visual, no por estética:

- **Everforest medium** — contraste fg/bg ≈ 8.5:1. Suficiente para leer, lejos del
  blanco puro sobre negro puro que deslumbra.
- **Sin transparencia** (`window_background_opacity = 1.0`) — el fondo translúcido
  baja el contraste efectivo y obliga al ojo a trabajar más.
- **Cursor fijo, sin parpadeo** (`SteadyBar`, `cursor_blink_rate = 0`) — el parpadeo
  es un estímulo de movimiento constante en el punto donde más miras.
- **`bold_brightens_ansi_colors = 'No'`** — la negrita no salta a los colores
  brillantes; la paleta se mantiene apagada.
- **`line_height = 1.15`** y padding de 18px — el texto respira.
- **`animation_fps = 1`** — animaciones al mínimo.
- **Sin campana** (`audible_bell = 'Disabled'`, `BellStyle None` en PSReadLine).
- **Prompt de dos líneas** — el comando siempre empieza en la misma columna,
  independientemente de lo larga que sea la ruta.

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
