NodUnitsBuggy = { 'bggy', 'bggy', 'bike', 'bike' }
NodUnitsRocket = { 'e3', 'e3', 'e3', 'e3', 'e3', 'e3' }
NodUnitsGunner = { 'e1', 'e1', 'e1', 'e1', 'e1', 'e1' }

Apc3CellTriggerActivator = { CPos.New(28,58), CPos.New(27,58), CPos.New(28,57), CPos.New(27,57), CPos.New(28,56), CPos.New(27,56), CPos.New(28,55), CPos.New(27,55), CPos.New(28,54), CPos.New(27,54), CPos.New(28,53), CPos.New(27,53) }
Civ1CellTriggerActivator = { CPos.New(24,52), CPos.New(23,52), CPos.New(22,52), CPos.New(23,51), CPos.New(22,51), CPos.New(21,51) }
Civ2CellTriggerActivator = { CPos.New(26,54), CPos.New(25,54), CPos.New(24,54), CPos.New(25,53), CPos.New(24,53), CPos.New(23,53) }

Apc1Units = { 'c2', 'c3', 'c4', 'c5' }

WinActorTriggerActivator = { Civilian1, Civilian2, Civilian3, Civilian4, Civilian5, Civilian6, Civilian7, Civilian8, CivBuilding1, CivBuilding2, CivBuilding3, CivBuilding4, CivBuilding5, CivBuilding6, CivBuilding7, CivBuilding8, CivBuilding9, CivBuilding10, CivBuilding11, CivBuilding12, CivBuilding13, CivBuilding14 }
Apc2ActorTriggerActivator = { NodGunner1, NodGunner2, NodGunner3 }

Apc1Waypoints = { waypoint0.Location, waypoint11.Location, waypoint10.Location, waypoint8.Location, waypoint9.Location }
Apc2Waypoints = { waypoint8, waypoint7, waypoint6, waypoint5, waypoint4 }
Apc3Waypoints = { waypoint3, waypoint2, waypoint1, waypoint0, waypoint11, waypoint10, waypoint8, waypoint9 }
Civ1Waypoints = { waypoint3, waypoint2, waypoint3, waypoint1, waypoint2, waypoint11, waypoint10, waypoint8, waypoint9 }
Civ2Waypoints = { waypoint3, waypoint2, waypoint1, waypoint11, waypoint10, waypoint8, waypoint9 }
Hummer1Waypoints = { waypoint8, waypoint7, waypoint6, waypoint5, waypoint4, waypoint3, waypoint2, waypoint1, waypoint0, waypoint11, waypoint10, waypoint8 }

Apc1TriggerFunctionTime = DateTime.Seconds(3)

Apc1TriggerFunction = function()
	Reinforcements.ReinforceWithTransport(GDI, 'apc', Apc1Units, Apc1Waypoints, nil,
	function(transport, cargo)
		Utils.Do(cargo, function(actor)
			IdleHunt(actor)
		end)
	end,
	nil)
end

Hum1TriggerFunction = function(actor, discoverer)
	MyActors = Utils.Take(2, GDI.GetActorsByType('jeep'))
	Utils.Do(MyActors, function(actor)
		MoveAndHunt(actor, Hummer1Waypoints)
	end)
end

Movement = function(unit)
	if unit ~= nil then
		Utils.Do(Civ1Waypoints, function(waypoint)
			unit.AttackMove(waypoint.Location)
		end)
	end
end

MoveAndHunt = function(unit)
	if unit ~= nil then
		Utils.Do(Apc2Waypoints, function(waypoint)
			unit.AttackMove(waypoint.Location)
		end)
		IdleHunt(unit)
	end
end

Apc2TriggerFunction = function()
	MyActors = Utils.Take(1, GDI.GetActorsByType('apc'))
	Utils.Do(MyActors, function(actor)
		MoveAndHunt(actor, Apc2Waypoints)
	end)
end

WinTriggerFunction = function()
	Nod.MarkCompletedObjective(NodObjective1)
end

