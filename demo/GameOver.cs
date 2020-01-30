using Godot;
using System;

public class GameOver : Node
{
    [Export] public string WinnerName { get; set; }
    [Export] public string WinText { get; set; } = "%s wins !!!";

    public override void _Ready()
    {
        string text = WinText + WinnerName;
        RainbowLabel label = GetNode<RainbowLabel>("PlayerLabel");
        label.SetText(text);
    }

    public void OnPlayAgainButtonPressed()
    {
        var tree = GetTree();

        tree.Root.RemoveChild(this);
        CallDeferred("Free");

        var mainScene = ResourceLoader.Load<PackedScene>("res://demo/main.tscn");
        tree.Root.AddChild(mainScene.Instance());
    }

    public void OnQuitButtonPressed() =>
        GetTree().Quit();
}
