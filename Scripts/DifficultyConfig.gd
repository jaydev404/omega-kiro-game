## DifficultyConfig — Resource centralizado para configurar la curva de dificultad.
## Todos los valores de dificultad se modifican aquí.
## Asignar al campo difficulty_config del DroneSpawner en el inspector.
class_name DifficultyConfig
extends Resource

## ================================================================
## CONFIGURACIÓN DE FASES POR TIEMPO
## Cada fase define los parámetros activos desde su segundo de inicio.
## El timer corre hacia abajo desde 1500s (25 min).
## Ejemplo: start_at=1200 significa "cuando queden 1200s" = minuto 5.
## ================================================================

## --- Fase 0: Inicio (0:00 - 2:00) ---
@export_group("Fase 0 — Inicio (0:00 - 2:00)")
@export var phase0_start_at: float          = 1500.0
@export var phase0_spawn_interval: float    = 5.0    ## segundos entre spawns
@export var phase0_max_drones: int          = 3      ## drones simultáneos
@export var phase0_drone_speed: float       = 120.0  ## velocidad base del dron
@export var phase0_bomb_chance: float       = 0.05   ## 5% probabilidad de bomba
@export var phase0_chase_chance: float      = 0.01   ## 1% prob. de persecución

## --- Fase 1: Normal (2:00 - 5:00) ---
@export_group("Fase 1 — Normal (2:00 - 5:00)")
@export var phase1_start_at: float          = 1380.0
@export var phase1_spawn_interval: float    = 4.0
@export var phase1_max_drones: int          = 4
@export var phase1_drone_speed: float       = 150.0
@export var phase1_bomb_chance: float       = 0.10
@export var phase1_chase_chance: float      = 0.05

## --- Fase 2: Presión (5:00 - 10:00) ---
@export_group("Fase 2 — Presión (5:00 - 10:00)")
@export var phase2_start_at: float          = 1200.0
@export var phase2_spawn_interval: float    = 3.0
@export var phase2_max_drones: int          = 5
@export var phase2_drone_speed: float       = 180.0
@export var phase2_bomb_chance: float       = 0.18
@export var phase2_chase_chance: float      = 0.10

## --- Fase 3: Caos (10:00 - 18:00) ---
@export_group("Fase 3 — Caos (10:00 - 18:00)")
@export var phase3_start_at: float          = 900.0
@export var phase3_spawn_interval: float    = 2.0
@export var phase3_max_drones: int          = 7
@export var phase3_drone_speed: float       = 220.0
@export var phase3_bomb_chance: float       = 0.28
@export var phase3_chase_chance: float      = 0.18

## --- Fase 4: Supervivencia (18:00 - 25:00) ---
@export_group("Fase 4 — Supervivencia (18:00 - 25:00)")
@export var phase4_start_at: float          = 420.0
@export var phase4_spawn_interval: float    = 1.2
@export var phase4_max_drones: int          = 10
@export var phase4_drone_speed: float       = 260.0
@export var phase4_bomb_chance: float       = 0.38
@export var phase4_chase_chance: float      = 0.25
