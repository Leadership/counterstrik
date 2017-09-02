/*
C4 Timer Count Hud & Sound (C4 Timer HS)
version: 1.4
by: PoSiTiOn Of PoWeR (P.Of.Pw)
Credits: SAMURAI, connor for circle hud coordonate (X,Y)
*/

#include <amxmodx>
#include <csx>

#define VERSION "1.4b"
#define TASK_C4 803891
#define MAX_PLAYERS 32

new const color_R[]=
{
	0,
	0,
	0,
	255,
	255
}

new const color_G[]=
{
	0,
	255,
	255,
	170,
	0
}

new const color_B[]=
{
	255,
	255,
	0,
	0,
	0
}

//by connor
new const Float:g_flCoords[][] = 
{
	{0.50, 0.40},
	{0.56, 0.44},
	{0.60, 0.50},
	{0.56, 0.56},
	{0.50, 0.60},
	{0.44, 0.56},
	{0.40, 0.50},
	{0.44, 0.44}
}

new g_pcvar[5], g_textmsg,
g_C4Timer, mpc4timer,
count, start, color = sizeof color_R,
g_iPlayerPos[MAX_PLAYERS+1], g_MaxPlayers

public plugin_init() 
{
	register_plugin("C4 Timer Count Hud & Sound", VERSION, "P.Of.Pw")
	register_cvar("C4 Timer Count Hud & Sound", VERSION, FCVAR_SERVER)
	
	g_pcvar[0] = register_cvar("c4_count_hs_on", "1")
	g_pcvar[1] = register_cvar("c4_count_hs_mode", "1")
	g_pcvar[2] = register_cvar("c4_count_hs_sound", "1")
	g_pcvar[3] = register_cvar("c4_count_hs_bomb_dropped", "1")
	g_pcvar[4] = register_cvar("c4_count_hs_bomb_pickup", "1")
	
	mpc4timer = get_cvar_pointer("mp_c4timer")
	g_textmsg = get_user_msgid("TextMsg")
	g_MaxPlayers = get_maxplayers()
	
	register_event("ResetHUD", "reset_c4timer", "be")
	register_event("SendAudio", "round_end_by_win", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw") 
	
	register_logevent("logevent_newround", 2, "1=Round_Start")
	register_logevent("logevent_endround", 2, "1=Round_End")
	register_logevent("logevent_endround", 2, "1&Restart_Round_")
	
	register_message(g_textmsg, "message_bomb")
}

public bomb_planted() 
{
	new plugin_on = get_pcvar_num(g_pcvar[0])
	if (!plugin_on)
		return
		
	client_print(0, print_chat, "[ ** ] A bomba foi ativada!!!")
	
	new bomb_sound = get_pcvar_num(g_pcvar[2])
	if (bomb_sound)
		client_cmd(0, "spk misc/bomba_2.wav")
	
	g_C4Timer = get_pcvar_num(mpc4timer) - 1
	
	new bomb_mode = get_pcvar_num(g_pcvar[1])
	switch (bomb_mode)
	{
		case 1: set_task(1.0, "effect_one", TASK_C4, "", 0, "b")
		case 2: set_task(1.0, "effect_two", TASK_C4, "", 0, "b")
		case 3: set_task(1.0, "effect_three", TASK_C4, "", 0, "b")
		default: set_task(1.0, "effect_one", TASK_C4, "", 0, "b") 
	}
}

public effect_one() 
{
	if (g_C4Timer > 0)
	{ 
		if (g_C4Timer > 20)
		{
			set_hudmessage(0, 255, 0, -1.0, 0.17, 0, 6.0, 12.0)
			show_hudmessage(0, "[C4] Tempo: %d", g_C4Timer)	
		}
		
		if (g_C4Timer <= 20 && g_C4Timer > 0)
		{
			new bomb_sound = get_pcvar_num(g_pcvar[2])
			if (bomb_sound)
			{
				new temp[48]
				num_to_word(g_C4Timer, temp, 47)
				client_cmd(0, "spk ^"vox/%s^"", temp)
			}
			
			switch (g_C4Timer) 
			{
				case 20:
					set_hudmessage(235, 45, 0, 0.93, 0.09, 0, 0.0, 1.0, 0.2, 0.2, 4) 	
				case 19:
					set_hudmessage(235, 45, 0, 0.94, 0.13, 0, 0.0, 1.0, 0.2, 0.2, 4)  
				case 18:
					set_hudmessage(235, 45, 0, 0.93, 0.18, 0, 0.0, 1.0, 0.2, 0.2, 4)  	
				case 17:
					set_hudmessage(235, 45, 0, 0.93, 0.25, 0, 0.0, 1.0, 0.2, 0.2, 4)
				case 16:
					set_hudmessage(235, 45, 0, 0.93, 0.32, 0, 0.0, 1.0, 0.2, 0.2, 4) 	
				case 15:
					set_hudmessage(235, 45, 0, 0.94, 0.43, 0, 0.0, 1.0, 0.2, 0.2, 4) 
				case 14:
					set_hudmessage(235, 45, 0, 0.93, 0.62, 0, 0.0, 1.0, 0.2, 0.2, 4) 	
				case 13:
					set_hudmessage(235, 45, 0, 0.93, 0.64, 0, 0.0, 1.0, 0.2, 0.2, 4) 
				case 12:
					set_hudmessage(235, 45, 0, 0.93, 0.73, 0, 0.0, 1.0, 0.2, 0.2, 4)  
				case 11:
					set_hudmessage(235, 45, 0, 0.93, 0.81, 0, 0.0, 1.0, 0.2, 0.2, 4)  
				case 10:
					set_hudmessage(235, 45, 0, 0.05, 0.75, 0, 0.0, 1.0, 0.2, 0.2, 4) 
				case 9:
					set_hudmessage(235, 45, 0, 0.05, 0.70, 0, 0.0, 1.0, 0.2, 0.2, 4)
				case 8:
					set_hudmessage(235, 45, 0, 0.05, 0.65, 0, 0.0, 1.0, 0.2, 0.2, 4)
				case 7:
					set_hudmessage(235, 45, 0, 0.05, 0.60, 0, 0.0, 1.0, 0.2, 0.2, 4)
				case 6:
					set_hudmessage(235, 45, 0, 0.05, 0.55, 0, 0.0, 1.0, 0.2, 0.2, 4)
				case 5:
					set_hudmessage(235, 45, 0, 0.05, 0.50, 0, 0.0, 1.0, 0.2, 0.2, 4)
				case 4:
					set_hudmessage(235, 45, 0, 0.05, 0.45, 0, 0.0, 1.0, 0.2, 0.2, 4)
				case 3:
					set_hudmessage(235, 45, 0, 0.05, 0.40, 0, 0.0, 1.0, 0.2, 0.2, 4)
				case 2:
					set_hudmessage(235, 45, 0, 0.05, 0.35, 0, 0.0, 1.0, 0.2, 0.2, 4)
				case 1:
					set_hudmessage(235, 45, 0, 0.05, 0.30, 0, 0.0, 1.0, 0.2, 0.2, 4)
				default:
					set_hudmessage(235, 45, 0, 0.05, 0.75, 0, 0.0, 1.0, 0.2, 0.2, 4)
			}
			
			show_hudmessage(0, "%d", g_C4Timer) 
		}
		
		--g_C4Timer 
	}
	
	else 
		remove_task(TASK_C4)
}

public effect_two()
{
	if (g_C4Timer > 0)
	{
		set_hudmessage(color_R[count], color_G[count], color_B[count], -1.0, 0.83, 0, 1.0, 1.0, 0.01, 0.01, -1)
      
		count = start
		? count - 1 
		: count + 1

		if (!start && count >= color - 1)
		{
			count = color -1
			start = 1
		}

		else if (start && count <= color - 1)
		{
			count = 0
			start = 0
		}
      
		show_hudmessage(0, "A bomba vai explodir em: %d segundos!", g_C4Timer)
 
		--g_C4Timer
	}
	
	else 
		remove_task(TASK_C4)
}

public effect_three()
{
	if (g_C4Timer > 0)
	{ 
		if (g_C4Timer > 20)
		{
			set_hudmessage(0, 255, 0, -1.0, 0.17, 0, 5.0, 1.7)
			show_hudmessage(0, "[C4] Timer: %d", g_C4Timer)	
		}
		
		if (g_C4Timer <= 20 && g_C4Timer > 0)
		{
			new bomb_sound = get_pcvar_num(g_pcvar[2])
			if (bomb_sound)
			{
				new temp[48]
				num_to_word(g_C4Timer, temp, 47)
				client_cmd(0, "spk ^"vox/%s^"", temp)
			}
			
			for (new id = 1; id <= g_MaxPlayers; id++)
			{
				if (!is_user_connected(id))
					continue
				
				//by connor
				new iPos = ++g_iPlayerPos[id]
				if (iPos == sizeof(g_flCoords))
				{
					iPos = g_iPlayerPos[id] = 0
				}
				
				set_hudmessage(color_R[count], color_G[count], color_B[count], Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
      
				count = start
				? count - 1 
				: count + 1

				if (!start && count >= color - 1)
				{
					count = color -1
					start = 1
				}

				else if (start && count <= color - 1)
				{
					count = 0
					start = 0
				}
      
				show_hudmessage(0, "[C4]: %d", g_C4Timer)
			}
		}
		
		--g_C4Timer
	}
	
	else 
		remove_task(TASK_C4)
}

public bomb_defused() 
{
	new plugin_on = get_pcvar_num(g_pcvar[0])
	if (!plugin_on)
		return
	
	new bomb_sound = get_pcvar_num(g_pcvar[2])
	if (bomb_sound)
		client_cmd(0, "spk misc/defusebmb.wav")
	
	set_hudmessage(0, 0, 255, -1.0, 0.16, 0, 6.0, 5.0)
	show_hudmessage(0, "[ ** ] A bomba foi desarmada!")
	
	remove_bomb_task()
}

public bomb_explode() 
{
	new plugin_on = get_pcvar_num(g_pcvar[0])
	if (!plugin_on)
		return
	
	new bomb_sound = get_pcvar_num(g_pcvar[2])
	if (bomb_sound)
		client_cmd(0, "spk misc/explodebmb.wav")
	
	set_hudmessage(255, 0, 0, -1.0, 0.16, 0, 6.0, 6.0)
	show_hudmessage(0, "[ ** ] A bomba explodiu!")
	
	remove_bomb_task()
}

public message_bomb(msg_id, msg_dest, id)
{
	new plugin_on = get_pcvar_num(g_pcvar[0])
	if (!plugin_on)
		return PLUGIN_CONTINUE
    
	static msg[64]
	get_msg_arg_string(2, msg, sizeof msg - 1)
	
	new cbomb_dropped = get_pcvar_num(g_pcvar[3])
	if (cbomb_dropped && equal(msg, "#Game_bomb_drop"))
	{
		set_hudmessage(255, 0, 0, -1.0, 0.16, 0, 6.0, 5.0)
		show_hudmessage(0, "[ ** ] A bomba foi perdida!")
		return PLUGIN_HANDLED
	}
	
	new cbomb_pickup = get_pcvar_num(g_pcvar[4])
	if (cbomb_pickup  && equal(msg, "#Game_bomb_pickup") || cbomb_pickup  && equal(msg, "#Got_bomb"))
	{
		set_hudmessage(255, 0, 0, -1.0, 0.16, 0, 6.0, 6.0)
		show_hudmessage(0, "[ ** ] A bomba foi recuperada!^n Go go go...")
		return PLUGIN_HANDLED
	}
	
	if (equal(msg, "#Bomb_Planted") || equal(msg, "#Target_Bombed") || equal(msg, "#Bomb_Defused"))
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE
}

public reset_c4timer()
{
	g_C4Timer = 0
}

public round_end_by_win()
{
	remove_bomb_task()
}

public logevent_newround()
{
	remove_bomb_task()
}

public logevent_endround()
{
	remove_bomb_task()
}

public plugin_end()
{
	remove_bomb_task()
}

public remove_bomb_task()
{
	new plugin_on = get_pcvar_num(g_pcvar[0])
	if (!plugin_on)
		return
		
	g_C4Timer = -1
	remove_task(TASK_C4)
}

public plugin_precache() 
{
	precache_sound("misc/bomba_2.wav")
	precache_sound("misc/explodebmb.wav")
	precache_sound("misc/defusebmb.wav")
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang3081\\ f0\\ fs16 \n\\ par }
*/
