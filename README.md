# Advanced Rappelling

Adds support for helicopter rappelling. SP & MP Compatible.

**Features:**

 - Rappel up to 6 players or AI from any helicopter at the same time (depending on helicopter size)
 - Enhanced rope physics. Takes into account wind speeds (from the rotor and environment) and air resistance. Players will swing around if the helicopter doesn't stay still.
 - Players control when and how quickly to descend down the rope using the "move backward" key
 - Supports rappelling onto tops of buildings, through trees, etc
 - Command AI in your group to rappel from a helicopter. AI will automatically descend the rope once told to rappel

**Directions:**

 - Get into any helicopter (not as pilot)
 - Once more than 5m off the ground, actions become available to rappel either yourself or your AI units
 - Once you are rappelling, press the "move backwards" key to descend down the rope (note: AI will auto-descend)
 
**Installation:**

1. Subscribe via steam: http://steamcommunity.com/sharedfiles/filedetails/?id=713709341 or download latest release from https://github.com/sethduda/AdvancedRappelling/releases
2. If installing this on a server, add the addon to the -serverMod command line option. It's only needed on the server side. Clients down need it. (However, if clients want to hear the nice rappelling sounds effects, they can optionally install it locally)

**Notes for Mission Makers:**

You can customize which classes of vehicles support rappelling by setting the AR_SUPPORTED_VEHICLES_OVERRIDE variable in an init.sqf file. 

```AR_SUPPORTED_VEHICLES_OVERRIDE = [ "CUP_CH47F_base", "RHS_CH_47F" ]; ```

The example above will only allow rappelling from vehicles of class CUP_CH47F_base and RHS_CH_47F.

You can define custom rappel points instead of using the default 6 rappel points by using the AP_CUSTOM_RAPPEL_POINTS variable. You can either specify [x,y,z] model positions or memory point names. Define the AP_CUSTOM_RAPPEL_POINTS variable in your init.sqf file.

Here's an example mixing both memory point names and [x,y,z] model positions. You would put this in an init.sqf file.

```
AP_CUSTOM_RAPPEL_POINTS = [
    ["CUP_CH47F_base",["slingload0",[1.2,1.0,0.5],"fastrope0"]],
    ["RHS_CH_47F", ["slingload0","slingload1","fastrope0"]]
];
```

In the example above, all vehicles of class type CUP_CH47F_base will use the rappel points defined by memory point slingload0, model position [1.2,1.0,0.5] and memory point fastrope0. All vehicles of class RHS_CH_47F will use rappel points defined by memory points slingload0, slingload1, and fastrope0. All other vehicles will use the default 6 rappel points.
 
If anyone works on heli models and would like their heli's rappel points pre-defined in my addon, let me know.

You can have AI auto-rappel from a helicopter using the following script (all units in the cargo seats will rappel): 

```[HELI_NAME] call AR_Rappel_All_Cargo ```

This function will rappel the cargo units at 25m at the heli's current position. If the heli is currently moving, it will stop so units can rappel. 

If you want more control, there are addtional parameters you can set: 

```[HELI_NAME,RAPPEL_HEIGHT,POSITION_ASL] call AR_Rappel_All_Cargo ```

RAPPEL_HEIGHT: height in meters to rappel 
POSITION_ASL: Exact position ASL where you want the units to rappel to. This script will get them within ~1m of that position. 

**Not working on your server?**

Make sure you have the mod listed in the -mod or -serverMod command line option. Only -serverMod is required for this addon. If still not working, check your server log to make sure the addon is found. 

**FAQ**

*This addon is only required on the server - is it going to slow down my server?*

No - while this addon is server-side only, it installs itself on all clients without them downloading the addon. Most of the time, the rappelling code actually runs client-side, even though you installed the addon only on the server. Magic! 

*Battleye kicks me when I try to do xyz. What do I do?*

You need to configure Battleye rules on your server. Below are the files you need to configure: 

setvariable.txt 

Add the following exclusions to the end of all lines starting with 4, 5, 6, or 7 if they contain "" (meaning applies to all values): 

!"AR_"

setvariableval.txt 

If you have any lines starting with 4, 5, 6, or 7 and they contain "" (meaning applies to all values) it's not going to work. Either remove the line or explicitly define the values you want to kick. Since the values of the variables above can vary, I don't know of a good way to define an exclusion rule. 

Also, it's possible there are other battleye filter files that can cause issues. If you check your battleye logs you can figure out which file is causing a problem.

*The rappelling action appears while in a heli, but do nothing when I select them. How do I fix that?*

Most likely your server is setup with a white list for remote executions. In order to fix this, you need to modify your mission's description.ext file, adding the following CfgRemoteExec rules. If using InfiStar you should edit your cfgremoteexec.hpp instead of the description.ext file. See https://community.bistudio.com/wiki/Arma_3_Remote_Execution for more details on CfgRemoteExec.

```
class CfgRemoteExec
{
	class Functions
	{
		class AR_Client_Rappel_From_Heli { allowedTargets=0; }; 
		class AR_Hint { allowedTargets=1; }; 
		class AR_Hide_Object_Global { allowedTargets=2; }; 
		class AR_Enable_Rappelling_Animation { allowedTargets=2; }; 
		class AR_Rappel_From_Heli { allowedTargets=2; }; 
	};
};
```

**Issues & Feature Requests**

https://github.com/sethduda/AdvancedRappelling/issues 

If anyone wants to help fix any of these, please let me know. You can fork the repo and create a pull request. 

**Special Thanks for Testing & Support:**

- Stay Alive Tactical Team (http://sa.clanservers.com)
- Boosh and Beachhead

---

The MIT License (MIT)

Copyright (c) 2016 Seth Duda

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
