class_name BaseSkill extends Node2D

## skill_user: the group that uses this skill.  
## Determine wether this skill is used by player tower or by enemy tower
func setup(skill_user: Character.Type) -> void:
	push_error("ERRORS: setup(skill_user: SkillUser, direction: Direction) not implemented")
