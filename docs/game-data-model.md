# Game Data Model

Modelo de todas las entidades, atributos y relaciones.
Todos los valores son parametrizables por Resource o @export.

---

## PlayerStats (Resource - persiste entre partidas)
PlayerStats.tres base_max_hearts: int = 1 base_speed: float = 150.0 base_force: float = 1.0 has_revive: bool = false has_ally_drone: bool = false permanent_money: int = 0

---

## RuntimePlayerStats (nodo en partida - temporal)
RuntimePlayerStats current_hearts: int current_fragments: int -> 0 a 4 por corazon current_speed: float current_force: float level: int = 1 xp: int = 0 xp_to_next_level: int = 50 money_earned: int = 0 is_invulnerable: bool = false invulnerability_timer: float = 0.0

---

## LevelUpConfig (Resource - tabla de XP)
LevelUpConfig.tres xp_per_level: Array[int] = [50, 100, 150, 200, 250, 300, 350, 400, 450, 500] max_xp_per_level: int = 500 force_increment: float = 0.5 speed_increment: float = 20.0 health_fragment_increment: int = 1


---

## MatchConfig (Resource - parametros de partida)

MatchConfig.tres match_duration: float = 1500.0 -> 25 min en segundos endgame_event_start: float = 1500.0 endgame_bonus_multiplier: float = 2.0 invulnerability_duration: float = 2.0


---

## DifficultyPhase (Resource - una fase de dificultad)
DifficultyPhase.tres start_time: float active_package_types: Array[String] drone_count: int drone_speed: float bomb_chance: float bomb_immediate_chance: float spawn_interval: float


---

## PackageTypeData (Resource - tipo de paquete)
PackageTypeData.tres id: String display_name: String color: Color delivery_point_id: String xp_reward: int money_reward: int

---

## BombData (Resource - propiedades de bomba)
BombData.tres type: BombType enum (IMMEDIATE, TIMER) damage_fragments: int = 2 radius: float -> 64 o 80 segun tipo timer_duration: float = 3.0 -> solo para TIMER can_be_picked: bool -> IMMEDIATE=false, TIMER=true

---

## DropTable (Resource - probabilidades de spawn)
DropTable.tres package_weight: float = 0.5 coin_weight: float = 0.2 powerup_weight: float = 0.1 bomb_weight: float = 0.15 surprise_weight: float = 0.05

---

## PermanentUpgrade (Resource - item de tienda)
PermanentUpgrade.tres id: String display_name: String description: String cost: int max_level: int = -1 -> -1 = acumulable sin limite effect_type: UpgradeEffect enum effect_value: float

---

## Relaciones entre Entidades
PlayerStats (persistente) | al iniciar partida v RuntimePlayerStats (temporal) | lee de v LevelUpConfig + MatchConfig

DifficultyPhase[] (ordenado por start_time) | consulta v DroneSpawner | usa v DropTable -> decide que drop instanciar | +--> PackageTypeData (si paquete) +--> BombData (si bomba) +--> Coin (si moneda) +--> PowerUpDrop (si power-up)

DeliveryPoint <-- referenciado por PackageTypeData.delivery_point_id


---

## Ubicacion de archivos Resource

| Dato | Ruta | Tipo |
|---|---|---|
| Stats base | Resources/PlayerStats.tres | Resource |
| Tabla XP | Resources/LevelUpConfig.tres | Resource |
| Config partida | Resources/MatchConfig.tres | Resource |
| Fases dificultad | Resources/Difficulty/phase_*.tres | Resource[] |
| Tipos paquete | Resources/Packages/type_*.tres | Resource[] |
| Datos bomba | Resources/Bombs/bomb_*.tres | Resource[] |
| Tabla drops | Resources/DropTable.tres | Resource |
| Upgrades tienda | Resources/Upgrades/upgrade_*.tres | Resource[] |

Todos editables desde el inspector de Godot sin tocar codigo.


