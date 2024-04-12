class_name MapTutorialDog extends TutorialDog

var _team_setup_button: Button
func get_team_setup_button(): return _team_setup_button

func setup(team_setup_button: Button) -> void:
	_team_setup_button = team_setup_button
