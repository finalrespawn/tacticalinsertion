#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>
#include <smlib>

#pragma semicolon 1
#pragma newdecls required

Handle g_TacticalInsertion = INVALID_HANDLE;

bool g_TacInsHas[MAXPLAYERS + 1];
bool g_PlacingTacIns[MAXPLAYERS + 1];

float g_FirstTacIns[MAXPLAYERS + 1][3];
float g_TempTacIns[MAXPLAYERS + 1][3];

int g_ButtonsPressed[MAXPLAYERS + 1];
int g_TacInsSec[MAXPLAYERS + 1];
int g_RedGlowSprite;

public void OnMapStart()
{
	g_TacticalInsertion = CreateTimer(0.1, Timer_TacticalInsertion, _, TIMER_REPEAT);
	g_RedGlowSprite = PrecacheModel("sprites/purpleglow1.vmt");
}

public void OnMapEnd()
{
	ClearTimer(g_TacticalInsertion);
}

public void OnClientDisconnect_Post(int Client)
{
	g_ButtonsPressed[Client] = 0;
}

public Action OnPlayerRunCmd(int Client, int &Buttons)
{
	g_ButtonsPressed[Client] = Buttons;
}

public Action Timer_TacticalInsertion(Handle timer, any data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i))
			continue;
			
		if (GetClientTeam(i) != CS_TEAM_T || !IsPlayerAlive(i))
			continue;
			
		if (g_PlacingTacIns[i])
		{
			if (g_TacInsSec[i] >= 20)
			{
				PrintHintText(i, "Placed tactical insertion!");
				g_TacInsHas[i] = true;
				TE_SetupGlowSprite(g_FirstTacIns[i], g_RedGlowSprite, 1.0, 0.5, 250);
				TE_SendToAll();
				continue;
			}
			else
			{
				GetClientAbsOrigin(i, g_TempTacIns[i]);
				
				if (g_TempTacIns[i][0] != g_FirstTacIns[i][0])
				{
					PrintToChat(i, "You cannot move while placing your tactial insertion.");
					g_PlacingTacIns[i] = false;
				}
				else
				{
					g_TacInsSec[i]++;
				}
				
				PrintHintText(i, "Stage %i", g_TacInsSec[i]);
				continue;
			}
		}
		
		int Buttons = g_ButtonsPressed[i];
		
		if (Buttons & IN_RELOAD)
		{
			if (!(GetEntityFlags(i) & FL_ONGROUND))
				PrintToChat(i, "You need to be on the ground to use your tactial insertion.");
			
			g_PlacingTacIns[i] = true;
			GetClientAbsOrigin(i, g_FirstTacIns[i]);
		}
	}
}

stock void ClearTimer(Handle &timer)
{
	if (timer != INVALID_HANDLE)
	{
		KillTimer(timer);
		timer = INVALID_HANDLE;
	}
}