InsertNodUnits = function()
	Camera.Position = CameraPoint.CenterPosition

	Media.PlaySpeechNotification(Nod, "Reinforce")
	Reinforcements.ReinforceWithTransport(Nod, 'tran', NodUnitsBuggy, { EntryPointVehicle.Location, RallyPointVehicle.Location }, { EntryPointVehicle.Location }, nil, nil)
	Reinforcements.ReinforceWithTransport(Nod, 'tran', NodUnitsRocket, { EntryPointRocket.Location, RallyPointRocket.Location }, { EntryPointRocket.Location }, nil, nil)
	Reinforcements.ReinforceWithTransport(Nod, 'tran', NodUnitsGunner, { EntryPointGunner.Location, RallyPointGunner.Location }, { EntryPointGunner.Location }, nil, nil)
end

initialSong = "warfare"
PlayMusic = function()
	Media.PlayMusic(initialSong, PlayMusic)
	initialSong = nil
end

WorldLoaded = function()
	GDI = Player.GetPlayer("GDI")
	Nod = Player.GetPlayer("Nod")

	Trigger.AfterDelay(Apc1TriggerFunctionTime, Apc1TriggerFunction)

	Trigger.OnEnteredFootprint(Civ2CellTriggerActivator, function(a, id)
		if a.Owner == Nod then
			for type, count in pairs({ ['c6'] = 1, ['c7'] = 1, ['c8'] = 1, ['c9'] = 1 }) do
				MyActors = Utils.Take(count, GDI.GetActorsByType(type))
				Utils.Do(MyActors, function(actor)
					Movement(actor, Civ2Waypoints)
				end)
			end
			Trigger.RemoveFootprintTrigger(id)
		end
	end)

	Trigger.OnEnteredFootprint(Civ1CellTriggerActivator, function(a, id)
		if a.Owner == Nod then
			for type, count in pairs({ ['c2'] = 1, ['c3'] = 1, ['c4'] = 1, ['c5'] = 1 }) do
				MyActors = Utils.Take(count, GDI.GetActorsByType(type))
				Utils.Do(MyActors, function(actor)
					Movement(actor, Civ1Waypoints)
				end)
			end
			Trigger.RemoveFootprintTrigger(id)
		end
	end)

	Trigger.OnDiscovered(Convoi, Hum1TriggerFunction)

	Trigger.OnAllRemovedFromWorld(Apc2ActorTriggerActivator, Apc2TriggerFunction)

	Trigger.OnEnteredFootprint(Apc3CellTriggerActivator, function(a, id)
		if a.Owner == Nod then
			MoveAndHunt(GDI.GetActorsByType('apc')[1], Apc3Waypoints)
			Trigger.RemoveFootprintTrigger(id)
		end
	end)

	Trigger.OnAllRemovedFromWorld(WinActorTriggerActivator, WinTriggerFunction)

	Trigger.OnObjectiveAdded(Nod, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "New " .. string.lower(p.GetObjectiveType(id)) .. " objective")
	end)

	Trigger.OnObjectiveCompleted(Nod, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective completed")
	end)

	Trigger.OnObjectiveFailed(Nod, function(p, id)
		Media.DisplayMessage(p.GetObjectiveDescription(id), "Objective failed")
	end)

	Trigger.OnPlayerWon(Nod, function()
		Media.PlaySpeechNotification(Nod, "Win")
	end)

	Trigger.OnPlayerLost(Nod, function()
		Media.PlaySpeechNotification(Nod, "Lose")
	end)

	GDIObjective = GDI.AddPrimaryObjective("Kill all enemies.")
	NodObjective1 = Nod.AddPrimaryObjective("Destroy the village and kill all civilians.")
	NodObjective2 = Nod.AddSecondaryObjective("Kill all GDI units in the area.")

	PlayMusic()

	InsertNodUnits()
end

Tick = function()
	if Nod.HasNoRequiredUnits() then
		if DateTime.GameTime > 2 then
			GDI.MarkCompletedObjective(GDIObjective)
		end
	end

	if GDI.HasNoRequiredUnits() then
		Nod.MarkCompletedObjective(NodObjective2)
	end
end

IdleHunt = function(unit)
	if not unit.IsDead then
		Trigger.OnIdle(unit, unit.Hunt)
	end
end
