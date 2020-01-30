using Godot;

namespace unicorn_wars.scenes.ui.direction_indicator
{
    public class DirectionIndicator : Node2D
    {
        [Export] public float PlaybackSpeed = 1.75f;

        private Line2D _line;
        private AnimationPlayer _animationPlayer;

        public override void _Ready()
        {
            _line = GetNode<Line2D>("Line2D");
            _animationPlayer = GetNode<AnimationPlayer>("Line2D/AnimationPlayer");
            _animationPlayer.PlaybackSpeed = PlaybackSpeed;
        }


        public void Start() =>
            _animationPlayer.Play();


        public void Stop() =>
            _animationPlayer.Stop();


        public Vector2 GetDirection()
        {
            var direction = new Vector2(Mathf.Sin(_line.Rotation), Mathf.Cos(_line.Rotation));

            if (direction.x < -1)
                direction.x = -1;

            if (direction.y < 0)
                direction.y = 0;

            return direction;
        }
    }
}