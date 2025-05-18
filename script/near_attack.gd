extends Area2D
var damage
@export var texture: Texture2D
func _ready():
	body_entered.connect(_on_body_entered)
	$Sprite2D.texture = texture
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
	
func activate():
	$CollisionShape2D.disabled = false
	$Sprite2D.visible = true
	
func deactivate():
	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false
