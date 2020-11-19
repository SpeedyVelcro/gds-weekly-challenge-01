# Player.gd

extends KinematicBody2D

enum {
	STATE_IDLE,
	STATE_REWIND
}
var state = STATE_IDLE
var velocity = Vector2(0, 0)
var gravity = Vector2(0, 750)
var up_direction = Vector2(0, -1)
var walk_speed = 140
var jump_speed = 400
var transform_history = PoolVector2Array()
var transform_history_max_size = 200

func _ready():
	_on_state_enter(state)

func change_state(p_state):
	_on_state_exit(state)
	state = p_state
	_on_state_enter(p_state)

func _physics_process(delta):
	match state:
		STATE_IDLE:
			#if not is_on_floor():
			velocity += gravity * delta
			velocity.x = 0
			if Input.is_action_pressed("move_left"):
				velocity.x -= Input.get_action_strength("move_left") * walk_speed
			if Input.is_action_pressed("move_right"):
				velocity.x += Input.get_action_strength("move_right") * walk_speed
			if Input.is_action_just_pressed("jump"):
				if is_on_floor():
					velocity.y = -jump_speed
				else:
					print("Tried to jump when not on floor")
			#add_to_history(velocity)
			velocity = move_and_slide(velocity, up_direction)
			add_to_history(velocity)
		STATE_REWIND:
			var repeats = 4
			for i in range(repeats):
				if not transform_history.empty():
					velocity = transform_history[transform_history.size() - 1]
					transform_history.remove(transform_history.size() - 1)
					move_and_slide(velocity * -1, up_direction)
				else:
					change_state(STATE_IDLE)
					break
			

func _process(_delta):
	if Input.is_action_just_pressed("rewind"):
		change_state(STATE_REWIND)

func _on_state_enter(p_state):
	match p_state:
		STATE_IDLE:
			velocity = Vector2(0, 0)
		STATE_REWIND:
			pass

func _on_state_exit(p_state):
	match p_state:
		STATE_IDLE:
			pass
		STATE_REWIND:
			pass

func add_to_history(vel):
	transform_history.append(vel)
	while transform_history.size() > transform_history_max_size:
		transform_history.remove(0)
