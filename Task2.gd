extends Node2D

var tools_open = false
var story_open = false
var helpers = []
var penguin_speech = null
var persona_speech = null
var penguin_file = "res://assets/script/script"
var script_counter = 0
var msgs = []
var task_frozen = true
var tools = null
var fixed = false
var sr_on = false
var sr_clicked = false
var tools_opened = true
var video_playing = false
var stopped = false

func _ready():
	load_file(penguin_file)
	penguin_speech = get_node("PenguinSpeech")
	persona_speech = get_node("PersonaSpeech")
	tools = get_node("Tools")
	script_counter = 37
	talk()

func load_file(file):
	var f = FileAccess.open(file, FileAccess.READ)
	while !f.eof_reached():
		var split = f.get_line().split("|")
		msgs.push_back([split[0],int(split[1])])
	f.close()

func _on_ToolsBtn_pressed():
	
	if !tools_opened:
		talk()
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
	
func read_form():
	
	var helper = get_node("TaskContainer/sr_help")
	
	var voices = DisplayServer.tts_get_voices_for_language("en")
	var voice_id = voices[3]
	
	sr_on = true
	
	if !sr_clicked:
		sr_clicked = true
		
	helper.visible = true
		
	helper.position = Vector2(249,81)
	helper.size = Vector2(336,47)
	if !fixed:
		DisplayServer.tts_speak("text box", voice_id)
	else:
		DisplayServer.tts_speak("first name. edit text", voice_id)
	
	var t = Timer.new()
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	await t.timeout
	
	helper.position = Vector2(249,134)
	if !fixed:
		DisplayServer.tts_speak("text box", voice_id)
	else:
		DisplayServer.tts_speak("surname. edit text", voice_id)
	
	t.start()
	await t.timeout
	
	if fixed:
		helper.position = Vector2(165,216)
		helper.size = Vector2(203,113)
		DisplayServer.tts_speak("gender button group", voice_id)
		
		t.start()
		await t.timeout
	
	helper.position = Vector2(168,220)
	helper.size = Vector2(30,30)
	if !fixed:
		DisplayServer.tts_speak("radio button", voice_id)
	else:
		DisplayServer.tts_speak("male. radio button unselected", voice_id)
		
	
	t.start()
	await t.timeout
	
	helper.position = Vector2(168,257)
	if !fixed:
		DisplayServer.tts_speak("radio button", voice_id)
	else:
		DisplayServer.tts_speak("female. radio button unselected", voice_id)
	
	t.start()
	await t.timeout
	
	helper.position = Vector2(168,294)
	if !fixed:
		DisplayServer.tts_speak("radio button", voice_id)
	else:
		DisplayServer.tts_speak("other. radio button unselected", voice_id)
	
	t.start()
	await t.timeout
	
	helper.position = Vector2(155,350)
	helper.size = Vector2(112,44)
	if !fixed:
		DisplayServer.tts_speak("button", voice_id)
	else:
		DisplayServer.tts_speak("submit. button", voice_id)
	
	t.start()
	await t.timeout
	helper.visible = false
		
	sr_on = false
	
	if script_counter == 59 || script_counter == 66:
		talk()
		
func form_state(is_active):
	var fn_box = get_node("TaskContainer/fn_box")
	var sn_box = get_node("TaskContainer/sn_box")
	var male_cb = get_node("TaskContainer/male_cb")
	var female_cb = get_node("TaskContainer/female_cb")
	var other_cb = get_node("TaskContainer/other_cb")
	var submit = get_node("TaskContainer/submit_button")
	
	task_frozen = !is_active
	fn_box.editable = is_active
	sn_box.editable = is_active
	male_cb.disabled = !is_active
	female_cb.disabled = !is_active
	other_cb.disabled = !is_active
	submit.disabled = !is_active
	
	fn_box.text = ""
	sn_box.text = ""
	male_cb.button_pressed = false
	female_cb.button_pressed = false
	other_cb.button_pressed = false
	
