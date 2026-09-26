extends Node2D

# Main game controller - manages level generation, scoring, and game state

var current_bridge_index: int = 0
var bridges: Array = []
var bridge_gap: float = 200.0  # Gap between bridges
var base_bridge_width: float = 120.0  # Starting bridge width
var width_increment: float = 40.0  # How much wider each successive bridge gets
var base_bridge_height: float = 24.0
var bridge_y_position: float = 400.0
var total_bridges: int = 20

@onready var cat: CharacterBody2D = $Cat
@onready var camera: Camera2D = $Camera2D
@onready var hud: CanvasLayer = $HUD
@onready var background: ColorRect = $Background

signal bridge_crossed(bridge_number: int)
signal game_won
signal game_lost

func _ready():
	generate_level()
	cat.global_position = Vector2(bridges[0].global_position.x - 30, bridge_y_position - 80)
	camera.global_position = cat.global_position
	# Connect cat signals
	cat.fell_in_water.connect(_on_cat_fell_in_water)
	cat.landed_on_bridge.connect(_on_cat_landed_on_bridge)

func generate_level():
	# Create starting platform
	var start_platform = _create_bridge(0, 0.0, base_bridge_width + 60)
	bridges.append(start_platform)
	
	# Create subsequent bridges with increasing width
	for i in range(1, total_bridges):
		var bridge_width = base_bridge_width + (i * width_increment)
		var x_offset = bridges[i - 1].global_position.x + bridges[i - 1].get_meta("width") / 2.0 + bridge_gap + bridge_width / 2.0
		var bridge = _create_bridge(i, x_offset, bridge_width)
		bridges.append(bridge)
	
	# Create finish platform
	var last_bridge = bridges[bridges.size() - 1]
	var finish_x = last_bridge.global_position.x + last_bridge.get_meta("width") / 2.0 + 150 + 100
	var finish = _create_bridge(total_bridges, finish_x, 300)
	finish.get_node("CollisionShape2D").position.y = 0
	# Add a "Finish" label to the last platform
	var finish_label = Label.new()
	finish_label.text = "🏠 HOME!"
	finish_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_label.add_theme_font_size_override("font_size", 28)
	finish_label.position = Vector2(-50, -60)
	finish_label.name = "FinishLabel"
	finish.add_child(finish_label)
	bridges.append(finish)

