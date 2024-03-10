extends Node2D

var save_file_path = "user://save/"
var save_file_name = "user_stats.tres"
var stats_res


func _ready():
	$Sprite2D.material.set_shader_parameter("speed", .01)
	$Sprite2D.material.set_shader_parameter("dot_size", .1)
	
	# make a directory on computer for save data. please note I know this is unsafe. It's not a concern for a project this small though
	DirAccess.make_dir_absolute(save_file_path)
	stats_res = ResourceLoader.load(save_file_path + save_file_name)
	# check if null
	if stats_res == null:
		stats_res = StatsResource.new()
		
	else:
		update_labels()

func _input(event):
	if event.is_action_pressed("click"):
		$Click.play()

func update_labels():
		if stats_res.goal_amount > 0:
			%GoalAmount.text = str(stats_res.goal_amount)
		else:
			%GoalAmount.text = ""
		%GoalUnits.text = stats_res.goal_units
		%GoalName.text = stats_res.goal_name
		if stats_res.total_amount_done > 0:
			%TotalDoneAmount.text = str(stats_res.total_amount_done)
		else:
			%TotalDoneAmount.text = ""
		%UnchangingUnitsLabel.text = stats_res.goal_units + "."
		%UnchangingUnitsLabel2.text = stats_res.goal_units + "."
		if stats_res.goal_amount > stats_res.total_amount_done:
			%AmountLeftLabel.text = "I have " + str(stats_res.goal_amount - stats_res.total_amount_done) + " " + stats_res.goal_units + " left."
		else:
			if stats_res.goal_amount > 0:
				%AmountLeftLabel.text = "Great job! You did it!"

func _on_goal_amount_text_submitted(new_text):
	new_text = int(new_text)
	if new_text == 0:
		stats_res.goal_amount = new_text
		%GoalAmount.text = ""
		ResourceSaver.save(stats_res, save_file_path + save_file_name)
	else:
		stats_res.goal_amount = new_text
		ResourceSaver.save(stats_res, save_file_path + save_file_name)
		update_labels()


func _on_goal_units_text_submitted(new_text):
	stats_res.goal_units = new_text
	ResourceSaver.save(stats_res, save_file_path + save_file_name)
	update_labels()

func _on_goal_name_text_submitted(new_text):
	stats_res.goal_name = new_text
	ResourceSaver.save(stats_res, save_file_path + save_file_name)
	update_labels()

func _on_total_done_amount_text_submitted(new_text):
	stats_res.total_amount_done = float(new_text)
	ResourceSaver.save(stats_res, save_file_path + save_file_name)
	update_labels()

func _on_today_done_amount_text_submitted(new_text):
	stats_res.total_amount_done += float(new_text)
	ResourceSaver.save(stats_res, save_file_path + save_file_name)
	update_labels()
	%TodayDoneAmount.text = ""


func _update_all_stats_resource():
	
	if float(%GoalAmount.text) == 0:
		stats_res.goal_amount = %GoalAmount.text
		%GoalAmount.text = ""
		ResourceSaver.save(stats_res, save_file_path + save_file_name)
	else:
		stats_res.goal_amount = %GoalAmount.text
		ResourceSaver.save(stats_res, save_file_path + save_file_name)
	
	stats_res.goal_units = %GoalUnits.text
	
	stats_res.goal_name = %GoalName.text
	stats_res.total_amount_done = %TotalDoneAmount.text
	
	stats_res.total_amount_done += float(%TodayDoneAmount.text)
	%TodayDoneAmount.text = ""
	
	if stats_res.goal_amount > stats_res.total_amount_done:
		%AmountLeftLabel.text = "I have " + str(stats_res.goal_amount - stats_res.total_amount_done) + " " + stats_res.goal_units + " left."
	else:
		if stats_res.goal_amount > 0:
			%AmountLeftLabel.text = "Great job! You did it!"
		else:
			%AmountLeftLabel.text = ""
	ResourceSaver.save(stats_res, save_file_path + save_file_name)
	update_labels()





func _on_close_button_pressed():
	_update_all_stats_resource()
	get_tree().quit()


