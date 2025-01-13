extends CharacterBody2D

@onready var game: Node = %GameManager

const SPEED = 230.0
const JUMP_VELOCITY = -400.0
const SHOOT_SPEED = 600.0


@export var freq:float = 1.0
@export_range(0,PI/3) var amp:float = 0.0
@export var swing_speed:float = 3.0
@export var reel_speed:float = 100.0

var theta:float = 0.0
var origin:Vector2 = Vector2(0,0)

var grapple_instance:Node
var web_length = 48

var fired:bool = false

var swinging:bool = false

var unattached:bool = false
var unattached_frames:int = 0

var forward = true

var jumps = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var reeling_in:bool = false
var reeling_out:bool = false

func _physics_process(delta: float) -> void:
	#print("Jumps: " + str(jumps))
	
	if swinging:
		if game.swinging_unlocked:
			var swing_direction = Input.get_axis("ui_left", "ui_right")
			
			if swing_direction != 0:
				amp = max(min(amp*1.5, PI/2),0.1)
				swing_speed = min(swing_speed + 0.05, 4)
			
			if swing_direction > 0 and not forward:
				forward = true
				amp = max(min(amp*1.5, PI/2),0.1)
				swing_speed = min(swing_speed + 0.05, 4)
				
			if swing_direction < 0 and forward:
				forward = false
				amp =  max(min(amp*1.5, PI/2),0.1)
				swing_speed = min(swing_speed + 0.05, 4)
				
			if swing_direction == 0:
				#amp *= .8
				pass
				
		if theta <= amp and forward:
			theta += .02*swing_speed
			
			if theta > amp:
				forward = false
				theta -=.02*swing_speed
				if not game.swinging_unlocked:
					amp *= 0.8
				else:
					amp *= 0.9
					
		elif theta >= -amp and not forward:
			theta -= .02*swing_speed
			
			if theta < -amp:
				forward = true
				theta +=.02*swing_speed
				if not game.swinging_unlocked:
					amp *= 0.8
				else:
					amp *= 0.9
					
				swing_speed *= .95
		
		if forward:
			animated_sprite_2d.flip_h = false
		elif not forward:
			animated_sprite_2d.flip_h = true
		#$AnimatedSprite2D.rotation = sin(theta*freq)*amp*amt
		if Input.is_action_just_released("ui_swing") and swinging:
			print("Not Swinging")
			swinging = false
			reeling_in = false
			reeling_out = false
			var grapple = get_parent().get_node("grapple")
			if(grapple):
				grapple.queue_free()
			unattached = true
		
		if game.reeling_unlocked:
			if Input.is_action_just_pressed("ui_reel") and not reeling_in:
				print("Reeling in")
				reeling_in = true
			
			if Input.is_action_just_pressed("ui_reelout") and not reeling_out:
				print("Reeling out")
				reeling_out = true
				
			if Input.is_action_just_released("ui_reel") and  reeling_in:
				print("Not Reeling in")
				reeling_in = false
				web_length = origin.distance_to(position) * 1.1
			if Input.is_action_just_released("ui_reelout") and  reeling_out:
				print("Not Reeling in")
				reeling_out = false
				web_length = origin.distance_to(position)
			
		if not reeling_in and not reeling_out:
			var newpositionx = web_length * sin(theta*freq) + origin.x
			var newpositiony = web_length * cos(theta*freq) + origin.y
			velocity.x = (newpositionx-position.x )*swing_speed
			velocity.y = (newpositiony-position.y )*swing_speed
		elif reeling_in:
			velocity.x = (origin.x-position.x)*delta * reel_speed
			velocity.y = (origin.y-position.y)*delta * reel_speed
		elif reeling_out:
			if origin.distance_to(position) < game.max_web_range:
				velocity.x = (origin.x-position.x)*delta * -reel_speed
				velocity.y = (origin.y-position.y)*delta * -reel_speed
			else:
				velocity.x = 0
				velocity.y = 0
		if Input.is_action_just_pressed("ui_accept"):
			print("Velocity y at jump is: " + str(velocity.y))
			velocity.y = min(velocity.y,0) * 1.1 + JUMP_VELOCITY	
			print("jump velocity is: " + str(velocity.y))
			jumps -=1
			print("Not Swinging")
			swinging = false
			reeling_in=false
			var grapple = get_parent().get_node("grapple")
			grapple.queue_free()
			unattached = true
		
	else:
		
		# Add the gravity.
		if fired:
			if (position.distance_to(grapple_instance.position) > game.max_web_range):
				print("range exceeded")
				fired = false
				$BulletTimer.stop()
				var grapple = get_parent().get_node("grapple")
				grapple.queue_free()
				
			if grapple_instance.sleeping:
				amp = max(max(PI/3 * abs(velocity.normalized().x)/0.6,PI/3 * abs(velocity.normalized().y)/0.9), PI/4)
				print("Velocity x nomalized is: " + str(velocity.normalized().x))
				print("Amplitude is: " + str(amp))
				print("Scale factor is " + str(max(PI/3 * abs(velocity.normalized().x)/0.6,PI/3 * abs(velocity.normalized().y)/0.9)))
				swing_speed = max(1.5 * max(PI/3 * abs(velocity.normalized().x)/0.3,PI/3 * abs(velocity.normalized().y)/0.5),3.2)
				print("Swing speed is: " + str(swing_speed))
				web_length = origin.distance_to(position) * 1.1
				if origin.x < position.x:
					forward = false
					theta = amp
					theta = amp/2
				if origin.x > position.x:
					forward = true
					theta = -amp
					theta = -amp/2
				fired = false
				swinging = true
				$BulletTimer.stop()
		if not is_on_floor():
			velocity += get_gravity() * delta
			animated_sprite_2d.play("jump")

	# Handle jump.
		if is_on_floor():
			jumps = 1
			if game.double_jump_unlocked:
				jumps = 2
		if Input.is_action_just_pressed("ui_accept") and jumps >= 1:
			velocity.y = JUMP_VELOCITY
			jumps-=1
		
		
		if (Input.is_action_just_pressed("ui_swing") and not swinging) and game.grapple_unlocked:
			
			jumps = 1
			if game.double_jump_unlocked:
				jumps = 2
			
			
			
			#velocity.y = 0
			#velocity.x = 0
			origin = get_global_mouse_position()
			print("around " + str(origin))
			var grapple_point_packed = load("res://scenes/grapple_point.tscn")
			grapple_instance = grapple_point_packed.instantiate()
			grapple_instance.set_name("grapple")
			add_sibling(grapple_instance)
			grapple_instance.position = position
			grapple_instance.apply_impulse((origin-position).normalized()*SHOOT_SPEED)
			print("Fired")
			fired = true
			$BulletTimer.start()
			print("Timer Started")
			
			
				
		
		if (Input.is_action_just_pressed("ui_reel") and not swinging) and game.reeling_unlocked:
			
			jumps = 1
			if game.double_jump_unlocked:
				jumps = 2
			
			
			
			web_length = origin.distance_to(position) * 1.1
			print("Reeling")
			swinging = true
			reeling_in = true
			#velocity.y = 0
			#velocity.x = 0
			
			print("toward " + str(origin))
			var grapple_point_packed = load("res://scenes/grapple_point.tscn")
			grapple_instance = grapple_point_packed.instantiate()
			grapple_instance.set_name("grapple")
			add_sibling(grapple_instance)
			grapple_instance.position = origin
				
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		
		if direction > 0:
			animated_sprite_2d.flip_h = false
		elif direction < 0:
			animated_sprite_2d.flip_h = true
		
		if direction==0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
		
		if not unattached:	
			if direction:
				velocity.x = direction * SPEED
			else:
				if is_on_floor():
					velocity.x = move_toward(velocity.x, 0, SPEED)
		else :
			velocity.x = get_real_velocity().x * 1.01
			if unattached_frames > 10:
				unattached = false
				unattached_frames = 0
				print("no longer uattached")
			else:
				unattached_frames+=1
	move_and_slide()


func _on_bullet_timer_timeout() -> void:
	print("Timeout")
	fired = false
	$BulletTimer.stop()
	var grapple = get_parent().get_node("grapple")
	grapple.queue_free()
	
