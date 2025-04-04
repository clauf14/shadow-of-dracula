extends Control

@onready var healthBar = $HealthBar as ProgressBar
@onready var goldText = $GoldText as Label

# called when we take damage
func update_health_bar (curHp, maxHp):
	healthBar.value = (100 / maxHp) * curHp

# called when our gold changes
func update_gold_text (gold):
	goldText.text = "Gold: " + str(gold)
