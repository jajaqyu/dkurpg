extends Control

# 미니맵(서브뷰포트)의 크기
var minimap_size =Vector2(220,150)  # 예: Vector2(320, 320)
# 월드 전체 크기 (타일맵 등 기준)
var world_size = Vector2(900, 800)
# 플레이어의 월드 좌표
var player_node = null



func _process(delta):
	if player_node:
		var player_world_pos = player_node.global_position
		var player_minimap_pos = player_world_pos / world_size * minimap_size + Vector2(850,-40)
		$SubViewport/PortalMarker/PlayerMarker.position = player_minimap_pos
