extends Window

func _ready():
	connect("close_requested", Callable(self, "_on_close_requested"))


func _on_close_requested():
	hide()  # 또는 queue_free()로 완전히 제거


func _input(event):
	if event.is_action_pressed("hide_popup_L"):
		hide()
