extends Resource
class_name StatsResource

@export var goal_amount: float
@export var goal_units: String
@export var goal_name: String
@export var total_amount_done: float

@export var current_streak: int
# this will be the timestamp of the last entry
# the timestamp will be how many days it's been since the unix epoch
@export var last_entry_daystamp: int
