using Godot;
using System;

namespace Game.core
{
    public partial class Globals : Node
    {
        public static Globals Instance { get; private set; }

        [ExportCategory("Gameplay")]
        [Export]
        public int GRID_SIZE = 16;

        public override void _Ready()
        {
            Instance = this;

            Core.Logger.Info("Loading Globals ...");
        }
    }
}

