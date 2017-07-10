//Animations by Ruppertle

class CfgMovesBasic
{
	class DefaultDie;
	class ManActions
	{
		AR_01="AR_01_Idle";
								
	};
	class Actions
	{
		class RifleStandActions;
		class AR_BaseActions: RifleStandActions		
		{
			AdjustF="";
			AdjustB="";
			AdjustL="";
			AdjustR="";
			AdjustLF="";
			AdjustLB="";
			AdjustRB="";
			AdjustRF="";
			agonyStart="";
			agonyStop="";
			medicStop="";
			medicStart="";
			medicStartUp="";
			medicStartRightSide="";
			GestureAgonyCargo="";
			grabCarry="";
			grabCarried="";
			grabDrag="";
			grabDragged="";
			carriedStill="";
			released="";
			releasedBad="";
			Stop="";
			StopRelaxed="";
			TurnL="";
			TurnR="";
			TurnLRelaxed="";
			TurnRRelaxed="";
			ReloadMagazine="";
			ReloadMGun="";
			ReloadRPG="ReloadRPG";
			ReloadMortar="";
			WalkF="";
			WalkLF="";
			WalkRF="";
			WalkL="";
			WalkR="";
			WalkLB="";
			WalkRB="";
			WalkB="";
			PlayerWalkF="";
			PlayerWalkLF="";
			PlayerWalkRF="";
			PlayerWalkL="";
			PlayerWalkR="";
			PlayerWalkLB="";
			PlayerWalkRB="";
			PlayerWalkB="";
			SlowF="";
			SlowLF="";
			SlowRF="";
			SlowL="";
			SlowR="";
			SlowLB="";
			SlowRB="";
			SlowB="";
			PlayerSlowF="";
			PlayerSlowLF="";
			PlayerSlowRF="";
			PlayerSlowL="";
			PlayerSlowR="";
			PlayerSlowLB="";
			PlayerSlowRB="";
			PlayerSlowB="";
			FastF="";
			FastLF="";
			FastRF="";
			FastL="";
			FastR="";
			FastLB="";
			FastRB="";
			FastB="";
			TactF="";
			TactLF="";
			TactRF="";
			TactL="";
			TactR="";
			TactLB="";
			TactRB="";
			TactB="";
			PlayerTactF="";
			PlayerTactLF="";
			PlayerTactRF="";
			PlayerTactL="";
			PlayerTactR="";
			PlayerTactLB="";
			PlayerTactRB="";
			PlayerTactB="";
			EvasiveLeft="";
			EvasiveRight="";
			startSwim="";
			surfaceSwim="";
			bottomSwim="";
			StopSwim="";
			startDive="";
			SurfaceDive="";
			BottomDive="";
			StopDive="";
			Down="";
			Up="";
			PlayerStand="";
			PlayerCrouch="";
			PlayerProne="";
			Lying="";
			Stand="";
			Combat="";
			Crouch="";
			CanNotMove="";
			Civil="";
			CivilLying="";
			FireNotPossible="";
			WeaponOn="";
			WeaponOff="";
			Default="";
			JumpOff="";
			StrokeFist="";
			StrokeGun="";
			SitDown="";
			Salute="";
			saluteOff="";
			GetOver="";
			Diary="";
			Surrender="";
			Gear="";
			BinocOn="";
			BinocOff="";
			PutDown="";
			PutDownEnd="";
			Medic="";
			MedicOther="";
			Treated="";
			LadderOnDown="";
			LadderOnUp="";
			LadderOff="";
			LadderOffTop="";
			LadderOffBottom="";
			PrimaryWeapon="";
			SecondaryWeapon="";
			Binoculars="";
			StartFreefall = "";
			FDStart = "";
			useFastMove = 0;
			stance = "ManStanceUndefined";
		};
		class AR_01_Actions: AR_BaseActions
		{
			upDegree="ManPosCombat";		
			stop="AR_01_Aim";			
			stopRelaxed="AR_01_Aim";		
			default="AR_01_Aim";			
			Stand="AR_01_Idle";			
			HandGunOn="AR_01_Aim_Pistol";	
			PrimaryWeapon="AR_01_Aim";
			SecondaryWeapon="";		
			Binoculars="";	
			die="AR_01_Die";				
			Unconscious="AR_01_Die";		
			civil="";
		};
		class AR_01_DeadActions: AR_BaseActions
		{
			stop="AR_01_Die";
			default="AR_01_Die";
			die="AR_01_Die";
			Unconscious="AR_01_Die";
		};
		class AR_01_IdleActions: AR_01_Actions
		{
			upDegree="ManPosStand";
			stop="AR_01_Idle";
			stopRelaxed="AR_01_Idle";
			default="AR_01_Idle";
			Combat="AR_01_Aim";
			fireNotPossible="AR_01_Aim";
			PlayerStand="AR_01_Aim";
		};
		class AR_01_PistolActions: AR_01_Actions
		{
			upDegree="ManPosHandGunStand";
			stop="AR_01_Aim_Pistol";
			stopRelaxed="AR_01_Aim_Pistol";
			default="AR_01_Aim_Pistol";
			throwGrenade[]=
			{
				"GestureThrowGrenadePistol",
				"Gesture"
			};
			Stand="AR_01_Idle_Pistol";
			die="AR_01_Die_Pistol";
			Unconscious="AR_01_Die_Pistol";
		};
		class AR_01_IdlePistolActions: AR_01_Actions
		{
			upDegree="ManPosHandGunStand";
			stop="AR_01_Idle_Pistol";
			stopRelaxed="AR_01_Idle_Pistol";
			default="AR_01_Idle_Pistol";
			Combat="AR_01_Aim_Pistol";
			fireNotPossible="AR_01_Aim_Pistol";
			PlayerStand="AR_01_Aim_Pistol";
			die="AR_01_Die_Pistol";
			Unconscious="AR_01_Die_Pistol";
		};
	};
};
class CfgMovesMaleSdr: CfgMovesBasic
{
	class States
	{
		class Crew;
		class AmovPercMstpSrasWrflDnon;
		class AmovPercMstpSrasWpstDnon;
		class AmovPercMstpSoptWbinDnon;
		class AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon;
		class AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon_end;
		class AmovPpneMstpSrasWpstDnon_AmovPpneMstpSrasWrflDnon;
		class AmovPpneMstpSrasWpstDnon_AmovPpneMstpSrasWrflDnon_end;
		class ar_cargo_marksman: AmovPercMstpSrasWrflDnon
		{
		};
		class ar_cargo_base: ar_cargo_marksman	
		{
			variantsPlayer[]={};
			variantsAI[]={};
			enableMissile = 0;
			enableBinocular = 0;
		};
		class ar_cargo_base_Rope: ar_cargo_base	
		{
			ignoreMinPlayTime[] = {"Unconscious"};
			leaning = "AR_aimingDefault_Rope";
		};
		class ar_cargo_base_idle: ar_cargo_base
		{
			weaponLowered=1;
			enableOptics=0;
			disableWeapons=1;
			disableWeaponsLong=1;
			variantsPlayer[]={};
			variantsAI[]={};
		};
		class ar_cargo_basepistol: AmovPercMstpSrasWpstDnon
		{
			variantsPlayer[]={};
			variantsAI[]={};
			enableMissile = 0;
			enableBinocular = 0;
		};
		class ar_cargo_base_idle_pistol: ar_cargo_basepistol
		{
			weaponLowered=1;
			enableOptics=0;
			disableWeapons=1;
			disableWeaponsLong=1;
		};
		class AR_01_Aim: ar_cargo_base_Rope
		{
			actions="AR_01_Actions";
			leftHandIKCurve[]={1};
			minPlayTime = 0.1;								
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_aim.rtm";	/// what file is going to be played in this state
			speed=100000;											
			ConnectTo[]={};											
			InterpolateTo[]=										
			{
				"AR_01_Idle",
				0.1,
				"AR_01_Aim_ToPistol",
				0.1,
				"AR_01_Die",
				0.1
			};
			variantsAI[]=
			{
				"AR_01_Aim_Idling",
				1
			};
			variantsPlayer[]=
			{
				"AR_01_Aim_Idling",
				1
			};
		};
		class AR_01_Aim_No_Actions : AR_01_Aim
		{
			actions="NoActions";
			variantsPlayer[]={};
			variantsAI[]={};
			ConnectTo[]={};											
			InterpolateTo[]={};
		};
		class AR_01_Aim_Idling: AR_01_Aim
		{
			variantsPlayer[]={};
			headBobStrength=0;
			soundEnabled=1;
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_aim1.rtm";
			speed=-8;												
			ConnectTo[]=
			{
				"AR_01_Aim",
				0.1
			};
		};
		class AR_01_Idle: ar_cargo_base_idle
		{
			actions="AR_01_IdleActions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_idle.rtm";
			speed=100000;
			minPlayTime = 0.1;
			aiming="aimingDefault";
			leftHandIKCurve[]={0};
			InterpolateTo[]=
			{
				"AR_01_Aim",
				0.1,
				"AR_01_Aim_ToPistol",
				0.1,
				"AR_01_Die",
				0.1
			};
			variantsAI[]=
			{
				"AR_01_Idle_Idling",
				1
			};
			variantsPlayer[]=
			{
				"AR_01_Idle_Idling",
				1
			};
		};
		class AR_01_Idle_No_Actions : AR_01_Idle
		{
			actions="NoActions";
			variantsPlayer[]={};
			variantsAI[]={};
			ConnectTo[]={};											
			InterpolateTo[]={};
		};
		class AR_01_Idle_Idling: AR_01_Idle
		{
			variantsPlayer[]={};
			headBobStrength=0;
			soundEnabled=1;
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_idle1.rtm";
			speed=-10;
			ConnectTo[]=
			{
				"AR_01_Idle",
				0.1
			};
		};
		class AR_01_Aim_Pistol: ar_cargo_basepistol
		{
			actions="AR_01_PistolActions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_aimpistol.rtm";
			aiming="aimingRifleSlingDefault";
			aimingBody="aimingUpRifleSlingDefault";
			speed=100000;
			variantsAI[]=
			{
				"AR_01_Aim_Pistol_Idling",
				1
			};
			variantsPlayer[]=
			{
				"AR_01_Aim_Pistol_Idling",
				1
			};
			ConnectTo[]={};		
			InterpolateTo[]=
			{
				"AR_01_Aim_FromPistol",
				0.1,
				"AR_01_Idle_Pistol",
				0.2,
				"AR_01_Die_Pistol",
				0.5
			};
		};
		class AR_01_Aim_Pistol_No_Actions : AR_01_Aim_Pistol
		{
			actions="NoActions";
			variantsPlayer[]={};
			variantsAI[]={};
			ConnectTo[]={};											
			InterpolateTo[]={};
		};
		class AR_01_Aim_Pistol_Idling: AR_01_Aim_Pistol
		{
			variantsPlayer[]={};
			headBobStrength=0;
			soundEnabled=1;
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_aimpistol1.rtm";
			speed=-8;
			ConnectTo[]=
			{
				"AR_01_Aim_Pistol",
				0.1
			};
		};
		class AR_01_Idle_Pistol: ar_cargo_base_idle_pistol
		{
			actions="AR_01_IdlePistolActions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_idlepistol.rtm";
			speed=100000;
			aiming="aimingRifleSlingDefault";
			aimingBody="aimingUpRifleSlingDefault";
			InterpolateTo[]=
			{
				"AR_01_Aim_Pistol",
				0.1,
				"AR_01_Aim_FromPistol",
				0.1,
				"AR_01_Die_Pistol",
				0.1
			};
			variantsAI[]=
			{
				"AR_01_Idle_Pistol_Idling",
				1
			};
			variantsPlayer[]=
			{
				"AR_01_Idle_Pistol_Idling",
				1
			};
		};
		class AR_01_Idle_Pistol_No_Actions : AR_01_Idle_Pistol
		{
			actions="NoActions";
			variantsPlayer[]={};
			variantsAI[]={};
			ConnectTo[]={};											
			InterpolateTo[]={};
		};
		class AR_01_Idle_Pistol_Idling: AR_01_Idle
		{
			variantsPlayer[]={};
			headBobStrength=0;
			soundEnabled=1;
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_idlepistol1.rtm";
			speed=-10;
			ConnectTo[]=
			{
				"AR_01_Idle_Pistol",
				0.1
			};
		};
		class AR_01_Aim_ToPistol: AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon
		{
			actions="AR_01_PistolActions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_aimtopistol.rtm";
			speed=2;
			ConnectTo[]=
			{
				"AR_01_Aim_ToPistol_End",
				0.1
			};
			InterpolateTo[]={};
		};
		class AR_01_Aim_ToPistol_End: AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon_end
		{
			actions="AR_01_PistolActions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_aimtopistol_end.rtm";
			speed=1.875;
			ConnectTo[]=
			{
				"AR_01_Aim_Pistol",
				0.1
			};
			InterpolateTo[]={};
		};
		class AR_01_Aim_FromPistol: AmovPpneMstpSrasWpstDnon_AmovPpneMstpSrasWrflDnon
		{
			actions="AR_01_PistolActions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_aimFrompistol.rtm";
			speed=2.3076921;
			ConnectTo[]=
			{
				"AR_01_Aim_FromPistol_End",
				0.1
			};
			InterpolateTo[]={};
		};
		class AR_01_Aim_FromPistol_End: AmovPpneMstpSrasWpstDnon_AmovPpneMstpSrasWrflDnon_end
		{
			actions="AR_01_Actions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_aimfrompistol_end.rtm";
			aiming="aimingDefault";
			aimingBody="aimingUpDefault";
			speed=2;
			leftHandIKCurve[]={0,0,0.5,1};
			ConnectTo[]=
			{
				"AR_01_Aim",
				0.1
			};
			InterpolateTo[]={};
		};
		class AR_01_Die: DefaultDie
		{
			actions="AR_01_DeadActions";
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_die.rtm";
			speed=1;
			looped="false";
			terminal=1;
			ragdoll=1;
			ConnectTo[]=
			{
				"Unconscious",
				0.1
			};
			InterpolateTo[]={};
		};
		class AR_01_Die_Pistol: AR_01_Die
		{
			file="\AR_AdvancedRappelling\anims\Rup_RopeFX_01_die.rtm";
			actions="AR_01_DeadActions";
			showHandGun=1;
		};
	};
	class BlendAnims;
	class BlendAnims: BlendAnims
	{
		AR_aimingDefault_Rope[] = {"head",0.6,"neck1",0.6,"neck",0.6,"weapon",1,"launcher",1,"RightShoulder",0.8,"RightArm",0.8,"RightArmRoll",1,"RightForeArm",1,"RightForeArmRoll",1,"RightHand",1,"RightHandRing",1,"RightHandPinky1",1,"RightHandPinky2",1,"RightHandPinky3",1,"RightHandRing1",1,"RightHandRing2",1,"RightHandRing3",1,"RightHandMiddle1",1,"RightHandMiddle2",1,"RightHandMiddle3",1,"RightHandIndex1",1,"RightHandIndex2",1,"RightHandIndex3",1,"RightHandThumb1",1,"RightHandThumb2",1,"RightHandThumb3",1,"Spine",0.3,"Spine1",0.4,"Spine2",0.5,"Spine3",0.6};
	};
};
