using System;

namespace unicorn_wars.scripts.systems.event_manager
{
    public enum GameEvent
    {
        Died,
        DamageTaken,
        TurnEnd,
        BulletDestroyed
    }

    interface IEventManager
    {
        void Listen(GameEvent gameEvent, Action listener);
        void StopListining(GameEvent gameEvent, Action listener);
        void Rise(GameEvent gameEvent);
    }

    interface IEventManager<TArgs>
    {
        void Listen(GameEvent gameEvent, Action<TArgs> listener);
        void StopListining(GameEvent gameEvent, Action<TArgs> listener);
        void Rise(GameEvent gameEvent, TArgs args);
    }
}