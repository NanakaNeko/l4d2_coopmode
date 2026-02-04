#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

#define Difficulty 4
ConVar
	cv_hostname,
	cv_hostport,
	cv_difficulty,
	cv_gamemode,
	cv_alone,
	cv_fog,
	cv_lily,
	cv_hunter,
	cv_hunterParty,
	cv_charger;

ConVar cv_SiNum, cv_SiTime;
//int SiNum, SiTime;
static KeyValues key;
char c_DifficultyName[Difficulty][16] = {"[简单]", "[普通]", "[高级]", "[专家]"};
char c_DifficultyCode[Difficulty][16] = {"Easy", "Normal", "Hard", "Impossible"};

public Plugin myinfo = 
{
	name = "服务器名字",
	author = "奈",
	description = "服务器名",
	version = "1.3.4",
	url = "https://github.com/NanakaNeko/l4d2_plugins_coop"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion game = GetEngineVersion();
	if (game!=Engine_Left4Dead && game!=Engine_Left4Dead2)
	{
		strcopy(error, err_max, "本插件只支持 Left 4 Dead 1&2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	cv_SiNum = FindConVar("l4d2_si_spawn_control_max_specials");
	cv_SiTime = FindConVar("l4d2_si_spawn_control_spawn_time");
	if(cv_SiNum != null && cv_SiTime != null){
		cv_SiNum.AddChangeHook(CvarInfected);
		cv_SiTime.AddChangeHook(CvarInfected);
	}
	//SiNum = GetConVarInt(cv_SiNum);
	//SiTime = GetConVarInt(cv_SiTime);
	cv_alone = CreateConVar("l4d2_alone_mode", "0");
	cv_fog = CreateConVar("l4d2_fog_mode", "0");
	cv_lily = CreateConVar("l4d2_lily_mode", "0");
	cv_hunter = CreateConVar("l4d2_hunter_mode", "0");
	cv_hunterParty = CreateConVar("l4d2_hunter_party_mode", "0");
	cv_charger = CreateConVar("l4d2_charger_mode", "0");

	key = new KeyValues("hostname");
	cv_hostport = FindConVar("hostport");
	cv_hostname = FindConVar("hostname");
	cv_difficulty = FindConVar("z_difficulty");
	cv_gamemode = FindConVar("mp_gamemode");
	HookConVarChange(cv_difficulty, CvarChange);
	HookConVarChange(cv_gamemode, CvarChange);
	HookConVarChange(cv_alone, CvarChange);
	HookConVarChange(cv_fog, CvarChange);
	HookConVarChange(cv_lily, CvarChange);
	HookConVarChange(cv_hunter, CvarChange);
	HookConVarChange(cv_hunterParty, CvarChange);
	HookConVarChange(cv_charger, CvarChange);

	char filePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, filePath, sizeof(filePath), "data/hostname.txt");
	if (FileExists(filePath))
	{
		if (!key.ImportFromFile(filePath))
		{
			SetFailState("导入 %s 失败！", filePath);
		}
	}
	setHostname();
}

public void CvarChange(ConVar convar, const char[] oldValue, const char[] newValue) 
{
	setHostname();
}

public void CvarInfected(ConVar convar, const char[] oldValue, const char[] newValue) 
{
	//SiNum = GetConVarInt(cv_SiNum);
	//SiTime = GetConVarInt(cv_SiTime);
	setHostname();
}

public void OnClientPutInServer(int client)
{
	setHostname();
}

public void setHostname()
{
	char port[16], servername[256];
	FormatEx(port, sizeof(port), "%d", cv_hostport.IntValue);
	key.JumpToKey(port);
	key.GetString("hostname", servername, sizeof(servername), "求死之路");
	if(!isServerEmpty())
	{
		//多特
		char infected[16];
		FormatEx(infected, sizeof(infected), "[%i特%i秒]", GetConVarInt(cv_SiNum), GetConVarInt(cv_SiTime));
		StrCat(servername, sizeof(servername), infected);
		//单人
		if(cv_alone.BoolValue)
			StrCat(servername, sizeof(servername), "[单人]");
		//浓雾
		if(cv_fog.BoolValue)
			StrCat(servername, sizeof(servername), "[浓雾]");
		//药役
		if(cv_lily.BoolValue)
			StrCat(servername, sizeof(servername), "[药役]");
		//hunter
		if(cv_hunter.BoolValue)
			StrCat(servername, sizeof(servername), "[单人HT]");
		//hunter party
		if(cv_hunterParty.BoolValue)
			StrCat(servername, sizeof(servername), "[HT派对]");
		//charger
		if(cv_charger.BoolValue)
			StrCat(servername, sizeof(servername), "[牛牛快跑]");
		//模式
		char GameMode[32];
		GetConVarString(cv_gamemode, GameMode, sizeof(GameMode));
		if(StrEqual(GameMode, "realism"))
			StrCat(servername, sizeof(servername), "[写实]");
		if(StrEqual(GameMode, "community5"))
			StrCat(servername, sizeof(servername), "[死门]");
		if(StrEqual(GameMode, "mutation2"))
			StrCat(servername, sizeof(servername), "[猎头]");
		if(StrEqual(GameMode, "survival"))
			StrCat(servername, sizeof(servername), "[生还者]");
		if(StrEqual(GameMode, "community4"))
			StrCat(servername, sizeof(servername), "[噩梦经历]");
		//难度
		for (int i = 0; i < Difficulty; i++)
			if(StrEqual(GetGameDifficulty(), c_DifficultyCode[i], false))
				StrCat(servername, sizeof(servername), c_DifficultyName[i]);
	}
	cv_hostname.SetString(servername);
}

public void OnConfigsExecuted()
{
	if(cv_SiNum != null && cv_SiTime != null){
		cv_SiNum.AddChangeHook(CvarInfected);
		cv_SiTime.AddChangeHook(CvarInfected);
	}
	else if(FindConVar("l4d2_si_spawn_control_max_specials") && FindConVar("l4d2_si_spawn_control_spawn_time")){
		cv_SiNum = FindConVar("l4d2_si_spawn_control_max_specials");
		cv_SiTime = FindConVar("l4d2_si_spawn_control_spawn_time");
		cv_SiNum.AddChangeHook(CvarInfected);
		cv_SiTime.AddChangeHook(CvarInfected);
	}

	setHostname();
}

bool isServerEmpty()
{
	for (int i = 1; i <= MaxClients; i++) { if (IsClientConnected(i) && !IsFakeClient(i)) { return false; } }
	return true;
}

char[] GetGameDifficulty()
{
	char GameDifficulty[16];
	GetConVarString(cv_difficulty, GameDifficulty, sizeof(GameDifficulty));
	return GameDifficulty;
}