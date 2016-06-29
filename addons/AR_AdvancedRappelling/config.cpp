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