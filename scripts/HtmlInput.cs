using Godot;

namespace unicorn_wars.scripts
{
    public class HtmlInput : LineEdit
    {
        [Export] public string Title = "Enter value";
        [Export] public NodePath LabelPath;

        private bool _isHtml;
        private Label _label;

        public override void _Ready()
        {
            _isHtml = OS.GetName().ToLower().Contains("html5");
            _label = GetNode<Label>(LabelPath);
            Title = _label.Text;
        }

        public override void _Input(InputEvent @event)
        {
            if (_isHtml)
            {
                var inputEvent = @event as InputEventMouseButton;
                
                if (inputEvent != null && GetGlobalRect().HasPoint(inputEvent.Position))
                {
                    GetTree().SetInputAsHandled();
                    string newText = JavaScript.Eval($"prompt({Title}{Text})") as string;
                    
                    if (!string.IsNullOrEmpty(newText))
                    {
                        Text = newText.Substring(0, MaxLength);
                        EmitSignal("text_changed", newText);
                        EmitSignal("text_changed", newText);
                    }
                }
            }
        }
    }
}