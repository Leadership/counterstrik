#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
#include <cstrike>
#include <engine>

new g_type
new prim, sec, gren, armor_type
new g_prim[33], g_sec[33], g_gren[33], g_armor_type[33]

new const Primary[][] = { "weapon_scout", "weapon_xm1014", "weapon_mac10", "weapon_aug", "weapon_ump45", "weapon_sg550", "weapon_galil", "weapon_famas", "weapon_awp", "weapon_mp5navy", "weapon_m249", "weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_sg552", "weapon_ak47", "weapon_p90" }
new const Secondary[][] = { "weapon_glock18", "weapon_usp", "weapon_p228", "weapon_deagle", "weapon_elite", "weapon_fiveseven" }
new PrimAmmo[] = { CSW_SCOUT, CSW_XM1014, CSW_MAC10, CSW_AUG, CSW_UMP45, CSW_SG550, CSW_GALIL, CSW_FAMAS, CSW_AWP, CSW_MP5NAVY, CSW_M249, CSW_M3, CSW_M4A1, CSW_TMP, CSW_G3SG1, CSW_SG552, CSW_AK47, CSW_P90 }
new SecAmmo[] = { CSW_GLOCK18, CSW_USP, CSW_P228, CSW_DEAGLE, CSW_ELITE, CSW_FIVESEVEN }
new const Grenades[][] = { "weapon_hegrenade", "weapon_flashbang", "weapon_smokegrenade" }
new MaxPrim[] = { 90, 32, 100, 90, 100, 90, 90, 90, 30, 120, 200, 32, 90, 120, 90, 90, 90, 100 }
new MaxSec[] = { 120, 100, 52, 35, 120, 100 }
new const MessagesPrim[][] = { "Scout", "XM1014", "MAC10", "AUG", "UMP45", "SG550", "Galil", "Famas", "AWP", "MP5NAVY", "M249", "M3", "M4A1", "TMP", "G3SG1", "SG552", "AK47", "P90"}
new const MessagesSec[][] = { "Glock18", "USP", "P228", "Deagle", "Elite", "Fiveseven"}
new const MessagesGren[][] = { "взрывные", "слеповые", "дымовые"}
new const MessagesArmor[][] = { "", " и броня", " и броня со шлемом" }


public plugin_init()
{
	register_plugin("Weapon Mod", "beta", "Chaiker")

	RegisterHam(Ham_Spawn, "player", "fwd_HamSpawn", 1)
	RegisterHam(Ham_CS_RoundRespawn, "player", "fwd_HamSpawn", 1)

	register_event("HLTV", "EventRoundStart", "a", "1=0", "2=0")

	g_type = register_cvar("wm_type", "1") // [1 - todos igualmente armados | 2 - com tudo diferente aleatória]
}

public plugin_precache()
{
	new Ent = create_entity("info_map_parameters")
        DispatchKeyValue(Ent, "buying", "3")
	DispatchSpawn(Ent)
	server_cmd("sv_restart 1")
}

public pfn_keyvalue(Ent)  
{ 
	new ClassName[20], dummy[2]
	copy_keyvalue(ClassName, charsmax(ClassName), dummy, charsmax(dummy), dummy, charsmax(dummy))
	if(equal(ClassName, "info_map_parameters"))
	{
		remove_entity(Ent)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public EventRoundStart()
	random_weapon()

random_weapon()
{
	if(get_pcvar_num(g_type) == 1)
	{
		prim = random_num(0, 17)
		sec = random_num(0, 5)
		gren = random_num(0, 2)
		armor_type = random_num(0, 2)
		//server_print("type = %d, %d, %d, %d", prim, sec, gren)
	}
}

public fwd_HamSpawn(id)
{
	if(!is_user_connected(id) || !is_user_alive(id)) return PLUGIN_HANDLED
	remove_task(id)
	if(cs_get_user_team(id) == CS_TEAM_T || cs_get_user_team(id) == CS_TEAM_CT)
	{
		give_weapon(id)
		//server_print("gived - %d", get_pcvar_num(g_type))
	}
	return PLUGIN_HANDLED
}

give_weapon(id)
{
	//server_print("type = %d", get_pcvar_num(g_type))
	switch(get_pcvar_num(g_type))
	{
		case 1:
		{
			client_print(id, print_center, "jogar com %s e %s. todos emitidos%s granadas%s", MessagesPrim[prim], MessagesSec[sec], MessagesGren[gren], MessagesArmor[armor_type])
			client_print(id, print_console, "Jogar com %s e %s. todos emitidos%s granadas%s", MessagesPrim[prim], MessagesSec[sec], MessagesGren[gren], MessagesArmor[armor_type])
			set_task(1.9, "CenterMsg", id, _, _, "a", 3)
			if(!user_has_weapon(id, CSW_C4))
				strip_user_weapons(id)
			else
			{
				strip_user_weapons(id)
				give_item(id, "weapon_c4")
			}
			give_item(id, "weapon_knife")
			give_item(id, Primary[prim])
			give_item(id, Secondary[sec])
			give_item(id, Grenades[gren])
			cs_set_user_bpammo(id, PrimAmmo[prim], MaxPrim[prim])
			cs_set_user_bpammo(id, SecAmmo[sec], MaxSec[sec])
			if(armor_type != 0)
				cs_set_user_armor(id, 100, CsArmorType:armor_type)
			if(gren == 1)
				cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
		}
		case 2:
		{
			g_prim[id] = random_num(0, 17)
			g_sec[id] = random_num(0, 5)
			g_gren[id] = random_num(0, 2)
			g_armor_type[id] = random_num(0, 2)
			set_task(1.9, "CenterMsg", id, _, _, "a", 3)
			client_print(id, print_center, "Ganhou: %s, %s, %s granadas%s", MessagesPrim[g_prim[id]], MessagesSec[g_sec[id]], MessagesGren[g_gren[id]], MessagesArmor[g_armor_type[id]])
			client_print(id, print_console, "Ganhou: %s, %s, %s granadas%s", MessagesPrim[g_prim[id]], MessagesSec[g_sec[id]], MessagesGren[g_gren[id]], MessagesArmor[g_armor_type[id]])
			if(!user_has_weapon(id, CSW_C4))
				strip_user_weapons(id)
			else
			{
				strip_user_weapons(id)
				give_item(id, "weapon_c4")
			}
			give_item(id, "weapon_knife")
			give_item(id, Primary[g_prim[id]])
			give_item(id, Secondary[g_sec[id]])
			give_item(id, Grenades[g_gren[id]])
			cs_set_user_bpammo(id, PrimAmmo[g_prim[id]], MaxPrim[g_prim[id]])
			cs_set_user_bpammo(id, SecAmmo[g_sec[id]], MaxSec[g_sec[id]])
			if(g_armor_type[id] != 0)
				cs_set_user_armor(id, 100, CsArmorType:g_armor_type[id])
			else
				cs_set_user_armor(id, 0, CsArmorType:0)
			if(g_gren[id] == 1)
				cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
		}
	}
}

public CenterMsg(id)
{
	if(get_pcvar_num(g_type) == 1)
		client_print(id, print_center, "jogar em %s e %s. todos emitidos %s granadas%s", MessagesPrim[prim], MessagesSec[sec], MessagesGren[gren], MessagesArmor[armor_type])
	if(get_pcvar_num(g_type) == 2)
		client_print(id, print_center, "Ganhou: %s, %s, %s granadas%s", MessagesPrim[g_prim[id]], MessagesSec[g_sec[id]], MessagesGren[g_gren[id]], MessagesArmor[g_armor_type[id]])
}