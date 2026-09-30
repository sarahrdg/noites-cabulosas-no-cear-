extends Node2D

const TOTAL_PARADAS := 8
const CORAGEM_INICIAL := 4

var coragem := CORAGEM_INICIAL
var parada := 0
var em_escolha := true
var rng := RandomNumberGenerator.new()
var encontros: Array = []

var itens := {
	"fumo": 2,
	"terco": 2,
	"sal": 2
}

const LENDAS := [
	{
		"id": "caipora",
		"nome": "Caipora",
		"item": "fumo",
		"item_nome": "Oferecer fumo",
		"sprite": "res://assets/noites/caipora.png",
		"clue": "Na beira da mata, os bichos se calam de repente. Um assobio curto vem de algum lugar entre as árvores, mas não há ninguém à vista. Quanto mais o viajante tenta seguir pela trilha, mais os sons parecem guiá-lo para longe da estrada. Os moradores evitam desrespeitar a dona daquele lugar."
	},
	{
		"id": "comadre",
		"nome": "Comadre Fulozinha",
		"item": "fumo",
		"item_nome": "Oferecer fumo",
		"sprite": "res://assets/noites/comadre.png",
		"clue": "A trilha parecia reta, mas depois de alguns minutos a porteira conhecida desaparece de vista. Galhos se mexem sem vento e uma risada distante surge entre os arbustos. Quem atravessa aquele trecho sem respeito pela mata costuma perceber tarde demais que já não sabe por onde voltou."
	},
	{
		"id": "lobisomem",
		"nome": "Lobisomem",
		"item": "terco",
		"item_nome": "Rezar o terço",
		"sprite": "res://assets/noites/lobisomem.png",
		"clue": "Na noite de lua cheia, os cachorros começam a latir antes que qualquer coisa apareça. Um uivo atravessa a estrada e passos pesados se aproximam. Por um instante, a silhueta parece a de um homem; no seguinte, corre sobre quatro patas. Os moradores mais antigos conhecem histórias sobre a transformação."
	},
	{
		"id": "procissao",
		"nome": "Procissão das Almas",
		"item": "terco",
		"item_nome": "Rezar o terço",
		"sprite": "res://assets/noites/procissao.png",
		"clue": "Depois da meia-noite, uma fileira de luzes surge onde antes só havia escuridão. As figuras avançam em silêncio, cobertas e quase sem tocar o chão. Nenhuma delas responde quando alguém chama, e os mais velhos dizem que não se deve atrapalhar o caminho daqueles que já partiram."
	},
	{
		"id": "mula",
		"nome": "Mula sem Cabeça",
		"item": "sal",
		"item_nome": "Jogar sal grosso",
		"sprite": "res://assets/noites/mula.png",
		"clue": "Perto da capela, o silêncio é quebrado por um tropel que parece vir de todos os lados. Uma luz avermelhada surge na estrada e o chão fica marcado por passadas apressadas. Não há cavaleiro algum, mas algo dispara pela noite, deixando atrás de si calor e faíscas."
	},
	{
		"id": "cabra",
		"nome": "Cabra Cabriola",
		"item": "sal",
		"item_nome": "Jogar sal grosso",
		"sprite": "res://assets/noites/cabra.png",
		"clue": "Na saída da vila, uma porteira range sozinha. Entre as sombras aparece um animal que parece comum à primeira vista, mas seus olhos permanecem fixos no viajante e seus chifres desenham uma silhueta incomum contra a lua. O bicho não se comporta como uma criação normal e começa a seguir quem tenta fugir."
	}
]

@onready var bg: Sprite2D = $Background

var title_label: Label
var parada_label: Label
var coragem_label: Label
var clue_label: Label
var feedback_label: Label
var creature_sprite: TextureRect
var progress_bar: ProgressBar
var fumo_button: Button
var terco_button: Button
var sal_button: Button
var correr_button: Button
var fumo_count: Label
var terco_count: Label
var sal_count: Label

func _ready() -> void:
	rng.randomize()
	encontros = LENDAS.duplicate(true)
	while encontros.size() < TOTAL_PARADAS:
		var extra = LENDAS[rng.randi_range(0, LENDAS.size() - 1)].duplicate(true)
		encontros.append(extra)
	encontros.shuffle()
	_criar_interface()
	_atualizar_parada()

