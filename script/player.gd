extends CharacterBody2D
@onready var hitbox = $attackeparent
@onready var animated_sprite = $AnimatedSprite2D
var speed = 20000.0

const Fireball = preload("res://tscn//fireball.tscn")
var attack_texture = preload("res://sprites/attack.png")
var attack_texture_lv1 = preload("res://sprites/attack_skill_lv1.png")
var attack_texture_lv2 = preload("res://sprites/attack_skill_lv2.png")

var input_vector = Vector2.ZERO
var can_skill = true
@onready var shoot_timer = $ShootTimer
@onready var anim = $AnimatedSprite2D
signal player_died
var health :int
var curHP : int
var char_name

#파이어볼 크기
@export var scale_multiplier: float = 1.0  # 기본 크기
var damage_multiplier = 1.0

#근접공격 스킬
var is_reinforce =false
var is_reinforce_lv2 =false

#방어력 스킬
var is_barriear = false
var is_heal = false

#dash skill
var is_dashing = false
var dash_speed_multiplier = 3.0  # 대시 시 속도 배수
var dash_duration = 0.3  # 대시 지속 시간(초)
@onready var dash_timer = $DashTimer
var is_dash_attack = false
var is_attacking = false

const FRAMES_SW = preload("res://sprites/frames/sw_spriteframes.tres")
const FRAMES_LAW = preload("res://sprites/frames/law_spriteframes.tres")
const FRAMES_ARCH = preload("res://sprites/frames/arch_spriteframes.tres")
const FRAMES_PHY = preload("res://sprites/frames/phy_spriteframes.tres")

#idle 이랑 walk도 직업 따라 바뀌게 구현
func _ready():
	char_name = HUD.char_name
	load_stats_from_db(char_name)
	plus_item_stat(item_check())
	curHP = health
	speed = 2000+(HUD.MOV+HUD.MOVItem)*100
	HUD.skill_cooldown = 5 -0.1*(HUD.INT+HUD.INTItem)
	$attackeparent/nearAttack.monitoring = false
	animated_sprite.play("idle")
	add_to_group("player")  # 플레이어를 그룹에 추가
	HUD.set_stats(curHP,[health,HUD.ATK,HUD.DEF,HUD.INT,HUD.MOV,HUD.itemCount])
	HUD.set_progress();
	dash_timer.connect("timeout", Callable(self, "_on_dash_timer_timeout"))
	
	match HUD.job:
		"SW":
			anim.frames = FRAMES_SW
		"Law":
			anim.frames = FRAMES_LAW
		"건축":
			anim.frames = FRAMES_ARCH
		"체육학과":
			anim.frames = FRAMES_PHY


func load_stats_from_db(char_name):	
	var db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	var table = []
	db.query("SELECT HP,ATK,DEF,INT,MOV,itemCount,Progress,Job FROM character WHERE character_name = '%s' LIMIT 1;"%char_name)

	if db.query_result.size() > 0:
		var row = db.query_result[0]
		health = row["HP"]
		HUD.ATK = row["ATK"]
		HUD.DEF = row["DEF"]
		HUD.INT = row["INT"]
		HUD.MOV = row["MOV"]
		HUD.itemCount = row["itemCount"]
		HUD.progress = row["Progress"]
		HUD.job = row["job"]


func _process(delta):
	if HUD.skill_timer== 0 :
		can_skill = true
		
	if Input.is_action_just_pressed("skill"):
		if HUD.job == "SW" and can_skill:
			if HUD.INT >= 20:
				if HUD.INT >=40:
					is_reinforce_lv2 = true
					await near_attack(input_vector) 
					is_reinforce_lv2 = false
					HUD.use_skill()
					can_skill = false
				else:
					is_reinforce = true
					await near_attack(input_vector) 
					is_reinforce = false
					HUD.use_skill()
					can_skill = false
		
		elif HUD.job == "Law" and can_skill:
			if HUD.ATK >= 20 :
				if HUD.ATK >=40:
					scale_multiplier = 2.0
					damage_multiplier = 2.0
					shoot()
					HUD.use_skill()
					can_skill = false	
				else:
					shoot()
					HUD.use_skill()
					can_skill = false
	
		elif  HUD.job == "건축" and can_skill:
			if HUD.DEF >= 20:
				if HUD.DEF >=40:
					is_heal = true
					#이미지 변경
					HUD.use_skill()
					can_skill = false	
				else:
					is_barriear = true
					HUD.use_skill()
					can_skill = false	
		
		elif HUD.job == "체육학과" and can_skill:
			if HUD.MOV >= 20:
				start_dash()
				HUD.use_skill()
				can_skill = false
				if HUD.MOV >= 40:
					is_dash_attack = true
					#외형변경 코드
					
	if Input.is_action_just_pressed("attack"):
		near_attack(input_vector)


