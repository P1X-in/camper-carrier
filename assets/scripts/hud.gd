extends Control

onready var camp_hud = $"camp_management"

onready var beer_label = $"right/resources/beer/label"
onready var sausage_label = $"right/resources/sausage/label"

onready var smokescreen = $"right/bonuses/smokescreen"
onready var noisemaker = $"right/bonuses/noisemaker"
onready var boarding_party = $"right/bonuses/boarding"
onready var smokescreen_label = $"right/bonuses/smokescreen/label"
onready var noisemaker_label = $"right/bonuses/noisemaker/label"
onready var boarding_party_label = $"right/bonuses/boarding/label"

onready var hp_label = $"top/Label"

func show_camp_hud():
    camp_hud.show()

func hide_camp_hud():
    camp_hud.hide()

func update_resources_panel(sausage, beer):
    beer_label.set_value(beer)
    sausage_label.set_value(sausage)

func update_hp(current, hp):
    var hpstring = str(current) + "/" + str(hp) + " HP"
    get_node("top/Label").set_text(hpstring)
    
func update_kills(value):
    get_node("top/kills/Label").set_text(str(value).pad_zeros(2))
