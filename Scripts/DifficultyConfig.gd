## DifficultyConfig — Resource centralizado para configurar la curva de dificultad.
## Todos los valores de dificultad se modifican aquí.
## Asignar al campo difficulty_config del DroneSpawner en el inspector.
##
## Duracion de partida: 600s (10 minutos)
## Los start_at son segundos RESTANTES cuando activa la fase:
## Fase 0: 600s restantes = minuto 0:00 (inicio)
## Fase 1: 480s restantes = minuto 2:00
## Fase 2: 360s restantes = minuto 4:00
## Fase 3: 180s restantes = minuto 7:00
## Fase 4:  60s restantes = minuto 9:00 (sprint final)
## Bombardeo: 30s restantes = minuto 9:30
class_name DifficultyConfig
extends Resource

## ================================================================
## CONFIGURACION DE FASES POR TIEMPO
## El timer corre hacia abajo desde 600s (10 min).
## start_at = segundos restantes en que comienza la fase.
## ================================================================

## --- Fase 0: Inicio (0:00 - 2:00) ---
@export_group("Fase 0 — Inicio (0:00 - 2:00)")
@export var phase0_start_at: float          = 600.0
@export var phase0_spawn_interval: float    = 5.0
@export var phase0_max_drones: int          = 3
@export var phase0_drone_speed: float       = 120.0
@export var phase0_bomb_chance: float       = 0.05
@export var phase0_chase_chance: float      = 0.01

## --- Fase 1: Normal (2:00 - 4:00) ---
@export_group("Fase 1 — Normal (2:00 - 4:00)")
@export var phase1_start_at: float          = 480.0
@export var phase1_spawn_interval: float    = 3.5
@export var phase1_max_drones: int          = 4
@export var phase1_drone_speed: float       = 155.0
@export var phase1_bomb_chance: float       = 0.12
@export var phase1_chase_chance: float      = 0.06

## --- Fase 2: Presion (4:00 - 7:00) ---
@export_group("Fase 2 — Presion (4:00 - 7:00)")
@export var phase2_start_at: float          = 360.0
@export var phase2_spawn_interval: float    = 2.5
@export var phase2_max_drones: int          = 5
@export var phase2_drone_speed: float       = 190.0
@export var phase2_bomb_chance: float       = 0.22
@export var phase2_chase_chance: float      = 0.12

## --- Fase 3: Caos (7:00 - 9:00) ---
@export_group("Fase 3 — Caos (7:00 - 9:00)")
@export var phase3_start_at: float          = 180.0
@export var phase3_spawn_interval: float    = 1.8
@export var phase3_max_drones: int          = 7
@export var phase3_drone_speed: float       = 230.0
@export var phase3_bomb_chance: float       = 0.32
@export var phase3_chase_chance: float      = 0.20

## --- Fase 4: Sprint Final (9:00 - 9:30) ---
@export_group("Fase 4 — Sprint Final (9:00 - 9:30)")
@export var phase4_start_at: float          = 60.0
@export var phase4_spawn_interval: float    = 1.2
@export var phase4_max_drones: int          = 10
@export var phase4_drone_speed: float       = 270.0
@export var phase4_bomb_chance: float       = 0.42
@export var phase4_chase_chance: float      = 0.28
