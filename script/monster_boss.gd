extends CharacterBody2D

var health = HUD.progress*5
var respawn_time = 10.0
var respawn_timer = 0.0
var player = null
var speed = 200
var is_alive = true
@export var projectile_scene: PackedScene  # 파이어볼(투사체) 프리팹
var attack_cooldown = 5.0
var attack_timer = 0.0
var attack_range = 500  # 공격 사거리(원하는 값으로 조정
var drop_chance = 0.5 #드롭확률

var can_attack = true

# 영역 공격 관련 변수
var area_active = false
var area_timer = 0.0
var damage_interval = 1.0
var damage_timer = 0.0
@export var area_scene: PackedScene

#라이트닝
@export var lightning_scene: PackedScene
@export var warning_scene: PackedScene 

signal died
@onready var animated_sprite = $AnimatedSprite2D
enum State { IDLE, ATTACK, SKILL, DIE ,HIT}
var current_state = State.IDLE

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	add_to_group("enemies")
	change_state(State.IDLE)
	show()

func _process(delta):
	if not is_alive:
		respawn_timer += delta
		if respawn_timer >= respawn_time:
			respawn()
		return

	if player == null:
		return
	var distance = global_position.distance_to(player.global_position)
	if is_alive && current_state != State.SKILL: 
# 플레이어 추적 이동 (선택사항)
		if distance <= 1000: # 공격 중 이동 금지
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO	
	update_state()
	
	# 공격 쿨타임 관리 및 공격
	attack_timer += delta
	if distance <= attack_range and attack_timer >= attack_cooldown:
		var n = randi() % 4
		if n ==0:
			fire_projectile()
			attack_timer = 0.0
		elif n ==1:
			attack()
			attack_timer = 0.0
		elif n == 2:
			if area_timer >= 4.0:  # 4초 후 영역 재활성화
				area_active = true
				area_timer = 0.0
				_spawn_area()	
		else:
			attack_lighting()
			attack_timer =0.0
	area_timer += delta
	if area_active:
		damage_timer += delta
		if damage_timer >= damage_interval:
			damage_timer = 0.0
		if area_timer >= 5.0:  # 3초 후 영역 비활성화
			area_active = false
			area_timer = 0.0
			_remove_area()


func fire_projectile():
	change_state(State.SKILL)
	await animated_sprite.animation_finished
	
	if projectile_scene and player:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position + Vector2(0,0)
		# 방향 계산
		var direction = (player.global_position - global_position).normalized()
		projectile.init(direction)
	

func take_damage(amount):
	change_state(State.HIT)
	if not is_alive:
		return
	health -= amount
	if health <= 0:
		die()


func die():
	change_state(State.DIE)
	is_alive = false
	health = 0
	$CollisionShape2D.set_deferred("disabled", true)
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
	change_state(State.IDLE)  
	animated_sprite.play("idle")
	animated_sprite.show()


func attack():
	if player and is_alive:
		change_state(State.ATTACK)
		player.take_damage(10)
		

func _on_area_entered(area):
	if area.is_in_group("fireball"):
		take_damage(area.damage)
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
		State.ATTACK:
			animated_sprite.play("attack")
			await animated_sprite.animation_finished
			change_state(State.IDLE)


func update_state():
	if current_state in [State.DIE, State.SKILL, State.HIT]: return
	
	if velocity.length() > 10:  # 이동 감지 임계값
		change_state(State.IDLE)
	else:
		change_state(State.IDLE)


func _spawn_area():
	if area_scene:
		var area = area_scene.instantiate()
		add_child(area)
		area.name = "AttackArea"
		area.position = Vector2(250, 275) # aura 위치 조절, 크기 조절은 아우라의 콜리전 영역 조절
		# area.get_node("area").scale = Vector2(2, 2) # 필요시 이미지 크기 조정
		change_state(State.SKILL)
		await animated_sprite.animation_finished


func _remove_area():
	var area = get_node_or_null("AttackArea")
	if area:
		area.queue_free()

		
func attack_lighting():
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
