extends Control

@onready var a = $Container/a
@onready var b = $Container/b
@onready var c = $Container/c
@onready var d = $Container/d
@onready var e = $Container/e
@onready var f = $Container/f
@onready var g = $Container/g
@onready var h = $Container/h
@onready var i = $Container/i
@onready var buttons = [a,b,c,d,e,f,g,h,i]
@onready var control_konec = $ControlKonec
@onready var label_konec = $ControlKonec/CenterContainer/BoxContainer/LabelKonec

enum states { PRAZNO, X, O }
var stanje = [states.PRAZNO, states.PRAZNO, states.PRAZNO,
			  states.PRAZNO, states.PRAZNO, states.PRAZNO,
			  states.PRAZNO, states.PRAZNO, states.PRAZNO]

var je_na_vrsti_x = true   # x je človek
var igra_koncana = false

const ZMAGOVALNE_LINIJE = [
	[0,1,2], [3,4,5], [6,7,8],   # vrstice
	[0,3,6], [1,4,7], [2,5,8],   # stolpci
	[0,4,8], [2,4,6]             # diagonale
]


func _ready():
	for button in buttons:
		button.pressed.connect(on_press.bind(button.get_meta("moj_id")))
	osvezi()


func on_press(id):
	if igra_koncana or not je_na_vrsti_x or stanje[id] != states.PRAZNO:
		return
	
	stanje[id] = states.X
	je_na_vrsti_x = false
	osvezi()
	
	if preveri_konec():
		return
	
	# timer za namerni "lag" pred potezo računalnika
	await get_tree().create_timer(0.25).timeout
	naredi_ai_potezo()


func naredi_ai_potezo():
	var najboljsa_vrednost = -INF
	var najboljsa_poteza = -1
	
	for i in 9:
		if stanje[i] == states.PRAZNO:
			stanje[i] = states.O
			# potezo človeka (x) minimiziramo
			var vrednost = minimax(stanje, false)
			stanje[i] = states.PRAZNO
			
			if vrednost > najboljsa_vrednost:
				najboljsa_vrednost = vrednost
				najboljsa_poteza = i
	
	if najboljsa_poteza != -1:
		stanje[najboljsa_poteza] = states.O
		je_na_vrsti_x = true
		osvezi()
		preveri_konec()


# minimax: AI (o) maksimizira, človek (x) minimizira
func minimax(s, je_max: bool) -> int:
	var zmag = dobi_zmagovalca(s)
	if zmag == states.O:
		return 10
	elif zmag == states.X:
		return -10
	elif not s.has(states.PRAZNO):
		return 0
	
	if je_max:
		var najboljsi = -INF
		for i in 9:
			if s[i] == states.PRAZNO:
				s[i] = states.O
				najboljsi = max(najboljsi, minimax(s, false))
				s[i] = states.PRAZNO
		return najboljsi
	else:
		var najboljsi = INF
		for i in 9:
			if s[i] == states.PRAZNO:
				s[i] = states.X
				najboljsi = min(najboljsi, minimax(s, true))
				s[i] = states.PRAZNO
		return najboljsi


func dobi_zmagovalca(s):
	for linija in ZMAGOVALNE_LINIJE:
		if s[linija[0]] != states.PRAZNO \
		and s[linija[0]] == s[linija[1]] \
		and s[linija[1]] == s[linija[2]]:
			return s[linija[0]]
	return null


func preveri_konec() -> bool:
	var zmag = dobi_zmagovalca(stanje)
	if zmag == states.X:
		igra_koncana = true
		label_konec.text = "Zmagal si!"
		control_konec.visible = true
		return true
	elif zmag == states.O:
		igra_koncana = true
		label_konec.text = "Računalnik je zmagal"
		control_konec.visible = true
		return true
	elif not stanje.has(states.PRAZNO):
		igra_koncana = true
		label_konec.text = "Neodločeno"
		control_konec.visible = true
		return true
	return false

func osvezi():
	for i in 9:
		if stanje[i] == states.O:
			buttons[i].text = "O"
		elif stanje[i] == states.X:
			buttons[i].text = "X"
		else:
			buttons[i].text = ""

func _on_button_ponovi_pressed():
	get_tree().reload_current_scene()
