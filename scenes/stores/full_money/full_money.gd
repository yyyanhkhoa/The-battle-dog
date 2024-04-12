class_name StoreFullMoney extends Node2D


func store_setup(_dog_tower: DogTower,  player_data: BaseBattlefieldPlayerData):
	Data.store["full_money"].amount -= 1
	

