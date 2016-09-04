//Animations by Ruppertle

class CfgMovesBasic;
class CfgMovesMaleSdr: CfgMovesBasic
{
	class States
	{
		class AmovPercMstpSrasWrflDnon;
		class AmovPercMstpSrasWpstDnon;
		class AR_01_Idle: AmovPercMstpSrasWrflDnon
		{
			actions="NoActions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_idle.rtm";
			speed=100000;
			minPlayTime = 0.1;
			aiming="aimingDefault";
			leftHandIKCurve[]={0};
			variantsPlayer[]={};
			variantsAI[]={};
			ConnectTo[]={};											
			InterpolateTo[]={};
			weaponLowered=1;
		};
		class AR_01_Idle_Pistol: AmovPercMstpSrasWpstDnon
		{
			actions="NoActions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_idlepistol.rtm";
			speed=100000;
			aiming="aimingRifleSlingDefault";
			aimingBody="aimingUpRifleSlingDefault";
			variantsPlayer[]={};
			variantsAI[]={};
			ConnectTo[]={};											
			InterpolateTo[]={};
			weaponLowered=1;
		};
	};
};
