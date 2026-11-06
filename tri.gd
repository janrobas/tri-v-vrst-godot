extends Control

@onready var a = $Vbox/Container/a
@onready var b = $Vbox/Container/b
@onready var c = $Vbox/Container/c
@onready var d = $Vbox/Container/d
@onready var e = $Vbox/Container/e
@onready var f = $Vbox/Container/f
@onready var g = $Vbox/Container/g
@onready var h = $Vbox/Container/h
@onready var i = $Vbox/Container/i
@onready var buttons = [a,b,c,d,e,f,g,h,i]
@onready var control_konec = $ControlKonec
@onready var label_konec = $ControlKonec/CenterContainer/BoxContainer/LabelKonec
@onready var tezavnost_slider = $Vbox/Margin/HFlowContainer/Tezavnost

enum states { PRAZNO, X, O }
var stanje = [states.PRAZNO, states.PRAZNO, states.PRAZNO,
			  states.PRAZNO, states.PRAZNO, states.PRAZNO,
			  states.PRAZNO, states.PRAZNO, states.PRAZNO]

var je_na_vrsti_x = true   # x je človek
var igra_koncana = false

var verjetnost_napake = 0.0
var max_globina = 9

const ZMAGOVALNE_LINIJE = [
	[0,1,2], [3,4,5], [6,7,8],
	[0,3,6], [1,4,7], [2,5,8],
	[0,4,8], [2,4,6]
]


func _ready():
	for button in buttons:
		button.pressed.connect(on_press.bind(button.get_meta("moj_id")))
	nastavi_tezavnost(int(tezavnost_slider.value))
	osvezi()

func nastavi_tezavnost(level: int) -> void:
	match level:
		1:
			verjetnost_napake = 0.55
			max_globina = 2
		2:
			verjetnost_napake = 0.35
			max_globina = 3
		3:
			verjetnost_napake = 0.15
			max_globina = 6
		_:
			verjetnost_napake = 0.0
			max_globina = 9

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
	if randf() < verjetnost_napake:
		naredi_nakljucno_potezo()
		return
	
	var najboljsa_vrednost = -INF
	var najboljsa_poteza = -1
	
	for j in 9:
		if stanje[j] == states.PRAZNO:
			stanje[j] = states.O
			var v = minimax(stanje, false, 0)
			stanje[j] = states.PRAZNO
			
			if v > najboljsa_vrednost:
				najboljsa_vrednost = v
				najboljsa_poteza = j
	
	if najboljsa_poteza != -1:
		stanje[najboljsa_poteza] = states.O
		je_na_vrsti_x = true
		osvezi()
		preveri_konec()


func naredi_nakljucno_potezo():
	var prazna = []
	for j in 9:
		if stanje[j] == states.PRAZNO:
			prazna.append(j)
	if prazna.is_empty():
		return
	var p = prazna.pick_random()
	stanje[p] = states.O
	je_na_vrsti_x = true
	osvezi()
	preveri_konec()


# minimax z omejeno globino
func minimax(s, je_max: bool, globina: int) -> int:
	var zmag = dobi_zmagovalca(s)
	if zmag == states.O:
		return 10 - globina          # raje zmagaj hitro
	elif zmag == states.X:
		return -10 + globina         # raje izgubi pozno
	elif not s.has(states.PRAZNO) or globina >= max_globina:
		return 0                     # neodločeno ali dosežena max globina
	
	if je_max:
		var najboljsi = -INF
		for j in 9:
			if s[j] == states.PRAZNO:
				s[j] = states.O
				najboljsi = max(najboljsi, minimax(s, false, globina + 1))
				s[j] = states.PRAZNO
		return najboljsi
	else:
		var najboljsi = INF
		for j in 9:
			if s[j] == states.PRAZNO:
				s[j] = states.X
				najboljsi = min(najboljsi, minimax(s, true, globina + 1))
				s[j] = states.PRAZNO
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
	for j in 9:
		if stanje[j] == states.O:
			buttons[j].text = "O"
		elif stanje[j] == states.X:
			buttons[j].text = "X"
		else:
			buttons[j].text = ""


func _on_button_ponovi_pressed():
	get_tree().reload_current_scene()

func _on_tezavnost_value_changed(value):
	nastavi_tezavnost(int(value))
