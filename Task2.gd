extends Node2D

var tools_open = false
var story_open = false
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
		
func _on_sr_btn_toggled(button_pressed):
	if button_pressed && !sr_on:
		stopped = false
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
	elif sur.text == "":
		err.text = "Invalid Input: Enter a surname"
	elif group.get_pressed_button() == null:
		err.text = "Invalid Input: Select a gender"
	else:
		err.text = "Success!"
		err.set("theme_override_colors/font_color", Color(0.29,0.59,0.0))
		
		
