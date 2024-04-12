class_name FSMState extends Node

signal transition (state_path: String, data: Dictionary)

func enter(_data: Dictionary) -> void:
	push_error("ERROR: Please define method 'enter', this method is called when the state is activated")
