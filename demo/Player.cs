using System;
using Godot;
using unicorn_wars.scenes.ui.direction_indicator;
using unicorn_wars.scenes.ui.power_indicator;
using unicorn_wars.scripts;
using unicorn_wars.scripts.behaviours;
using unicorn_wars.scripts.systems.event_manager;

namespace unicorn_wars.demo
{
    public class Player : RigidBody2D
    {
        #region Stats
        [Export] public int HealthPoints { get; set; } = 150;
        [Export] public string DisplayName { get; set; } = "Player";
        [Export] public int MaxShotPower { get; set; }
        [Export] public int Armor { get; set; } = 100;
        [Export] public bool CanBeDamageAfterHit { get; set; }
        [Export] public int DeathPower { get; set; } = 8000;
        [Export] public int GameOverTimeout { get; set; } = 10;
        #endregion
        #region PackedScenes
        [Export] public PackedScene PowerIndicatorScene { get; set; }
        [Export] public PackedScene ShootingStarsScene { get; set; }
        [Export] public PackedScene DeathBlowScene { get; set; }
        [Export] public PackedScene BulletScene { get; set; }
        [Export] public PhysicsMaterial DeathPhysicMaterial { get; set; }
        #endregion
        #region NodePaths
        [Export] public NodePath PowerIndicatorPlaceholderPath { get; set; }
        [Export] public NodePath BulletContainerPath { get; set; }
        [Export] public NodePath OtherPlayerNodePath { get; set; }
        [Export] public NodePath StartingPositionPath { get; set; }
        [Export] public NodePath DirectionIndicatorPath { get; set; }
        [Export] public NodePath HubPath { get; set; }
        #endregion

        private Player _otherPlayer;
        private Node2D _startingPosition;
        private bool _resetState;
        private DirectionIndicator _directionIndicator;
        private Node _hud;
        private Node2D _powerIndicatorPlaceholder;
        private PowerIndicator _powerIndicator;
        private Particles2D _shootingStars;
        private bool _thisPlayerTurn;
        private bool _canShoot;
        public bool Dead { get; set; }


        public override void _Ready()
        {
            _directionIndicator = GetNode<DirectionIndicator>(DirectionIndicatorPath);
            _otherPlayer = GetNode<Player>(OtherPlayerNodePath);
            _startingPosition = GetNode<Node2D>(StartingPositionPath);
            _startingPosition.Transform = Transform;
            _hud = GetNode(HubPath);
            _powerIndicatorPlaceholder = GetNode<Node2D>(PowerIndicatorPlaceholderPath);
            _shootingStars = ShootingStarsScene.Instance() as Particles2D;
            _shootingStars.Position = GetNode<Node2D>("ShootingPoint").Position;
            AddChild(_shootingStars);

            if (string.IsNullOrEmpty(DisplayName))
                DisplayName = Name;
        }


        public override void _Input(InputEvent @event)
        {
            if (_thisPlayerTurn && _canShoot)
                HandlePlayerInput(@event);
        }

        private void HandlePlayerInput(InputEvent input)
        {
            if (input is InputEventMouseButton)
            {
                if (input.IsActionPressed("shot"))
                {
                    _directionIndicator.Stop();
                    EmitStars();
                    DisplayPowerIndicator();
                }

                if (input.IsActionReleased("shot"))
                {
                    ShotBullet();
                    HidePowerIndicator();
                    StopStars();
                    _directionIndicator.Start();
                }
            }

            if (input.IsActionPressed("ui_accept"))
                _resetState = true;
        }

        private void ShotBullet()
        {
            var bullet = CreateBullet();

            var bulletContainer = GetNode<Node2D>(BulletContainerPath);
            bulletContainer.AddChild(bullet);

            float power = MaxShotPower * _powerIndicator.GetPowerRatio();
            bullet.ApplyCentralImpulse(new Vector2(power, -power) * _directionIndicator.GetDirection());
            _canShoot = false;
        }

        public override void _IntegrateForces(Physics2DDirectBodyState state)
        {
            if (_resetState)
                ResetState(state);
        }

        public void ResetPosition() =>
            _resetState = true;

