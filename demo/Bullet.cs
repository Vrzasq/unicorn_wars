using Godot;
using unicorn_wars.scripts.systems.event_manager;

namespace unicorn_wars.demo
{
    public class Bullet : RigidBody2D
    {
        [Export] public float TimeToDestroyOnHit { get; set; } = 5.0f;
        [Export] public float TimeToDestroy { get; set; } = 15.0f;
        [Export] public int MinDamage { get; set; } = 5;
        [Export] public bool DestroyOnHit { get; set; }

        private Timer _destoryTimer;
        private bool _collided;
        private bool _setState;
        private uint _shapeOwner;

        public bool CanDamage { get; set; } = true;

        public override void _Ready()
        {
            _destoryTimer = GetNode<Timer>("DestroyTimer");
            _destoryTimer.Start(TimeToDestroy);
            _shapeOwner = (uint)GetShapeOwners()[0];
            ZIndex = 2;
        }

        public override void _PhysicsProcess(float delta) =>
            RotateBasedOnVelocity();

        
        public int GetBulletDamage() =>
            (int)(Mathf.Round(LinearVelocity.Length()) * Mass);

        private void RotateBasedOnVelocity()
        {
            if (!_collided)
                Rotation = LinearVelocity.Angle();
        }

        public void OnRigidBody2DBodyEntered(Node body)
        {
            if (DestroyOnHit)
                ShapeOwnerRemoveShape(_shapeOwner, 0);
            
            if (!_collided)
            {
                _destoryTimer.Start(TimeToDestroyOnHit);
                _collided = true;
                _setState = true;
            }
        }

        public void OnDestroyTimerTimeout()
        {
            EventManager<object>.Inastance.Rise(GameEvent.BulletDestroyed, null);
            QueueFree();
        }
    }
}