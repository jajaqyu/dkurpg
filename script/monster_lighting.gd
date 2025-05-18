extends CharacterBody2D

var health = 3
var respawn_time = 10.0
var respawn_timer = 0.0
var player = null
var speed = 200
var attack_cooldown = 5.0
var attack_timer = 0.0
var is_alive = true
var can_attack = true
@export var lightning_scene: PackedScene
@export var warning_scene: PackedScene 
var drop_chance = 0.5 #드롭확률
var damage_number = 5

signal died
@onready var animated_sprite = $AnimatedSprite2D
enum State { IDLE, WALK, SKILL, DIE ,HIT}
var current_state = State.IDLE

func _ready():
	print("Monster _ready() called!")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("Player found at: ", player.global_position)
	else:
		print("Error: No player found in group 'player'!")
	add_to_group("enemies")
	change_state(State.IDLE)
	show()
	print("Monster initialized at: ", global_position)

func _process(delta):
	if not is_alive:
		respawn_timer += delta
		if respawn_timer >= respawn_time:
			respawn()
		return

	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= 1000:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	if distance <= 200 and can_attack and is_alive:
		attack()
		can_attack = false
		attack_timer = 0.0
	elif not can_attack:
		attack_timer += delta
		if attack_timer >= attack_cooldown:
			can_attack = true
	update_state()
func take_damage(amount):
	change_state(State.HIT)
	if not is_alive:
		return
	health -= amount
	print("Monster took damage: ", amount, ", Health: ", health)
	if health <= 0:
		die()

func die():
	change_state(State.DIE)
	is_alive = false
	health = 0
	$CollisionShape2D.set_deferred("disabled", true)
	print("Monster died at: ", global_position)
	emit_signal("died")
	_try_give_item_to_player()
	await animated_sprite.animation_finished
	hide()

func respawn():
	health = 3
	is_alive = true
	respawn_timer = 0.0
	global_position = Vector2(100, 0)
	show()
	$CollisionShape2D.set_deferred("disabled", false)
	set_process(true)
	set_physics_process(true)
	attack_timer = 4.0             # ← 추가: 공격 타이머 초기화
	print("Monster respawned at: ", global_position)
	change_state(State.IDLE)  # ← 추가
	animated_sprite.play("idle")  # ← 추가
	animated_sprite.show()

func attack():
	if player and is_alive:
		# 플레이어 위치 캐싱 (2초 후에 같은 위치에 번개 떨어트림)
		var target_pos = player.global_position
		
		# 1) 경고 이펙트 생성
		var warning = warning_scene.instantiate()
		get_parent().add_child(warning)
		warning.global_position = target_pos

		# 2초 딜레이 후 공격 실행
		await get_tree().create_timer(2.0).timeout
		if is_instance_valid(warning):
			warning.queue_free() 
		## 공격 유효성 재확인
		#if is_instance_valid(player) && global_position.distance_to(player.global_position) <= 250:
		_spawn_lightning(target_pos)
		
func _spawn_lightning(pos: Vector2):
	if lightning_scene:
		change_state(State.SKILL)
		await animated_sprite.animation_finished
		var lightning = lightning_scene.instantiate()
		get_parent().add_child(lightning)
		lightning.global_position = pos
		print("번개 생성 at: ", pos)

func _on_area_entered(area):
	print("Monster Hitbox detected area: ", area.name)
	if area.is_in_group("fireball"):
		take_damage(damage_number)
		area.queue_free()
		print("Monster hit by fireball!")
func _try_give_item_to_player():
	if player:  # player 변수에 플레이어 노드가 연결되어 있다고 가정
		var rand = randf()
		if rand < drop_chance:
			player.add_item()
func change_state(new_state):
	if current_state == State.DIE: return
	current_state = new_state
	
	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.HIT:
			animated_sprite.play("hit")
			await animated_sprite.animation_finished
			
			change_state(State.IDLE)
		State.SKILL:
			animated_sprite.play("skill")
			await animated_sprite.animation_finished
			change_state(State.IDLE) 
		State.DIE:
			animated_sprite.play("die")
func update_state():
	if current_state in [State.DIE, State.SKILL, State.HIT]: return
	
	if velocity.length() > 10:  # 이동 감지 임계값
		change_state(State.IDLE)
	else:
		change_state(State.IDLE)
