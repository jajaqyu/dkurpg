extends Control

var db

@onready var radio1 = $SW  # ButtonGroup 노드 경로에 맞게 설정
@onready var create_button = $create
@onready var name_input = $LineEdit
var button_group
func _ready():
	db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	create_button.pressed.connect(_on_create_button_pressed)
	button_group = radio1.button_group 
	print(HUD.id)
func _on_create_button_pressed():
	var name = name_input.text.strip_edges()
	var job = get_selected_button_info()
	# 캐릭터 생성
	db.query("INSERT INTO Character (ID, character_name, Job) VALUES ('%s', '%s', '%s')" % [HUD.id, name, job])
	get_tree().change_scene_to_file("res://tscn/character_select.tscn")
	
func get_selected_button_info():
	var selected_button = button_group.get_pressed_button()
	if selected_button:
		return selected_button.name
		# 필요하다면 사용자 정의 변수도 사용 가능
	else:
		print("선택된 버튼이 없습니다.")
	
