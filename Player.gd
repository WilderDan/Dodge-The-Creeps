extends Area2D

signal hit

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
# Add this variable to hold the clicked position.
var target = Vector2()
var shouldMoveToTarget

func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
func start(pos):
	position = pos
	# Initial target is the start position.
	target = pos
	shouldMoveToTarget = false
	show()
	$CollisionShape2D.disabled = false
	
# Change the target whenever a touch event happens.
func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target = event.position
		shouldMoveToTarget = true
	
func _process(delta):
	var velocity = Vector2()  # The player's movement vector.
	
	# Mouse/Touch controls
	if shouldMoveToTarget:
		if position.distance_to(target) > 10:
			velocity = target - position
		else:
			shouldMoveToTarget = false
	
	# Otherwise keyboard controls
	if Input.is_action_pressed("ui_right"):
	   velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
			
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
	# See the note below about boolean assignment
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
	$	AnimatedSprite.flip_v = velocity.y > 0
	
func _on_Player_body_entered(body):
	hide()  # Player disappears after being hit.
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)
