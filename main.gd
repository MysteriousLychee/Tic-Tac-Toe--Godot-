extends Node

@export var cross_scene: PackedScene
@export var circle_scene: PackedScene

var player: int
var moves: int
var winner: int
var temp_marker
var player_panel_pos: Vector2i
var grid_data: Array
var grid_pos: Vector2i
var board_size: int
var cell_size: int
var row_sum: int
var col_sum: int
var diag1_sum: int
var diag2_sum: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_size = $Board.texture.get_width()
	cell_size = board_size / 3
	player_panel_pos = $PlayerPanel.get_position()
	new_game()
	$GameOverMenu.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.position.x < board_size:
				grid_pos = Vector2i(event.position / cell_size)
				if grid_data[grid_pos.y][grid_pos.x] == 0:
					moves += 1
					grid_data[grid_pos.y][grid_pos.x] = player
					create_marker(player, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))
					if check_win() != 0:
						get_tree().paused = true
						$GameOverMenu.show()
						if winner == 1:
							$GameOverMenu.get_node("ResultLabel").text = "Player 1 wins!"
						elif winner == -1:
							$GameOverMenu.get_node("ResultLabel").text = "Player 2 wins!"
					elif moves == 9:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu.get_node("ResultLabel").text = "Cat's game!"
					player *= -1
					if is_instance_valid(temp_marker):
						temp_marker.queue_free()
					create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
					print(grid_data)

func new_game():
	player = 1
	moves = 0
	winner = 0
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]
	row_sum = 0
	col_sum = 0
	diag1_sum = 0
	diag2_sum = 0
	# clear markers
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2, cell_size / 2), true)
	$GameOverMenu.hide()
	get_tree().paused = false

func create_marker(player, position, temp = false):
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp:
			temp_marker = circle
	else:
		var cross = cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if temp:
			temp_marker = cross

func check_win():
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diag1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diag2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
		if row_sum == 3 or col_sum == 3 or diag1_sum == 3 or diag2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diag1_sum == -3 or diag2_sum == -3:
			winner = -1
	return winner


func _on_game_over_menu_restart() -> void:
	new_game()
