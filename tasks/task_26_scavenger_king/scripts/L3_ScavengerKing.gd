extends CharacterBody2D
class_name L3_ScavengerKing
## UC-L3-15: Armored spawn state, 90% projectile reduction (except Dimotfer Rifle), Gile/Tor vs armor,
## rifle collision breach + exposed hide visuals (see `notify_rifle_hit_boss`).
## UC-L3-16: Vulnerable charge (20–80% integrity), linear acceleration, Tor stagger + 3s stun,
## post-stun jackal wave at Haboob perimeter, charge impact damage, Haboob friction hook.
##
## S-17 (`L2_Rifle.tscn`): the rifle’s `rifle_hit_boss` signal has **no parameters**, so it
## cannot be bound directly to `take_damage(amount, weapon)` without a `Callable.bind(...)`.
## Connect it to **`apply_s17_rifle_hit_from_raycast`** instead: that runs `notify_rifle_hit_boss` in
## phase one (armor break) and applies Dimotfer damage in phase two. This node is in group **`Boss`**
## (capital B) so `RayCast2D` collision checks for that group match, and still in **`boss`** for
## `call_group("boss", ...)`.

enum Phase { ONE, TWO }

signal phase_two_entered
signal armor_breach_audio_cue_requested
signal charge_ground_shake_changed(active: bool)
## Emitted when a full charge connects (A1). Listeners should apply `integrity_loss_ratio` to max integrity.
signal charge_impact_dealt(target: Node2D, integrity_loss_ratio: float)

@export var max_integrity: float = 500.0
@export var charge_max_speed: float = 280.0
@export var charge_acceleration: float = 180.0
@export var tor_stagger_duration_sec: float = 3.0
@export var charge_hit_cooldown_sec: float = 0.8
@export var charge_hit_integrity_ratio: float = 0.15
@export var charge_shake_speed_threshold_ratio: float = 0.25

@export var jackal_scene: PackedScene
@export var jackals_per_wave: int = 4
@export var haboob_perimeter_spawn_radius: float = 480.0
## World-space center for jackal perimeter spawns; if `Vector2.ZERO`, uses group "Haboob" or this boss.
@export var haboob_spawn_center_global: Vector2 = Vector2.ZERO
## Used when `L2_Rifle.rifle_hit_boss` fires after armor is already broken (phase two only).
@export var s17_rifle_damage_exposed: float = 40.0

var integrity: float
var phase: Phase = Phase.ONE
var hyena_king_exposed: bool = false
var target: Node2D = null

var _charging: bool = false
var _charge_speed_current: float = 0.0
var _stun_remaining: float = 0.0
var _pending_summon_after_stun: bool = false
var _haboob_charge_speed_multiplier: float = 1.0
var _charge_impact_cooldown: float = 0.0
var _shake_vfx_active: bool = false

@onready var visuals: L3_ScavengerKingVisuals = $Visuals


func _ready() -> void:
	integrity = max_integrity
	add_to_group("boss")
	add_to_group("Boss")
	add_to_group("hazard")
	visuals.set_phase(phase)


## S-17: intended receiver for `L2_Rifle.rifle_hit_boss` (zero-arg signal).
func apply_s17_rifle_hit_from_raycast() -> void:
	if phase == Phase.ONE:
		notify_rifle_hit_boss()
	else:
		take_damage(s17_rifle_damage_exposed, L3_Weapons.Kind.RIFLE)


## UC-L3-16 A2: Haboob at max intensity — pass `0.75` so charge top speed is reduced by 25%.
func set_haboob_environment_friction_multiplier(multiplier: float) -> void:
	_haboob_charge_speed_multiplier = clampf(multiplier, 0.25, 1.0)


func _physics_process(delta: float) -> void:
	if integrity <= 0.0:
		return

	if _charge_impact_cooldown > 0.0:
		_charge_impact_cooldown -= delta

	if _stun_remaining > 0.0:
		_stun_remaining -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		if _stun_remaining <= 0.0:
			_on_stun_recovered()
		return

	_charging = _should_run_charge_logic()

	if _charging:
		if target == null or not is_instance_valid(target):
			target = _pick_charge_target()
		if target:
			var to_t := target.global_position - global_position
			var dist_sq := to_t.length_squared()
			if dist_sq > 0.0001:
				var dir := to_t.normalized()
				var cap := charge_max_speed * _haboob_charge_speed_multiplier
				_charge_speed_current = move_toward(_charge_speed_current, cap, charge_acceleration * delta)
				velocity = dir * _charge_speed_current
			else:
				velocity = Vector2.ZERO
		else:
			velocity = Vector2.ZERO

		move_and_slide()
		_process_charge_slide_hits()
	else:
		_charge_speed_current = move_toward(_charge_speed_current, 0.0, charge_acceleration * 2.0 * delta)
		velocity = Vector2.ZERO
		move_and_slide()

	_update_charge_shake_vfx()