func talk(line = 0):
	var penguin_box = penguin_speech.get_node("Message")
	var penguin = get_node("Penguin")
	var persona_box = persona_speech.get_node("Message")
	var persona_ani = get_node("Persona/PersonaAnimator")
	
	if script_counter == 41:
		form_state(true)
	elif script_counter == 46:
		persona_ani.play("enter")
	elif script_counter == 53:
		get_node("TaskContainer/err_label").visible = false
		get_node("Blur").visible = true
	elif script_counter == 57:
		tools_opened = false
		get_node("Tools").visible = true
	elif script_counter == 58:
		get_node("Tools/SR_btn").disabled = false
		persona_ani.play("join")
	elif script_counter == 59:
		if !sr_clicked:
			penguin_speech.visible = false
			persona_speech.visible = false
		else:
			persona_ani.play("leave")
	elif script_counter == 64:
		persona_ani.play("join")
	elif script_counter == 65:
		penguin_speech.visible = false
		video_playing = true
		var vid = get_node("Task2_Fix")
		var bg = get_node("fade_bg")
		bg.visible = true
		vid.visible = true
		vid.play()
		await vid.finished
		bg.visible = false
		video_playing = false
		vid.visible = false
		fixed = true
		sr_clicked = false
	elif script_counter == 66:
		if !sr_clicked:
			penguin_speech.visible = false
			persona_speech.visible = false
		else:
			persona_ani.play("leave")
	elif script_counter == 73:
		persona_ani.play("exit")
	
	if script_counter != 59 || sr_clicked:
		if script_counter != 66 || sr_clicked:
			if !line:
				var msg = msgs[script_counter][0]
				if msg[0] == "*":
					persona_speech.visible = false
					msg = msg.right(msg.length()-1)
					penguin_box.text = msg
					penguin.frame = msgs[script_counter][1]
					penguin_speech.visible = true
				elif msg[0] == "^":
					penguin_speech.visible = false
					msg = msg.right(msg.length()-1)
					persona_box.text = msg
					persona_speech.visible = true
				else:
					msg = "Error. Line not assigned to character."
					penguin_box.text = msg
					persona_box.text = msg
					persona_speech.visible = true
					penguin_speech.visible = true
			else:
				var msg = msgs[line][0]
				if msg[0] == "*":
					persona_speech.visible = false
					msg = msg.right(msg.length()-1)
					penguin_box.text = msg
					penguin.frame = msgs[line][1]
					penguin_speech.visible = true
				elif msg[0] == "^":
					penguin_speech.visible = false
					msg = msg.right(msg.length()-1)
					persona_box.text = msg
					persona_speech.visible = true
				else:
					msg = "Error. Line not assigned to character."
					penguin_box.text = msg
					persona_box.text = msg
					persona_speech.visible = true
					penguin_speech.visible = true
			
			if task_frozen && !video_playing:
					script_counter += 1

func silence():
	penguin_speech.visible = false
	persona_speech.visible = false
	if task_frozen && tools_opened && !sr_on:
		script_counter += 1

func _on_Speech_pressed():
	if task_frozen && script_counter < msgs.size() && tools_opened && !sr_on && !video_playing:
		talk()
	elif script_counter == 74:
		get_tree().change_scene_to_file("res://title_screen.tscn")
	else:
		silence()
		
func _on_sr_btn_toggled(button_pressed):
	if button_pressed && !sr_on:
		stopped = false
		read_form()
	else:
		stopped = true
		DisplayServer.tts_stop()

func _on_submit_button_pressed():
	var first = get_node("TaskContainer/fn_box")
	var sur = get_node("TaskContainer/sn_box")
	var err = get_node("TaskContainer/err_label")
	
	var group = get_node("TaskContainer/male_cb").button_group
	
	if first.text == "":
		err.text = "Invalid Input: Enter a first name"
		talk(42)
	elif sur.text == "":
		err.text = "Invalid Input: Enter a surname"
		talk(42)
	elif group.get_pressed_button() == null:
		err.text = "Invalid Input: Select a gender"
		talk(42)
	else:
		err.text = "Success!"
		err.set("theme_override_colors/font_color", Color(0.29,0.59,0.0))
		talk(43)
		script_counter = 44
		form_state(false)
