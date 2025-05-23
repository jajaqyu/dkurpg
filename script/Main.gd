extends Node
var typing_scene: Node2D
var popup_scene = preload("res://tscn/job_description.tscn")
var popup_scene1 = preload("res://tscn/game_help.tscn")
var popup_scene2 = preload("res://tscn/item_view.tscn")
var popup_instance = null

@export var hud_scene: PackedScene
@export var player_scene: PackedScene
@export var portal_scene: PackedScene
@onready var my_panel1 = $CanvasLayer/Panel
@onready var my_panel2 = $CanvasLayer/Panel2
@onready var my_panel3 = $CanvasLayer/Panel3

var char_name : String
var login = false
@export var map_scene: PackedScene
var current_map = null

func _ready():
	if !login:
		my_panel1.hide()
		my_panel2.hide()
		my_panel3.hide()		
		show_login_scene()
	else:
		playGame()


func playInit():	
	current_map = map_scene.instantiate()
	add_child(current_map)
	var spawn_point = current_map.get_node("PlayerSpawn").global_position
	
	var hud = hud_scene.instantiate()
	add_child(hud)
	
	var player = player_scene.instantiate()
	player.global_position = spawn_point
	current_map.add_child(player)
	
	var portal1 = portal_scene.instantiate()
	current_map.add_child(portal1)
	portal1.global_position = Vector2(200, 200)
	portal1.portal_name = "Stage 1"
	portal1.target_scene_path = "res://tscn/stage/stage_near.tscn"
	
	var portal2 = portal_scene.instantiate()
	current_map.add_child(portal2)
	portal2.global_position = Vector2(200, 400)
	portal2.portal_name = "Stage 2"
	portal2.target_scene_path = "res://tscn/stage/stage_lighting.tscn"
	
	var portal3 = portal_scene.instantiate()
	current_map.add_child(portal3)
	portal3.global_position = Vector2(400, 200)
	portal3.portal_name = "Stage 3"
	portal3.target_scene_path = "res://tscn/stage/stage_aura.tscn"
	
	var portal4 = portal_scene.instantiate()
	current_map.add_child(portal4)
	portal4.global_position = Vector2(400, 400)
	portal4.portal_name = "Stage 4"
	portal4.target_scene_path = "res://tscn/stage/stage_fireball.tscn"
	
	var portal5 = portal_scene.instantiate()
	current_map.add_child(portal5)
	portal5.global_position = Vector2(600, 200)
	portal5.checkItem = true
	portal5.portal_name = "Stage 5"
	portal5.target_scene_path = "res://tscn/random_item.tscn"
	
	var portal6 = portal_scene.instantiate()
	current_map.add_child(portal6)
	portal6.global_position = Vector2(600, 400)
	portal6.portal_name = "Stage Boss"
	portal6.target_scene_path = "res://tscn/stage_boss.tscn"
	if HUD.progress >= 140:
		portal6.set_locked(false)
		portal6.get_node("Label").text = "Stage Boss"
	else:
		portal6.set_locked(true)
		portal6.get_node("Label").text = "??? (진행도 140 필요)"


func _on_player_died():
	get_tree().change_scene_to_file("res://tscn/Main.tscn")


func _input(event):
	if event.is_action_pressed("show_popup"): #k
		popup_instance = popup_scene.instantiate()
		add_child(popup_instance)
		popup_instance.show_trait("example")
		popup_instance.show()
		
	elif event.is_action_pressed("show_popup_L"): #L
		popup_instance = popup_scene1.instantiate()
		add_child(popup_instance)

		popup_instance.show()
	elif event.is_action_pressed("show_popup_j"): #j
		popup_instance = popup_scene2.instantiate()
		popup_instance.show_trait(item_check())
		add_child(popup_instance)

		popup_instance.show()
	elif event.is_action_pressed("hide_popup") and popup_instance: #K
		popup_instance.hide()


func _on_login_success(username):
	var character_scene = preload("res://tscn/character_select.tscn").instantiate()
	HUD.id = username
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(character_scene)
	get_tree().current_scene = character_scene


func playGame():
	my_panel1.show()
	my_panel2.show()
	my_panel3.show()		
	playInit()
	HUD.show_hud()


func show_login_scene():
	var login_scene = preload("res://tscn/login_scene.tscn").instantiate()
	add_child(login_scene)
	login_scene.login_success.connect(_on_login_success)
	HUD.hide_hud()


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
