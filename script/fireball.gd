extends Area2D

var speed = 1000
var direction = Vector2.RIGHT
var direction_modifier = 1
var scale_multiplier = 1.0 	
var damage


func _ready():
	add_to_group("fireball")  # 파이어볼 그룹 추가
	
	# 크기 조정
	$Sprite2D.scale *= scale_multiplier

	# 충돌 영역 조정 (CircleShape2D 기준)
	var shape = $CollisionShape2D.shape.duplicate()
	shape.radius *= scale_multiplier
	$CollisionShape2D.shape = shape
	
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.autostart = true
	get_tree().current_scene.add_child(timer)
	timer.timeout.connect(queue_free)


func _physics_process(delta):
	position += direction * speed * delta
	# 회전 애니메이션 (선택 사항)
	rotation += 5 * delta


func _on_area_entered(area):
	if area.is_in_group("enemies"):
		print("ball")
		area.get_parent().take_damage(damage)  # 몬스터의 부모 노드(CharacterBody2D)에 데미지
	queue_free()
