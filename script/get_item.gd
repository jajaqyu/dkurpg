extends Window
@onready var getButton = $Button
@onready var xButton = $Button2

var plus_ATK = "" 
var plus_DEF = ""
var plus_INT = ""
var plus_MOV = ""
var rare = ""
var db
var Item_info
var Type
func _ready():
	xButton.pressed.connect(_on_close_requested)
	getButton.pressed.connect(_on_get_button_pressed)
	connect("close_requested", Callable(self, "_on_close_requested"))
	show_div()

func _on_close_requested():
	queue_free()
func _on_get_button_pressed():
	db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	var tmp = Item_info["Item_name"]
	db.query("UPDATE character SET %s = %s WHERE character_name = %s"%[Type,tmp,HUD.char_name])
	db.close_db()
	queue_free()


func show_div():
	db = SQLite.new()
	db.path = HUD.db_path
	db.open_db()
	db.query("SELECT plus_ATK, plus_DEF,plus_INT,plus_MOV,rare FROM Item WHERE Item_name = (SELECT %s FROM Character WHERE character_name = '%s' ) " %[Type,HUD.char_name]) #내가 입고있는것
	var row = db.query_result[0]
	if db.query_result.size() > 0:
		plus_ATK = row["plus_ATK"]
		plus_DEF = row["plus_DEF"]
		plus_INT = row["plus_INT"]
		plus_MOV = row["plus_MOV"]
		rare = row["Rare"]
		
	$Label.text = Item_info["Item_name"]
	$Label2.text =  "ATK: "+str(plus_ATK)+">"+str(Item_info["plus_ATK"])
	$Label3.text =  "DEF: "+str(plus_DEF)+">"+str(Item_info["plus_DEF"])
	$Label4.text =  "INT: "+str(plus_INT)+">"+str(Item_info["plus_INT"])
	$Label5.text =  "MOV: "+str(plus_MOV)+">"+str(Item_info["plus_MOV"])
	$Label6.text = Item_info["description"]
	$Label7.text =  "Rare: "+str(rare)+">"+str(Item_info["Rare"])
	$TextureRect.texture = load(Item_info["appearance"])
	db.close_db()
