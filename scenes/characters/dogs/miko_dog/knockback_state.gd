extends CharacterKnockbackState

const PICHUUUN_SOUND: AudioStream = preload("res://scenes/characters/dogs/miko_dog/se_pldead00.wav")

func enter(data: Dictionary) -> void:
	super.enter(data)
	
	if character.health <= 0:
		AudioPlayer.play_in_battle_sfx(PICHUUUN_SOUND)
		
