extends Control

var db  # SQLite 인스턴스
var username  # 로그인한 아이디

@onready var char_box1 = $CharBox1
@onready var char_box2 = $CharBox2
@onready var char_box3 = $CharBox3
@onready var create_button = $create
func _ready():
	
	db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	# username은 show_character_select_scene에서 전달받아 저장
	load_characters()

func load_characters():
	db.query("SELECT * FROM Character WHERE ID = '%s'" % HUD.id)
	var char_list = db.query_result
	var boxes = [char_box1, char_box2, char_box3]
	for i in range(3):
		if i < char_list.size():
			var char_info = char_list[i]
			print(char_info)
			boxes[i].show_character(char_info)  # 캐릭터 정보 표시 함수
		else:
			boxes[i].show_plus_button(username)
