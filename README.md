# The Guardian of the Fields
**Project Status:** Implementation Phase (v2.0) - Final Sprint
**Engine:** Godot 4.2.x (GDScript)

## 1. Project Overview
"The Guardian of the Fields" is an Ethiopian pixel-art action game. Players defend the nation's agricultural and livestock wealth across three distinct regions: The Highland Origins, the Southern Savannah, and the Searing Salt Plains.

## 2. System Requirements
- **Engine:** Godot 4.x (Standard Edition)
- **Version Control:** Git
- **Art Standards:** 64x64px base grid, 4-color shading, .png format.

## 3. Repository Structure
- `/Assets` - All sprites, animations, and audio (res://Assets/)
- `/Scenes` - All .tscn scene files and templates (res://Scenes/)
- `/Scripts` - All .gd logic and character scripts (res://Scripts/)
- `/UI` - Menu systems, HUD, and transitions (res://UI/)
- `/tasks` - Production briefs and task tracking logs.

## 4. Setup & Installation
1. Clone this repository: `git clone https://github.com/Yosseph-Getnet/The_Guardian_of_the_Fields.git`
2. Open Godot 4.x and "Import" the project using the `project.godot` file in the root directory.
3. The main entry point is `res://Scenes/Levels/L1_Main.tscn`.

## 5. Development Progress
- **Level 1 (Highlands):** Wenchif (Sling) mechanics and Baboon AI implemented.
- **Level 2 (Savannah):** Zebu Herd movement and Bow/Arrow logic implemented.
- **Level 3 (Salt Plains):** Thirst system and Camel Caravan escort in progress.

## 6. Known Issues
- UI transparency adjustments needed for Level 2 hazards.
- Global variable sync for Level 3 Thirst meter pending.
