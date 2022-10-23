local replicated_storage = game:GetService("ReplicatedStorage");
local run_service = game:GetService("RunService");
local players = game:GetService("Players");
local tween_service = game:GetService("TweenService");

--// variables

local player = players.LocalPlayer;

local dependencies = {
    variables = {
        up_vector = Vector3.new(0, 500, 0),
        raycast_params = RaycastParams.new(),
        player_speed = 150, 
        vehicle_speed = 450,
        teleporting = false,
        stopVelocity = false
    },
    modules = {
        ui = require(replicated_storage.Module.UI),
        store = require(replicated_storage.App.store),
        player_utils = require(replicated_storage.Game.PlayerUtils),
        vehicle_data = require(replicated_storage.Game.Garage.VehicleData),
        character_util = require(replicated_storage.Game.CharacterUtil)
    },
    helicopters = { Heli = true }, -- heli is included in free vehicles
    motorcycles = { Volt = true }, -- volt type is "custom" but works the same as a motorcycle
    free_vehicles = { Camaro = true },
    unsupported_vehicles = { SWATVan = true },
    door_positions = { }    
};

local utilities = { };

--// function to toggle if a door can be collided with

function utilities:toggle_door_collision(door, toggle)
    for index, child in next, door.Model:GetChildren() do 
        if child:IsA("BasePart") then 
            child.CanCollide = toggle;
        end; 
    end;
end;

--// function to get the nearest vehicle that can be entered

function utilities:get_nearest_vehicle(tried) -- unoptimized
    local nearest;
    local distance = math.huge;

    for index, action in next, dependencies.modules.ui.CircleAction.Specs do -- all of the interations
        if action.IsVehicle and action.ShouldAllowEntry == true and action.Enabled == true and action.Name == "Enter Driver" then -- if the interaction is to enter the driver seat of a vehicle
            local vehicle = action.ValidRoot;

            if not table.find(tried, vehicle) and workspace.VehicleSpawns:FindFirstChild(vehicle.Name) then
                if not dependencies.unsupported_vehicles[vehicle.Name] and (dependencies.modules.store._state.garageOwned.Vehicles[vehicle.Name] or dependencies.free_vehicles[vehicle.Name]) and not vehicle.Seat.Player.Value then -- check if the vehicle is supported, owned and not already occupied
                    if not workspace:Raycast(vehicle.Seat.Position, dependencies.variables.up_vector, dependencies.variables.raycast_params) then
                        local magnitude = (vehicle.Seat.Position - player.Character.HumanoidRootPart.Position).Magnitude; 

                        if magnitude < distance then 
                            distance = magnitude;
                            nearest = action;
                        end;
                    end;
                end;
            end;
        end;
    end;

    return nearest;
end;


local function teleport(cframe, tried) -- unoptimized
    local relative_position = (cframe.Position - player.Character.HumanoidRootPart.Position);
    local target_distance = relative_position.Magnitude;

    if target_distance <= 20 and not workspace:Raycast(player.Character.HumanoidRootPart.Position, relative_position.Unit * target_distance, dependencies.variables.raycast_params) then 
        player.Character.HumanoidRootPart.CFrame = cframe; 
        
        return;
    end; 

    local tried = tried or { };
    local nearest_vehicle = utilities:get_nearest_vehicle(tried);
    local vehicle_object = nearest_vehicle and nearest_vehicle.ValidRoot;

    dependencies.variables.teleporting = true;

    if vehicle_object then 
        local vehicle_distance = (vehicle_object.Seat.Position - player.Character.HumanoidRootPart.Position).Magnitude;


            if vehicle_object.Seat.PlayerName.Value ~= player.Name then

                dependencies.variables.stopVelocity = true;

                local enter_attempts = 1;

                repeat -- attempt to enter car
                    nearest_vehicle:Callback(true)
                    
                    enter_attempts = enter_attempts + 1;

                    task.wait(0.1);
                until enter_attempts == 10 or vehicle_object.Seat.PlayerName.Value == player.Name;

                dependencies.variables.stopVelocity = false;

                if vehicle_object.Seat.PlayerName.Value ~= player.Name then -- if it failed to enter, try a new car
                    table.insert(tried, vehicle_object);

                    return teleport(cframe, tried or { vehicle_object });
                end;
            end;

            local vehicle_root_part; -- inline conditional would be way too long

            if dependencies.helicopters[vehicle_object.Name] then -- each type of vehicle has a different root part, which is why we sort them so we can do this
                vehicle_root_part = vehicle_object.Model.TopDisc;
            elseif dependencies.motorcycles[vehicle_object.Name] then 
                vehicle_root_part = vehicle_object.CameraVehicleSeat;
            elseif vehicle_object.Name == "DuneBuggy" then 
                vehicle_root_part = vehicle_object.BoundingBox;
            else 
                vehicle_root_part = vehicle_object.PrimaryPart;
            end;

            repeat -- attempt to exit car
                task.wait(0.15);
                dependencies.modules.character_util.OnJump();
            until vehicle_object.Seat.PlayerName.Value ~= player.Name;
        end;
    end;

    task.wait(0.5);
    dependencies.variables.teleporting = false;

return teleport;
