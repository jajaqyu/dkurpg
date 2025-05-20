extends Area2D

@export var damage: int = HUD.progress / 4 + 1
@onready
var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("strike")
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# 신호 연결: 플레이어가 번개 영역에 들어올 때 데미지
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

func _on_animation_finished():
	queue_free()
