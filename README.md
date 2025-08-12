# XSAN Fish It Pro - Enhanced Version

🎣 **Advanced fishing automation script with modern responsive UI**

## 🚀 Quick Start (Loadstring)

### Main Script (Recommended)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/part2/main/main.lua"))()
```

### Standalone Version
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/donitono/part2/main/skriplain.lua"))()
```

## ✨ Features

### 🎮 Main Script (main.lua)
- ✅ **Modern Rayfield UI** with responsive design
- ✅ **7-tier device detection** (SmallMobile to Desktop)
- ✅ **Dynamic text scaling** and responsive layouts
- ✅ **Walkspeed control** with compact sliders (16-60)
- ✅ **Hotkey F7** for walkspeed toggle
- ✅ **Auto fishing** with multiple modes
- ✅ **Safe Mode**: 50-85% power
- ✅ **Hybrid Mode**: 60-80% power

### 🔧 Standalone Script (skriplain.lua)
- ✅ **All-in-one solution** (no dependencies)
- ✅ **Built-in walkspeed** (1-100 range)
- ✅ **Complete fishing automation**
- ✅ **Traditional UI** with full functionality

## 🛠️ Development Scripts

### Quick Update
```bash
./quick-update.sh "Your commit message"
```

### Sync with Testing
```bash
./sync-test.sh "Optional commit message"
```

### Auto Push Only
```bash
./auto-push.sh
```

## 📱 Responsive Design

The UI automatically adapts to different screen sizes:
- **SmallMobile**: 320x568 (iPhone SE)
- **Mobile**: 375x667 (Standard phones)
- **LargeMobile**: 414x896 (iPhone Pro Max)
- **SmallTablet**: 768x1024 (iPad Mini)
- **Tablet**: 834x1194 (iPad Air)
- **LargeTablet**: 1024x1366 (iPad Pro)
- **Desktop**: 1200x800+ (PC/Laptop)

## 🎯 Usage Instructions

1. **Copy the loadstring** from above
2. **Paste in Roblox executor**
3. **Execute the script**
4. **Configure settings** in the UI
5. **Use F7 hotkey** for quick walkspeed toggle

## 🔄 Auto-Update Workflow

When you make changes in this workspace:
1. Test with `./sync-test.sh`
2. Commit with `./quick-update.sh "message"`
3. URLs automatically update on GitHub
4. Users get latest version via loadstring

## 📋 File Structure

```
├── main.lua          # Main script with modern UI
├── ui.lua            # Enhanced Rayfield framework
├── skriplain.lua     # Standalone all-in-one script
├── quick-update.sh   # Quick commit and push
├── sync-test.sh      # Test syntax then sync
└── auto-push.sh      # Simple auto-push
```

## 🐛 Troubleshooting

- **Syntax errors**: Run `luac -p filename.lua`
- **Git issues**: Check with `git status`
- **URL not updating**: Wait 1-2 minutes for GitHub CDN

---

**Latest Update**: Enhanced responsive system with comprehensive device support and optimized slider controls.