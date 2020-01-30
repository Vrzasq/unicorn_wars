using System.Collections.Generic;
using Godot;
using unicorn_wars.scripts.systems.event_manager;

namespace unicorn_wars.demo
{
    public class DemoManager : Node2D
    {
        [Export] public string Player1Name { get; set; }
        [Export] public string Player2Name { get; set; }

        private Dictionary<string, Player> _players;
        private Player _currentPlayer;
        private RainbowLabel _playerNameDisplay;


        public override void _Ready()
        {
            _players = new Dictionary<string, Player>();
            _playerNameDisplay = GetNode<RainbowLabel>("HUD/PlayerName");
            AssignPlayers();
            ChooseStartingPlayer();
            GetTree().Paused = true;
        }


        private void AssignPlayers()
        {
            var allPlayers = GetTree().GetNodesInGroup("players");

            for (int i = 0; i < allPlayers.Count; i++)
            {
                var player = allPlayers[i] as Player;
                _players.Add(player.Name, player);
            }

            SetPlayerName(_players["Player1"], Player1Name);
            SetPlayerName(_players["Player2"], Player2Name);

            var eventManager = EventManager<Player>.Inastance;

            eventManager.Listen(GameEvent.TurnEnd, OnPlayerTurnEnd);
            eventManager.Listen(GameEvent.Died, OnPlayerDeath);
        }

        private void SetPlayerName(Player player, string playerName)
        {
            if (!string.IsNullOrEmpty(playerName))
                player.DisplayName = playerName;
            else
                player.DisplayName = player.Name;
        }

        private void ChooseStartingPlayer()
        {
            GD.Randomize();
            int rand = (int)GD.Randi() % 2;

            if (rand == 0)
                _currentPlayer = _players["Player1"];
            else
                _currentPlayer = _players["Player2"];

            _currentPlayer.StartTurn();
            SetCurrentPlayerName();
        }

        private void SetCurrentPlayerName() =>
            _playerNameDisplay.SetText(_currentPlayer.DisplayName);


        private void OnPlayerTurnEnd(Player otherPlayer)
        {
            _currentPlayer.EndTurn();
            _currentPlayer.ResetPosition();

            otherPlayer.StartTurn();
            otherPlayer.ResetPosition();

            _currentPlayer = otherPlayer;
            SetCurrentPlayerName();
        }


        private void OnPlayerDeath(Player player)
        {
            EventManager<Player>.Inastance.StopListining(GameEvent.TurnEnd, OnPlayerTurnEnd);
            EventManager<Player>.Inastance.StopListining(GameEvent.Died, OnPlayerDeath);
            ShowGameOverScene(player);
        }


        private void ShowGameOverScene(Player winnerPlayer)
        {
            var tree = GetTree();
            tree.Root.RemoveChild(this);
            CallDeferred("Free");

            var gameOver = ((PackedScene)ResourceLoader.Load("res://demo/game_over.tscn")).Instance() as GameOver;
            gameOver.WinnerName = winnerPlayer.DisplayName;
            tree.Root.AddChild(gameOver);
        }

        private void OnGameStartTimerTmeout()
        {
            GetTree().Paused = false;
            var gameTimer = GetNode<Timer>("GameStartTimer");
            gameTimer.QueueFree();
        }
    }
}