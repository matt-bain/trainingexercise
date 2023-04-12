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
	
	cars = [get_node("Car1"),
			get_node("Car2"),
			get_node("Car3"),
			get_node("Car4")]
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

func random_order(set_num):
	var sets = [[0,1,2,3],[4,5,6,7],[8,9,10,11]]
	var car_set = sets[set_num]
	while (car_set[0] % 4 == 0):
		randomize()
		car_set.shuffle()
	
	for i in 4:
		cars[i].get_node("Sprite2D").frame = car_set[i]

func _on_Car1_pressed():
	car_pressed(cars[0])

func _on_Car2_pressed():
	car_pressed(cars[1])

func _on_Car3_pressed():
	car_pressed(cars[2])

func _on_Car4_pressed():
	car_pressed(cars[3])
	
func read_cars():
	# One-time steps.
	# Pick a voice. Here, we arbitrarily pick the first English voice.
	var voices = DisplayServer.tts_get_voices_for_language("en")
	var voice_id = voices[3]
	
	sr_on = true

	for car in cars:
		var sprite = car.get_node("Sprite2D")
		var helper = car.get_node("SRHelper")
		
		if stopped:
			helper.visible = false
			sr_on = false
			break
		
		helper.visible = true
		if fixed == false:
			DisplayServer.tts_speak("image - car", voice_id)
		elif sprite.frame == 0 || sprite.frame == 4:
			DisplayServer.tts_speak("image - red car", voice_id)
		elif sprite.frame == 1 || sprite.frame == 5:
			DisplayServer.tts_speak("image - green car", voice_id)
		elif sprite.frame == 2 || sprite.frame == 6:
			DisplayServer.tts_speak("image - blue car", voice_id)
		elif sprite.frame == 3 || sprite.frame == 7:
			DisplayServer.tts_speak("image - yellow car", voice_id)
		var t = Timer.new()
		t.set_wait_time(2)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		await t.timeout
		helper.visible = false
		
	sr_on = false
	
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
	
	if penguin_counter == 3:
		spawn_cars()
		task_frozen = false
		penguin_counter = 6
	elif penguin_counter == 10:
		random_order(1)
	elif penguin_counter == 18:
		tools_opened = false
		get_node("Tools").visible = true
	elif penguin_counter == 20:
		get_node("Tools/SR_btn").disabled = false
	elif penguin_counter == 24:
		fixed = true
	
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
		read_cars()
	else:
		stopped = true
		DisplayServer.tts_stop()
