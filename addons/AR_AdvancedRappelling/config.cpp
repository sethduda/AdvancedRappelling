class CfgPatches
{
	class AR_AdvancedRappelling
	{
		units[] = {"AR_AdvancedRappelling"};
		requiredVersion = 1.0;
		requiredAddons[] = {"A3_Modules_F"};
	};
};

class CfgNetworkMessages
{
	
	class AdvancedRappellingRemoteExecClient
	{
		module = "AdvancedRappelling";
		parameters[] = {"ARRAY","STRING","OBJECT","BOOL"};
	};
	
	class AdvancedRappellingRemoteExecServer
	{
		module = "AdvancedRappelling";
		parameters[] = {"ARRAY","STRING","BOOL"};
	};
	
};

class CfgFunctions 
{
	class SA
	{
		class AdvancedRappelling
		{
			file = "\AR_AdvancedRappelling\functions";
			class advancedRappellingInit{postInit=1};
		};
	};
};

class CfgSounds
{
	class AR_Rappel_Loop
	{
		name = "AR_Rappel_Loop";
		sound[] = {"\AR_AdvancedRappelling\sounds\AR_Rappel_Loop.ogg", db+20, 1};
		titles[] = {0,""};
	};
	class AR_Rappel_Start
	{
		name = "AR_Rappel_Start";
		sound[] = {"\AR_AdvancedRappelling\sounds\AR_Rappel_Start.ogg", db+20, 1};
		titles[] = {0,""};
	};
	class AR_Rappel_End
	{
		name = "AR_Rappel_End";
		sound[] = {"\AR_AdvancedRappelling\sounds\AR_Rappel_End.ogg", db+20, 1};
		titles[] = {0,""};
	};
};

#include "cfgAnimations.hpp"