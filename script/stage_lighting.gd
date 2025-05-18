extends Node2D

@export var player_scene: PackedScene
@export var monster_scene: PackedScene
@onready var char_name

var total_time := 180.0 # 3분(180초)
var time_left := total_time
@onready var timer := $Timer
@onready var time_label := $TimeLabel
var isCheck =true
var monsters_defeated = 0
@onready var game_over_dialog = $GameoverDialog
var tmp
func _ready():
	# 플레이어 생성
	var player = player_scene.instantiate()
	player.char_name = char_name
	add_child(player)
	player.global_position = Vector2(200, 200)  # 원하는 위치
	player.connect("player_died", Callable(self, "_on_player_died"))
	# 몬스터 여러 개 생성
	for i in range(5):
		var monster = monster_scene.instantiate()
		add_child(monster)
		monster.global_position = Vector2(400 + i * 100, 400)  # 원하는 위치에 배치
	game_over_dialog.hide()
	game_over_dialog.connect("confirmed", Callable(self, "_on_game_over_confirmed"))
	
func _on_monster_died():
	monsters_defeated += 1
func _on_player_died():
	_on_time_up()

func _process(delta):
	if time_left > 0:
		time_left = max(0, time_left - delta)
		update_time_label()
		if time_left == 0:
			_on_time_up()

func update_time_label():
	var min = int(time_left) / 60
	var sec = int(time_left) % 60
	time_label.text = "남은 시간: %02d:%02d" % [min, sec]

func _on_time_up():
	if isCheck:
		HUD.progress += 5
		stat_update()
		timer.stop()
		get_tree().paused = true
		game_over_dialog.dialog_text = "몬스터 처치 수: %d, 오르는 스텟: %s, 오르는 양: %d"%[monsters_defeated,"MOV",tmp]
		game_over_dialog.popup_centered()
		isCheck = false

func stat_update():
	# 스탯 업데이트
	
	var db = SQLite.new()
	db.path = "res://dkurpg.db"
	db.open_db()
	#스텟 늘리는 양 (조절가능)
	tmp = monsters_defeated/2
	db.query("UPDATE character SET MOV = MOV + %d, Progress = %d, ItemCount = %d WHERE character_name = '%s'" % [tmp, HUD.progress,HUD.itemCount,HUD.char_name])
	db.close_db()
func _on_game_over_confirmed():
	get_tree().paused = false
	# 실제 씬 전환 처리
	var packed_scene = preload("res://tscn/Main.tscn")
	var new_scene = packed_scene.instantiate()
	new_scene.login = true
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
