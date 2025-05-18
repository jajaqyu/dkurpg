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

# 영역 공격 관련 변수
var area_active = false
var area_timer = 0.0
var damage_interval = 1.0
var damage_timer = 0.0
var drop_chance = 0.5 #드롭확률	
var damage_number = 5
signal died
@onready var animated_sprite = $AnimatedSprite2D
enum State { IDLE, WALK, SKILL, DIE ,HIT}
var current_state = State.IDLE

@export var area_scene: PackedScene
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
	
	area_timer += delta
	if area_active:
		damage_timer += delta
		if damage_timer >= damage_interval:
			damage_timer = 0.0
		if area_timer >= 3.0:  # 3초 후 영역 비활성화
			area_active = false
			area_timer = 0.0
			_remove_area()
	else:
		if area_timer >= 4.0:  # 4초 후 영역 재활성화
			area_active = true
			area_timer = 0.0
			_spawn_area()
	update_state()
func take_damage(amount):
	change_state(State.HIT)
	if not is_alive:
		return
	health -= amount
	print("Monster took damage: ", amount, ", Health: ", health)
	if health <= 0:
		die()


func _spawn_area():
	if area_scene:
		var area = area_scene.instantiate()
		add_child(area)
		area.name = "AttackArea"
		area.position = Vector2(250, 275) # aura 위치 조절, 크기 조절은 아우라의 콜리전 영역 조절
		# area.get_node("area").scale = Vector2(2, 2) # 필요시 이미지 크기 조정
		print("영역 공격 생성: ", area.position)
		change_state(State.SKILL)
		await animated_sprite.animation_finished

func _remove_area():
	var area = get_node_or_null("AttackArea")
	if area:
		area.queue_free()
		print("영역 공격 제거")
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
		print()
		

func _on_area_entered(area):
	print("Monster Hitbox detected area: ", area.name)
	if area.is_in_group("fireball"):
		take_damage(1)
		area.queue_free()
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
