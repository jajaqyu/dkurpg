extends Node2D

# SQLite 모듈 로드 (GDExtension으로 등록된 SQLite 클래스 사용)
var sqlite = SQLite.new()

# UI 노드
var sentence_label: Label
var input_field: LineEdit
var result_label: Label
var timer_label: Label
var restart_button: Button
var instruction_label: Label
var dialog: AcceptDialog

# 타이머 변수
var time_left: float = 30.0
var timer_active: bool = false
var char_name
# 현재 문장
var current_sentence: String = ""
signal game_result(result: bool)
func _ready():
	# SQLite 데이터베이스 설정
	
	sqlite.path = HUD.db_path
	var success = sqlite.open_db()
	print("SQLite open success: ", success)
	if not success:
		print("SQLite error: ")
	
	# 데이터베이스 테이블 생성 (최초 실행 시)
	create_sentences_table()
	
	# UI 설정
	setup_ui()

# 새 문장 로드 및 타이머 시작
	load_random_sentence()
	timer_active = true

func create_sentences_table():
# 테이블 없으면 생성
	var create_success = sqlite.query("CREATE TABLE IF NOT EXISTS sentences (id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT NOT NULL);")
	print("Create table success: ", create_success)
	
# 문장 개수 확인
	#var count_success = sqlite.query("SELECT COUNT(*) AS count FROM sentences;")
	#print("Count query success: ", count_success)
	#sqlite.query_result()
	#var count = result[0]["count"] if result.size() > 0 else 0

  # 문장 개수 확인 (query와 query_result 속성 사용)
	var query_success = sqlite.query("SELECT COUNT(*) AS count FROM sentences;")
	print("Query success: ", query_success)
	var result = sqlite.query_result
	print("Query result: ", result)
	var count = result[0]["count"] if result.size() > 0 else 0
	print("Sentence count: ", count)

# 하나도 없으면 예시 문장 생성
	if count == 0:
		var sample_sentences = [
		"The quick brown fox jumps over the lazy dog.",
		"Godot Engine is a powerful tool for game development.",
		"Typing fast improves your productivity.",
		"Practice makes perfect in any skill.",
		"Explore the universe with xAI's Grok."
			]
		for sentence in sample_sentences:
			var insert_success = sqlite.query("INSERT INTO sentences (text) VALUES ('%s');" % sentence)
			print("Insert sentence success: ", insert_success)

func setup_ui():
	var viewport_size = get_viewport_rect().size
# 배경 이미지
	var background = Sprite2D.new()
	background.texture = load("res://background.jpg")
	background.position = Vector2(0, 0)
	add_child(background)
	background.scale = Vector2(3,2.5)
# 문장 표시 레이블
	sentence_label = Label.new()
	sentence_label.position = Vector2(viewport_size.x / 2-350, viewport_size.y / 2)
	sentence_label.text = "Loading..."
	sentence_label.add_theme_font_size_override("font_size", 32)
	add_child(sentence_label)

	# 입력 필드
	input_field = LineEdit.new()
	input_field.position = Vector2(300, 400)
	input_field.size = Vector2(500, 50)
	input_field.add_theme_stylebox_override("normal", create_stylebox("res://input_field.png"))
	input_field.add_theme_color_override("font_color", Color.BLUE)
	input_field.text_submitted.connect(_on_input_submitted)
	add_child(input_field)

	# 결과 레이블
	result_label = Label.new()
	result_label.position = Vector2(460, 500)
	result_label.text = ""
	result_label.add_theme_font_size_override("font_size", 28)
	add_child(result_label)

	# 타이머 레이블
	timer_label = Label.new()
	timer_label.position = Vector2(50, 50)
	timer_label.text = "Time: 30.0"
	timer_label.add_theme_font_size_override("font_size", 28)
	add_child(timer_label)
	
	instruction_label = Label.new()
	instruction_label.add_theme_font_size_override("font_size", 28)
	instruction_label.text = "Enter를 눌러 입력하세요! \n기회는 한 번 뿐입니다"
	instruction_label.custom_minimum_size = Vector2(400, 40)
	instruction_label.position = Vector2((viewport_size.x - instruction_label.custom_minimum_size.x) / 2, 200) # 재시작 버튼 위치
	add_child(instruction_label)
	# 재시작 버튼
	#restart_button = Button.new()
	#restart_button.position = Vector2(450, 500)
	#restart_button.size = Vector2(200, 50)
	#restart_button.text = "Restart"
	#restart_button.add_theme_stylebox_override("normal", create_stylebox("res://button_normal.png"))
	#restart_button.add_theme_stylebox_override("pressed", create_stylebox("res://button_pressed.png"))
	#restart_button.pressed.connect(_on_restart_pressed)
	#add_child(restart_button)
	
