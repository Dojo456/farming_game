@tool
class_name MainCharacter
extends CharacterBody2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle_timer: Timer = $Timer
@onready var item_sprite: Sprite2D = $AnimatedSprite2D/ItemSprite

@export var speed = 16

var dir: String = "d"
var idle: bool = false
@export var editor_disable_idle: bool = true

## @deprecated: Do not use, use GameState.active_item instead
var holding_item: Item:
	get():
		return GameState.active_item

func show_holding_item():
	# TODO: items will have a "show while holding" attribute to be added to replace the always true
	if not self.holding_item or true:
		return
		
	if self.idle:
		item_sprite.texture = null
		return
		
	print(self.holding_item)
		
	var sprite_to_show = null
	var flipped = false
	var offset = Vector2.ZERO
	var behind = false
	
	if self.dir == "l":
		sprite_to_show = holding_item.left_sprite
		offset = Vector2(-8, 2)
		behind = true
	elif self.dir == "r":
		sprite_to_show = holding_item.left_sprite
		flipped = true
		offset = Vector2(8, 2)
	elif self.dir == "u":
		sprite_to_show = holding_item.up_sprite
		offset = Vector2(5, -8)
		behind = true
	elif self.dir == "d":
		sprite_to_show = holding_item.down_sprite
		offset = Vector2(-5, 8)
	
	item_sprite.texture = sprite_to_show
	item_sprite.flip_h = flipped
	item_sprite.position = offset
	item_sprite.show_behind_parent = behind

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
@onready var temp_animation_sprite: AnimatedSprite2D = $TempAnimationSprite2D

var showing_temp_animation = false

func play_sprite_frame_once(sprite_frame: SpriteFrames, animation: String):
	temp_animation_sprite.sprite_frames = sprite_frame
	print(sprite_frame.get_animation_speed(animation))
	sprite_frame.set_animation_loop(animation, false)
	temp_animation_sprite.play(animation)
	temp_animation_sprite.show()
	sprite.hide()
	showing_temp_animation = true
	await temp_animation_sprite.animation_finished
	
func _on_temp_animation_sprite_2d_animation_finished() -> void:
	temp_animation_sprite.hide()
	sprite.show()
	showing_temp_animation = false

func show_character_animation(move_dir: Vector2):
	# If is moving
	if not move_dir.is_zero_approx():
		# Set idle timer to 0
		self.idle_timer.start()
		self.idle = false
		
		if move_dir.y != 0:
			self.dir = "d" if move_dir.y > 0 else "u"
		if move_dir.x != 0:
			self.dir = "r" if move_dir.x > 0 else "l"
		
		# Update animation based on if moving and dir
		var animation = "move_" + self.dir
		self.sprite.play(animation)
	else: # Set idle animation and control play pause		
		var animation = "idle_" + self.dir
		self.sprite.animation = animation
		
		if self.idle:
			self.sprite.play()
		else:
			self.sprite.pause()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if self.showing_temp_animation:
		return
	
	var move_dir = Input.get_vector("move_l", "move_r", "move_u", "move_d")
	
	var moving = move_dir != Vector2.ZERO
	
	# Move and slide based on input dir
	self.velocity = move_dir.normalized() * self.speed
	self.move_and_slide()
	
	self.show_character_animation(move_dir)
	
	self.show_holding_item()

func _on_timer_timeout() -> void:
	self.idle = true
	print("timed out")