func shoot():
	var input_vector = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	
	if input_vector == Vector2.ZERO:	
		input_vector = Vector2.RIGHT if !animated_sprite.flip_h else Vector2.LEFT

	var fireball = Fireball.instantiate()
	fireball.direction = input_vector
	fireball.global_position = global_position
	
	fireball.scale_multiplier = scale_multiplier
	fireball.damage = HUD.ATK * damage_multiplier
	
	get_parent().add_child(fireball)


func _on_shoot_timer_timeout():
	can_skill = true


func _physics_process(delta):	
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		if input_vector.x < 0:
			animated_sprite.flip_h = true
		elif input_vector.x > 0:
			animated_sprite.flip_h = false
		# ✅ 공격 중이 아닐 때만 walk 실행
		if not is_attacking:
			animated_sprite.play("walk")
			if not animated_sprite.is_playing():
				animated_sprite.playing = true
	else:
		#✅ 공격 중이 아닐 때만 idle 실행
		if not is_attacking:
			animated_sprite.play("idle")
	if is_dashing:
		velocity = input_vector * speed * dash_speed_multiplier * delta
	else:
		velocity = input_vector * speed * delta
	move_and_slide()


func near_attack(direction: Vector2):
	var damage = (HUD.ATK+HUD.ATKItem) + (HUD.MOV + HUD.MOVItem) * 0.25
	if is_dash_attack:
		damage *=2
		is_dash_attack = false
		#이미지 해제
	if is_reinforce:
		$attackeparent/nearAttackLv1/Sprite2D.texture = attack_texture_lv1	
		$attackeparent/nearAttackLv1.damage = damage*1.5
		$attackeparent/nearAttackLv1.activate()
	elif is_reinforce_lv2:
		$attackeparent/nearAttackLv2/Sprite2D.texture = attack_texture_lv2
		$attackeparent/nearAttackLv2.damage = damage*2
		$attackeparent/nearAttackLv2.activate()		
	else:
		$attackeparent/nearAttack/Sprite2D.texture = attack_texture	
		$attackeparent/nearAttack.damage = damage
		$attackeparent/nearAttack.activate()

	var offset = 32
	var angle = direction.angle()

	# 기본값: 오른쪽 공격
	var hitbox_pos = Vector2(offset, 0)
	var hitbox_rot = 0.0
	animated_sprite.flip_h = false

	if direction.x > 0 and direction.y == 0:
		# 동
		hitbox_pos = Vector2(offset, 0)
		hitbox_rot = 0.0
	elif direction.x > 0 and direction.y < 0:
		# 북동
		hitbox_pos = Vector2(offset, 0)
		hitbox_rot = deg_to_rad(-90)
	elif direction.x > 0 and direction.y > 0:
		# 남동
		hitbox_pos = Vector2(offset, 0)
		hitbox_rot = deg_to_rad(45)
	elif direction.x < 0 and direction.y == 0:
		# 서
		hitbox_pos = Vector2(offset, 0)
		hitbox_rot = 0.0
		hitbox_rot = deg_to_rad(135)
	elif direction.x < 0 and direction.y < 0:
		# 북서
		hitbox_pos = Vector2(offset, 0)
		hitbox_rot = deg_to_rad(-150)
	elif direction.x < 0 and direction.y > 0:
		# 남서
		hitbox_pos = Vector2(offset, 0)
		hitbox_rot = deg_to_rad(90)
	elif direction.x == 0 and direction.y > 0:
		# 남
		hitbox_pos = Vector2(offset, 0)
		hitbox_rot = deg_to_rad(70)
	elif direction.x == 0 and direction.y < 0:
		# 북
		hitbox_pos = Vector2(offset, 0)
		hitbox_rot = deg_to_rad(-120)
	hitbox.position = hitbox_pos
	hitbox.rotation = hitbox_rot

	$attackeparent/nearAttack.monitoring = true
	$attackeparent/nearAttack.visible = true
	await get_tree().create_timer(0.2).timeout
	
	$attackeparent/nearAttack.deactivate()
	$attackeparent/nearAttackLv1.deactivate()
	$attackeparent/nearAttackLv2.deactivate()
	
	$attackeparent/nearAttack.monitoring = false
	$attackeparent/nearAttack.visible = false
	hitbox.position = Vector2(offset, 0)
	hitbox.rotation = 0


