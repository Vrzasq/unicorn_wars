using Godot;

namespace unicorn_wars.scenes.ui.power_indicator
{
    public class PowerIndicator : Node2D
    {
        [Export] public float GrowthMultiplayer { get; set; } = 0.6f;
        
        private TextureProgress _progressBar;

        public override void _Ready() =>
            _progressBar = GetNode<TextureProgress>("TextureProgress");


        public override void _Process(float delta) =>
            UpdateProgressBar(delta);

        
        private void UpdateProgressBar(float delta)
        {
            _progressBar.Value += delta * GrowthMultiplayer;

            if (_progressBar.Value >= _progressBar.MaxValue
                || _progressBar.Value <= _progressBar.MinValue)
            {
                GrowthMultiplayer *= -1;
            }
        }


        public float GetPowerRatio() =>
            (float) _progressBar.Value;
    }
}