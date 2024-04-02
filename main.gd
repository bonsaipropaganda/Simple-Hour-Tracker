extends Node2D

var save_file_path = "user://save/"
var save_file_name = "user_stats.tres"
var stats_res


func _ready():
	# setup our background shader
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

	$Control/VBoxContainer/Control2/StreakLabel.text = "Streak: " + str(stats_res.current_streak)


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
	if float(new_text) > 0:
		$bonus.play()
	stats_res.total_amount_done += float(new_text)
	check_for_streak()
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


func check_for_streak():
	var current_days_since_epoch = get_current_days_since_epoch()
	# first we rule out that another entry is being made on the same day
	if current_days_since_epoch == stats_res.last_entry_daystamp:
		return
	# if the current day is one day after the last entry then we add one to our counter
	if current_days_since_epoch == stats_res.last_entry_daystamp + 1:
		stats_res.current_streak += 1
	
	else:
		# reset streak
		stats_res.current_streak = 0
	
	# create a timestamp overriding the current timestamp
	stats_res.last_entry_daystamp = current_days_since_epoch
	
	ResourceSaver.save(stats_res, save_file_path + save_file_name)


func get_current_days_since_epoch():
	# get current system time in sytem's time zone
	var current_datetime_dict = Time.get_datetime_dict_from_system(false)
	
	# convert this to unix time
	var seconds_since_epoch = Time.get_unix_time_from_datetime_dict(current_datetime_dict)
	# convert this time to days since unix epoch
	var days_since_epoch = seconds_since_epoch / 86400
	return days_since_epoch

func _on_close_button_pressed():
	_update_all_stats_resource()
	get_tree().quit()


