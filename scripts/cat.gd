extends CharacterBody2D

# Cat player controller
# Can move left/right and jump with realistic physics

signal fell_in_water
signal landed_on_bridge(bridge: Node2D)

const GRAVITY: float = 800.0
const JUMP_FORCE: float = -480.0
const MOVE_SPEED: float = 200.0
const ACCELERATION: float = 2000.0
const FRICTION: float = 1500.0

var is_jumping: bool = false
var is_falling: bool = false
var on_ground: bool = false
var is_dead: bool = false
var jump_buffer_time: float = 0.15  # Allow jump input shortly before landing
var jump_buffer_timer: float = 0.0
var coyote_time: float = 0.1  # Allow jump shortly after leaving ground
var coyote_timer: float = 0.0

@onready var sprite: Node2D = $Sprite
@onready var animation_timer: Timer = $AnimationTimer

func _ready():
	animation_timer.wait_time = 0.1
	animation_timer.timeout.connect(_on_animation_timeout)

func _physics_process(delta):
	if is_dead:
		return
	
	# Apply gravity
	if not on_ground:
		velocity.y += GRAVITY * delta
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time
	
	# Handle jump buffering
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Input
	var input_dir = Input.get_axis("move_left", "move_right")
	
	# Horizontal movement with acceleration/friction
	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * MOVE_SPEED, ACCELERATION * delta)
		
		# Flip sprite based on direction
		if input_dir > 0:
			sprite.scale.x = 1.0
		else:
			sprite.scale.x = -1.0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	# Jump
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	
	if jump_buffer_timer > 0 and coyote_timer > 0:
		_jump()
		jump_buffer_timer = 0.0
	
	# Update states
	is_jumping = velocity.y < 0 and not on_ground
	is_falling = velocity.y > 0 and not on_ground
	
	# Move and slide
	var previous_y = global_position.y
	move_and_slide()
	
	# Check if we landed on something
	var was_on_ground = on_ground
	on_ground = is_on_floor()
	
	# Detect landing on a bridge
	if on_ground and not was_on_ground:
		_check_landed_on_bridge()
	
	# Update animation
	_update_animation(delta)
	
	# Check if fell too far (in water)
	if global_position.y > 600:
		fall_in_water()

func _jump():
	velocity.y = JUMP_FORCE
	on_ground = false
	_play_jump_animation()

func _check_landed_on_bridge():
	# Check what we're standing on by raycasting downward
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(0, 30),
		2  # Bridge collision layer (bit 2 = value 2)
	)
	query.exclude = [self.get_rid()]
	var result = space_state.intersect_ray(query)
	if result:
		var collider = result.collider
		if collider:
			# Walk up to find the bridge StaticBody2D
			var bridge_node = collider
			while bridge_node and not bridge_node.is_in_group("bridge") and bridge_node.get_parent():
				bridge_node = bridge_node.get_parent()
			if bridge_node and bridge_node.is_in_group("bridge"):
				landed_on_bridge.emit(bridge_node)

func fall_in_water():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	fell_in_water.emit()
	# Simple sink animation then free
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 60, 1.0)
	tween.tween_callback(queue_free)

func _play_jump_animation():
	sprite.modulate = Color.WHITE
	sprite.position.y = -8

func _update_animation(delta):
	if is_jumping:
		# Jump pose
		var jump_progress = abs(velocity.y) / JUMP_FORCE
		sprite.position.y = lerp(0, 8, jump_progress)
		sprite.modulate = Color.WHITE
	elif on_ground:
		# Idle/running animation
		if abs(velocity.x) > 10:
			# Bounce while running
			var bounce = sin(Time.get_ticks_msec() * 0.015) * 3
			sprite.position.y = -bounce
		else:
			sprite.position.y = 0
		# Reset color
		sprite.modulate = sprite.modulate.lerp(Color.WHITE, delta * 5)
	else:
		# Falling
		sprite.position.y = 0
		sprite.modulate = sprite.modulate.lerp(Color(0.8, 0.8, 0.8), delta * 2)

func _on_animation_timeout():
	pass
