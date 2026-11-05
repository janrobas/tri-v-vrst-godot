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

enum states { PRAZNO, X, O }
var stanje = [states.PRAZNO, states.PRAZNO, states.PRAZNO, states.PRAZNO, states.PRAZNO, states.PRAZNO, states.PRAZNO, states.PRAZNO, states.PRAZNO ]
var je_na_vrsti_x = false


# Called when the node enters the scene tree for the first time.
func _ready():
	for button in buttons:
		button.pressed.connect(on_press.bind(button.get_meta("moj_id")))
	osvezi()

func on_press(id):
	if je_na_vrsti_x:
		stanje[id] = states.X
	else:
		stanje[id] = states.O
		
	je_na_vrsti_x = !je_na_vrsti_x
		
	osvezi()
	
func osvezi():
	for i in 9:
		if stanje[i] == states.O:
			buttons[i].text = "O"
		elif stanje[i] == states.X:
			buttons[i].text = "X"
		else:
			buttons[i].text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
