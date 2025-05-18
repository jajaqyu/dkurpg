extends Window

@onready var randomButton = $random
@onready var minigameButton = $minigame
var item_scene = preload("res://tscn/get_item.tscn")
var plusProbability = false
var minigameCount = 2
var type = "ItemArmor"
var rare


func _ready():
	minigameButton.pressed.connect(_on_minigame_button_pressed)
	randomButton.pressed.connect(_on_random_button_pressed)
	connect("close_requested", Callable(self, "_on_close_requested"))
	print(1111111)
func _on_close_requested():
	hide()  # 또는 queue_free()로 완전히 제거

func _on_minigame_button_pressed():
	var idx= randi() % minigameCount
	if idx == 0:
		show_quiz()
	elif idx == 1:
		show_tiping()


func _on_random_button_pressed():
	#rare = weighted_random_number(plusProbability)
	rare = 3 #테스트용
	var db = SQLite.new()
	db.path = "res://dkurpg.db"
	db.open_db()
	db.query("SELECT Item_name, plus_ATK, plus_DEF,plus_INT,plus_MOV,description, appearance, rare FROM Item WHERE type = '%s' AND Rare = %d" %[type,rare]) #Item은 rare에 따라 10까지 있다고 가정
	var result = db.query_result[0]
	var itemScene = item_scene.instantiate()
	itemScene.Type = type
	itemScene.Item_info = result
	add_child(itemScene)
	

func show_quiz():
	var quiz_scene = preload("res://tscn/QuizScene.tscn").instantiate()
	add_child(quiz_scene)
	quiz_scene.quiz_result.connect(_on_quiz_result)
	
func _on_quiz_result(is_correct: bool):
	plusProbability =is_correct
func show_tiping():		
	var typing_scene_packed = preload("res://tscn/typing_minigame.tscn")
	var typing_scene = typing_scene_packed.instantiate()
	# 결과 시그널 연결
	typing_scene.game_result.connect(_on_typing_game_result)
	# 씬 추가
	add_child(typing_scene)

func _on_typing_game_result(result: bool):
	plusProbability =result
	
func weighted_random_number(is_special: bool) -> int:
	var numbers = [1,2,3,4,5,6,7,8,9,10]
	var weights = []

	if not is_special:
		# 기본 가중치: 1은 10, 2는 9, ..., 10은 1
		for i in range(10):
			weights.append(10 - i)
	else:
		# is_special == true일 때
		# 8,9,10의 가중치를 3으로 변경, 나머지는 기본 가중치 유지
		for i in range(10):
			var w = 10 - i
			if numbers[i] in [8,9,10]:
				w = 3
			weights.append(w)
	
	# 가중치 합 계산
	var total_weight = 0
	for w in weights:
		total_weight += w
	
	# 0~total_weight 사이의 랜덤 값 뽑기
	var rand_val = randi() % total_weight
	var cumulative = 0
	for i in range(numbers.size()):
		cumulative += weights[i]
		if rand_val < cumulative:
			return numbers[i]
	
	return numbers[-1]  # 안전장치
