#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#pragma newdecls required

public Plugin myinfo =
{
	name = "Block Wall Damage",
	author = "Ilusion9",
	description = "Block damage done through walls.",
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

bool g_IsPluginLoadedLate;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_IsPluginLoadedLate = late;
}

public void OnPluginStart()
{
	if (g_IsPluginLoadedLate)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, SDK_OnTakeDamage);
}

public Action SDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	/* Check if the damage was not done by a player */
	if (attacker < 1 || attacker > MaxClients || inflictor < 1 || inflictor > MaxClients)
	{
		return Plugin_Continue;
	}
	
	float attackerPos[3];
	GetClientEyePosition(attacker, attackerPos);
	
	Handle trace = TR_TraceRayFilterEx(attackerPos, damagePosition, MASK_SHOT, RayType_EndPoint, TraceRayFilterPlayers);
	bool blockDamage = TR_DidHit(trace);
	delete trace;
	
	if (blockDamage)
	{
		damage = 0.0;
		damagetype |= DMG_PREVENT_PHYSICS_FORCE;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public bool TraceRayFilterPlayers(int entity, int contentsMask, any data)
{
	/* Allow all entities to be hit by the trace, except players */
	if (entity < 0 || entity > MaxClients)
	{
		return true;
	}
	
	return false;
}
