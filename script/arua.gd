extends Area2D

@export var damage: int = HUD.progress / 6 + 1
@export var damage_interval: float = 1.0
var player_in_area = null
var timer := 0.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))


func _process(delta):
	if player_in_area:
		timer += delta
		if timer >= damage_interval:
			timer = 0.0
			if player_in_area.has_method("take_damage"):
				player_in_area.take_damage(damage)


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = body
		timer = 0.0  # 영역 진입 시 즉시 데미지 주고 싶다면 0.0, 아니면 damage_interval로


func _on_body_exited(body):
	if body == player_in_area:
		player_in_area = null
		timer = 0.0
