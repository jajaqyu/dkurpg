extends CanvasLayer

@onready var hp_label = $HUD/Panel/HPLabel
@onready var atk_label = $HUD/Panel/ATKLabel
@onready var def_label = $HUD/Panel/DEFLabel
@onready var int_label = $HUD/Panel/INTLabel
@onready var mov_label = $HUD/Panel/MOVLabel
@onready var skill_cooldown_label = $HUD/Panel/SkillCooldownLabel
@onready var itemCount_label = $HUD/Panel/itemCount
@onready var progress_label = $HUD/Panel/Progress

var id
var char_name =""
var progress
var ATK
var DEF
var INT
var MOV
var itemCount
var job
var ATKItem
var DEFItem
var INTItem
var MOVItem
var skill_cooldown := 5.0
var skill_timer := 0.0

var db_path ="res://dkurpg.db"

#func _ready():
	#데이터베이스 경로 설정	
	# 빌드된 exe 실행 중일 때 (exe 파일로 만들때에는 이 부분을 주석 해재 후 export)
	#var exe_path = OS.get_executable_path()
	#var exe_dir = exe_path.get_base_dir()
	#db_path = exe_dir + "/dkurpg.db"


func _process(delta):
	if skill_timer > 0:
		skill_timer = max(0, skill_timer - delta)
		skill_cooldown_label.text = str("쿨타임 : %.1f" % skill_timer)
	else:
		skill_cooldown_label.text = "Ready!"

func use_skill():
	if skill_timer == 0:
		# 스킬 사용 로직
		skill_timer = skill_cooldown


func set_hp(value,value2):
	hp_label.text = "HP: %d/%d" % [value,value2]

func set_skill_cooldown(time):
	skill_cooldown_label.text = "쿨타임: %.1f" % time

func set_atk():
	atk_label.text = "ATK: %d (+ %d)" % [ATK,ATKItem]

func set_def():
	def_label.text = "DEF: %d (+ %d)" % [DEF,DEFItem]

func set_int():
	int_label.text = "INT: %d (+ %d)" % [INT,INTItem]

func set_mov():
	mov_label.text = "MOV: %d (+ %d)" % [MOV,MOVItem]

func set_itemCount():
	itemCount_label.text = "X %d" %itemCount


func set_stats(curHP,stats: Array):
	hp_label.text = "HP: %d/%d" % [curHP,stats[0]]
	atk_label.text = "공격력: %d (+ %d)" %[stats[1],ATKItem]
	def_label.text = "방어력: %d (+ %d)" %[stats[2],DEFItem]
	int_label.text = "지능: %d (+ %d)" %[stats[3],INTItem]
	mov_label.text = "이동속도: %d (+ %d)" %[stats[4],MOVItem]
	itemCount_label.text = "X	 %d" %stats[5]


func set_progress():
	progress_label.text = "학점 %d/140"%progress

func show_hud():
	self.visible = true

func hide_hud():
	self.visible = false
