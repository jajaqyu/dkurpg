extends CanvasLayer

# SQLite 노드 참조
@onready var db 

# 현재 문제 데이터
var current_question_data
signal quiz_result(is_correct: bool)
# 노드 참조
@onready var question_label = $VBoxContainer/QuestionLabel
@onready var buttons = [
	$VBoxContainer/Button,
	$VBoxContainer/Button2,
	$VBoxContainer/Button3,
	$VBoxContainer/Button4
]
@onready var result_label = $VBoxContainer/ResultLabel

func _ready():
	db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_answer_pressed.bind(i))
	load_question()

# DB에서 랜덤 문제 1개 가져오기
func get_random_question() -> Dictionary:
	var query = "SELECT question, choice1, choice2, choice3, choice4, answer_index FROM quiz_questions ORDER BY RANDOM() LIMIT 1"
	db.query(query)
	var result = db.query_result
	if result.size() > 0:
		var row = result[0]
		return {
			"question": row["question"],
			"choices": [row["choice1"], row["choice2"], row["choice3"], row["choice4"]],
			"answer": int(row["answer_index"])
		}
	return {}

# 문제 로드 및 UI 반영
func load_question():
	current_question_data = get_random_question()
	if current_question_data.is_empty():
		result_label.text = "문제를 불러올 수 없습니다."
		for button in buttons:
			button.disabled = true
		return

	question_label.text = current_question_data["question"]
	for i in range(4):
		buttons[i].text = current_question_data["choices"][i]
		buttons[i].disabled = false
		buttons[i].modulate = Color(1, 1, 1)
	result_label.text = ""

# 버튼 클릭 처리
func _on_answer_pressed(selected_index: int):
	var correct_index = current_question_data["answer"]
	for i in range(4):
		buttons[i].disabled = true
		if i == correct_index:
			buttons[i].modulate = Color.GREEN
		elif i == selected_index:
			buttons[i].modulate = Color.RED
	var is_correct = (selected_index == correct_index)
	result_label.text = "정답입니다!" if selected_index == correct_index else "오답입니다."
	emit_signal("quiz_result", is_correct)
	await get_tree().create_timer(2.0).timeout
	queue_free()
	#load_question()