func create_stylebox(texture_path: String) -> StyleBoxTexture:
	var stylebox = StyleBoxTexture.new()
	stylebox.texture = load(texture_path)
	return stylebox

func load_random_sentence():
# 랜덤 문장 선택
	var query_success = sqlite.query("SELECT text FROM sentences ORDER BY RANDOM() LIMIT 1;")
	print("Random sentence query success: ", query_success)
	var result = sqlite.query_result
	if result.size() > 0:
		current_sentence = result[0]["text"]
		sentence_label.text = current_sentence
	else:
		sentence_label.text = "No sentences available!"
		current_sentence = ""

func _on_input_submitted(text: String):
	if not timer_active:
		return
	var is_correct = text.strip_edges() == current_sentence
# 입력된 텍스트와 현재 문장 비교
	if is_correct:
		result_label.text = "Correct! Well done!"
		result_label.modulate = Color.GREEN
	else	:
		result_label.text = "Fail..."
		result_label.modulate = Color.RED

	# 입력 필드 비활성화
	input_field.editable = false
	timer_active = false

	# 경고창 표시
	show_result_dialog(is_correct)

func _on_restart_pressed():
# 게임 초기화
	time_left = 30.0
	timer_active = true
	result_label.text = ""
	result_label.modulate = Color.WHITE
	timer_label.text = "Time: 30.0"
	input_field.text = ""
	load_random_sentence()

func _process(delta):
	if timer_active:
		time_left -= delta
		timer_label.text = "Time: %.1f" % time_left
	if time_left <= 0:
		timer_active = false
		timer_label.text = "Time: 0.0"
		result_label.text = "Time's up!"
		result_label.modulate = Color.RED
		input_field.editable = false
		# 시간 초과 시 경고창 표시 (실패로 처리)
		show_result_dialog(false)

func _exit_tree():
# 데이터베이스 닫기
	sqlite.close_db()
func show_result_dialog(is_correct: bool):
# AcceptDialog 생성
	dialog = AcceptDialog.new()
	dialog.title = "Result"
	dialog.dialog_text = "Correct! Well done!" if is_correct else "Fail..."
	dialog.ok_button_text = "Close"

	# 다이얼로그 크기 조정
	dialog.size = Vector2(400, 200)
	dialog.position = Vector2((get_viewport_rect().size.x - dialog.size.x) / 2, (get_viewport_rect().size.y - dialog.size.y) / 2)

	# 다이얼로그 닫힐 때 처리
	dialog.confirmed.connect(_on_dialog_confirmed.bind(is_correct))
	dialog.canceled.connect(_on_dialog_confirmed.bind(is_correct))
	add_child(dialog)

	# 다이얼로그 표시
	dialog.popup_centered()

func _on_dialog_confirmed(is_correct: bool):
# 결과 시그널 발생
	emit_signal("game_result", is_correct)
	print("Game result emitted: ", is_correct)

	# 다이얼로그 제거
	if dialog != null:
		dialog.queue_free()
		dialog = null

	# 씬 종료 (부모 씬에서 처리하도록 함)
	queue_free()

#메인 씬에서 연결하는 방법
#extends Node
#
#var typing_scene: Node
#
#func _ready():
	## 타이핑 게임 씬 로드
	#var typing_scene_packed = load("res://typing_minigame.tscn")
	#typing_scene = typing_scene_packed.instantiate()
#
	## 결과 시그널 연결
	#typing_scene.game_result.connect(_on_typing_game_result)
#
	## 씬 추가
	#add_child(typing_scene)
#
#func _on_typing_game_result(result: bool):
	#print("Typing game result: ", result)
	## 결과에 따라 추가 처리
	#if result:
		#print("Player succeeded!")
	#else:
		#print("Player failed!")
	# 필요 시 다른 씬으로 전환
	# get_tree().change_scene_to_file("res://next_scene.tscn")
