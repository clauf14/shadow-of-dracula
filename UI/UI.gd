extends Control

@onready var healthBar = $HealthBar as ProgressBar
@onready var goldText = $GoldText as Label
@onready var princess_label = $PrincessLabel as Label  # Labelul trebuie să existe deja în scenă

func _ready():
	princess_label.visible = false
	
func update_health_bar (curHp, maxHp):
	healthBar.value = (100 / maxHp) * curHp

# called when our gold changes
func update_gold_text (gold):
	goldText.text = "Gold: " + str(gold)
