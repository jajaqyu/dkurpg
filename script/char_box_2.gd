extends Control
var db
var create_scene =  preload("res://tscn/create_character.tscn")
var main_scene = preload("res://tscn/main1.tscn")
@onready var discardButton =$DiscardButton
var new_scene =null
var main = null
@onready var job_appearance = $JobApperance
var job_name: String = ""

func show_character(char_info):
	$NameLabel.text = char_info["character_name"]
	$JobLabel.text = char_info["job"]
	$HPLabel.text = "HP: %d" % char_info["HP"]
	$ATKLabel.text = "공격력: %d" % char_info["ATK"]
	$DEFLabel.text = "방어력: %d" % char_info["DEF"]
	$INTLabel.text = "지능: %d" % char_info["INT"]
	$MOVLabel.text = "이동속도: %d" % char_info["MOV"]
	$ProgressLabel.text = "진행도: %d/140" % char_info["Progress"]
	discardButton.pressed.connect(func(): _on_delete_button_pressed($NameLabel.text))
	$SelectButton.show()
	$DiscardButton.show()
	$PlusButton.hide()
	# 캐릭터 선택 버튼 활성화 
	$SelectButton.pressed.connect(func(): _on_select_button_pressed($NameLabel.text))

	job_name = char_info["job"]

	var path = ""

	if job_name == "SW":
		path = "res://sprites/character/sw/idle/0.png"
	elif job_name == "Law":
		path = "res://sprites/character/law/idle/0.png"
	elif job_name == "건축":
		path = "res://sprites/character/architecture/idle/0.png"
	elif job_name == "체육학과":
		path = "res://sprites/character/phy/idle/0.png"
	else:
		path = "res://sprites/character/default.png"

	var texture = load(path)
	job_appearance.texture = texture
	
func show_plus_button(ID):
	$NameLabel.text = ""
	$JobLabel.text = ""
	$HPLabel.text =""
	$ATKLabel.text = ""
	$DEFLabel.text =""
	$INTLabel.text = ""
	$MOVLabel.text =""
	$ProgressLabel.text = ""
	$SelectButton.hide()
	$DiscardButton.hide()
	$PlusButton.show()
	$PlusButton.pressed.connect(func(): _on_plus_button_pressed(ID))

	
func _on_select_button_pressed(character_name):
	main = main_scene.instantiate()
	HUD.char_name = character_name
	main.login = true
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(main)
	get_tree().current_scene = main

	
func _on_plus_button_pressed(ID):
	new_scene = create_scene.instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene

	
func _on_delete_button_pressed(character_name):
	db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	db.query("DELETE FROM character WHERE character_name = '%s'" %character_name)
	get_tree().change_scene_to_file("res://tscn/character_select.tscn")
	db.close_db()
