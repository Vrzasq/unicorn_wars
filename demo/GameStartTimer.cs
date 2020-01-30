using Godot;

namespace unicorn_wars.demo
{
    public class GameStartTimer : Timer
    {
        [Export] public string GoText = "GO";
        [Export] public float StepCount = 1.0f;

        private RainbowLabel _label;
        private int _leftTime;

        public override void _Ready()
        {
            _label = GetNode<RainbowLabel>("TimerLabel");
            _leftTime = (int)WaitTime - 1;
            _label.SetText(_leftTime.ToString());
        }

        public override void _Process(float delta)
        {
            StepCount -= delta;

            if (StepCount <= 0)
            {
                StepCount = 1.0f;
                _leftTime -= 1;
                _label.SetText(_leftTime.ToString());
            }

            if (_leftTime < 1)
                _label.SetText(GoText);
        }
    }
}