using Godot;
using unicorn_wars.scripts;

namespace unicorn_wars.scenes.ui.hp_bar
{
    public class HpBar : Node2D
    {
        [Export] public int MaxValue { get; set; }
        [Export] public bool Flip { get; set; }
        [Export] public NodePath SourcePath { get; set; }

        private TextureProgress _progressBar;
        private Label _hpLabel;
        private Tween _tweenAnimation;
        private AnimationPlayer _animationPlayer;

        public override void _Ready()
        {
            _tweenAnimation = GetNode<Tween>("Tween");
            _hpLabel = GetNode<Label>("Label");
            _progressBar = GetNode<TextureProgress>("TextureProgress");
            _animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");

            if (SourcePath != null)
                MaxValue = GetNode<IHealthPoints>(SourcePath).HealthPoints;

            if (Flip)
                _progressBar.FillMode = (int)TextureProgress.FillModeEnum.RightToLeft;

            AssignInitialValues();
        }

        private void AssignInitialValues()
        {
            _progressBar.MaxValue = MaxValue;
            _progressBar.Value = MaxValue;
            _hpLabel.Text = MaxValue.ToString();
        }

        public void OnHpLoss(DamageTakenArgs damageTakenArgs)
        {
            _animationPlayer.Play("hp_los");
            _tweenAnimation.InterpolateProperty(
                _progressBar,
                "value",
                damageTakenArgs.CurrentHp,
                damageTakenArgs.TargetHp, 0.6f,
                Tween.TransitionType.Bounce,
                Tween.EaseType.Out);

            _tweenAnimation.Start();
            _progressBar.Value = damageTakenArgs.TargetHp;
            _hpLabel.Text = damageTakenArgs.TargetHp.ToString();
        }
    }
}