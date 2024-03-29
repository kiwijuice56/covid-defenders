extends Area2D

export var drop := 10
export var slowed := false setget set_slowed
export var health := 0 setget set_health
export var speed := .5
export var damage := 3
var path := []
var dying := false

onready var main = get_tree().get_root().get_child(0)

func set_slowed(new_slowed):
	slowed = true
	$Timer.start(2)
	yield($Timer, "timeout")
	slowed = false
	modulate = Color(1, 1, 1)

func set_health(new_health):
	if health < new_health:
		health = new_health
		return
	if dying: return
	health = new_health
	$AnimationPlayer.current_animation = "hurt"
	$AudioStreamPlayer2D.playing = true
	if health <= 0:
		dying = true
		main.cash += drop
		$AnimationPlayer.current_animation = "die"
		yield($AnimationPlayer, "animation_finished")
		get_parent().remove_child(self)
		queue_free()

func at_point():
	if len(path)-1 == 0:
		set_physics_process(false)
		main.life -= damage
		get_parent().remove_child(self)
		queue_free() #it escaped! decrease health
	path.pop_front()

func _physics_process(delta):
	var vel = (path[0].global_position - global_position).normalized() * speed * delta
	global_position += vel * 0.5 if slowed else vel
