using Godot;

namespace unicorn_wars.scripts.behaviours
{
    public interface IPlayer : IDamageable, IKillable<Node2D>
    {
        string DisplayName { get; set; }
        void StartTurn();
        void EndTurn();
        void ResetPosition();
    }
}