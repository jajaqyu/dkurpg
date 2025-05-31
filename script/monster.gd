extends CharacterBody2D

var health = HUD.progress * 1.5 +5
var damage_number = HUD.progress/5 +1

var respawn_time = 10.0
var respawn_timer = 0.0
var player = null
var speed = 200
var attack_cooldown = 5.0
var attack_timer = 0.0
var is_alive = true
var drop_chance = 0.5 #드롭확률

signal died

@onready var animated_sprite = $AnimatedSprite2D
enum State { IDLE, WALK, ATTACK, DIE ,HIT}
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

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	update_state()

	attack_timer += delta
	if distance <= 200 and attack_timer >= attack_cooldown and is_alive:
		attack()
		attack_timer = 0.0


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
	global_position = Vector2(300, 300)
	show()
	$CollisionShape2D.set_deferred("disabled", false)
	set_process(true)
	set_physics_process(true)
	attack_timer = 4.0             # ← 추가: 공격 타이머 초기화
	current_state = State.IDLE
	animated_sprite.play("idle")  
	animated_sprite.show()


func attack():
	if player and is_alive:
		change_state(State.ATTACK)
		await animated_sprite.animation_finished 
		player.take_damage(damage_number)
		change_state(State.IDLE)


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
		State.ATTACK:
			animated_sprite.play("attack")
			await animated_sprite.animation_finished
			change_state(State.IDLE) 
		State.DIE:
			animated_sprite.play("die")
			

func update_state():
	if current_state in [State.DIE, State.ATTACK, State.HIT]: return
	
	if velocity.length() > 10:  # 이동 감지 임계값
		change_state(State.IDLE)
	else:
		change_state(State.IDLE)