func _should_run_charge_logic() -> bool:
	if phase != Phase.TWO:
		return false
	if max_integrity <= 0.0:
		return false
	var ratio := integrity / max_integrity
	return ratio >= 0.2 and ratio <= 0.8


func _pick_charge_target() -> Node2D:
	var candidates: Array[Node2D] = []
	for n in get_tree().get_nodes_in_group("Player"):
		if n is Node2D:
			candidates.append(n as Node2D)
	for n in get_tree().get_nodes_in_group("Camel"):
		if n is Node2D:
			candidates.append(n as Node2D)
	if candidates.is_empty():
		return get_tree().get_first_node_in_group("Player") as Node2D
	return candidates[randi_range(0, candidates.size() - 1)]


func _process_charge_slide_hits() -> void:
	if not _charging or _charge_impact_cooldown > 0.0:
		return
	var count := get_slide_collision_count()
	for i in count:
		var col := get_slide_collision(i)
		if col == null:
			continue
		var collider := col.get_collider()
		if collider is not Node2D:
			continue
		var n := collider as Node2D
		if n.is_in_group("Player") or n.is_in_group("Camel"):
			_charge_impact_cooldown = charge_hit_cooldown_sec
			charge_impact_dealt.emit(n, charge_hit_integrity_ratio)
			break


func _update_charge_shake_vfx() -> void:
	var threshold := charge_max_speed * charge_shake_speed_threshold_ratio
	var want := _charging and _charge_speed_current >= threshold
	if want != _shake_vfx_active:
		_shake_vfx_active = want
		charge_ground_shake_changed.emit(want)


func _on_stun_recovered() -> void:
	if _pending_summon_after_stun:
		_pending_summon_after_stun = false
		_summon_jackals_at_haboob_perimeter(jackals_per_wave)


func _summon_jackals_at_haboob_perimeter(count: int) -> void:
	if jackal_scene == null:
		return
	var parent_n := get_parent()
	if parent_n == null:
		return
	var center := _resolve_haboob_spawn_center()
	for k in count:
		var inst := jackal_scene.instantiate()
		if not (inst is Node2D):
			if inst is Node:
				(inst as Node).queue_free()
			push_warning("L3_ScavengerKing: jackal_scene root must be Node2D.")
			return
		var jackal := inst as Node2D
		parent_n.add_child(jackal)
		var angle := TAU * (float(k) / float(count))
		jackal.global_position = center + Vector2.from_angle(angle) * haboob_perimeter_spawn_radius


func _resolve_haboob_spawn_center() -> Vector2:
	if haboob_spawn_center_global.length_squared() > 0.0001:
		return haboob_spawn_center_global
	var haboob := get_tree().get_first_node_in_group("Haboob") as Node2D
	if haboob != null:
		return haboob.global_position
	return global_position


func _enter_stagger_from_tor() -> void:
	_stun_remaining = tor_stagger_duration_sec
	_pending_summon_after_stun = true
	_charging = false
	_charge_speed_current = 0.0
	velocity = Vector2.ZERO
	_update_charge_shake_vfx_force_off()


func _update_charge_shake_vfx_force_off() -> void:
	if _shake_vfx_active:
		_shake_vfx_active = false
		charge_ground_shake_changed.emit(false)


## Invoked by S-17 after Dimotfer collision validation (UC-L3-15 main flow 4–6).
func notify_rifle_hit_boss() -> void:
	_on_rifle_hit_boss()


func _on_rifle_hit_boss() -> void:
	if phase != Phase.ONE:
		return
	phase = Phase.TWO
	hyena_king_exposed = true
	phase_two_entered.emit()
	armor_breach_audio_cue_requested.emit()
	visuals.set_phase(phase)


## UC-L3-15 armored rules + UC-L3-16 Tor vs active charge.
func take_damage(amount: float, weapon: L3_Weapons.Kind) -> void:
	if phase == Phase.ONE:
		if L3_Weapons.is_gile_or_tor(weapon):
			return
		if L3_Weapons.is_dimotfer_rifle(weapon):
			return
		integrity -= amount * 0.1
	else:
		if _charging and L3_Weapons.is_tor_throw(weapon):
			_enter_stagger_from_tor()
			return
		integrity -= amount

	if integrity <= 0.0:
		_die()


func _die() -> void:
	_update_charge_shake_vfx_force_off()
	var encounter_root := get_parent()
	if encounter_root:
		encounter_root.queue_free()
	else:
		queue_free()


func is_phase_two() -> bool:
	return phase == Phase.TWO
