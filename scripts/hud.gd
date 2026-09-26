extends CanvasLayer

# HUD - displays score, bridge count, and messages

@onready var bridges_label: Label = $BridgesLabel
@onready var controls_label: RichTextLabel = $ControlsLabel
@onready var message_label: Label = $MessageLabel
@onready var title_label: Label = $TitleLabel

var bridges_crossed: int = 0
var total_bridges: int = 0

func _ready():
	message_label.text = ""
	message_label.visible = false
	controls_label.bbcode_enabled = true
	controls_label.bbcode_text = "[b]Controls:[/b] A/D or ←/→ to move | W/↑/Space to jump | R to reset"

func update_bridges_crossed(crossed: int, total: int):
	bridges_crossed = crossed
	total_bridges = total
	bridges_label.text = "Bridges crossed: %d / %d" % [crossed, total]
	
	# Animate the label briefly
	bridges_label.modulate = Color.YELLOW
	var tween = create_tween()
	tween.tween_property(bridges_label, "modulate", Color.WHITE, 0.5)

func show_message(text: String, color: Color = Color.WHITE):
	message_label.text = text
	message_label.modulate = color
	message_label.visible = true
	
	# Center the message
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Pulse animation
	var tween = create_tween()
	tween.tween_property(message_label, "modulate", color, 0.1)
	tween.tween_property(message_label, "modulate", Color(color.r, color.g, color.b, 0.5), 0.5)
	tween.tween_property(message_label, "modulate", color, 0.5)
	tween.set_loops()
