using System;

namespace unicorn_wars.scripts.behaviours
{
    public class DamageTakenEventArgs : EventArgs
    {
        
    }
    public interface IDamageable
    {
         void TakeDamage(int damage);
    }
}