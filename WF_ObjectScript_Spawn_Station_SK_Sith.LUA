require("PGStateMachine")
require("PGSpawnUnits")

--script based  on AOTR one by Maxim, but upgraded
function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);
	Define_State("State_Active", State_Active)

	underworld_owner = false
	empire_owner = false
	rebel_owner = false

	spawn_distance = 15
end

function State_Init(message)
	if message == OnEnter then
		starbase_owner_human = Object.Get_Owner()
		--If human - exit
		if Object.Get_Owner().Is_Human() then
			--wait for AI to build a station, then build
			Sleep(7)
			spawn_station = Spawn_Unit(Find_Object_Type("Skirmish_Empire_Star_Base_1"), Object, starbase_owner_human)
			ScriptExit()
		end
		if not Object.Get_Owner().Is_Human() then
				--Spawn Construction ship
				sleeptimerdm = GameRandom(2, 7)
				starbase_owner = Object.Get_Owner()
				Sleep(sleeptimerdm)
				--Checking what table of Star Bases we will use
				if starbase_owner == Find_Player("Empire") then
					empire_owner = true	--Empire one
				elseif starbase_owner == Find_Player("Rebel") then
					rebel_owner = true --Rebel one
				elseif starbase_owner == Find_Player("Underworld") then
					underworld_owner = true --Underworld one
				end
				Sleep(1.0)
				--Then spawn a ship
				spawn_construction_ship = Spawn_Unit(Find_Object_Type("Skirmish_Construction_Ship"), Object, starbase_owner)
				Set_Next_State("State_Active")
		end
	end
end

function State_Active(message)
	--Checking, that a ship is alive on the map
	construction_ship_list = Find_All_Objects_Of_Type("Skirmish_Construction_Ship")
	for k,ship in pairs(construction_ship_list) do
				if TestValid(ship) then --if yes, so make it a god
					ship.Prevent_All_Fire(true)		    -- dont shoot
					ship.Make_Invulnerable(true)		    -- dont die
					ship.Prevent_Opportunity_Fire(true)	-- dont be shot at
					-- a short move to look like a ship not a station
					if not ship.Is_Ability_Active("HUNT") then
						ship.Activate_Ability("HUNT", true)
						Sleep(3.0)
						ship.Activate_Ability("HUNT", false)
						ship.Stop()
						ship.Activate_Ability("HUNT", true)
					end
				end
	end
	--If there is one at least, find it again
	construction_ship_list = Find_All_Objects_Of_Type("Skirmish_Construction_Ship")
	for k,ship in pairs(construction_ship_list) do
				if TestValid(ship) then
					--Checking a distance between Ship and Structure
					actual_distance = ship.Get_Distance(Object)
					if actual_distance > spawn_distance then
						--Make a randon station to spawn					
						spawnstationrdm = GameRandom(2, 4)
						if spawnstationrdm == 2 then
							spawn_station = Spawn_Unit(Find_Object_Type("Skirmish_Empire_Star_Base_1"), ship, starbase_owner)
						elseif spawnstationrdm == 3 then
							spawn_station = Spawn_Unit(Find_Object_Type("Skirmish_Mass_Effect_Star_Base_1"), ship, starbase_owner)
						elseif spawnstationrdm == 4 then
							spawn_station = Spawn_Unit(Find_Object_Type("Skirmish_Yuuzhan_Vong_Star_Base_1"), ship, starbase_owner)
						end
					end
					ship.Despawn()
				end
			end
	Sleep(1.0)
end
