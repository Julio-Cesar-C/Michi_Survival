extends TextureRect


var upgrade = null
func _ready():
	if upgrade != null:
		$itemTexture.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
