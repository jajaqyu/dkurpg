extends Window


func _ready():

	connect("close_requested", Callable(self, "_on_close_requested"))

func _on_close_requested():
	hide()  # 또는 queue_free()로 완전히 제거

func _input(event):
	if event.is_action_pressed("hide_popup"):
		hide()

func show_trait(trait_name): #이미지는 직업 캐릭터 사진과 스킬 모습
	var db = SQLite.new()
	db.path = "res://dkurpg.db"
	db.open_db()
	db.query("SELECT appearance, description FROM Item WHERE Item_name = '%s'" %trait_name)

	print(1)
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		var image_path = row["appearance"]
		var description = row["description"]
		$TextureRect.texture = load(image_path)
		$Label.text = description
	db.close_db()
