extends Control

var db

@onready var username_input = $VBoxContainer/UsernameInput
@onready var password_input = $VBoxContainer/PasswordInput
@onready var message_label = $MessageLabel
signal login_success(username)
func _ready():
	init_db()
	$VBoxContainer/HBoxContainer/LoginButton.pressed.connect(_on_login_pressed)
	$VBoxContainer/HBoxContainer/RegisterButton.pressed.connect(_on_register_pressed)

func init_db():
	db = SQLite.new()
	db.path = "res://dkurpg.db"
	db.open_db()
	db.query("CREATE TABLE IF NOT EXISTS UserInfo (ID VARCHAR(20) PRIMARY KEY, Password VARCHAR(20))")

func _on_login_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	
	if username == "" or password == "":
		message_label.text = "아이디와 비밀번호를 입력하세요."
		return
	
	db.query("SELECT * FROM UserInfo WHERE ID = '%s' AND Password = '%s'" %[username, password])
	if db.query_result.size() > 0:
		message_label.text = "로그인 성공!"
		# 여기에 씬 전환 가능
		emit_signal("login_success", username) 
		queue_free()
	else:
		message_label.text = "로그인 실패: 잘못된 정보입니다."

func _on_register_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	
	if username == "" or password == "":
		message_label.text = "아이디와 비밀번호를 입력하세요."
		return
	
	db.query("SELECT * FROM UserInfo WHERE ID = ('%s');" % username)
	if db.query_result.size() > 0:
		message_label.text = "이미 존재하는 아이디입니다."
	else:
		db.query("INSERT INTO UserInfo (ID, Password) VALUES (('%s'), ('%s'))" % [username , password] )
		message_label.text = "회원가입 성공!"
