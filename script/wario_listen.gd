# wario_listen.gd
class_name WarioListen extends Node

## Handles Wario's listening pattern
## and audio manipulation

const STR_LISTEN = [
	"Wario is not listening...",
	"Wario is listening..."
]

enum WarioState {
	IDLE = 0, 
	LISTENING = 1,
	SPEAKING = 2
}

signal wario_listening()
signal wario_done(player)

export (NodePath) var label_listening_path
onready var label_listening : Label = get_node(label_listening_path)
export (NodePath) var input_spinner_path
onready var input_spinner : OptionButton = get_node(input_spinner_path)

var state : int = WarioState.IDLE
var effect : AudioEffect
var recording : AudioStreamSample

func _ready() -> void:
	# Get input bus
	var idx := AudioServer.get_bus_index("AudioIn")
	effect = AudioServer.get_bus_effect(idx, 0)
	
	# Get available input devices
	var inp = AudioServer.capture_get_device_list()
	for v in inp:
		input_spinner.add_item(v)

func _on_button_press(toggle : bool) -> void:
	# Set listening state
	state = toggle
	label_listening.text = STR_LISTEN[1] if state else STR_LISTEN[0]
	
	# Toggle recording
	effect.set_recording_active(state)
	if state:
		$record.stream = AudioStreamMicrophone.new()
		$record.playing = true
		emit_signal("wario_listening")
	
	# If inactive, play sound back to user
	if !state:
		recording = effect.get_recording()
		$playback.stream = recording
		$playback.play()
		emit_signal("wario_done", $playback)

func _audio_input_selected(input : int) -> void:
	# Set input
	AudioServer.capture_device = input_spinner.get_item_text(input)
	print(AudioServer.capture_get_device())

# Fired every 1/5th of a second
func _on_audio_poll() -> void:
	# Get current db level
	var analyzer : AudioEffectSpectrumAnalyzerInstance = \
	AudioServer.get_bus_effect_instance(AudioServer.get_bus_index("AudioIn"), 1)
	var volume : float = analyzer.get_magnitude_for_frequency_range(1000, 10000).length() * 100
	
	# If the db is high enough
	if volume > 0.1 && !current_state(WarioState.SPEAKING):
		if !$debounce.is_stopped(): $debounce.stop()
		listen()
	# If the db is low, begin debounce timer
	elif current_state(WarioState.LISTENING):
		if $debounce.is_stopped(): $debounce.start()

# Fired when Wario is ready to speak
func _on_debounce() -> void:
	if current_state(WarioState.LISTENING):
		finish_listen()

# Fired when processed audio is completed
func _on_finished_speaking() -> void:
	if current_state(WarioState.SPEAKING):
		state = WarioState.IDLE

# Looping listening function
func listen() -> void:
	if current_state(WarioState.IDLE):
		effect.set_recording_active(true)
		emit_signal("wario_listening")
		state = WarioState.LISTENING

# Speaking function
func finish_listen() -> void:
	# Set state
	state = WarioState.SPEAKING
	
	# Play audio
	effect.set_recording_active(false)
	recording = effect.get_recording()
	$playback.stream = recording
	$playback.play()
	emit_signal("wario_done", $playback)

# Checks incoming state with current
func current_state(compare : int) -> bool:
	return state == compare
