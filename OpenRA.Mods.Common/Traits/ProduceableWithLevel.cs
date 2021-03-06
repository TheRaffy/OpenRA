﻿#region Copyright & License Information
/*
 * Copyright 2007-2015 The OpenRA Developers (see AUTHORS)
 * This file is part of OpenRA, which is free software. It is made
 * available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation. For more information,
 * see COPYING.
 */
#endregion

using OpenRA.Traits;

namespace OpenRA.Mods.Common.Traits
{
	[Desc("Actors possessing this trait should define the GainsExperience trait. When the prerequisites are fulfilled, ",
		"this trait grants a level-up to newly spawned actors. If additionally the actor's owning player defines the ProductionIconOverlay ",
		"trait, the production queue icon renders with an overlay defined in that trait.")]
	public class ProduceableWithLevelInfo : ITraitInfo, Requires<GainsExperienceInfo>
	{
		public readonly string[] Prerequisites = { };

		[Desc("Number of levels to give to the actor on creation.")]
		public readonly int InitialLevels = 1;

		[Desc("Should the level-up animation be suppressed when actor is created?")]
		public readonly bool SuppressLevelupAnimation = true;

		public object Create(ActorInitializer init) { return new ProduceableWithLevel(init, this); }
	}

	public class ProduceableWithLevel : INotifyCreated
	{
		readonly ProduceableWithLevelInfo info;

		public ProduceableWithLevel(ActorInitializer init, ProduceableWithLevelInfo info)
		{
			this.info = info;
		}

		public void Created(Actor self)
		{
			if (!self.Owner.PlayerActor.Trait<TechTree>().HasPrerequisites(info.Prerequisites))
				return;

			var ge = self.Trait<GainsExperience>();
			if (!ge.CanGainLevel)
				return;

			ge.GiveLevels(info.InitialLevels, info.SuppressLevelupAnimation);
		}
	}
}
