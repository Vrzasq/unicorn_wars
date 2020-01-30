using System;
using Godot;
using unicorn_wars.scripts;

namespace unicorn_wars.demo
{
    public class Main : Node
    {
        public void OnStartGameButtonPressed() =>
            LoadGameScene();

        public void LoadGameScene()
        {
            var tree = GetTree();
            tree.Root.RemoveChild(this);
            CallDeferred("Free");

            var game = ResourceLoader
                .Load<PackedScene>("res://demo/Demo.tscn")
                .Instance() as DemoManager;

            if (game != null)
            {
                game.Player1Name = GetNode<HtmlInput>("VBoxContainer/Player1Name").Text;
                game.Player2Name = GetNode<HtmlInput>("VBoxContainer/Player2Name").Text;
                tree.Root.AddChild(game);
            }
            else
            {
                throw new ArgumentNullException($"Failed to initialize {nameof(game)}");
            }
        }
    }
}