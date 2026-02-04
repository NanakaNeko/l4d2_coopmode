#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <left4dhooks>

public Plugin myinfo =
{
	name = "[L4D2]战役对抗模式",
	author = "奈",
	description = "coop versus",
	version = "1.2.1",
	url = "https://github.com/NanakaNeko/l4d2_plugins_coop"
};

public void OnPluginStart()
{
	SetConVarBool(FindConVar("sb_all_bot_game"), true);
	SetConVarInt(FindConVar("vs_max_team_switches"), 0);
	SetConVarInt(FindConVar("versus_round_restarttimer"), 0);
	SetConVarInt(FindConVar("versus_round_restarttimer_finale"), 0);
	SetConVarInt(FindConVar("z_mob_spawn_min_interval_normal"), 3600);
	SetConVarInt(FindConVar("z_mob_spawn_max_interval_normal"), 3600);
	HookEvent("player_team", Event_PlayerTeam);
}

public void OnPluginEnd()
{
	SetConVarString(FindConVar("mp_gamemode"), "coop");
	SetConVarBool(FindConVar("sb_all_bot_game"), false);
	FindConVar("vs_max_team_switches").RestoreDefault();
	FindConVar("versus_round_restarttimer").RestoreDefault();
	FindConVar("versus_round_restarttimer_finale").RestoreDefault();
	FindConVar("z_mob_spawn_min_interval_normal").RestoreDefault();
	FindConVar("z_mob_spawn_max_interval_normal").RestoreDefault();
}

public void OnMapEnd()
{
	SetConVarString(FindConVar("mp_gamemode"), "coop");
}

public Action Event_PlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetEventInt(event, "userid");
	int target = GetClientOfUserId(client);
	int team = GetEventInt(event, "team");
	bool disconnect = GetEventBool(event, "disconnect");
	if (0 < target <= MaxClients && IsClientConnected(target) && IsClientInGame(target) && !disconnect && team == 3)
	{
		if(!IsFakeClient(target))
		{
			CreateTimer(0.5, Timer_Check, target, TIMER_FLAG_NO_MAPCHANGE);
		}else{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action Timer_Check(Handle Timer, int client)
{
	ChangeClientTeam(client, 1); 
	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	if(client > 0 && IsClientConnected(client) && !IsFakeClient(client))
		CreateTimer(3.0, timer_team, client, TIMER_FLAG_NO_MAPCHANGE);
}

Action timer_team(Handle timer, int client)
{
	if(0 < client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && GetClientTeam(client) == 3)
		ChangeClientTeam(client, 1);
	return Plugin_Continue;
}

// 对抗计分面板出现前，切换游戏模式为战役
public Action L4D2_OnEndVersusModeRound(bool countSurvivors)
{
	SetConVarString(FindConVar("mp_gamemode"), "coop");
	return Plugin_Handled;
}

// 开局，切换游戏模式为对抗
public Action L4D_OnFirstSurvivorLeftSafeArea(int client)
{
	SetConVarString(FindConVar("mp_gamemode"), "versus");
	return Plugin_Stop;
}