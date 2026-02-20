# Rocker (Agat-7 Boulder Dash Clone)

**Rocker** is a free implementation of the game for the **Agat-7** computer, following the style of the classic **Boulder Dash**. This project is written in **Ada 2022** using the **ncurses** library.

## Features
- **Classic Mechanics**: Collect diamonds, dig through dirt, and avoid falling boulders.
- **Agat-7 Physics**: Implemented falling delays and escape windows, allowing the player to outrun landslides just like in the original game.
- **Random Generation**: Every run creates a new level configuration.

## Controls
- **Arrow Keys**: Movement.
- **Q**: Quit.

## Symbols Legend
- `P` — Player
- `O` — Boulder (Rounded)
- `*` — Diamond (Rounded)
- `+` — Dirt
- `#` — Wall
- `E` — Exit (Appears when enough diamonds are collected)

## Requirements
- GNAT Compiler (Ada 2022 standard).
- GPRbuild.
- `ncursesada` library.
  - On Debian/Ubuntu: `sudo apt-get install libncursesada-dev`

## Build and Run
To build the project:
```bash
gprbuild -P rocker.gpr
```
The executable will be placed in the `dest` directory. Run it:
```bash
./dest/main
```

## Project Structure
- `src/main.adb` — Entry point and game loop.
- `src/engine.ads/adb` — Physics logic, movement, and game state.
- `src/renderer.ads/adb` — Ncurses-based UI and map rendering.
- `src/levels.ads/adb` — Level generation and setup.
- `rocker.gpr` — GPRbuild project file.

---

This project was developed with Gemini 3 as a demonstration of using Ada for terminal-based game development.
