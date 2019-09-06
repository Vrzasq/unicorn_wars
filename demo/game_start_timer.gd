extends Timer

var label : RainbowLabel
var step_count = 1.0
var left_time : int
var go_text = "GO"


func _ready() -> void:
    label = $TimerLabel
    label.set_text(str(self.wait_time - 1))
    left_time = self.wait_time - 1


func _process(delta: float) -> void:
    step_count -= delta
    
    if step_count <= 0:
        step_count = 1.0
        left_time -= 1
        label.set_text(str(left_time))
        
    if left_time < 1:
        label.set_text(go_text)
