extends CharacterBody3D

const MOVE_SPEED = 2
const DATA_DIR = "res://data/"
const TUNING_FILE = "tuning.json"

@onready var raycast = $RayCast3D
@onready var anim_player = $AnimationPlayer

var player = null
var dead = false

func _ready():
	anim_player.play("walk")
	add_to_group("zombies")

func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
	
	var vec_to_player = player.position - position
	vec_to_player = vec_to_player.normalized()
	# raycast.cast_to = vec_to_player * 1.5
	raycast.target_position = vec_to_player * 1.5
	
	move_and_collide(vec_to_player * MOVE_SPEED * delta)
	
	if raycast.is_colliding():
		var coll = raycast.get_collider()
		if coll != null and coll.name == "Player":
			coll.kill()
			
func kill():
	var limits = JsonHelper.key_value(DATA_DIR, TUNING_FILE, "limits")
	var drop_rates = JsonHelper.key_value(DATA_DIR, TUNING_FILE, "enemies")
	
	if PlayerStat.level <= limits["level_cap"]:
		if PlayerStat.level >= 4 and PlayerStat.level <= limits["level_cap"]:
			PlayerStat.experience += drop_rates["gang_med"]["xp_drop"]
			PlayerStat.influence += drop_rates["gang_med"]["inf_drop"]
		else:
			PlayerStat.experience += drop_rates["gang_easy"]["xp_drop"]
			PlayerStat.influence += drop_rates["gang_easy"]["inf_drop"]
		
	dead = true
	$CollisionShape3D.disabled = true
	anim_player.play("die")

func set_player(p):
	player = p