        private void ResetState(Physics2DDirectBodyState state)
        {
            state.Transform = _startingPosition.Transform;
            state.LinearVelocity = Vector2.Zero;
            state.AngularVelocity = 0.0f;
            _resetState = false;
        }

        private Bullet CreateBullet()
        {
            var bullet = BulletScene.Instance() as Bullet;
            bullet.Position = GetNode<Node2D>("ShootingPoint").GlobalPosition;
            bullet.CollisionLayer = _otherPlayer.CollisionLayer;
            bullet.CollisionMask = _otherPlayer.CollisionMask;
            EventManager<object>.Inastance.Listen(GameEvent.BulletDestroyed, OnBulletDestroyed);

            return bullet;
        }

        private void OnBulletDestroyed(object data = null)
        {
            EventManager<object>.Inastance.StopListining(GameEvent.BulletDestroyed, OnBulletDestroyed);
            if (!_otherPlayer.Dead)
                EventManager<Player>.Inastance.Rise(GameEvent.TurnEnd, _otherPlayer);
        }

        private void DisplayPowerIndicator()
        {
            _powerIndicator = PowerIndicatorScene.Instance() as PowerIndicator;
            _powerIndicator.Position = _powerIndicatorPlaceholder.Position;
            _hud.AddChild(_powerIndicator);
        }

        private void HidePowerIndicator() =>
            _powerIndicator.QueueFree();

        private void EmitStars() =>
            _shootingStars.Emitting = true;

        private void StopStars() =>
            _shootingStars.Emitting = false;


        public void StartTurn()
        {
            _thisPlayerTurn = true;
            _canShoot = true;
        }

        public void EndTurn() =>
            _thisPlayerTurn = false;



        private void OnPlayerBody_BodyEntered(Node body)
        {
            var bullet = body as Bullet;
            if (bullet != null && bullet.CanDamage)
            {
                bullet.CanDamage = CanBeDamageAfterHit;
                int damage = CalculateDamage(bullet.GetBulletDamage(), bullet.MinDamage);
                TakeDamage(damage);
                if (Dead)
                    HandleDeath(bullet);
            }
        }

        private int CalculateDamage(int bulletDamage, int minDamage)
        {
            int damage = (int)((((bulletDamage / Mass) * 0.1f) - Armor) * 0.3f) + minDamage;

            if (damage < minDamage)
                damage = minDamage;

            return damage;
        }

        public void TakeDamage(int damage)
        {
            var damageTakenArgs = new DamageTakenArgs
            {
                CurrentHp = HealthPoints,
                Damage = damage
            };

            ReduceHP(damage);
            damageTakenArgs.TargetHp = HealthPoints;
            EventManager<DamageTakenArgs>.Inastance.Rise(GameEvent.DamageTaken, damageTakenArgs);
        }

        private void ReduceHP(int damage)
        {
            HealthPoints -= damage;
            if (HealthPoints <= 0)
            {
                HealthPoints = 0;
                Dead = true;
            }
        }

        public void HandleDeath(Bullet bullet)
        {
            PlayDeathParticles();
            ApplyDeathPower(bullet);
            StartGameOverCountdown();
            _directionIndicator.QueueFree();
        }

        private void PlayDeathParticles()
        {
            var deathBlow = DeathBlowScene.Instance() as Particles2D;
            deathBlow.Emitting = true;
            deathBlow.Position = Vector2.Zero;
            AddChild(deathBlow);
        }

        private void ApplyDeathPower(Bullet bullet)
        {
            var direction = bullet.GlobalPosition.DirectionTo(GlobalPosition);
            PhysicsMaterialOverride = DeathPhysicMaterial;
            ApplyCentralImpulse(direction * new Vector2(DeathPower, -DeathPower));
        }

        private void StartGameOverCountdown()
        {
            var gameOverTimer = new Timer();
            gameOverTimer.Start(GameOverTimeout);
            gameOverTimer.Connect("timeout", this, "OnGameOverTimeout");
            AddChild(gameOverTimer);
        }

        private void OnGameOverTimeout() =>
            EventManager<Player>.Inastance.Rise(GameEvent.Died, _otherPlayer);

    }
}