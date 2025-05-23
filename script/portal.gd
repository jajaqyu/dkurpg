extends Area2D

@export var target_scene_path: String = ""
@export var portal_name: String = "Stage"

var player_in_area = false
var player_body = null
var asking = false
var checkItem = false

@onready var label = $Label
@onready var confirm_dialog = $ConfirmDialog
@onready var animated_sprite = $AnimatedSprite2D

var is_locked = false

func _ready():
	label.text = portal_name
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	confirm_dialog.connect("confirmed", Callable(self, "_on_confirmed"))
	confirm_dialog.connect("canceled", Callable(self, "_on_canceled"))
	confirm_dialog.hide()


func _on_body_entered(body):
	if body.is_in_group("player"):
		if is_locked:  # ← 추가된 부분
			label.text = "잠김 상태! (진행도 140 필요)"
			return
		player_in_area = true
		player_body = body
		label.text = "%s\n[↑] 입장" % portal_name


func _on_body_exited(body):
	if body == player_body:
		player_in_area = false
		player_body = null
		label.text = portal_name
		asking = false
		confirm_dialog.hide()


func _process(delta):
	if player_in_area and not asking:
		if Input.is_action_just_pressed("ui_up"):
			asking = true
			confirm_dialog.dialog_text = "%s에 입장하시겠습니까?" % portal_name
			confirm_dialog.popup_centered()
	elif asking:
		# 팝업이 떠 있을 때는 키 입력을 무시
		pass
	set_locked(is_locked)


func _on_confirmed():
	asking = false
	if target_scene_path != "" and !checkItem:
		get_tree().change_scene_to_file(target_scene_path)
	elif target_scene_path != "" and checkItem:
		var ItemScene = load(target_scene_path)
		var sc = ItemScene.instantiate()
		add_child(sc)


func _on_canceled():
	asking = false
	label.text = "%s\n[↑] 입장" % portal_name


func set_locked(state: bool):
	is_locked = state
	if is_locked:
		animated_sprite.play("locked")
	else:
		animated_sprite.play("unlocked")