func take_damage(amount):
	if is_barriear:
		print("막힘")
	elif is_heal:
		curHP += amount
	else:
		amount = amount-(HUD.DEF+HUD.DEFItem)
		if amount>=0:
			curHP -= amount
		else:
			amount = 0
	HUD.set_hp(curHP,health)
	if curHP <= 0:
		die()


func die():
	#save_stats_to_db()
	emit_signal("player_died")
	queue_free()  # 플레이어 제거 (필요에 따라 게임 오버 화면 추가)

	
func add_item():
	HUD.itemCount+=1
	HUD.set_itemCount()


func start_dash():
	is_dashing = true
	dash_timer.start(dash_duration)
	

func _on_dash_timer_timeout():
	is_dashing = false


func item_check(): #이미지는 직업 캐릭터 사진과 스킬 모습
	var db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	db.query("SELECT ItemHat, ItemArmor, ItemShoes, Itemweapon FROM character WHERE character_name = '%s'" %HUD.char_name)

	var items = [null, null, null, null]
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		# Hat
		if row.has("ItemHat") and row["ItemHat"] != "":	
			items[0] = row["ItemHat"]
		else:
			items[0] = null
		# Armor
		if row.has("ItemArmor") and row["ItemArmor"] != "":
			items[1] = row["ItemArmor"]
		else:
			items[1] = null
		# Shoes
		if row.has("ItemShoes") and row["ItemShoes"] != "":
			items[2] = row["ItemShoes"]
		else:
			items[2] = null
		# Weapon
		if row.has("Itemweapon") and row["Itemweapon"] != "":
			items[3] = row["Itemweapon"]
		else:
			items[3] = null
	db.close_db()
	return items


func plus_item_stat(items):
	var db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	var plus_ATK = 0
	var plus_DEF = 0
	var plus_MOV = 0
	var plus_INT = 0
	
	db.query("SELECT plus_ATK, plus_DEF,plus_INT,plus_MOV FROM Item WHERE Item_name = '%s'" %items[0])
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		plus_ATK += int(row["plus_ATK"])
		plus_DEF += int(row["plus_DEF"])
		plus_INT += int(row["plus_INT"])
		plus_MOV += int(row["plus_MOV"])
		
	db.query("SELECT plus_ATK, plus_DEF,plus_INT,plus_MOV FROM Item WHERE Item_name = '%s'" %items[1])
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		plus_ATK += int(row["plus_ATK"])
		plus_DEF += int(row["plus_DEF"])
		plus_INT += int(row["plus_INT"])
		plus_MOV += int(row["plus_MOV"])
	
	db.query("SELECT plus_ATK, plus_DEF,plus_INT,plus_MOV FROM Item WHERE Item_name = '%s'" %items[2])
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		plus_ATK += int(row["plus_ATK"])
		plus_DEF += int(row["plus_DEF"])
		plus_INT += int(row["plus_INT"])
		plus_MOV += int(row["plus_MOV"])

	db.query("SELECT plus_ATK, plus_DEF,plus_INT,plus_MOV FROM Item WHERE Item_name = '%s'" %items[3])
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		plus_ATK += int(row["plus_ATK"])
		plus_DEF += int(row["plus_DEF"])
		plus_INT += int(row["plus_INT"])
		plus_MOV += int(row["plus_MOV"])
		
	HUD.ATKItem = plus_ATK
	HUD.DEFItem = plus_DEF
	HUD.INTItem = plus_INT
	HUD.MOVItem = plus_MOV


func _input(event):
	if event.is_action_pressed("attack") and not is_attacking:
		is_attacking = true
		anim.play("attack")


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		anim.play("idle")
		is_attacking = false
