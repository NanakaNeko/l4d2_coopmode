#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

public Plugin myinfo =
{
	name = "fog",
	author = "奈",
	description = "fog",
	version = "1.1",
	url = "https://github.com/NanakaNeko/l4d2_plugins_coop"
};

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "env_fog_controller", true))
		SDKHook(entity, SDKHook_Spawn, Fog_Controller);
}

Action Fog_Controller(int entity)
{
	DispatchKeyValue(entity, "fogenable", "1");
	//DispatchKeyValue(entity, "fogstart", "242");
	DispatchKeyValue(entity, "fogstart", "1");
	DispatchKeyValue(entity, "fogend", "730");
	DispatchKeyValue(entity, "fogcolor", "44 25 28");
	DispatchKeyValue(entity, "fogcolor2", "44 25 28");
	//DispatchKeyValue(entity, "fogcolor", "22 25 28");
	//DispatchKeyValue(entity, "fogcolor2", "22 25 28");
	AcceptEntityInput(entity, "TurnOn", -1, -1, 0);
	return Plugin_Handled;
}

/**
public Action L4D_OnFirstSurvivorLeftSafeArea(int client)
{
	CreateSnow();
	return Plugin_Stop;
}

void CreateSnow()
{
	int value, entity = -1;
	while( (entity = FindEntityByClassname(entity, "func_precipitation")) != INVALID_ENT_REFERENCE )
	{
		value = GetEntProp(entity, Prop_Data, "m_nPrecipType");
		if( value < 0 || value == 4 || value > 5 )
			RemoveEntity(entity);
	}

	entity = CreateEntityByName("func_precipitation");
	if( entity != -1 )
	{
		char buffer[128];
		GetCurrentMap(buffer, sizeof(buffer));
		Format(buffer, sizeof(buffer), "maps/%s.bsp", buffer);

		DispatchKeyValue(entity, "model", buffer);
		DispatchKeyValue(entity, "targetname", "silver_snow");
		DispatchKeyValue(entity, "preciptype", "3");
		DispatchKeyValue(entity, "renderamt", "100");
		DispatchKeyValue(entity, "rendercolor", "200 200 200");

		int g_iSnow = EntIndexToEntRef(entity);

		float vBuff[3], vMins[3], vMaxs[3];
		GetEntPropVector(0, Prop_Data, "m_WorldMins", vMins);
		GetEntPropVector(0, Prop_Data, "m_WorldMaxs", vMaxs);
		SetEntPropVector(g_iSnow, Prop_Send, "m_vecMins", vMins);
		SetEntPropVector(g_iSnow, Prop_Send, "m_vecMaxs", vMaxs);

		bool found = false;
		for( int i = 1; i <= MaxClients; i++ )
		{
			if( !found && IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) )
			{
				found = true;
				GetClientAbsOrigin(i, vBuff);
				break;
			}
		}

		if( !found )
		{
			vBuff[0] = vMins[0] + vMaxs[0];
			vBuff[1] = vMins[1] + vMaxs[1];
			vBuff[2] = vMins[2] + vMaxs[2];
		}

		DispatchSpawn(g_iSnow);
		ActivateEntity(g_iSnow);
		TeleportEntity(g_iSnow, vBuff, NULL_VECTOR, NULL_VECTOR);
	}
	else
		LogError("Failed to create Snow %d 'func_precipitation'");

}
**/
