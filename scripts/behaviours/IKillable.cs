using System;

namespace unicorn_wars.scripts.behaviours
{
    public interface IKillable<T>
    {
         void HandleDeath(T args);
    }
}