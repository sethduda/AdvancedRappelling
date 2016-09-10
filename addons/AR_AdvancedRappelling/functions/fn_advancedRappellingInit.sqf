/*
The MIT License (MIT)

Copyright (c) 2016 Seth Duda

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

if (!isServer) exitWith {};

AR_Advanced_Rappelling_Install = {

// Prevent advanced rappelling from installing twice
if(!isNil "AR_RAPPELLING_INIT") exitWith {};
AR_RAPPELLING_INIT = true;

diag_log "Advanced Rappelling Loading...";

AP_RAPPEL_POINTS = [];

AR_RAPPEL_POINT_CLASS_HEIGHT_OFFSET = [  
	["All", [-0.05, -0.05, -0.05, -0.05, -0.05, -0.05]]
];


#define AR_FNC_CAMERA_DISTANCE (missionNamespace getVariable ["AR_3rd_Person_Camera_Distance",5])
#define AR_FNC_CAMERA (missionNamespace getVariable ["AR_3rd_Person_Camera",objNull])
#define AR_FNC_CAMERA_X_TOTAL (missionNamespace getVariable ["AR_3rd_Person_Camera_X_Move_Total",-90])
#define AR_FNC_CAMERA_Y_TOTAL (missionNamespace getVariable ["AR_3rd_Person_Camera_Y_Move_Total",60])
#define AR_FNC_CAMERA_Y_TOTAL_PRIOR (missionNamespace getVariable ["AR_3rd_Person_Camera_Y_Move_Total_Prior",AR_FNC_CAMERA_Y_TOTAL])
#define AR_FNC_CAMERA_REL_POSITION [AR_FNC_CAMERA_DISTANCE * (cos AR_FNC_CAMERA_X_TOTAL) * (sin AR_FNC_CAMERA_Y_TOTAL), AR_FNC_CAMERA_DISTANCE * (sin AR_FNC_CAMERA_X_TOTAL) * (sin AR_FNC_CAMERA_Y_TOTAL), AR_FNC_CAMERA_DISTANCE * (cos AR_FNC_CAMERA_Y_TOTAL)]
#define AR_FNC_CAMERA_WORLD_POSITION ((camTarget AR_FNC_CAMERA) modelToWorld AR_FNC_CAMERA_REL_POSITION)
	
AR_Enable_3rd_Person_Camera = {
	_this spawn {
		params ["_object"];
		private ["_lastPosition"];
		waitUntil {time > 0};
		showCinemaBorder false;
		AR_3rd_Person_Camera = "camera" camCreate (_object modelToWorld [0,0,0]); 
		AR_3rd_Person_Camera camSetTarget _object; 
		AR_3rd_Person_Camera cameraEffect ["internal", "BACK"];
		[] call AR_Camera_Update_Position;
		waitUntil {!isNull (findDisplay 46)};
		_mouseMoveEventHandler = (findDisplay 46) displayAddEventHandler ["MouseMoving", "_this call AR_Camera_Mouse_Move_Handler"];
		_mouseZoomEventHandler = (findDisplay 46) displayAddEventHandler ["MouseZChanged", "_this call AR_Camera_Mouse_Zoom_Handler"];
		_lastPosition = getPos _object;
		_lastVectorDir = vectorDir _object;
		while {!isNull AR_FNC_CAMERA && !isNull _object && alive _object} do {
			if(_lastPosition distance _object > 0.01 || vectorMagnitude (_lastVectorDir vectorDiff (vectorDir _object)) > 0.01 ) then {
				[] call AR_Camera_Update_Position;
				_lastPosition = getPos _object;
			};
			sleep 0.01;
		};
		[] call AR_Disable_3rd_Person_Camera;
	};
};

AR_Disable_3rd_Person_Camera = {
	if(!isNull AR_FNC_CAMERA) then {
		AR_FNC_CAMERA cameraEffect ["Terminate", "Back"];
		camDestroy AR_FNC_CAMERA;
		missionNamespace setVariable ["AR_3rd_Person_Camera_Distance",nil];
		missionNamespace setVariable ["AR_3rd_Person_Camera",nil];
		missionNamespace setVariable ["AR_3rd_Person_Camera_X_Move_Total",nil];
		missionNamespace setVariable ["AR_3rd_Person_Camera_Y_Move_Total",nil];
		missionNamespace setVariable ["AR_3rd_Person_Camera_Y_Move_Total_Prior",nil];
	}
};

AR_Camera_Mouse_Zoom_Handler = {
	private ["_mouseZoom","_distance"];
	_mouseZoom = (_this select 1);
	if(_mouseZoom > 0) then {
		_mouseZoom = 1;
	} else {
		_mouseZoom = -1;
	};
	_distance =	AR_FNC_CAMERA_DISTANCE;
	AR_3rd_Person_Camera_Distance = (_distance - _mouseZoom) max 3 min 30;
	[] spawn AR_Camera_Update_Position;
};

AR_Camera_Mouse_Move_Handler = {
	private ["_cam","_distance","_target"];
	AR_3rd_Person_Camera_X_Move_Total = AR_FNC_CAMERA_X_TOTAL + (-(_this select 1)*0.16);
	AR_3rd_Person_Camera_Y_Move_Total = AR_FNC_CAMERA_Y_TOTAL + (-(_this select 2)*0.16);
	AR_3rd_Person_Camera_Y_Move_Total = AR_FNC_CAMERA_Y_TOTAL max 20 min 160;
	[] spawn AR_Camera_Update_Position;
};

AR_Camera_Update_Position = {
	private ["_cam"];
	_cam = AR_FNC_CAMERA;
	if(!isNil "_cam") then {
		if(AR_FNC_CAMERA_WORLD_POSITION select 2 < 0) then {
			AR_3rd_Person_Camera_Y_Move_Total = AR_FNC_CAMERA_Y_TOTAL min AR_FNC_CAMERA_Y_TOTAL_PRIOR;
		};
		_cam camSetRelPos AR_FNC_CAMERA_REL_POSITION;
		_cam camCommit 0.01;
		AR_3rd_Person_Camera_Y_Move_Total_Prior = AR_FNC_CAMERA_Y_TOTAL;
	};
};

AR_Get_Unit_Anchor = {
	params ["_unit"];
	_unit getVariable ["AR_Anchor_Attached_To_Unit",objNull];
};

// Must be executed where unit's anchor is local (or unit if no anchor exists)
AR_Unit_Rope_Create = {
	params ["_unit","_length",["_ropePosition",[-0.14,-0.155,0.1]]];
	private ["_unitAnchor","_rope","_ropeEndPositions"];
	_rope = objNull;
	_unitAnchor = [_unit] call AR_Create_Or_Get_Unit_Anchor;
	if(!isNull _unitAnchor) then {
		if(!isNull attachedTo _unitAnchor) then {
			detach _unitAnchor;
			_rope = ropeCreate [_unitAnchor, [0,0,-1000] vectorAdd _ropePosition, _length];
			[_rope,_unitAnchor, _unit] spawn {
				params ["_rope","_unitAnchor","_unit"];	
				_time = diag_tickTime;
				waitUntil {
					// Rope won't work if you immediately attach anchor to unit. 
					// need to wait for rope to be created first by checking rope ends
					// or 1 second has passed.
					_ropeEndPositions = ropeEndPosition _rope;
					((_ropeEndPositions select 0) distance2D (_ropeEndPositions select 1)) > 0.1 || (diag_tickTime - _time) > 1;
				};
				_unitAnchor attachTo [_unit, [0,0,1] vectorAdd [0,0,1000]];
			};
		} else {
			_rope = ropeCreate [_unitAnchor, [0,0,-1000] vectorAdd _ropePosition, _length];
		};
	};
	_rope;
};

AR_Attach_Rope_To_Unit_Anchor = {
	params ["_rope","_unitAnchor",["_extend",0]];
	if(!local _rope) exitWith {
		[_this,"AR_Attach_Rope_To_Unit_Anchor",_rope] call AR_RemoteExec;
	};
	if(_extend > 0) then {
		ropeUnwind [_rope, 100, (ropeLength _rope) + _extend];
	};
	[_unitAnchor, [0,0,-1000], [0,0,-1]] ropeAttachTo _rope;
	_unitAnchor setMass 80;
};

AR_Unit_Leave_Rope_Chain = {
	params ["_unit"];
	private ["_rope","_vehicle","_cargo","_cargoAnchor"];
	private ["_cargoUnit","_cargoRope","_unitAnchor"];
	_unitAnchor = [_unit] call AR_Get_Unit_Anchor;
	if(!local _unitAnchor) exitWith {
		[_this,"AR_Unit_Leave_Rope_Chain",_unitAnchor] call AR_RemoteExec;
	};
	_rope = _unit getVariable ["AR_Rope_Attached_To_Unit",objNull];
	_vehicle = ropeAttachedTo _unitAnchor;
	_cargo = ropeAttachedObjects _unitAnchor;
	if(count _cargo > 0) then {
		_cargoAnchor = _cargo select 0;
		_cargoUnit = _cargoAnchor getVariable ["AR_Anchor_Attached_To_Unit",objNull];
		_cargoRope = _cargoUnit getVariable ["AR_Rope_Attached_To_Unit",objNull];
		[_cargoUnit, _rope, _vehicle, ropeLength _cargoRope] call AR_Attach_Rope_To_Unit;
	};
	deleteVehicle _unitAnchor;
	_unit setVariable ["AR_Rope_Attached_To_Unit",nil,true];
	_unit setVariable ["AR_Anchor_Attached_To_Unit",nil,true];
};

AR_Detach_Rope_From_Unit_Anchor = {
	params ["_rope","_unitAnchor"];
	if(local _rope) then {
		_unitAnchor ropeDetach _rope;
	} else {
		[_this,"AR_Detach_Rope_From_Unit_Anchor",_rope] call AR_RemoteExec;
	};
};

AR_Detach_Rope_From_Unit = {
	params ["_unit"];
	private ["_unitAnchor","_rope","_cargo"];
	if(!local _unit) exitWith {
		[_this,"AR_Detach_Rope_From_Unit",_unit] call AR_RemoteExec;
	};
	_unitAnchor = [_unit] call AR_Get_Unit_Anchor;
	_rope = _unit getVariable ["AR_Rope_Attached_To_Unit",objNull];
	if(!isNull _unitAnchor && !isNull _rope) then {
		_cargo = ropeAttachedObjects _unitAnchor;
		if(count _cargo > 0) then {
			[_rope,_unitAnchor] call AR_Detach_Rope_From_Unit_Anchor;
			_unit setVariable ["AR_Rope_Attached_To_Unit",nil,true];
		} else {
			deleteVehicle _unitAnchor;
			_unit setVariable ["AR_Rope_Attached_To_Unit",nil,true];
			_unit setVariable ["AR_Anchor_Attached_To_Unit",nil,true];
		};
	};
};

AR_Simulate_Unit_Rope_Attachment_Terminated = {
	params ["_unit"];
	_unit allowDamage true;
	[_unit] call AR_Unit_Leave_Rope_Chain;
	if(player == _unit) then {
		[_unit] spawn AR_Disable_3rd_Person_Camera;
	};
	if((_unit getVariable ["AR_Detach_Action",-1]) >= 0) then {
		_unit removeAction (_unit getVariable ["AR_Detach_Action",-1]);
	};
	_unit setVariable ["AR_Unit_Rope_Simulation_Running",nil];
	_unit setVariable ["AR_Detach_Action",nil];
};

AR_Simulate_Rope_Lengths = {
	params ["_unit","_topRope"];
	private ["_bottomRopes","_lastRopeDistanceMoved","_currentRopeDistanceMoved","_distanceMoved","_topRopeLength","_decendSpeedMetersPerSecond","_bottomRopeLength","_unitAnchor"];	
	if(!local _topRope) exitWith {
		[_this,"AR_Simulate_Rope_Lengths",_topRope] call AR_RemoteExec;
	};
	_unitAnchor = [_unit] call AR_Get_Unit_Anchor;
	_lastRopeDistanceMoved = 0;
	while {_unit getVariable ["AR_Unit_Rope_Simulation_Running", false]} do {	
		_bottomRopes = ropes _unitAnchor;
		_decendSpeedMetersPerSecond = _unit getVariable ["AR_Rope_Unwind_Speed", 3];
		_currentRopeDistanceMoved = _unit getVariable ["AR_Rope_Distance_Moved", _lastRopeDistanceMoved];
		if(_lastRopeDistanceMoved != _currentRopeDistanceMoved) then {
			_distanceMoved = _currentRopeDistanceMoved - _lastRopeDistanceMoved;
			_topRopeLength = ropeLength _topRope;
			_bottomRopeLength = 2;
			if(count _bottomRopes > 0) then {
				_bottomRopeLength = ropeLength (_bottomRopes select 0);
				ropeUnwind [(_bottomRopes select 0), _decendSpeedMetersPerSecond, (_bottomRopeLength - _distanceMoved) max 2];
			};
			ropeUnwind [_topRope, _decendSpeedMetersPerSecond, (_topRopeLength + (_distanceMoved min (_bottomRopeLength-2))) max 2];
			_lastRopeDistanceMoved = _currentRopeDistanceMoved;
		};
		sleep 0.2;
	};
};

AR_Simulate_Unit_Rope_Attachment = {
	params ["_unit"];
	private ["_lastUnitSetPosTime","_lastUnitPosition","_currentUnitPosition"];
	private ["_unitAnchor","_allRopes","_vehicleRope"];
	private ["_unitInAir","_ropeEnds","_ropeLength"];
	if(!local _unit) exitWith {
		[_this,"AR_Simulate_Unit_Rope_Attachment",_unit] call AR_RemoteExec;
	};
	if(_unit getVariable ["AR_Unit_Rope_Simulation_Running",false]) exitWith {};
	
	_unit setVariable ["AR_Unit_Rope_Simulation_Running",true];
	
	if(isPlayer _unit) then {		
		_detatchAction = _unit addAction ["Detach Self", { 
			[player] call AR_Simulate_Unit_Rope_Attachment_Terminated;
		}, nil, 0, false, true, ""];
		_unit setVariable ["AR_Detach_Action", _detatchAction];
	};
	
	_vehicleRope = _unit getVariable ["AR_Rope_Attached_To_Unit",objNull];

	[_unit] orderGetIn false;
	[_unit, _vehicleRope] spawn AR_Play_Rappelling_Sounds;
	[_unit, _vehicleRope] spawn AR_Simulate_Rope_Lengths;
	[_unit] spawn AR_Simulate_Unit_Rope_Movement;
	
	_lastUnitSetPosTime = -1;
	_lastUnitPosition = getPosASL _unit;	
	while {true} do {
		_currentUnitPosition = getPosASL _unit;
		_unitAnchor = [_unit] call AR_Get_Unit_Anchor;
		_allRopes = ropes _unitAnchor;
		if(isNil "_allRopes") then {
			_allRopes = [];
		};
		_vehicleRope = _unit getVariable ["AR_Rope_Attached_To_Unit",objNull];
		if(!isNull _vehicleRope) then {
			_allRopes pushBack _vehicleRope;
		};
		if(count _allRopes == 0 || !alive _unit || isNull _unitAnchor || !(_unit getVariable ["AR_Unit_Rope_Simulation_Running",false])) exitWith {
			[_unit] call AR_Simulate_Unit_Rope_Attachment_Terminated;
		};
		_unitInAir = _unit getVariable ["AR_Rope_Unit_In_Air",false];
		if(!_unitInAir) then {
			{
				_rope = _x;
				_ropeEnds = ropeEndPosition _rope;
				_ropeLength = ropeLength _rope;
				_unitEnd = (_ropeEnds select 0);
				_vehicleEnd = (_ropeEnds select 1);
				_vehicleEnd = ASLtoAGL _vehicleEnd;
				_vehicleEnd set [2, (_vehicleEnd select 2) max 0];
				_vehicleEnd = AGLToASL _vehicleEnd;
				if(_currentUnitPosition distance _unitEnd > _currentUnitPosition distance _vehicleEnd) then {
					_unitEnd = (_ropeEnds select 1);
					_vehicleEnd = (_ropeEnds select 0);
				};		
				if(_unitEnd distance _vehicleEnd > _ropeLength && ((getPos _unit) select 2) < 0.1) then {
					if(_rope == _vehicleRope || count ropeAttachedObjects _unitAnchor > 0) then {
						if( _lastUnitPosition distance _currentUnitPosition > 0.01 && _currentUnitPosition distance _vehicleEnd > _lastUnitPosition distance _vehicleEnd ) then {
							_unit allowDamage false;
							_unit setPosASL _lastUnitPosition;
							_lastUnitSetPosTime = diag_tickTime;
						};
					};
				};
				if(_rope == _vehicleRope) then {
					_playerInAir = _unitEnd distance _vehicleEnd > _ropeLength + 1 && (ASLtoAGL _vehicleEnd select 2) > 1;
					_playerInAir = _playerInAir || ( _unitEnd distance _vehicleEnd > _ropeLength && (ASLtoAGL _vehicleEnd select 2) > 1 && ((getPos _unit) select 2) > 1);
					if(_playerInAir) then {
						_unit allowDamage false;
						_lastUnitSetPosTime = diag_tickTime;
						detach _unitAnchor;
						_unit attachTo [_unitAnchor, [0,-0.155,-0.6] vectorAdd [0,0,-1000]];
						[_unit,true] call AR_Enable_Rappelling_Animation;						
						if(player == _unit) then {
							[_unit] call AR_Enable_3rd_Person_Camera;
						};
						_unit setVariable ["AR_Rope_Unit_In_Air",true,true];
						sleep 2;
					};
				};
			} forEach _allRopes;
		} else {
			_unitPos = getPos _unit;
			if(_unitPos select 2 <= 0) then {
				_unitSpeedMetersPerSec = vectorMagnitude (velocity _unitAnchor);
				if(_unitSpeedMetersPerSec > 10) then {
					_currentUnitDamage = damage _unit;
					_damagePercent = ((_unitSpeedMetersPerSec - 10) / 25) min 1;
					_unit setDamage (_currentUnitDamage + ((1-_currentUnitDamage) * _damagePercent));
				};
				_unit allowDamage false;
				_lastUnitSetPosTime = diag_tickTime;
				detach _unit;
				_unitAnchor attachTo [_unit, [0,0.155,0.9] vectorAdd [0,0,1000]];
				_unitStartASLIntersect = (getPosASL _unit) vectorAdd [0,0,2];
				_unitEndASLIntersect = [_unitStartASLIntersect select 0, _unitStartASLIntersect select 1, (_unitStartASLIntersect select 2) - 7];
				_surfaces = lineIntersectsSurfaces [_unitStartASLIntersect, _unitEndASLIntersect, _unit, objNull, true, 10];
				_intersectionASL = [];
				{
					scopeName "surfaceLoop";
					_intersectionObject = _x select 2;
					_objectFileName = str _intersectionObject;
					if((_objectFileName find " t_") == -1 && (_objectFileName find " b_") == -1) then {
						_intersectionASL = _x select 0;
						breakOut "surfaceLoop";
					};
				} forEach _surfaces;
				if(count _intersectionASL != 0) then {
					_unit setPosASL _intersectionASL;
				};			
				[_unit,false] call AR_Enable_Rappelling_Animation;
				if(player == _unit) then {
					[] call AR_Disable_3rd_Person_Camera;
				};
				_unit setVariable ["AR_Rope_Unit_In_Air",false,true];				
				sleep 2;
			};
		};
		if(_lastUnitSetPosTime > 0 && diag_tickTime -_lastUnitSetPosTime > 2) then {
			_unit allowDamage true;
			_lastUnitSetPosTime = -1;
		};
		_lastUnitPosition = getPosASL _unit;
		sleep 0.01;
	};
};

AR_Simulate_Unit_Rope_Movement = {
	params ["_unit"];	
	
	if(!local _unit) exitWith {
		[_this,"AR_Simulate_Unit_Rope_Movement",_unit] call AR_RemoteExec;
	};
	
	private ["_ropeKeyDownHandler","_ropeKeyUpHandler"];	
	
	_ropeKeyDownHandler = -1;
	_ropeKeyUpHandler = -1;
	
	if(_unit == player) then {

		_unit setVariable ["AR_DECEND_PRESSED",false];
		_unit setVariable ["AR_FAST_DECEND_PRESSED",false];
		_unit setVariable ["AR_RANDOM_DECEND_SPEED_ADJUSTMENT",0];
		
		_ropeKeyDownHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			if(_this select 1 in (actionKeys "MoveBack")) then {
				player setVariable ["AR_DECEND_PRESSED",true];
			};
			if(_this select 1 in (actionKeys "Turbo")) then {
				player setVariable ["AR_FAST_DECEND_PRESSED",true];
			};
		}];
		
		_ropeKeyUpHandler = (findDisplay 46) displayAddEventHandler ["KeyUp", {
			if(_this select 1 in (actionKeys "MoveBack")) then {
				player setVariable ["AR_DECEND_PRESSED",false];
			};
			if(_this select 1 in (actionKeys "Turbo")) then {
				player setVariable ["AR_FAST_DECEND_PRESSED",false];
			};
		}];
		
	} else {
	
		_unit setVariable ["AR_DECEND_PRESSED",false];
		_unit setVariable ["AR_FAST_DECEND_PRESSED",false];
		_unit setVariable ["AR_RANDOM_DECEND_SPEED_ADJUSTMENT",(random 2) - 1];

		[_unit] spawn {
			params ["_unit"];
			sleep 2;
			_unit setVariable ["AR_DECEND_PRESSED",true];
		};
		
	};
	
	// Cause player to fall from rope if moving too fast
	_this spawn {
		params ["_unit"];
		private ["_unitSpeedMetersPerSec","_unitAnchor"];
		while {_unit getVariable ["AR_Unit_Rope_Simulation_Running", false]} do {
			_unitAnchor = [_unit] call AR_Get_Unit_Anchor;
			_unitSpeedMetersPerSec = vectorMagnitude (velocity _unitAnchor);
			if(_unitSpeedMetersPerSec > 41) then {
				if(isPlayer _unit) then {
					["Moving too fast! You've lost grip of the rope.", false] call AR_Hint;
				};
				[_unit] call AR_Unit_Leave_Rope_Chain;
			};
			sleep 2;
		};
	};

	private ["_lastTime","_lastPlayerInAir","_totalRopeDistanceMoved","_playerInAir","_currentTime","_timeSinceLastUpdate"];	
	
	_lastTime = diag_tickTime;
	_lastPlayerInAir = _unit getVariable ["AR_Rope_Unit_In_Air",false];
	_totalRopeDistanceMoved = 0;
	while {_unit getVariable ["AR_Unit_Rope_Simulation_Running", false]} do {
	
		_playerInAir = _unit getVariable ["AR_Rope_Unit_In_Air",false];
		_currentTime = diag_tickTime;
		_timeSinceLastUpdate = _currentTime - _lastTime;
		_lastTime = _currentTime;
		if(_timeSinceLastUpdate > 1) then {
			_timeSinceLastUpdate = 0;
		};
				
		// Handle rappelling down rope
		if(_unit getVariable ["AR_DECEND_PRESSED",false] && _playerInAir) then {
			_decendSpeedMetersPerSecond = 3;
			if(_unit getVariable ["AR_FAST_DECEND_PRESSED",false]) then {
				_decendSpeedMetersPerSecond = 4.5;
			};
			_decendSpeedMetersPerSecond = _decendSpeedMetersPerSecond + (_unit getVariable ["AR_RANDOM_DECEND_SPEED_ADJUSTMENT",0]);
			_totalRopeDistanceMoved = _totalRopeDistanceMoved + (_timeSinceLastUpdate * _decendSpeedMetersPerSecond);
			_unit setVariable ["AR_Rope_Distance_Moved", _totalRopeDistanceMoved, true];
			_unit setVariable ["AR_Rope_Unwind_Speed", _decendSpeedMetersPerSecond, true];
		};
		
		// Handle player landing on ground (auto-pull 3m of rope through rappel device)
		if(!_playerInAir && _lastPlayerInAir) then {
			_totalRopeDistanceMoved = _totalRopeDistanceMoved + 3;
			_unit setVariable ["AR_Rope_Distance_Moved", _totalRopeDistanceMoved, true];
		};

		if( not (_unit getVariable ["AR_Rope_Unit_In_Air",false]) && !isPlayer _unit && (getPos _unit) select 2 < 1 ) exitWith {
			sleep 2;
			[_unit] call AR_Unit_Leave_Rope_Chain;
		};
		
		_lastPlayerInAir = _playerInAir;
		
		sleep 0.1;
	};

	_unit setVariable ["AR_Rope_Distance_Moved", nil, true];
	_unit setVariable ["AR_Rope_Unwind_Speed", nil, true];
		
	if(_ropeKeyDownHandler != -1) then {			
		(findDisplay 46) displayRemoveEventHandler ["KeyDown", _ropeKeyDownHandler];
	};
	
	if(_ropeKeyUpHandler != -1) then {			
		(findDisplay 46) displayRemoveEventHandler ["KeyUp", _ropeKeyUpHandler];
	};
	
};



AR_Create_Or_Get_Unit_Anchor = {
	params ["_unit"];
	private ["_unitAnchor","_unitPosition","_unitAnchorPosition","_unitAnchorHeight"];
	_unitAnchor = [_unit] call AR_Get_Unit_Anchor;
	if(isNull _unitAnchor) then {
		_unitAnchorHeight = 1000;
		_unitPosition = getPos _unit;
		_unitAnchorPosition = _unitPosition vectorAdd [0,0,_unitAnchorHeight];
		_unitAnchor =  createVehicle ["B_static_AA_F", _unitAnchorPosition, [], 0, "CAN_COLLIDE"];
		_unitAnchor setVectorUp [0,0,1];
		_unitAnchor allowDamage false;
		_unitAnchor setCenterOfMass [0,0,-_unitAnchorHeight];
		_unitAnchor attachTo [_unit, [0,0.155,0.9] vectorAdd [0,0,_unitAnchorHeight]];
		_unitAnchor setVariable ["AR_Anchor_Attached_To_Unit",_unit,true];
		_unit setVariable ["AR_Anchor_Attached_To_Unit",_unitAnchor,true];
	};
	_unitAnchor;
};

AR_Attach_Rope_To_Unit = {
	params ["_unit","_rope","_vehicle",["_extend",0]];
	private ["_unitAnchor","_vehicleAnchor"];
	if(!local _unit) exitWith {
		[_this,"AR_Attach_Rope_To_Unit",_unit] call AR_RemoteExec;
	};
	[_unit] call AR_Detach_Rope_From_Unit;
	_unitAnchor = [_unit] call AR_Create_Or_Get_Unit_Anchor;
	_vehicleAnchor = _vehicle getVariable ["AR_Anchor_Attached_To_Unit",objNull];
	if(!isNull _vehicleAnchor) then {
		_vehicle = _vehicleAnchor;
	};
	_unit setVariable ["AR_Rope_Attached_To_Unit",_rope,true];
	_unit setVariable ["AR_Rope_Unit_In_Air",false,true];
	[_rope,_unitAnchor,_extend] call AR_Attach_Rope_To_Unit_Anchor;
	[_unit] spawn AR_Simulate_Unit_Rope_Attachment;
};

AR_Has_Addon_Animations_Installed = {
	(count getText ( configFile / "CfgMovesMaleSdr" / "States" / "AR_01_Idle" / "actions" )) > 0;
};

AR_Has_Addon_Sounds_Installed = {
	private ["_config","_configMission"];
	_config = getArray ( configFile / "CfgSounds" / "AR_Rappel_Start" / "sound" );
	_configMission = getArray ( missionConfigFile / "CfgSounds" / "AR_Rappel_Start" / "sound" );
	(count _config > 0 || count _configMission > 0);
};

AR_Rappel_All_Cargo = {
	params ["_vehicle",["_rappelHeight",25],["_positionASL",[]]];
	if(isPlayer (driver _vehicle)) exitWith {};
	if(local _vehicle) then {
		_this spawn {
			params ["_vehicle",["_rappelHeight",25],["_positionASL",[]]];
	
			_heliGroup = group driver _vehicle;
			_vehicle setVariable ["AR_Units_Rappelling",true];

			_heliGroupOriginalBehaviour = behaviour leader _heliGroup;
			_heliGroupOriginalCombatMode = combatMode leader _heliGroup;
			_heliGroupOriginalFormation = formation _heliGroup;

			if(count _positionASL == 0) then {
				_positionASL = AGLtoASL [(getPos _vehicle) select 0, (getPos _vehicle) select 1, 0];
			};
			_positionASL = _positionASL vectorAdd [0, 0, _rappelHeight];
			
			_gameLogicLeader = _heliGroup createUnit ["LOGIC", ASLToAGL _positionASL, [], 0, ""];
			_heliGroup selectLeader _gameLogicLeader;

			_heliGroup setBehaviour "Careless";
			_heliGroup setCombatMode "Blue";
			_heliGroup setFormation "File";
			
			// Wait for heli to slow down
			waitUntil { (vectorMagnitude (velocity _vehicle)) < 10 && _vehicle distance2d _gameLogicLeader < 50  };
			
			// Force heli to specific position
			[_vehicle, _positionASL] spawn {
				params ["_vehicle","_positionASL"];
				
				while { _vehicle getVariable ["AR_Units_Rappelling",false] && alive _vehicle } do {

					_velocityMagatude = 5;
					_distanceToPosition = ((getPosASL _vehicle) distance _positionASL);
					if( _distanceToPosition <= 10 ) then {
						_velocityMagatude = (_distanceToPosition / 10) * _velocityMagatude;
					};
					
					_currentVelocity = velocity _vehicle;
					_currentVelocity = _currentVelocity vectorAdd (( (getPosASL _vehicle) vectorFromTo _positionASL ) vectorMultiply _velocityMagatude);
					_currentVelocity = (vectorNormalized _currentVelocity) vectorMultiply ( (vectorMagnitude _currentVelocity) min _velocityMagatude );
					_vehicle setVelocity _currentVelocity;
					
					sleep 0.05;
				};
			};

			// Find all units that will be rappelling
			_rappelUnits = [];
			_rappelledGroups = [];
			{
				if( group _x != _heliGroup && alive _x ) then {
					_rappelUnits pushBack _x;
					_rappelledGroups = _rappelledGroups + [group _x];
				};
			} forEach crew _vehicle;
	
			// Rappel all units
			_unitsOutsideVehicle = [];
			while { count _unitsOutsideVehicle != count _rappelUnits } do { 	
				_distanceToPosition = ((getPosASL _vehicle) distance _positionASL);
				if(_distanceToPosition < 3) then {
					{
						[_x, _vehicle] call AR_Rappel_From_Heli;					
						sleep 1;
					} forEach (_rappelUnits-_unitsOutsideVehicle);
					{
						if!(_x in _vehicle) then {
							_unitsOutsideVehicle pushBack _x;
						};
					} forEach (_rappelUnits-_unitsOutsideVehicle);
				};
				sleep 2;
			};
			
			// Wait for all units to reach ground
			_unitsRappelling = true;
			while { _unitsRappelling } do { 
				_unitsRappelling = false;
				{
					if( _x getVariable ["AR_Is_Rappelling",false] ) then {
						_unitsRappelling = true;
					};
				} forEach _rappelUnits;
				sleep 3;
			};
			
			deleteVehicle _gameLogicLeader;
			
			_heliGroup setBehaviour _heliGroupOriginalBehaviour;
			_heliGroup setCombatMode _heliGroupOriginalCombatMode;
			_heliGroup setFormation _heliGroupOriginalFormation;

			_vehicle setVariable ["AR_Units_Rappelling",nil];
	
		};
	} else {
		[_this,"AR_Rappel_All_Cargo",_vehicle] call AR_RemoteExec;
	};
};

AR_Play_Rappelling_Sounds_Global = {
	params ["_player","_vehicleRope"];
	[_player,_vehicleRope,true] remoteExec ["AR_Play_Rappelling_Sounds", 0];
};

AR_Play_Rappelling_Sounds = {
	params ["_player","_vehicleRope",["_globalExec",false]];
	if(local _player && _globalExec) exitWith {};
	if(local _player && !_globalExec) then {
		[_this,"AR_Play_Rappelling_Sounds_Global"] call AR_RemoteExecServer;
	};
	if(!hasInterface || !(call AR_Has_Addon_Sounds_Installed) ) exitWith {};
	if(player distance _player < 15) then {
		[_player, "AR_Rappel_Start"] call AR_Play_3D_Sound;
	};
	_this spawn {
		params ["_player","_vehicleRope"];
		private ["_lastDistanceFromAnchor","_distanceFromAnchor"];
		_lastDistanceFromAnchor = ropeLength _vehicleRope;
		while {_player getVariable ["AR_Unit_Rope_Simulation_Running",false]} do {
			_distanceFromAnchor = ropeLength _vehicleRope;
			if(_distanceFromAnchor > _lastDistanceFromAnchor + 1 && player distance _player < 15) then {
				[_player, "AR_Rappel_Loop"] call AR_Play_3D_Sound;
				sleep 0.2;
				[_player, "AR_Rappel_Loop"] call AR_Play_3D_Sound;
			};
			sleep 0.9;
			_lastDistanceFromAnchor = _distanceFromAnchor;
		};
	};
	_this spawn {
		params ["_player"];
		while {_player getVariable ["AR_Unit_Rope_Simulation_Running",false]} do {
			sleep 0.1;
		};
		if(player distance _player < 15) then {
			[_player, "AR_Rappel_End"] call AR_Play_3D_Sound;
		};
	};
};

AR_Play_3D_Sound = {
	params ["_soundSource","_className"];
	private ["_config","_configMission"];
	_config = getArray ( configFile / "CfgSounds" / _className / "sound" );
	if(count _config > 0) exitWith {
		_soundSource say3D  _className;
	};
	_configMission = getArray ( missionConfigFile / "CfgSounds" / _className / "sound" );
	if(count _configMission > 0) exitWith {
		_soundSource say3D  _className;
	};
};

AR_Get_Heli_Rappel_Points = {
	params ["_vehicle"];
	
	// Check for pre-defined rappel points
	
	private ["_preDefinedRappelPoints","_className","_rappelPoints","_preDefinedRappelPointsConverted"];
	_preDefinedRappelPoints = [];
	{
		_className = _x select 0;
		_rappelPoints = _x select 1;
		if( _vehicle isKindOf _className ) then {
			_preDefinedRappelPoints = _rappelPoints;
		};
	} forEach (AP_RAPPEL_POINTS + (missionNamespace getVariable ["AP_CUSTOM_RAPPEL_POINTS",[]]));
	if(count _preDefinedRappelPoints > 0) exitWith { 
		_preDefinedRappelPointsConverted = [];
		{
			if(typeName _x == "STRING") then {
				_modelPosition = _vehicle selectionPosition _x;
				if( [0,0,0] distance _modelPosition > 0 ) then {
					_preDefinedRappelPointsConverted pushBack _modelPosition;
				};
			} else {
				_preDefinedRappelPointsConverted pushBack _x;
			};
		} forEach _preDefinedRappelPoints;
		_preDefinedRappelPointsConverted;
	};
	
	// Calculate dynamic rappel points
	
	private ["_rappelPointsArray","_cornerPoints","_frontLeftPoint","_frontRightPoint","_rearLeftPoint","_rearRightPoint","_rearLeftPointFinal"];
	private ["_rearRightPointFinal","_frontLeftPointFinal","_frontRightPointFinal","_middleLeftPointFinal","_middleRightPointFinal","_vehicleUnitVectorUp"];
	private ["_rappelPoints","_modelPoint","_modelPointASL","_surfaceIntersectStartASL","_surfaceIntersectEndASL","_surfaces","_intersectionASL","_intersectionObject"];
	private ["_la","_lb","_n","_p0","_l","_d","_validRappelPoints"];
	
	_rappelPointsArray = [];
	_cornerPoints = [_vehicle] call AR_Get_Corner_Points;
	
	_frontLeftPoint = (((_cornerPoints select 2) vectorDiff (_cornerPoints select 3)) vectorMultiply 0.2) vectorAdd (_cornerPoints select 3);
	_frontRightPoint = (((_cornerPoints select 2) vectorDiff (_cornerPoints select 3)) vectorMultiply 0.8) vectorAdd (_cornerPoints select 3);
	_rearLeftPoint = (((_cornerPoints select 0) vectorDiff (_cornerPoints select 1)) vectorMultiply 0.2) vectorAdd (_cornerPoints select 1);
	_rearRightPoint = (((_cornerPoints select 0) vectorDiff (_cornerPoints select 1)) vectorMultiply 0.8) vectorAdd (_cornerPoints select 1);
	
	_rearLeftPointFinal = ((_frontLeftPoint vectorDiff _rearLeftPoint) vectorMultiply 0.2) vectorAdd _rearLeftPoint;
	_rearRightPointFinal = ((_frontRightPoint vectorDiff _rearRightPoint) vectorMultiply 0.2) vectorAdd _rearRightPoint;
	_frontLeftPointFinal = ((_rearLeftPoint vectorDiff _frontLeftPoint) vectorMultiply 0.2) vectorAdd _frontLeftPoint;
	_frontRightPointFinal = ((_rearRightPoint vectorDiff _frontRightPoint) vectorMultiply 0.2) vectorAdd _frontRightPoint;
	_middleLeftPointFinal = ((_frontLeftPointFinal vectorDiff _rearLeftPointFinal) vectorMultiply 0.5) vectorAdd _rearLeftPointFinal;
	_middleRightPointFinal = ((_frontRightPointFinal vectorDiff _rearRightPointFinal) vectorMultiply 0.5) vectorAdd _rearRightPointFinal;

	_vehicleUnitVectorUp = vectorNormalized (vectorUp _vehicle);
	
	_rappelPointHeightOffset = 0;
	{
		if(_vehicle isKindOf (_x select 0)) then {
			_rappelPointHeightOffset = (_x select 1);
		};
	} forEach AR_RAPPEL_POINT_CLASS_HEIGHT_OFFSET;
	
	_rappelPoints = [];
	{
		_modelPoint = _x;
		_modelPointASL = AGLToASL (_vehicle modelToWorldVisual _modelPoint);
		_surfaceIntersectStartASL = _modelPointASL vectorAdd ( _vehicleUnitVectorUp vectorMultiply -5 );
		_surfaceIntersectEndASL = _modelPointASL vectorAdd ( _vehicleUnitVectorUp vectorMultiply 5 );
		
		// Determine if the surface intersection line crosses below ground level
		// If if does, move surfaceIntersectStartASL above ground level (lineIntersectsSurfaces
		// doesn't work if starting below ground level for some reason
		// See: https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection
		
		_la = ASLToAGL _surfaceIntersectStartASL;
		_lb = ASLToAGL _surfaceIntersectEndASL;
		
		if(_la select 2 < 0 && _lb select 2 > 0) then {
			_n = [0,0,1];
			_p0 = [0,0,0.1];
			_l = (_la vectorFromTo _lb);
			if((_l vectorDotProduct _n) != 0) then {
				_d = ( ( _p0 vectorAdd ( _la vectorMultiply -1 ) ) vectorDotProduct _n ) / (_l vectorDotProduct _n);
				_surfaceIntersectStartASL = AGLToASL ((_l vectorMultiply _d) vectorAdd _la);
			};
		};
		
		_surfaces = lineIntersectsSurfaces [_surfaceIntersectStartASL, _surfaceIntersectEndASL, objNull, objNull, true, 100];
		_intersectionASL = [];
		{
			_intersectionObject = _x select 2;
			if(_intersectionObject == _vehicle) exitWith {
				_intersectionASL = _x select 0;
			};
		} forEach _surfaces;
		if(count _intersectionASL > 0) then {
			_intersectionASL = _intersectionASL vectorAdd (( _surfaceIntersectStartASL vectorFromTo _surfaceIntersectEndASL ) vectorMultiply (_rappelPointHeightOffset select (count _rappelPoints)));
			_rappelPoints pushBack (_vehicle worldToModelVisual (ASLToAGL _intersectionASL));
		} else {
			_rappelPoints pushBack [];
		};
	} forEach [_middleLeftPointFinal, _middleRightPointFinal, _frontLeftPointFinal, _frontRightPointFinal, _rearLeftPointFinal, _rearRightPointFinal];

	_validRappelPoints = [];
	{
		if(count _x > 0 && count _validRappelPoints < missionNamespace getVariable ["AR_MAX_RAPPEL_POINTS_OVERRIDE",6]) then {
			_validRappelPoints pushBack _x;
		};
	} forEach _rappelPoints;
	
	_validRappelPoints;
};


AR_Rappel_From_Heli = {
	params ["_player","_heli"];
	private ["_rappelPoints","_rappelPointIndex","_rappellingPlayer"];
	
	if(!isServer) exitWith {
		[_this,"AR_Rappel_From_Heli",true] call AR_RemoteExecServer;
	};
	
	if!(_player in _heli) exitWith {};
	if(_player getVariable ["AR_Is_Rappelling", false]) exitWith {};
	
	// Find next available rappel anchor
	_rappelPoints = [_heli] call AR_Get_Heli_Rappel_Points;
	_rappelPointIndex = 0;
	{
		_rappellingPlayer = _heli getVariable ["AR_Rappelling_Player_" + str _rappelPointIndex,objNull];
		if(isNull _rappellingPlayer) exitWith {};
		_rappelPointIndex = _rappelPointIndex + 1;
	} forEach _rappelPoints;
	
	// All rappel anchors are taken by other players. Hint player to try again.
	if(count _rappelPoints == _rappelPointIndex) exitWith {
		if(isPlayer _player) then {
			[["All rappel anchors in use. Please try again.", false],"AR_Hint",_player] call AR_RemoteExec;
		};
	};
	
	_heli setVariable ["AR_Rappelling_Player_" + str _rappelPointIndex,_player];

	_player setVariable ["AR_Is_Rappelling",true,true];

	[_player,_heli,_rappelPoints select _rappelPointIndex] spawn AR_Rappel_From_Heli_Local;
	
	// Wait for player to finish rappeling before freeing up anchor
	[_player, _heli, _rappelPointIndex] spawn {
		params ["_player","_heli", "_rappelPointIndex"];
		while {true} do {
			if(!alive _player || ( isNull ([_player] call AR_Get_Unit_Anchor) && ((getPos _player) select 2 < 1)) ) exitWith {
				sleep 1;
				_player setVariable ["AR_Is_Rappelling",false,true];
			};
			sleep 1;
		};
		_heli setVariable ["AR_Rappelling_Player_" + str _rappelPointIndex, nil];
	};

};

AR_Rappel_From_Heli_Local = {
	params ["_player","_heli","_rappelPoint",["_ropeLength", 50],["_topRopeLength", 2]];
	private ["_topRope","_bottomRope","_playerStartPosition"];
	if(!local _heli) exitWith {
		[_this,"AR_Rappel_From_Heli_Local",_heli] call AR_RemoteExec;
	};
	moveOut _player;
	waitUntil { vehicle _player == _player};
	_topRope = ropeCreate [_heli, _rappelPoint, _topRopeLength]; 
	[_player, _topRope, _heli] call AR_Attach_Rope_To_Unit;
	_bottomRope = [_player,_ropeLength - _topRopeLength] call AR_Unit_Rope_Create;
	waitUntil { !(_player getVariable ["AR_Is_Rappelling",false]) };
	ropeDestroy _bottomRope;
	ropeUnwind [_topRope, 6, 0];
	sleep ((ropeLength _topRope) / 6);
	ropeDestroy _topRope;
};

AR_Enable_Rappelling_Animation_Global = {
	params ["_player","_enable"];
	[_player,_enable,true] remoteExec ["AR_Enable_Rappelling_Animation", 0];
};

AR_Current_Weapon_Type_Selected = {
	params ["_player"];
	if(currentWeapon _player == handgunWeapon _player) exitWith {"HANDGUN"};
	if(currentWeapon _player == primaryWeapon _player) exitWith {"PRIMARY"};
	if(currentWeapon _player == secondaryWeapon _player) exitWith {"SECONDARY"};
	"OTHER";
};

AR_Enable_Rappelling_Animation = {
	params ["_player","_enable",["_globalExec",false]];
	if(local _player && _globalExec) exitWith {};
	if(local _player && !_globalExec) then {
		[_this,"AR_Enable_Rappelling_Animation_Global"] call AR_RemoteExecServer;
	};
	if(_enable) then {
		if(call AR_Has_Addon_Animations_Installed) then {		
			if([_player] call AR_Current_Weapon_Type_Selected == "HANDGUN") then {
				_player switchMove "AR_01_Idle_Pistol";
			} else {
				_player switchMove "AR_01_Idle";
			};
		} else {
			_player switchMove "HubSittingChairC_idle1";
		};
	} else {
		_player switchMove "";	
	};
};

AR_Rappel_From_Heli_Action = {
	params ["_player","_vehicle"];	
	if([_player, _vehicle] call AR_Rappel_From_Heli_Action_Check) then {
		[_player, _vehicle] call AR_Rappel_From_Heli;
	};
};

AR_Rappel_From_Heli_Action_Check = {
	params ["_player","_vehicle"];
	if!([_vehicle] call AR_Is_Supported_Vehicle) exitWith {false};
	if(((getPos _vehicle) select 2) < 5 ) exitWith {false};
	if(((getPos _vehicle) select 2) > 150 ) exitWith {false};
	if(driver _vehicle == _player && isEngineOn _vehicle) exitWith {false};
	if(speed _vehicle > 100) exitWith {false};
	true;
};

AR_Rappel_AI_Units_From_Heli_Action_Check = {
	params ["_player"];
	if(leader _player != _player) exitWith {false}; 
	_canRappelOne = false;
	{
		if(vehicle _x != _x && !isPlayer _x) then {
			if([_x, vehicle _x] call AR_Rappel_From_Heli_Action_Check) then {
				_canRappelOne = true;
			};
		};
	} forEach (units _player);
	_canRappelOne;
};

AR_Get_Corner_Points = {
	params ["_vehicle"];
	private ["_centerOfMass","_bbr","_p1","_p2","_rearCorner","_rearCorner2","_frontCorner","_frontCorner2"];
	private ["_maxWidth","_widthOffset","_maxLength","_lengthOffset","_widthFactor","_lengthFactor","_maxHeight","_heightOffset"];
	
	// Correct width and length factor for air
	_widthFactor = 0.5;
	_lengthFactor = 0.5;
	if(_vehicle isKindOf "Air") then {
		_widthFactor = 0.3;
	};
	if(_vehicle isKindOf "Helicopter") then {
		_widthFactor = 0.2;
		_lengthFactor = 0.45;
	};
	
	_centerOfMass = getCenterOfMass _vehicle;
	_bbr = boundingBoxReal _vehicle;
	_p1 = _bbr select 0;
	_p2 = _bbr select 1;
	_maxWidth = abs ((_p2 select 0) - (_p1 select 0));
	_widthOffset = ((_maxWidth / 2) - abs ( _centerOfMass select 0 )) * _widthFactor;
	_maxLength = abs ((_p2 select 1) - (_p1 select 1));
	_lengthOffset = ((_maxLength / 2) - abs (_centerOfMass select 1 )) * _lengthFactor;
	_maxHeight = abs ((_p2 select 2) - (_p1 select 2));
	_heightOffset = _maxHeight/6;
	
	_rearCorner = [(_centerOfMass select 0) + _widthOffset, (_centerOfMass select 1) - _lengthOffset, (_centerOfMass select 2)+_heightOffset];
	_rearCorner2 = [(_centerOfMass select 0) - _widthOffset, (_centerOfMass select 1) - _lengthOffset, (_centerOfMass select 2)+_heightOffset];
	_frontCorner = [(_centerOfMass select 0) + _widthOffset, (_centerOfMass select 1) + _lengthOffset, (_centerOfMass select 2)+_heightOffset];
	_frontCorner2 = [(_centerOfMass select 0) - _widthOffset, (_centerOfMass select 1) + _lengthOffset, (_centerOfMass select 2)+_heightOffset];
	
	[_rearCorner,_rearCorner2,_frontCorner,_frontCorner2];
};

AR_SUPPORTED_VEHICLES = [
	"Helicopter",
	"VTOL_Base_F"
];

AR_Is_Supported_Vehicle = {
	params ["_vehicle","_isSupported"];
	_isSupported = false;
	if(not isNull _vehicle) then {
		{
			if(_vehicle isKindOf _x) then {
				_isSupported = true;
			};
		} forEach (missionNamespace getVariable ["AR_SUPPORTED_VEHICLES_OVERRIDE",AR_SUPPORTED_VEHICLES]);
	};
	_isSupported;
};

AR_Hint = {
    params ["_msg",["_isSuccess",true]];
    if(!isNil "ExileClient_gui_notification_event_addNotification") then {
		if(_isSuccess) then {
			["Success", [_msg]] call ExileClient_gui_notification_event_addNotification; 
		} else {
			["Whoops", [_msg]] call ExileClient_gui_notification_event_addNotification; 
		};
    } else {
        hint _msg;
    };
};

AR_Hide_Object_Global = {
	params ["_obj"];
	if( _obj isKindOf "Land_Can_V2_F" || _obj isKindOf "B_static_AA_F" ) then {
		hideObjectGlobal _obj;
	};
};

AR_Add_Player_Actions = {
	params ["_player"];
	
	_player addAction ["Rappel Self", { 
		[player, vehicle player] call AR_Rappel_From_Heli_Action;
	}, nil, 0, false, true, "", "[player, vehicle player] call AR_Rappel_From_Heli_Action_Check"];
	
	_player addAction ["Rappel AI Units", { 
		{
			if(!isPlayer _x) then {
				sleep 1;
				[_x, vehicle _x] call AR_Rappel_From_Heli_Action;
			};
		} forEach (units player);
	}, nil, 0, false, true, "", "[player] call AR_Rappel_AI_Units_From_Heli_Action_Check"];
	
	_player addEventHandler ["Respawn", {
		player setVariable ["AR_Actions_Loaded",false];
	}];
	
};

if(!isDedicated) then {
	[] spawn {
		while {true} do {
			if(!isNull player && isPlayer player) then {
				if!(player getVariable ["AR_Actions_Loaded",false] ) then {
					[player] call AR_Add_Player_Actions;
					player setVariable ["AR_Actions_Loaded",true];
				};
			};
			sleep 5;
		};
	};
};

AR_RemoteExec = {
	params ["_params","_functionName","_target",["_isCall",false]];
	if(!isNil "ExileClient_system_network_send") then {
		["AdvancedRappellingRemoteExecClient",[_params,_functionName,_target,_isCall]] call ExileClient_system_network_send;
	} else {
		if(_isCall) then {
			_params remoteExecCall [_functionName, _target];
		} else {
			_params remoteExec [_functionName, _target];
		};
	};
};

AR_RemoteExecServer = {
	params ["_params","_functionName",["_isCall",false]];
	if(!isNil "ExileClient_system_network_send") then {
		["AdvancedRappellingRemoteExecServer",[_params,_functionName,_isCall]] call ExileClient_system_network_send;
	} else {
		if(_isCall) then {
			_params remoteExecCall [_functionName, 2];
		} else {
			_params remoteExec [_functionName, 2];
		};
	};
};

if(isServer) then {
	
	// Adds support for exile network calls (Only used when running exile) //
	
	AR_SUPPORTED_REMOTEEXECSERVER_FUNCTIONS = ["AR_Play_Rappelling_Sounds_Global","AR_Rappel_From_Heli","AR_Enable_Rappelling_Animation_Global"];

	ExileServer_AdvancedRappelling_network_AdvancedRappellingRemoteExecServer = {
		params ["_sessionId", "_messageParameters",["_isCall",false]];
		_messageParameters params ["_params","_functionName"];
		if(_functionName in AR_SUPPORTED_REMOTEEXECSERVER_FUNCTIONS) then {
			if(_isCall) then {
				_params call (missionNamespace getVariable [_functionName,{}]);
			} else {
				_params spawn (missionNamespace getVariable [_functionName,{}]);
			};
		};
	};
	
	AR_SUPPORTED_REMOTEEXECCLIENT_FUNCTIONS = ["AR_Attach_Rope_To_Unit_Anchor","AR_Unit_Leave_Rope_Chain","AR_Detach_Rope_From_Unit_Anchor","AR_Detach_Rope_From_Unit","AR_Simulate_Unit_Rope_Attachment","AR_Simulate_Unit_Rope_Attachment","AR_Attach_Rope_To_Unit","AR_Rappel_All_Cargo","AR_Hint","AR_Rappel_From_Heli","AR_Rope_Owner_Manage_Ropes","AR_Client_Rappel_From_Heli","AR_Client_Rappel_From_Heli"];
	
	ExileServer_AdvancedRappelling_network_AdvancedRappellingRemoteExecClient = {
		params ["_sessionId", "_messageParameters"];
		_messageParameters params ["_params","_functionName","_target",["_isCall",false]];
		if(_functionName in AR_SUPPORTED_REMOTEEXECCLIENT_FUNCTIONS) then {
			if(_isCall) then {
				_params remoteExecCall [_functionName, _target];
			} else {
				_params remoteExec [_functionName, _target];
			};
		};
	};
	
};

diag_log "Advanced Rappelling Loaded";

};

publicVariable "AR_Advanced_Rappelling_Install";

[] call AR_Advanced_Rappelling_Install;
// Install Advanced Rappelling on all clients (plus JIP) //
remoteExecCall ["AR_Advanced_Rappelling_Install", -2,true];
