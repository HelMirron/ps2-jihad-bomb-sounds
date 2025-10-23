# Pointshop2 - Jihad Bomb Custom Sounds

Custom sound Pointshop2 Addon for TTT Jihad Bomb / Suicide Bomb weapons. Players can purchase and equip custom countdown sounds that play when activating the bomb.

## Features

- **Custom countdown sounds** (explosion remains original by default)
- **Configurable sound patterns** - adjust which sounds to override
- **Customizable shop icons** - change colors and animation
- **Sound preview** in admin panel
- **Workshop sound support**
- Works with TTT Weapon Collection (Workshop ID: 194965598)

## Screenshots

### Shop View
![Jihad Sound Shop](https://i.imgur.com/d2GRaX8.png)

### Sound Item Detail
![Sound Item Detail](https://i.imgur.com/ZQESplv.png)

### Sound Item creation
![Item Creation](https://i.imgur.com/1lYOuQk.png)


![Jihad Sound Interface](https://i.imgur.com/e8zEoGz.png)

## Installation

1. Place addon in `garrysmod/addons/ps2-jihad-bomb-sounds/`
2. Restart server
3. Sounds go in `garrysmod/sound/custom_jihad/`

## Configuration

Access settings via **Pointshop2 Management → Jihad Bomb Sounds** to override your Suicide Bomb Sound

### Sound Override Settings

| Setting | Default | Description |
|---------|---------|-------------|
| **Countdown Sound Pattern** | `siege/suicide` | Lua pattern to match countdown sound |
| **Override Explosion Sound** | `false` | Enable to also replace explosion |
| **Explosion Sound Pattern** | `siege/big_explosion` | Pattern for explosion (if enabled) |

**Examples:**
- TTT Weapon Collection: `siege/suicide`
- Original Jihad Bomb: `jihad` or `allah`
- Generic: `countdown`, `beep`, `arm`

### Icon Design Settings

| Setting | Default | Description |
|---------|---------|-------------|
| **Gradient Top Color** | `35,120,200` | RGB values for top of gradient |
| **Gradient Bottom Color** | `70,200,255` | RGB values for bottom of gradient |
| **Animation Speed** | `2.5` | Speed of pulsing animation |
| **Animation Intensity** | `0.25` | Intensity of pulse effect (0-1) |

**Color Examples:**
- Blue theme: `35,120,200` → `70,200,255` (default)
- Red theme: `180,30,30` → `255,70,70`
- Green theme: `30,180,60` → `70,255,120`
- Purple theme: `120,30,180` → `180,70,255`

## Creating Sound Items

1. Open Pointshop2 Management (`!ps2`)
2. Go to "Items" → "Create Item"
3. Select "Jihad Bomb Sound"
4. Enter name, description, price
5. Select sound file from dropdown
6. Save

## Sound Format

- **Supported formats**: `.wav`, `.mp3`, `.ogg`
- **Path format**: `custom_jihad/filename.wav` (without `sound/` prefix)
- **Max 2 seconds** recommended for countdown
- **Max file size**: 10MB
- **Sample rate**: 44100Hz recommended

## Database

Table: `ps2_soundpersistence`

```sql
CREATE TABLE IF NOT EXISTS `ps2_soundpersistence` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `itemPersistenceId` INT(11) NOT NULL,
  `soundPath` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`itemPersistenceId`) REFERENCES `ps2_itempersistence`(`id`) ON DELETE CASCADE
);
```

## Technical Details

- Uses `EntityEmitSound` hook to intercept and replace sounds
- Configurable sound patterns via Pointshop2 Settings
- Supports both client and server-side sound caching
- Only replaces matched patterns (default: countdown only)

## Troubleshooting

### Sounds not playing?
1. Check file exists in `sound/custom_jihad/`
2. Verify file format is `.wav`,`.mp3` or `.ogg`
3. Ensure sound path is correct (without `sound/` prefix)
4. Check Pointshop2 logs for errors

### Icons not showing?
1. Restart server to load updated code
2. Check Pointshop2 settings are accessible
3. Verify color format is correct (R,G,B)

### Custom sounds not overriding?
1. Open Settings → Sound Override
2. Verify "Countdown Sound Pattern" matches your bomb sound
3. Check server console for sound detection
4. Ensure item is equipped in Pointshop2 inventory slot

## Credits

- **Author**: HelMirron / Peter Helbing (https://github.com/HelMirron)
- **Pointshop2**: Kamshak/ValentinFunk (https://github.com/ValentinFunk)
- **TTT**: Bad King Urgrain


## License

This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.

**This means:**
- ✅ You can copy and redistribute the material
- ✅ You can remix, transform, and build upon the material
- ❌ You cannot use it for commercial purposes
- ⚠️ You must give appropriate credit to the creator
- ⚠️ You must distribute your contributions under the same license

Full license text: https://creativecommons.org/licenses/by-nc-sa/4.0/