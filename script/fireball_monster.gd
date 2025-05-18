extends Area2D

@export var speed: float = 400.0
var direction = Vector2.ZERO

func init(dir: Vector2):
	direction = dir
func _ready():
	body_entered.connect(_on_body_entered)


func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		queue_free()
