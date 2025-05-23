extends Window

func _ready():
	connect("close_requested", Callable(self, "_on_close_requested"))


func _on_close_requested():
	hide()  # 또는 queue_free()로 완전히 제거


func _input(event):
	if event.is_action_pressed("hide_popup_j"):
		hide()

func show_trait(items): #이미지는 직업 캐릭터 사진과 스킬 모습
	var db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	
	db.query("SELECT appearance, description,plus_ATK,plus_DEF,plus_INT,plus_MOV FROM Item WHERE Item_name = '%s'" %items[0])
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		var image_path = row["appearance"]
		var description = row["description"]
		var plus_ATK = row["plus_ATK"]
		var plus_DEF = row["plus_DEF"]
		var plus_INT = row["plus_INT"]
		var plus_MOV = row["plus_MOV"]
		$Panel/TextureRect.texture = load(image_path)
		$Panel/Label.text = "공격력: "+str(plus_ATK)+"방어력: "+str(plus_DEF)+"지능: "+str(plus_INT)+"이동속도: "+str(plus_MOV)+"\n"+description
		
	db.query("SELECT appearance, description,plus_ATK,plus_DEF,plus_INT,plus_MOV FROM Item WHERE Item_name = '%s'" %items[1])
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		var image_path = row["appearance"]
		var description = row["description"]
		var plus_ATK = row["plus_ATK"]
		var plus_DEF = row["plus_DEF"]
		var plus_INT = row["plus_INT"]
		var plus_MOV = row["plus_MOV"]
		$Panel2/TextureRect.texture = load(image_path)
		$Panel2/Label.text = "공격력: "+str(plus_ATK)+"방어력: "+str(plus_DEF)+"지능: "+str(plus_INT)+"이동속도: "+str(plus_MOV)+"\n"+description
		
	db.query("SELECT appearance, description,plus_ATK,plus_DEF,plus_INT,plus_MOV FROM Item WHERE Item_name = '%s'" %items[2])
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		var image_path = row["appearance"]
		var description = row["description"]
		var plus_ATK = row["plus_ATK"]
		var plus_DEF = row["plus_DEF"]
		var plus_INT = row["plus_INT"]
		var plus_MOV = row["plus_MOV"]
		$Panel3/TextureRect.texture = load(image_path)
		$Panel3/Label.text = "공격력: "+str(plus_ATK)+"방어력: "+str(plus_DEF)+"지능: "+str(plus_INT)+"이동속도: "+str(plus_MOV)+"\n"+description		

	db.query("SELECT appearance, description,plus_ATK,plus_DEF,plus_INT,plus_MOV FROM Item WHERE Item_name = '%s'" %items[3])
	if db.query_result.size() > 0:
		var row = db.query_result[0]
		var image_path = row["appearance"]
		var description = row["description"]
		var plus_ATK = row["plus_ATK"]
		var plus_DEF = row["plus_DEF"]
		var plus_INT = row["plus_INT"]
		var plus_MOV = row["plus_MOV"]
		$Panel4/TextureRect.texture = load(image_path)
		$Panel4/Label.text = "공격력: "+str(plus_ATK)+"방어력: "+str(plus_DEF)+"지능: "+str(plus_INT)+"이동속도: "+str(plus_MOV)+"\n"+description		
	db.close_db()
