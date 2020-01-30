using Godot;
using System;

public class RainbowLabel : Node2D
{
    [Export] public string Text = "Hello There";
    [Export] public Theme Theme;

    private Label _label;

    public override void _Ready()
    {
        _label = GetNode<Label>("Label");
        _label.Text = Text;

        if (Theme != null)
            _label.Theme = Theme;
    }


    public void SetText(string text) =>
        Text = text;
}