func _create_bridge(index: int, x_pos: float, width: float) -> StaticBody2D:
	var bridge = StaticBody2D.new()
	bridge.name = "Bridge_%d" % index
	bridge.collision_layer = 2  # Bridge layer
	bridge.collision_mask = 0
	bridge.position = Vector2(x_pos, bridge_y_position)
	
	# Visual - bridge body
	var visual = ColorRect.new()
	visual.name = "Visual"
	var hue = fmod(0.08 + index * 0.04, 1.0)
	var bridge_color = Color.from_hsv(hue, 0.5, 0.7)
	visual.color = bridge_color
	visual.size = Vector2(width, base_bridge_height)
	visual.position = Vector2(-width / 2.0, -base_bridge_height / 2.0)
	bridge.add_child(visual)
	
	# Top plank detail
	var top_plank = ColorRect.new()
	top_plank.name = "TopPlank"
	top_plank.color = Color.from_hsv(hue, 0.4, 0.85)
	top_plank.size = Vector2(width + 4, 6)
	top_plank.position = Vector2(-width / 2.0 - 2, -base_bridge_height / 2.0 - 2)
	bridge.add_child(top_plank)
	
	# Plank lines for wooden look
	var num_planks = int(width / 20)
	for p in range(num_planks):
		var plank_line = ColorRect.new()
		plank_line.color = Color.from_hsv(hue, 0.55, 0.55)
		plank_line.size = Vector2(2, base_bridge_height - 4)
		var px = -width / 2.0 + (p + 1) * (width / (num_planks + 1))
		plank_line.position = Vector2(px, -base_bridge_height / 2.0 + 2)
		bridge.add_child(plank_line)
	
	# Railing posts
	for side in [-1, 1]:
		var post = ColorRect.new()
		post.color = Color.from_hsv(hue, 0.35, 0.65)
		post.size = Vector2(4, 30)
		post.position = Vector2(side * (width / 2.0 - 2), -base_bridge_height / 2.0 - 30)
		bridge.add_child(post)
	
	# Railing rope
	var rope = ColorRect.new()
	rope.color = Color(0.85, 0.7, 0.4)
	rope.size = Vector2(width - 4, 3)
	rope.position = Vector2(-width / 2.0 + 2, -base_bridge_height / 2.0 - 28)
	bridge.add_child(rope)
	
	# Collision shape
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(width, base_bridge_height)
	collision.shape = rect_shape
	collision.position = Vector2(0, 0)
	bridge.add_child(collision)
	
	# Bridge number label
	var label = Label.new()
	label.text = "%d" % (index + 1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(-8, -base_bridge_height / 2.0 - 20)
	label.name = "BridgeLabel"
	bridge.add_child(label)
	
	# Store width as metadata
	bridge.set_meta("bridge_index", index)
	bridge.set_meta("width", width)
	bridge.add_to_group("bridge")
	
	add_child(bridge)
	
	# Generate water below the gap (between this bridge and previous)
	if index > 0:
		var prev_bridge = bridges[index - 1]
		var gap_start = prev_bridge.global_position.x + prev_bridge.get_meta("width") / 2.0
		var gap_end = x_pos - width / 2.0
		var gap_center = (gap_start + gap_end) / 2.0
		var gap_width = gap_end - gap_start
		_create_water(gap_center, gap_width)
	
	return bridge

func _create_water(x_pos: float, gap_width: float):
	var water = Area2D.new()
	water.name = "Water"
	water.collision_layer = 4  # Water layer
	water.collision_mask = 1  # Detect Cat layer
	water.monitoring = true
	water.position = Vector2(x_pos, bridge_y_position + 40)
	water.set_meta("is_water", true)
	
	# Visual
	var water_visual = ColorRect.new()
	water_visual.color = Color(0.15, 0.4, 0.75, 0.8)
	water_visual.size = Vector2(gap_width, 300)
	water_visual.position = Vector2(-gap_width / 2.0, 0)
	water.add_child(water_visual)
	
	# Wave detail on top
	var wave = ColorRect.new()
	wave.color = Color(0.2, 0.5, 0.85, 0.6)
	wave.size = Vector2(gap_width, 8)
	wave.position = Vector2(-gap_width / 2.0, -4)
	water.add_child(wave)
	
	# Splash zones (small white highlights)
	for s in range(3):
		var splash = ColorRect.new()
		splash.color = Color(0.7, 0.85, 1.0, 0.4)
		splash.size = Vector2(gap_width * 0.2, 3)
		splash.position = Vector2(-gap_width / 2.0 + gap_width * (0.15 + s * 0.3), 2 + s * 6)
		water.add_child(splash)
	
	# Collision
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(gap_width, 300)
	collision.shape = rect_shape
	water.add_child(collision)
	
	# Connect body entered signal
	water.body_entered.connect(_on_water_body_entered)
	
	add_child(water)

func _on_water_body_entered(body: Node2D):
	if body.name == "Cat" and is_instance_valid(body):
		body.fall_in_water()

func _on_cat_fell_in_water():
	game_lost.emit()
	hud.show_message("The cat fell in the water! 😿\nPress R to retry", Color.RED)

func _on_cat_landed_on_bridge(bridge_node: Node2D):
	if bridge_node and bridge_node.has_meta("bridge_index"):
		var idx = bridge_node.get_meta("bridge_index")
		if idx > current_bridge_index:
			current_bridge_index = idx
			bridge_crossed.emit(idx + 1)
			hud.update_bridges_crossed(idx + 1, total_bridges + 1)
			
			if idx == total_bridges:
				game_won.emit()
				hud.show_message("The cat made it home! 🏠🐱\nYou crossed all %d bridges!" % (total_bridges + 1), Color.GREEN)

func _physics_process(_delta):
	if is_instance_valid(cat):
		# Smooth camera follow
		camera.global_position = camera.global_position.lerp(
			Vector2(cat.global_position.x, cat.global_position.y - 50),
			3.0 * _delta
		)
		camera.global_position.x = max(camera.global_position.x, cat.global_position.x - 100)
	
	# Reset
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