func _criar_interface() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	# Escurece o cenário para dar aparência de noite.
	var overlay := ColorRect.new()
	overlay.color = Color(0.04, 0.035, 0.08, 0.30)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(overlay)

	title_label = _label("NOITES CABULOSAS NO CEARÁ", 28)
	title_label.position = Vector2(32, 22)
	root.add_child(title_label)

	parada_label = _label("", 22)
	parada_label.position = Vector2(870, 26)
	root.add_child(parada_label)

	coragem_label = _label("", 22)
	coragem_label.position = Vector2(32, 65)
	root.add_child(coragem_label)

	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(260, 67)
	progress_bar.size = Vector2(520, 20)
	progress_bar.max_value = TOTAL_PARADAS
	progress_bar.show_percentage = false
	root.add_child(progress_bar)

	var panel := Panel.new()
	panel.position = Vector2(95, 125)
	panel.size = Vector2(962, 310)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035,0.04,0.08,0.92), Color(0.36,0.29,0.42,0.9), 3))
	root.add_child(panel)

	creature_sprite = TextureRect.new()
	creature_sprite.position = Vector2(120, 160)
	creature_sprite.size = Vector2(150, 170)
	creature_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	creature_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(creature_sprite)

	var clue_title := _label("PISTA DA PARADA", 18)
	clue_title.position = Vector2(300, 155)
	root.add_child(clue_title)

	clue_label = _label("", 18)
	clue_label.position = Vector2(300, 190)
	clue_label.size = Vector2(710, 180)
	clue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(clue_label)

	feedback_label = _label("", 18)
	feedback_label.position = Vector2(300, 382)
	feedback_label.size = Vector2(700, 35)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	root.add_child(feedback_label)

	var inventory_title := _label("ITENS", 18)
	inventory_title.position = Vector2(95, 458)
	root.add_child(inventory_title)

	fumo_button = _button("FUMO")
	fumo_button.position = Vector2(95, 495)
	fumo_button.size = Vector2(215, 58)
	fumo_button.pressed.connect(func(): _escolher("fumo"))
	root.add_child(fumo_button)
	fumo_count = _label("", 14); fumo_count.position = Vector2(260, 515); root.add_child(fumo_count)

	terco_button = _button("TERÇO")
	terco_button.position = Vector2(335, 495)
	terco_button.size = Vector2(215, 58)
	terco_button.pressed.connect(func(): _escolher("terco"))
	root.add_child(terco_button)
	terco_count = _label("", 14); terco_count.position = Vector2(500, 515); root.add_child(terco_count)

	sal_button = _button("SAL GROSSO")
	sal_button.position = Vector2(575, 495)
	sal_button.size = Vector2(215, 58)
	sal_button.pressed.connect(func(): _escolher("sal"))
	root.add_child(sal_button)
	sal_count = _label("", 14); sal_count.position = Vector2(740, 515); root.add_child(sal_count)

	correr_button = _button("CORRER  -1 CORAGEM")
	correr_button.position = Vector2(870, 495)
	correr_button.size = Vector2(190, 58)
	correr_button.pressed.connect(func(): _escolher("correr"))
	root.add_child(correr_button)

	var help := _label("Reconheça a lenda pela pista. Escolha o item certo ou corra para sobreviver.", 14)
	help.position = Vector2(95, 585)
	help.size = Vector2(965, 30)
	root.add_child(help)

func _label(texto: String, tamanho: int) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", Color(0.94,0.90,0.76))
	return l

func _button(texto: String) -> Button:
	var b := Button.new()
	b.text = texto
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_stylebox_override("normal", _panel_style(Color(0.12,0.09,0.15,0.95), Color(0.48,0.38,0.49), 2))
	b.add_theme_stylebox_override("hover", _panel_style(Color(0.23,0.16,0.24,0.98), Color(0.75,0.60,0.38), 2))
	b.add_theme_stylebox_override("disabled", _panel_style(Color(0.08,0.07,0.10,0.65), Color(0.18,0.17,0.20), 1))
	return b

func _panel_style(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(width)
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_left = 6
	s.corner_radius_bottom_right = 6
	return s

func _atualizar_parada() -> void:
	if parada >= TOTAL_PARADAS:
		_vitoria()
		return
	var encontro = encontros[parada]
	parada_label.text = "PARADA %d / %d" % [parada + 1, TOTAL_PARADAS]
	coragem_label.text = "CORAGEM: %d / %d" % [coragem, CORAGEM_INICIAL]
	progress_bar.value = parada
	clue_label.text = encontro["clue"]
	creature_sprite.texture = load(encontro["sprite"])
	feedback_label.text = "Qual proteção você vai usar?"
	feedback_label.add_theme_color_override("font_color", Color(0.80,0.76,0.68))
	_atualizar_itens()
	em_escolha = true

func _atualizar_itens() -> void:
	fumo_count.text = "x%d" % itens["fumo"]
	terco_count.text = "x%d" % itens["terco"]
	sal_count.text = "x%d" % itens["sal"]
	fumo_button.disabled = itens["fumo"] <= 0
	terco_button.disabled = itens["terco"] <= 0
	sal_button.disabled = itens["sal"] <= 0
	correr_button.disabled = false

func _escolher(acao: String) -> void:
	if not em_escolha:
		return
	em_escolha = false
	var encontro = encontros[parada]
	var correta = acao == encontro["item"]

	if acao == "correr":
		coragem -= 1
		feedback_label.text = "Você correu pela estrada escura. -1 coragem."
		feedback_label.add_theme_color_override("font_color", Color(0.95,0.72,0.40))
	elif correta:
		itens[acao] -= 1
		feedback_label.text = "A proteção funcionou! Era a %s. O caminho está livre." % encontro["nome"]
		feedback_label.add_theme_color_override("font_color", Color(0.56,0.92,0.63))
	else:
		itens[acao] -= 1
		coragem -= 2
		feedback_label.text = "Não funcionou... Era a %s. -2 coragem e -1 item." % encontro["nome"]
		feedback_label.add_theme_color_override("font_color", Color(0.95,0.42,0.42))

	coragem_label.text = "CORAGEM: %d / %d" % [coragem, CORAGEM_INICIAL]
	_atualizar_itens()

	if coragem <= 0:
		await get_tree().create_timer(0.8).timeout
		_derrota()
		return

	parada += 1
	await get_tree().create_timer(0.9).timeout
	_atualizar_parada()

func _derrota() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/end_game.tscn")

func _vitoria() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/win_game.tscn")
