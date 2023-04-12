extends Node2D

var tools_open = false
var story_open = false
var cars = []
var penguin_speech = null
var penguin_file = "res://assets/script/penguin_lines"
var penguin_counter = 0
var penguin_msgs = []
var task_frozen = true
var tools = null
var fixed = false
var sr_on = false
var tools_opened = true
var stopped = false

func _ready():
	load_file(penguin_file)
	penguin_speech = get_node("PenguinSpeech")
	tools = get_node("Tools")
	talk_penguin()

func load_file(file):
	var f = FileAccess.open(file, FileAccess.READ)
	while !f.eof_reached():
		var split = f.get_line().split("|")
		penguin_msgs.push_back([split[0],int(split[1])])
	f.close()

func _on_ToolsBtn_pressed():
	
	if !tools_opened:
		talk_penguin()
		tools_opened = true
	
	var button = tools.get_node("ToolsBtn")
	var animation = tools.get_node("ToolsAnimation")
	button.disabled = true
	if(tools_open):
		animation.play("MoveUp")
	else:
		animation.play("MoveDown")
	await animation.animation_finished
	button.disabled = false
	tools_open = !tools_open

func _on_StoryBtn_pressed():
	var button = get_node("StoryBtn")
	var animation = get_node("StoryAnimation")
	button.disabled = true
	if(story_open):
		animation.play("MoveDown")
	else:
		animation.play("MoveUp")
	await animation.animation_finished
	button.disabled = false
	story_open = !story_open
	
func spawn_cars():
	for car in cars:
		car.visible = true
	
func car_hovered(car):
	if !task_frozen:
		var animator = car.get_node("CarAnimator")
		animator.play("CarHovered")
	
func car_exited(car):
	if !task_frozen:
		var animator = car.get_node("CarAnimator")
		animator.play("RESET")

func car_pressed(car):
	if !task_frozen:
		var sprite = car.get_node("Sprite2D")
		var animation = car.get_node("CarAnimator")
		var penguin = get_node("Penguin")
	
		for btn in cars:
			btn.disabled = true
		if sprite.frame % 4 == 0:
			animation.play("Correct")
			talk_penguin(4)
			task_frozen = true
		else:
			animation.play("Incorrect")
			talk_penguin(5)
		await animation.animation_finished
		penguin.frame = 0
		for btn in cars:
			btn.disabled = false
		
		animation.play("RESET")
	
func talk_penguin(line = 0):
	var msg_box = penguin_speech.get_node("Message")
	var penguin = get_node("Penguin")
	
	if !line:
		msg_box.text = penguin_msgs[penguin_counter][0]
		penguin.frame = penguin_msgs[penguin_counter][1]
	else:
		msg_box.text = penguin_msgs[line][0]
		penguin.frame = penguin_msgs[line][1]
	penguin_speech.visible = true
	
	if task_frozen:
		penguin_counter += 1

func silence_penguin():
	penguin_speech.visible = false
	if task_frozen && tools_opened:
		penguin_counter += 1

func _on_PenguinSpeech_pressed():
	if task_frozen && penguin_counter < penguin_msgs.size() && tools_opened:
		talk_penguin()
	else:
		silence_penguin()

func _on_Car1_mouse_entered():
	if !cars[0].disabled:
		car_hovered(cars[0])
	
func _on_Car1_mouse_exited():
	if !cars[0].disabled:
		car_exited(cars[0])

func _on_Car2_mouse_entered():
	if !cars[1].disabled:
		car_hovered(cars[1])

func _on_Car2_mouse_exited():
	if !cars[1].disabled:
		car_exited(cars[1])

func _on_Car3_mouse_entered():
	if !cars[2].disabled:
		car_hovered(cars[2])

func _on_Car3_mouse_exited():
	if !cars[2].disabled:
		car_exited(cars[2])

func _on_Car4_mouse_entered():
	if !cars[3].disabled:
		car_hovered(cars[3])

func _on_Car4_mouse_exited():
	if !cars[3].disabled:
		car_exited(cars[3])
		
func _on_sr_btn_toggled(button_pressed):
	if button_pressed && !sr_on:
		stopped = false
	else:
		stopped = true
		DisplayServer.tts_stop()
