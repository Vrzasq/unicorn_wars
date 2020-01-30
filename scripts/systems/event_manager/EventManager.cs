using System;
using System.Collections.Generic;

namespace unicorn_wars.scripts.systems.event_manager
{
    public class EventManager<TArgs> : IEventManager<TArgs>
    {
        private static readonly object _eventListinersLock = new object();
        protected List<Action<TArgs>>[] _eventListiners;

        private static readonly object _instanceLock = new object();
        private static EventManager<TArgs> _instance;

        public static EventManager<TArgs> Inastance
        {
            get
            {
                lock (_instanceLock)
                {
                    if (_instance == null)
                        _instance = new EventManager<TArgs>();

                    return _instance;
                }
            }
        }

        private EventManager() =>
            Init();

        protected virtual void Init() =>
            _eventListiners = new List<Action<TArgs>>[Enum.GetValues(typeof(GameEvent)).Length];
        

        public void Listen(GameEvent gameEvent, Action<TArgs> listener)
        {
            lock (_eventListinersLock)
            {
                var callbacks = _eventListiners[(int)gameEvent];

                if (callbacks == null)
                    callbacks = new List<Action<TArgs>>();

                callbacks.Add(listener);
                _eventListiners[(int)gameEvent] = callbacks;
            }
        }

        public void Rise(GameEvent gameEvent, TArgs args)
        {
            var callbacks = _eventListiners[(int)gameEvent];

            if (callbacks == null) return;

            for (int i = 0; i < callbacks.Count; i++)
                callbacks[i].Invoke(args);
        }

        public void StopListining(GameEvent gameEvent, Action<TArgs> listener)
        {
            lock (_eventListinersLock)
            {
                var callbacks = _eventListiners[(int)gameEvent];

                if (callbacks == null) return;

                callbacks.Remove(listener);
                _eventListiners[(int)gameEvent] = callbacks;
            }
        }
    }
}