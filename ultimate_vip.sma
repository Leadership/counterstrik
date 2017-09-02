/*
	*English*
	
	This plugin is free software.
	You can modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.
	
	Description:
	This is a plugin which does not need any VIP "addition".
	I think I can say is ALL IN ONE.
	It has everything you need VIP plugin for CS 1.6 Public Server.
	
	Plugin Author: dEfuse[R]s^|-BS
	For more recent version of this plugin, visit forum.kgb-hosting.com
    
	*Serbian* 
	
	Ovaj plugin je besplatan program.
	Mozete ga menjati postujuci prava autora, samo ga ne smete prodavati.
	Opis:
	Ovo je plugin kome ne treba nikakav VIP "dodatak".
	Mislim da moze da se kaze ALL IN ONE.
	Ima sve sto je potrebno VIP pluginu za Public CS 1.6 Server.
	
	
	Autor Plugina: dEfuse[R]s^|-BS
	Za novije verzije ovog plugina poseti forum.kgb-hosting.com
	
*/

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <colorchat>
#include <fun>
#include <cstrike>

#define PLUGIN "Ultimate VIP"
#define VERSION "v1.6"
#define AUTHOR "BS"

static const COLOR[] = "^x04"
static const CONTACT[] = ""

enum { 
    SCOREATTRIB_ARG_PLAYERID = 1, 
    SCOREATTRIB_ARG_FLAGS 
}; 

enum ( <<= 1 ) { 
    SCOREATTRIB_FLAG_NONE = 0, 
    SCOREATTRIB_FLAG_DEAD = 1, 
    SCOREATTRIB_FLAG_BOMB, 
    SCOREATTRIB_FLAG_VIP 
}; 

new maxplayers, gmsgSayText

new const motddteng[] = "addons/amxmodx/configs/vip/motdSRB.html"
new const motddt[] = "addons/amxmodx/configs/vip/motdENG.html"
new const log[] = "addons/amxmodx/configs/vip/ChatLog.txt"
new const infos[] = "addons/amxmodx/configs/vip/INFO.txt"
new const g_ConfigFile[] = "addons/amxmodx/configs/vip/Settings-Podesavanja.cfg"
new const naruciti[] = "addons/amxmodx/configs/vip/Orders-Porudzbine.txt"
new const vipp[] = "addons/amxmodx/configs/vip/"
new const VipShop[] = "addons/amxmodx/configs/vip/VipShop.cfg"
new const users[] = "addons/amxmodx/configs/vip/vips.ini"

enum Cvarovi
{
	GRAVITY, BRZINA, VIP_HELTI, PARE, VIP_ARMOR, PREFIX, GLOW, AWP, PUSKE, DOSAO, HUD, C4,
	C4_CENA, REKLAMA, MONEYKILL, HPKILL, SHOP, LOGALL, LOGVIPS, HELTI, CENA_HP, KOLIKO_HP,
	ARMOR, CENA_ARMOR, KOLIKO_ARMOR, NO_GRAVITY, CENA_NOGRAV, TRAJANJE_NOGRAV, BES_HP,
	CENA_BESHP, TRAJANJE_BESHP, NOCLIP, CENA_NOCLIP, TRAJANJE_NOCLIP, JEZIK, HS_HP, HS_MONEY, VIPINFO,
	KUPIVIP, POSTANIVIP, START, KRAJ, NORELOAD, BOMMBS, HEAL, HEAL_MAX, HEAL_SPEED, FLAGS
}

new const g_ImenaCvarova[ Cvarovi ][] =
{
	"vip_gravity", "vip_speed", "vip_health", "vip_money", "vip_armor", "vip_prefix", "vip_glow",
	"vip_awp", "vip_guns", "vip_connect", "vip_connect_color", "vip_c4", "vip_c4_price",
	"vip_advert", "vip_money_kill", "vip_hp_kill", "vip_shop", "vip_log_all", "vip_log_vips", "Health",
	"Price_hp", "How_hp", "Armor", "Price_armor", "How_armor", "No_gravity", "Price_no_gravity",
	"Duration_no_gravity", "Unlimited_hp", "Price_unlimited_hp", "Duration_unlimited_hp", "Noclip",
	"Price_noclip", "Duration_noclip", "vip_language", "vip_hs_hp_kill", "vip_hs_money_kill", "vip_vipinfo",
	"vip_buyvip", "vip_becamevip", "vip_freevip_start", "vip_freevip_end", "vip_noreload", "vip_bombs",
	"vip_heal", "vip_heal_max", "vip_heal_speed", "vip_flags"
};

new const g_DefaultVrednost[ Cvarovi ][] =
{
	"0.8", "25.0", "50", "2000", "100", "1", "1", "1", "1", "1", "1", "1", "4000", "120.0", 
	"500", "20", "1", "0", "1", "1", "2000", "50", "1", "3500", "100", "1", "4000", "30.0", "1",
	"7000", "10.0", "1", "8000", "15.0", "1", "40", "1000", "1", "1", "1", "00","08", "1", "hsfd",
	"1", "120", "5.0", "b"
};

new g_SviCvarovi[ Cvarovi ];

new bool:bilo[33] = false
new bool:bilow[33] = false
new bool:biloa[33] = false
new bool:bilos[33] = false
new bool:bilod[33] = false

new Trie: Vipovi

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1)
	register_event("CurWeapon", "eCurWeapon", "be", "1=1");
	register_event("DeathMsg", "Death", "a")
	
	for ( new Cvarovi:i = GRAVITY ; i < Cvarovi ; i++ )
		g_SviCvarovi[ i ] = register_cvar( g_ImenaCvarova[ i ] , g_DefaultVrednost[ i ] );
	
	maxplayers = get_maxplayers()
	gmsgSayText = get_user_msgid("SayText")
	
	register_cvar("amx_contactinfo", CONTACT, FCVAR_SERVER)
	register_message( get_user_msgid( "ScoreAttrib" ), "MessageScoreAttrib" ); 
	
	set_task(get_pcvar_float( g_SviCvarovi[ REKLAMA ] ),"reklama",_,_,_,"b")
	set_task(30.0,"reload",_,_,_,"b")
	register_concmd("amx_reloadvips","komandom",ADMIN_LEVEL_H," - Reload-uje vipove iz vips.ini")
	register_clcmd("vip_chat","vipchat")
	
	register_clcmd("say /vip","plagin")
	register_clcmd("say /vipovi", "handle_say")
	register_clcmd("say /vips", "handle_say")
	register_clcmd("awp","awpp")
	register_clcmd("say /vipshop","prodavnica")
	register_clcmd("say /vipinfo","motdd")
	register_clcmd("say /kupivipa","kupii")
	register_clcmd("say /buyvip","kupii")
	register_clcmd("say /postanivip","postani")
	register_clcmd("say /becamevip","postani")
	register_clcmd("say /c4","cece")
	register_clcmd("say /bind","chatbind")
	register_clcmd("say","prefixe")
}

public plugin_cfg()
{
	Vipovi = TrieCreate()
	new Directory [] = "addons/amxmodx/configs/vip/vips.ini"
	
	new Data[35],File
	File = fopen(Directory, "rt")
		
	while (!feof(File)) {
		fgets(File, Data, charsmax(Data))
			
		trim(Data)
			
		if (Data[0] == ';' || !Data[0]) 
			continue;
			
		remove_quotes(Data)
		TrieSetCell(Vipovi, Data, true)  
	}
		
	fclose(File)
}

public Spawn(id)
{
	if(is_user_alive(id) && VIP(id))
	{
		accord(id)
	}
	return PLUGIN_HANDLED
}

bool:VIP(id)
{
	new steam[33]
	get_user_authid(id,steam,32)
	if(TrieKeyExists(Vipovi,steam))
	{
		set_user_flags(id,ADMIN_LEVEL_H)
		new flag[33]
		get_pcvar_string(g_SviCvarovi[ FLAGS ],flag,32)
		if(containi(flag,"b") != - 1)
		{
			set_user_flags(id,ADMIN_RESERVATION)
		}
		if(containi(flag,"a") != - 1)
		{
			set_user_flags(id,ADMIN_IMMUNITY)
		}
		if(containi(flag,"c") != - 1)
		{
			set_user_flags(id,ADMIN_KICK)
		}
		if(containi(flag,"d") != - 1)
		{
			set_user_flags(id,ADMIN_BAN)
		}
		if(containi(flag,"e") != - 1)
		{
			set_user_health(id,ADMIN_SLAY)
		}
		if(containi(flag,"i") != - 1)
		{
			set_user_health(id,ADMIN_CHAT)
		}
		return true
	}
	return false
}

public accord(id)
{
	if(VIP(id))
	{
		new vrednost[33]
		get_pcvar_string(g_SviCvarovi[ BOMMBS ],vrednost,32)
		if(containi(vrednost,"h") != - 1)
		{
			give_item(id,"weapon_hegrenade")
		}
		if(containi(vrednost,"s") != - 1)
		{
			give_item(id,"weapon_smokegrenade")
		}
		if(containi(vrednost,"f") != - 1)
		{
			give_item(id,"weapon_flashbang")
		}
		if(containi(vrednost,"d") != - 1)
		{
			give_item(id,"weapon_flashbang")
		}
		bilo[id] = false
		bilow[id] = false
		biloa[id] = false
		bilos[id] = false
		bilod[id] = false
		set_user_maxspeed(id, get_user_maxspeed(id) + get_pcvar_num( g_SviCvarovi[ BRZINA ] ))
		set_user_gravity(id, 1.0 - get_pcvar_float( g_SviCvarovi[ GRAVITY ] ))
		set_user_health(id, get_user_health(id) + get_pcvar_num( g_SviCvarovi[ VIP_HELTI ] ))
		cs_set_user_money(id, cs_get_user_money(id) + get_pcvar_num( g_SviCvarovi[ PARE ] ))
		set_user_armor(id, get_user_armor(id) + get_pcvar_num( g_SviCvarovi[ VIP_ARMOR ] ))
		switch(get_pcvar_num( g_SviCvarovi[ GLOW ] ))
		{
			case 0:
			{
				provera(id)
			}
			case 1:
			{
				glou(id)
			}
			case 2:
			{
				if(cs_get_user_team(id) == CS_TEAM_T)
				{
					set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25)
				}
				if(cs_get_user_team(id) == CS_TEAM_CT)
				{
					set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25)
				}
				provera(id)
			}
		}
		if(get_pcvar_num( g_SviCvarovi[ C4 ] ) == 2)
		{
			if(cs_get_user_team(id) == CS_TEAM_T)
			{
				if(!(user_has_weapon(id, CSW_C4)))
				{
					if(is_user_alive(id))
					give_item(id,"weapon_c4")
					switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
					{
						case 1:
						{
							ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You received^3 C4")
						}
						case 2:
						{
							ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Dobio si gratis^3 C4")
						}
					}
				}
			}
			return PLUGIN_HANDLED
		}	
	}
	return PLUGIN_HANDLED
}

public hiluj(id)
{
	if(VIP(id) && is_user_connected(id) && is_user_alive(id))
	{
		if(get_pcvar_num( g_SviCvarovi[ HEAL ] ) == 1)
		{
			if(get_user_health(id) < get_pcvar_num( g_SviCvarovi[ HEAL_MAX ] ))
			{
				set_user_health(id, get_user_health(id) + 5)
				set_hudmessage(255, 0, 0, -1.0, 0.0, 0, 6.0, 12.0)
				show_hudmessage(id, "+ 5 HP")
			}
		}
	}
	set_task(get_pcvar_float( g_SviCvarovi[ HEAL_SPEED ] ),"hiluj",id)
}

public plagin(id)
{
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 2:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 12.0)
			show_hudmessage(id, "Pogledaj konzolu")
			client_print(id,print_console,"=================================================")
			client_print(id,print_console," ")
			client_print(id,print_console,"KOMANDE VEZANE ZA ULTIMATE VIP PLUGIN:")
			client_print(id,print_console," ")
			if(get_pcvar_num( g_SviCvarovi[ VIPINFO ] ) == 1)
			{
				client_print(id,print_console,"say /vipinfo - informacije o sposobnostima VIP-a")
			}
			client_print(id,print_console,"say /vipovi - pogledaj ko je VIP na serveru")
			if(get_pcvar_num( g_SviCvarovi[ KUPIVIP ] ) == 1)
			{
				client_print(id,print_console,"say /kupivipa - pogledaj kako da postanes i ti VIP")
			}
			if(get_pcvar_num( g_SviCvarovi[ POSTANIVIP ] ) == 1)
			{
				client_print(id,print_console,"say /postanivip - obavesti Head-Admine ako si boost-ovao server")
			}
			if((get_pcvar_num( g_SviCvarovi[ C4 ] ) == 1) || (get_pcvar_num( g_SviCvarovi[ C4 ] ) == 2))
			{
				client_print(id,print_console,"say /c4 - mozes da kupujes C4 bombu ako si VIP")
			}
			if(get_pcvar_num( g_SviCvarovi[ SHOP ] ) == 1)
			{
				client_print(id,print_console,"say /vipshop - imas razne zabavne stvari u shopu takodje ako si VIP")
			}
			client_print(id,print_console," ")
			client_print(id,print_console,"=================================================")
		}
		case 1:
		{
			set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 12.0)
			show_hudmessage(id, "Look at console")
			client_print(id,print_console,"=================================================")
			client_print(id,print_console," ")
			client_print(id,print_console,"PLAYER COMMANDS OF ULTIMATE VIP PLUGIN:")
			client_print(id,print_console," ")
			if(get_pcvar_num( g_SviCvarovi[ VIPINFO ] ) == 1)
			{
				client_print(id,print_console,"say /vipinfo - What you have if you are VIP")
			}
			client_print(id,print_console,"say /vips - You see online VIPs")
			if(get_pcvar_num( g_SviCvarovi[ KUPIVIP ] ) == 1)
			{
				client_print(id,print_console,"say /buyvip - watch how can you become the VIP")
			}
			if(get_pcvar_num( g_SviCvarovi[ POSTANIVIP ] ) == 1)
			{
				client_print(id,print_console,"say /becomevip - inform Head-Admins if you boosted server")
			}
			if((get_pcvar_num( g_SviCvarovi[ C4 ] ) == 1) || (get_pcvar_num( g_SviCvarovi[ C4 ] ) == 2))
			{
				client_print(id,print_console,"say /c4 - if you are VIP, you can buy C4 bomb")
			}
			if(get_pcvar_num( g_SviCvarovi[ SHOP ] ) == 1)
			{
				client_print(id,print_console,"say /vipshop - you have got fun things in shop if you are VIP")
			}
			client_print(id,print_console," ")
			client_print(id,print_console,"=================================================")
		}
	}
	return PLUGIN_CONTINUE
}

public cece(id)
{
	if(get_pcvar_num( g_SviCvarovi[ C4 ] ) == 1)
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			if(!(user_has_weapon(id, CSW_C4)))
			{
				if(!VIP(id))
				{
					if(is_user_alive(id))
					{
						switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
						{
							case 1:
							{
								ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You're not^4 VIP^1, you could not buy^3 C4")
							}
							case 2:
							{
								ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Nisi^4 VIP^1, ne mozes da kupis^3 C4")
							}
						}
					}
					else
					{
						switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
						{
							case 1:
							{
								ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You're dead")
							}
							case 2:
							{
								ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Mrtav si")
							}
						}
					}
				}
				else
				{
					if(is_user_alive(id))
					{
						new cen = get_pcvar_num( g_SviCvarovi[ C4_CENA ] )
						if(cs_get_user_money(id) >= cen)
						{
							give_item(id,"weapon_c4")
							switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
							{
								case 1:
								{									
									ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You bought^4 C4^1 for^4 %i$", cen)
								}
								case 2:
								{
									ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Kupio si^4 C4^1 za^4 %i$", cen)
								}
							}
							cs_set_user_money(id, cs_get_user_money(id) - cen)
						}
						else
						{
							switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
							{
								case 1:
								{
									ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You don't have enought money for^4 C4^1, price is^3 %i$", cen)
								}
								case 2:
								{
									ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Nemas dovoljno para za kupovinu^4 C4^1, cena je^3 %i$", cen)
								}
							}
						}
					}
				}
			}
			else
			{
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You already have^3 C4")
					}
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Vec imas^3 C4")
					}
				}
			}
		}
		else
		{
			switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
			{
				case 1:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You're not^3 Terrorist^1, you couldn't buy^4 C4")
				}
				case 2:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Nisi^3 Teror^1, ne mozes da kupis^4 C4")
				}
			}
		}
	}
	if(get_pcvar_num( g_SviCvarovi[ C4 ] ) == 0)
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 1:
			{
				ColorChat(id,TEAM_COLOR,"^4[VIP]^1 Server has turned off this command")
			}
			case 2:
			{
				ColorChat(id,TEAM_COLOR,"^4[VIP]^1 Server je iskljucio ovu komandu")
			}
		}
	}
	return PLUGIN_HANDLED
}
				
public glou(id)
{
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 1:
		{
			new gloww = menu_create("Do you want glow ?","gloww")
			menu_additem(gloww,"Yeah")
			menu_additem(gloww,"Nope")
			menu_display(id,gloww)
		}
		case 2:
		{
			new gloww = menu_create("Da li hoces glow ?","gloww")
			menu_additem(gloww,"Da")
			menu_additem(gloww,"Ne")
			menu_display(id,gloww)
		}
	}
	return PLUGIN_HANDLED
}

public gloww(id,menu,item)
{
	if(item==MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE;
	}
	switch(item)
	{
		case 0:
		{
			if(get_pcvar_num( g_SviCvarovi[ PUSKE] ) == 1)
			{
				menii(id)
			}
			if(cs_get_user_team(id) == CS_TEAM_CT)
			{
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 25)
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 1:
					{
						ColorChat(id,TEAM_COLOR, "^4[VIP]^1 Now you have^3 blue^1 Glow")
					}
					case 2:
					{
						
						ColorChat(id,TEAM_COLOR, "^4[VIP]^1 Sada imas^3 plavi^1 Glow")
					}
				}
			}
			else if(cs_get_user_team(id) == CS_TEAM_T)
			{
				set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25)
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 1:
					{
						ColorChat(id,TEAM_COLOR, "^4[VIP]^1 Now you have^3 red^1 Glow")
					}
					case 2:
					{
						
						ColorChat(id,TEAM_COLOR, "^4[VIP]^1 Sada imas^3 crveni^1 Glow")
					}
				}
			}
		}
		case 1:
		{
			if(get_pcvar_num( g_SviCvarovi[ PUSKE ] ) == 1)
			{
				menii(id)
			}
		}
	}
	return PLUGIN_HANDLED
}

public provera(id)
{
	if(get_pcvar_num( g_SviCvarovi[ PUSKE ] ) == 1)
	{
		menii(id)
	}
}

public menii(id)
{
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 1:
		{
			new menu = menu_create("Choose Rifle","gun_meni")
			menu_additem(menu,"AK47")
			menu_additem(menu,"M4A1")
			menu_additem(menu,"Famas")
			menu_additem(menu,"Galil")
			menu_additem(menu,"MP5")
			menu_additem(menu,"Scout")
			menu_additem(menu,"AWP")
			menu_display(id,menu)
		}
		case 2:
		{
			new menu = menu_create("Izaberi pusku","gun_meni")
			menu_additem(menu,"AK47")
			menu_additem(menu,"M4A1")
			menu_additem(menu,"Famas")
			menu_additem(menu,"Galil")
			menu_additem(menu,"MP5")
			menu_additem(menu,"Scout")
			menu_additem(menu,"AWP")
			menu_display(id,menu)
		}
	}
	return PLUGIN_HANDLED
}

public gun_meni(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	switch(item)
	{
		case 0:
		{
			give_item(id,"weapon_ak47")
			cs_set_user_bpammo(id, CSW_AK47, 200)
			pistolj_menu(id)
		}
		case 1:
		{
			give_item(id,"weapon_m4a1")
			cs_set_user_bpammo(id, CSW_M4A1, 200)
			pistolj_menu(id)
		}
		case 2:
		{
			give_item(id,"weapon_famas")
			cs_set_user_bpammo(id, CSW_FAMAS, 200)
			pistolj_menu(id)
		}
		case 3:
		{
			give_item(id,"weapon_galil")
			cs_set_user_bpammo(id, CSW_GALIL, 200)
			pistolj_menu(id)
		}
		case 4:
		{
			give_item(id,"weapon_mp5navy")
			cs_set_user_bpammo(id, CSW_MP5NAVY, 200)
			pistolj_menu(id)
		}
		case 5:
		{
			give_item(id,"weapon_scout")
			cs_set_user_bpammo(id, CSW_SCOUT, 200)
			pistolj_menu(id)
		}
		case 6:
		{
			give_item(id,"weapon_awp")
			cs_set_user_bpammo(id, CSW_AWP, 200)
			pistolj_menu(id)
		}
	}
	return PLUGIN_HANDLED
}

public pistolj_menu(id)
{
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 1:
		{
			new pistolj_meni = menu_create("Choose gun","pistolj")
			menu_additem(pistolj_meni,"Desert Eagle")
			menu_additem(pistolj_meni,"USP")
			menu_additem(pistolj_meni,"Glock")
			menu_additem(pistolj_meni,"FiveSeven")
			menu_display(id,pistolj_meni)
		}
		case 2:
		{
			new pistolj_meni = menu_create("Izaberi pistolj","pistolj")
			menu_additem(pistolj_meni,"Desert Eagle")
			menu_additem(pistolj_meni,"USP")
			menu_additem(pistolj_meni,"Glock")
			menu_additem(pistolj_meni,"FiveSeven")
			menu_display(id,pistolj_meni)
		}
	}
	return PLUGIN_HANDLED
}

public pistolj(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	switch(item)
	{
		case 0:
		{
			give_item(id,"weapon_deagle")
			cs_set_user_bpammo(id, CSW_DEAGLE, 35)
		}
		case 1:
		{
			give_item(id,"weapon_usp")
			cs_set_user_bpammo(id, CSW_USP, 90)
		}
		case 2:
		{
			give_item(id,"weapon_glock18")
			cs_set_user_bpammo(id, CSW_GLOCK18, 120)
		}
		case 3:
		{
			give_item(id,"weapon_fiveseven")
			cs_set_user_bpammo(id, CSW_FIVESEVEN, 100)
		}
	}
	return PLUGIN_HANDLED
}

public eCurWeapon(id)
{
	CheckSpeed(id);
	cekujoruzje(id);
	return PLUGIN_CONTINUE;
}

public cekujoruzje(id)
{
	if(get_pcvar_num( g_SviCvarovi[ NORELOAD ] ) != 1)
	return PLUGIN_HANDLED
	if(VIP(id))
	{
		new Clip, Ammo, Weap[32] 
		new WeapId 
		WeapId = get_user_weapon(id, Clip , Ammo) 
		if (Clip == 0) 
		{ 
			get_weaponname(WeapId, Weap, 31) 
			give_item(id, Weap) 
			engclient_cmd(id, Weap)
			engclient_cmd(id, Weap) 
			engclient_cmd(id, Weap)
		}
	}
	return PLUGIN_CONTINUE;
}
 
public CheckSpeed(id)
	set_user_maxspeed(id, get_user_maxspeed(id) + get_pcvar_num( g_SviCvarovi[ BRZINA ] ));
    
public awpp(id)
{
	if(get_pcvar_num( g_SviCvarovi[ AWP ] ) == 1)
	{
		if(!VIP(id))
		{
			switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
			{
				case 1:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Just^4 VIP^1 could buy^3 AWP")
				}
				case 2:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Awp smeju da kupe samo^3 Vip-ovi")
				}
			}
			return PLUGIN_HANDLED
		}
		
	}
	return PLUGIN_CONTINUE
}

public handle_say(id) {
	set_task(0.1,"print_adminlist",id)
	return PLUGIN_CONTINUE
}

public print_adminlist(user) 
{
    new adminnames[33][32]
    new message[256]
    new contactinfo[256], contact[112]
    new id, count, x, len
    
    for(id = 1 ; id <= maxplayers ; id++)
        if(is_user_connected(id))
            if(VIP(id))
                get_user_name(id, adminnames[count++], 31)

    len = format(message, 255, "%s Online VIPs: ",COLOR)
    if(count > 0) {
        for(x = 0 ; x < count ; x++) {
            len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"")
            if(len > 96 ) {
                print_message(user, message)
                len = format(message, 255, "%s ",COLOR)
            }
        }
        print_message(user, message)
    }
    else {
        len += format(message[len], 255-len, "No VIPs Online")
        print_message(user, message)
    }
    
    get_cvar_string("amx_contactinfo", contact, 63)
    if(contact[0])  {
        format(contactinfo, 111, "%s Contact Server Vip -- %s", COLOR, contact)
        print_message(user, contactinfo)
    }
}

print_message(id, msg[])
{
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}  

public MessageScoreAttrib(iMsgId,iDest,iReceiver )
{
	new id = get_msg_arg_int(SCOREATTRIB_ARG_PLAYERID); 
	if(VIP(id))
		set_msg_arg_int(SCOREATTRIB_ARG_FLAGS,ARG_BYTE,SCOREATTRIB_FLAG_VIP); 
}

public client_putinserver(id)
{
	set_task(3.0,"vip_doso",id)
	set_task(5.0,"botinq",id)
	set_task(15.0,"hiluj",id)
}

public chatbind(id)
{
	switch(get_pcvar_num(g_SviCvarovi [ JEZIK ]))
	{
		case 2:
		{
			new meno = menu_create("Bind Vip Chat na O","handler_bind")
			menu_additem(meno,"Da")
			menu_additem(meno,"Ne")
			menu_display(id,meno)
		}
		case 1:
		{
			new meno = menu_create("Bind Vip Chat on key O","handler_bind")
			menu_additem(meno,"Yes")
			menu_additem(meno,"No")
			menu_display(id,meno)
		}
	}
	return PLUGIN_CONTINUE;
}

public handler_bind(id,menu,item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE;
	}
	switch(item)
	{
		case 0:
		{
			client_cmd(id,"bind o ^"messagemode vip_chat^"")
			switch(get_pcvar_num(g_SviCvarovi [ JEZIK ]))
			{
				case 2:
					ColorChat(id,TEAM_COLOR,"^4[VIP]^1 Vip Chat je bindovan na slovo^3 O")
				case 1:
					ColorChat(id,TEAM_COLOR,"^4[VIP]^1 Vip Chat has been binded on key^3 O")
			}
		}
		case 1:
			return PLUGIN_CONTINUE;
	}
	return PLUGIN_HANDLED
}

public botinq(id)
{
	set_hudmessage(0, 0, 255, -1.0, 0.0, 0, 6.0, 12.0)
	show_hudmessage(id, "say /vip - Ultimate VIP Plugin Info ^nPlugin by:[BS]")
	return PLUGIN_HANDLED
}

public vip_doso(id)
{
	if(get_pcvar_num( g_SviCvarovi[ DOSAO ] ) != 1)
	return PLUGIN_HANDLED
	if(is_user_connected(id))
	{
		if(VIP(id))
		{
			new name[32]
			get_user_name(id,name,31)
			switch(get_pcvar_num( g_SviCvarovi[ HUD ] ))
			{
				case 1:
				{
					switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
					{
						case 1:
						{
							set_hudmessage(255, 0, 0, 0.06, 0.73, 0, 6.0, 12.0)
							show_hudmessage(0, "VIP %s has connected on server",name)
						}
						case 2:
						{
							set_hudmessage(255, 0, 0, 0.06, 0.73, 0, 6.0, 12.0)
							show_hudmessage(0, "VIP %s je dosao na server",name)
						}
					}
				}
				case 2:
				{
					switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
					{
						case 1:
						{
							set_hudmessage(0, 255, 0, 0.06, 0.73, 0, 6.0, 12.0)
							show_hudmessage(0, "VIP %s has connected on server",name)
						}
						case 2:
						{
							set_hudmessage(0, 255, 0, 0.06, 0.73, 0, 6.0, 12.0)
							show_hudmessage(0, "VIP %s je dosao na server",name)
						}
					}
				}
				case 3:
				{
					switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
					{
						case 1:
						{
							set_hudmessage(0, 255, 255, 0.06, 0.73, 0, 6.0, 12.0)
							show_hudmessage(0, "VIP %s has connected on server",name)
						}
						case 2:
						{
							set_hudmessage(0, 255, 255, 0.06, 0.73, 0, 6.0, 12.0)
							show_hudmessage(0, "VIP %s je dosao na server",name)
						}
					}
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

public reklama()
{
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 1:
		{
			new broj
			broj = random_num(1,2)
			switch(broj)
			{
				case 1:
				{
					if(get_pcvar_num( g_SviCvarovi[ VIPINFO ] ))
					{
						ColorChat(0, TEAM_COLOR, "^4[VIP]^1 Type in console^3 say /vipinfo^1 to see^4 VIP^1 properties")
					}
					if(get_pcvar_num( g_SviCvarovi[ POSTANIVIP ] ))
					{
						ColorChat(0, TEAM_COLOR, "^4[VIP]^1 Type in console^3 say /becamevip^1 if you boosted server")
					}
				}
				case 2:
				{
					if(get_pcvar_num( g_SviCvarovi[ KUPIVIP ] ))
					{
						ColorChat(0, TEAM_COLOR, "^4[VIP]^1 Type in console^3 say /buyvip^1 if you want to buy^4 VIP")
					}
					ColorChat(0, TEAM_COLOR, "^4[VIP]^1 Type in console^3 say /vips^1 to see online^4 VIPS")
				}
			}
		}
		case 2:
		{
			new broj
			broj = random_num(1,2)
			switch(broj)
			{
				case 1:
				{
					if(get_pcvar_num( g_SviCvarovi[ VIPINFO ] ))
					{
						ColorChat(0, TEAM_COLOR, "^4[VIP]^1 Kucaj u konzoli^3 say /vipinfo^1 da vidis sposobnosti^4 VIP-a")
					}
					if(get_pcvar_num( g_SviCvarovi[ POSTANIVIP ] ))
					{
						ColorChat(0, TEAM_COLOR, "^4[VIP]^1 Kucaj u konzoli^3 say /postanivip^1 ako si Boost-ovao server")
					}
				}
				case 2:
				{
					if(get_pcvar_num( g_SviCvarovi[ KUPIVIP ] ))
					{
						ColorChat(0, TEAM_COLOR, "^4[VIP]^1 Kucaj u konzoli^3 say /kupivipa^1 da narucis^4 VIP-a")
					}
					ColorChat(0, TEAM_COLOR, "^4[VIP]^1 Kucaj u konzoli^3 say /vipovi^1 da vidis koji^4 VIP^1 je na serveru")
				}
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public motdd(id,level,cid)
{
	if(get_pcvar_num( g_SviCvarovi[ VIPINFO ] ) == 1)
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 1:
			{
				new configsdir[200]
				new MOTDfile[200] 
				get_configsdir(configsdir,199) 
				format(MOTDfile,199,"%s/vip/motdSRB.html",configsdir)
				show_motd(id,MOTDfile)
			}
			case 2:
			{	
				new configsdir[200]
				new MOTDfile[200] 
				get_configsdir(configsdir,199) 
				format(MOTDfile,199,"%s/vip/motdENG.html",configsdir)
				show_motd(id,MOTDfile)
			}
		}
	}
	if(get_pcvar_num( g_SviCvarovi[ KUPIVIP ] ) == 1)
	{
		kupii(id)
	}
	return PLUGIN_CONTINUE;
}

public kupii(id)
{
	if(get_pcvar_num( g_SviCvarovi[ KUPIVIP ] ) != 1)
	return PLUGIN_HANDLED
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 2:
		{
			new kupi = menu_create("Da li hoces da kupis vipa?","kupii_han")
			menu_additem(kupi,"DA")
			menu_additem(kupi,"NE")
			menu_display(id,kupi)
		}
		case 1:
		{
			new kupi = menu_create("Do you want to buy VIP ?","kupii_han")
			menu_additem(kupi,"Yes")
			menu_additem(kupi,"No")
			menu_display(id,kupi)
		}
	}
	return PLUGIN_HANDLED
}

public kupii_han(id,menu,item)
{
	if(item==MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	switch(item)
	{
		case 0:
		{
			switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
			{
				case 1:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You can buy^4 VIP^1 by sending one SMS message")
					cmdMenu(id)
				}
				case 2:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Mozes postati^4 VIP^1 slanjem jedne SMS poruke")
					cmdMenu(id)
				}
			}
		}
		case 1:
		{
			switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
			{
				case 2:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Odustao si od kupovine^3 Vip-a")
				}
				case 1:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You gaved from buying^4 VIP")
				}
			}
		}
	}
	return PLUGIN_HANDLED
}

public cmdMenu(id)
{
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 2:
		{
			new menua = menu_create("Izaberi drzavu", "menu_handlerrr")
			menu_additem(menua, "Srbija")
			menu_additem(menua, "Hrvatska")
			menu_additem(menua, "Bosna i Hercegovina")
			menu_additem(menua, "Crna Gora")
			menu_additem(menua, "Makedonija")
			menu_display(id, menua)
		}
		case 1:
		{
			new menua = menu_create("Select country", "ajzak")
			menu_additem(menua, "Serbia")
			menu_additem(menua, "Croatia")
			menu_additem(menua, "Bosnia and Herzegovina")
			menu_additem(menua, "Montenegro")
			menu_additem(menua, "Makedonia")
			menu_display(id, menua)
			set_hudmessage(255, 0, 0, -1.0, 0.38, 0, 6.0, 12.0)
			show_hudmessage(id, "Look at Chat")
			ColorChat(id, TEAM_COLOR, "^4[VIP]^1 If not from these countries^4 do not boost server !")
		}
	}
	return PLUGIN_HANDLED
}

public ajzak(id,menu,item)
{
    if(item==MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_CONTINUE
    }
    
    switch(item)
    {
        case 0:
        {
            new ipsrb[32]
            get_user_ip(0, ipsrb, 31)
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Look at Console")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "How to boost server from Serbia:")
            console_print(id, "-")
            console_print(id, "Message Text: 100 GTRS [IP] [Your name] send to 1310")
            console_print(id, "-")
            console_print(id, "To boost this server do just like this: type 100 GTRS %s your_name and send to 1310", ipsrb)
            console_print(id, "-")
            console_print(id, "Price of one message is: for MT:S 120.60 RSD, for VIP 118.00 RSD, for TELENOR 121.54 RSD")
            console_print(id, "-")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            return PLUGIN_HANDLED
        }
        case 1:
        {
            new iphrv[32]
            get_user_ip(0, iphrv, 31) 
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Look at Console")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "How to boost server from Croatia:")
            console_print(id, "-")
            console_print(id, "Message Text: TXT GTRS [IP] [Your name] send to 67454")
            console_print(id, "-")
            console_print(id, "To boost this server do just like this: type TXT GTRS %s your_name and send to 67454", iphrv)
            console_print(id, "-")
            console_print(id, "Price of one message is 6,10 KN")
            console_print(id, "-")
            console_print(id, "Support:             +385 1 638 8135      ")
            console_print(id, "-")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
        }
        case 2:
        {
            new ipbih[32]
            get_user_ip(0, ipbih, 31)
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Look at Console")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "How to boost server from Bosnia and Herzegovina:")
            console_print(id, "-")
            console_print(id, "Message text: TXT GTRS [IP] [Your name] send to 091810700")
            console_print(id, "-")
            console_print(id, "To boost this server do just like this: type TXT GTRS %s your_name and send to 091810700", ipbih)
            console_print(id, "-")
            console_print(id, "Price of one message is 2,00 BAM + PDV")
            console_print(id, "-")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            
            return PLUGIN_HANDLED
        }
        case 3:
        {
            new ipcg[32]
            get_user_ip(0, ipcg, 31)
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Look at Console")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "How to boost server from Montenegro:")
            console_print(id, "-")
            console_print(id, "Message Text: FOR GTRS [IP] [Your name] send to 14741")
            console_print(id, "-")
            console_print(id, "To boost this server do just like this: type FOR GTRS %s your_name and send to 14741", ipcg)
            console_print(id, "-")
            console_print(id, "Price of one message is 1.00 Euro")
            console_print(id, "-")
            console_print(id, "-----------------------------------BOOST---------------------------------------")   
            return PLUGIN_HANDLED
        }
        case 4:
        {
            new ipmkd[32]
            get_user_ip(0, ipmkd, 31)
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Look at Console")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "How to boost server from Makedonia:")
            console_print(id, "-")
            console_print(id, "Message text: TAP GTRS [IP] [Your name] send to 141551 ")
            console_print(id, "-")
            console_print(id, "To boost this server do just like this: type TAP GTRS %s your_name and send to 141551", ipmkd)
            console_print(id, "-")
            console_print(id, "Price of one message is 59.00 MKD")
            console_print(id, "-")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            return PLUGIN_HANDLED
        }
    }
    return PLUGIN_CONTINUE
}

public menu_handlerrr(id, menu, item)
    {
    if(item==MENU_EXIT)
        {
        menu_destroy(menu)
        return PLUGIN_CONTINUE
    }
    
    switch(item)
    {
        case 0:
        {
            new ipsrb[32]
            get_user_ip(0, ipsrb, 31)
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Pogledaj konzolu !")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "Kako boostovati server iz Srbije  (sve pazljivo procitaj):")
            console_print(id, "-")
            console_print(id, "Format poruke: 100 GTRS [IP] [Vase ime] posaljete na broj 1310")
            console_print(id, "-")
            console_print(id, "Da boostujete ovaj server radite ovako: ukucajte 100 GTRS %s vas_nick i posaljite na broj 1310", ipsrb)
            console_print(id, "-")
            console_print(id, "Cena jedne poruke je: za mt:s 120.60 RSD, za Vip 118.00 RSD, za Telenor 121.54 RSD")
            console_print(id, "-")
            console_print(id, "NAPOMENA! server se boostuje tek kada stigne status o naplati!")
            console_print(id, "To je uglavnom za par sekundi, ali nekad moze da potraje i do par sati !")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            return PLUGIN_HANDLED
        }
        case 1:
        {
            new iphrv[32]
            get_user_ip(0, iphrv, 31) 
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Pogledaj konzolu !")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "Kako boostovati server iz Hrvatske (sve pazljivo procitaj):")
            console_print(id, "-")
            console_print(id, "Format poruke: TXT GTRS [IP] [Vase ime] posaljete na broj 67454")
            console_print(id, "-")
            console_print(id, "Da boostate ovaj server radite ovako: ukucajte TXT GTRS %s vas_nick i posaljite na broj 67454", iphrv)
            console_print(id, "-")
            console_print(id, "Cijena jedne poruke je: 6,10 KN")
            console_print(id, "-")
            console_print(id, "Operator usluge s dodanom vrijednosti: NTH Media d.o.o., Horvacanska 17a, 10 000 Zagreb, MB: 1842358, OIB: 59547672558. Tel: 01 6388 160")
            console_print(id, "-")
            console_print(id, "Podrska:             +385 1 638 8135      ")
            console_print(id, "-")
            console_print(id, "NAPOMENA! server se boosta tek kada stigne status o naplati!") 
            console_print(id, "To je uglavnom za par sekundi, ali nekad moze potrajati i do par sati !")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
        }
        case 2:
        {
            new ipbih[32]
            get_user_ip(0, ipbih, 31)
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Pogledaj konzolu !")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "Kako boostovati server iz Bosne i Hercegovine (sve pazljvo procitaj):")
            console_print(id, "-")
            console_print(id, "Format poruke: TXT GTRS [IP] [Vase ime] posaljete na broj 091810700")
            console_print(id, "-")
            console_print(id, "Da boostujete ovaj server radite ovako: ukucajte TXT GTRS %s vas_nick i posaljite na broj 091810700", ipbih)
            console_print(id, "-")
            console_print(id, "Cijena jedne poruke je: 2,00 BAM + PDV")
            console_print(id, "-")
            console_print(id, "NAPOMENA! server se boostuje tek kada stigne status o naplati!") 
            console_print(id, "To je uglavnom za par sekundi, ali nekad moze da potraje i do par sati !")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            
            return PLUGIN_HANDLED
        }
        case 3:
        {
            new ipcg[32]
            get_user_ip(0, ipcg, 31)
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Pogledaj konzolu !")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "Kako boostovati server iz Crne Gore (sve pazljivo procitaj):")
            console_print(id, "-")
            console_print(id, "Format poruke: FOR GTRS [IP] [Vase ime] posaljete na broj 14741")
            console_print(id, "-")
            console_print(id, "Da boostujete ovaj server radite ovako: ukucajte FOR GTRS %s vas_nick i posaljite na broj 14741", ipcg)
            console_print(id, "-")
            console_print(id, "Cijena jedne poruke je: 1.00 e(euro)")
            console_print(id, "-")
            console_print(id, "NAPOMENA! server se boostuje tek kada stigne status o naplati!") 
            console_print(id, "To je uglavnom za par sekundi, ali nekad moze da potraje i do par sati !")
            console_print(id, "-----------------------------------BOOST---------------------------------------")   
            return PLUGIN_HANDLED
        }
        case 4:
        {
            new ipmkd[32]
            get_user_ip(0, ipmkd, 31)
	    set_hudmessage(0, 255, 0, -1.0, 0.26, 0, 6.0, 12.0)
	    show_hudmessage(id, "Pogledaj konzolu !")
	    set_task(30.0,"infow")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            console_print(id, "Kako da boostuvas server od Makedonija (Procitaj vnimatelno):")
            console_print(id, "-")
            console_print(id, "Format na porakata: TAP GTRS [IP] [Vaseto ime] ispratete na broj 141551 ")
            console_print(id, "-")
            console_print(id, "Za da go bustuvate ovoj server napravete vaka: napisete TAP GTRS %s vasiot_nick i ispratete na broj 141551", ipmkd)
            console_print(id, "-")
            console_print(id, "Cenata na edna poraka e: 59.00 MKD")
            console_print(id, "-")
            console_print(id, "IZVESTUVANJE! serverot se boostuva koga stigne do statususot za naplata! ") 
            console_print(id, "Vo glavno e od nekolku sekundi sekundi, no nekogas moze da bide i nekolku casa !")
            console_print(id, "-----------------------------------BOOST---------------------------------------")
            return PLUGIN_HANDLED
        }
    }
    return PLUGIN_CONTINUE
}

public infow(id)
{
	if(get_pcvar_num( g_SviCvarovi[ POSTANIVIP ] ) != 1)
	return PLUGIN_HANDLED
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 1:
		{
			ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Type in console^3 say /becamevip^1 if you boosted server")
		}
		case 2:
		{
			ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Kucaj u konzoli^3 say /postanivip^1 ako si Boost-ovao server")
		}
	}
	return PLUGIN_HANDLED
}

public prodavnica(id)
{
	if(VIP(id) && is_user_alive(id) && (get_pcvar_num( g_SviCvarovi[ SHOP ] ) == 1))
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 1:
			{
				new szText[555 char]
				formatex(szText, charsmax(szText), "\rChoose Item")
				new suma_menu = menu_create(szText, "itemmm")
						
				formatex(szText, charsmax(szText), "\r+%i Health \w%i$", get_pcvar_num( g_SviCvarovi[ KOLIKO_HP ] ), get_pcvar_num( g_SviCvarovi[ CENA_HP ] ))
				menu_additem(suma_menu, szText, "1", 0)
						
				formatex(szText, charsmax(szText), "\r+%i Armor \w%i$", get_pcvar_num( g_SviCvarovi[ KOLIKO_ARMOR ] ), get_pcvar_num( g_SviCvarovi[ CENA_ARMOR ] ))
				menu_additem(suma_menu, szText, "2", 0)
						
				formatex(szText, charsmax(szText), "\rNo Gravity \y[%i seconds] \w%i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_NOGRAV ] ), get_pcvar_num( g_SviCvarovi[ CENA_NOGRAV ] ))
				menu_additem(suma_menu, szText, "3", 0)
						
				formatex(szText, charsmax(szText), "\rUnlimited Health \y[%i seconds] \w%i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_BESHP ] ), get_pcvar_num(g_SviCvarovi[ CENA_BESHP ] ))
				menu_additem(suma_menu, szText, "4", 0)
						
				formatex(szText, charsmax(szText), "\rNoclip \y[%i sseconds] \w%i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_NOCLIP ] ), get_pcvar_num( g_SviCvarovi[ CENA_NOCLIP ] ))
				menu_additem(suma_menu, szText, "5", 0)	
						
				menu_setprop(suma_menu, MPROP_EXIT, MEXIT_ALL)
				menu_display(id, suma_menu)
			}
			case 2:
			{
				new szText[555 char]
				formatex(szText, charsmax(szText), "\rIzaberi item")
				new suma_menu = menu_create(szText, "itemmm")
						
				formatex(szText, charsmax(szText), "\r+%i helti \w%i$", get_pcvar_num( g_SviCvarovi[ KOLIKO_HP ] ), get_pcvar_num( g_SviCvarovi[ CENA_HP ] ))
				menu_additem(suma_menu, szText, "1", 0)
						
				formatex(szText, charsmax(szText), "\r+%i Armor-a \w%i$", get_pcvar_num( g_SviCvarovi[ KOLIKO_ARMOR ] ), get_pcvar_num( g_SviCvarovi[ CENA_ARMOR ] ))
				menu_additem(suma_menu, szText, "2", 0)
						
				formatex(szText, charsmax(szText), "\rNo Gravity \y[%i sekundi] \w%i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_NOGRAV ] ), get_pcvar_num( g_SviCvarovi[ CENA_NOGRAV ] ))
				menu_additem(suma_menu, szText, "3", 0)
						
				formatex(szText, charsmax(szText), "\rBeskonacno helti \y[%i sekundi] \w%i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_BESHP ] ), get_pcvar_num(g_SviCvarovi[ CENA_BESHP ] ))
				menu_additem(suma_menu, szText, "4", 0)
						
				formatex(szText, charsmax(szText), "\rNoclip \y[%i sekundi] \w%i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_NOCLIP ] ), get_pcvar_num( g_SviCvarovi[ CENA_NOCLIP ] ))
				menu_additem(suma_menu, szText, "5", 0)	
						
				menu_setprop(suma_menu, MPROP_EXIT, MEXIT_ALL)
				menu_display(id, suma_menu)	
			}
		}
	}
	return PLUGIN_HANDLED
}

public itemmm(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, charsmax(data), iName, charsmax(iName), callback )
	new key = str_to_num(data)
	switch(key)
	{ 
		case 1: hape(id)
		case 2: armor(id)
		case 3: gravity(id)
		case 4: beskonacno(id)
		case 5: noclip(id)
	}
	return PLUGIN_HANDLED
}

public hape(id)
{
	if(!is_user_alive(id))
	return PLUGIN_HANDLED
	new hea = get_pcvar_num( g_SviCvarovi[ CENA_HP ] )
	new jae = get_pcvar_num( g_SviCvarovi[ KOLIKO_HP ] )
	if(get_pcvar_num( g_SviCvarovi[ HELTI ] ) == 1)
	{
		if(cs_get_user_money(id) >= hea)
		{
			if(!bilo[id])
			{
				set_user_health(id, get_user_health(id) + jae)
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You bought^4 %i health^1 for^3 %i$", jae, hea)
					}
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Kupio si^4 %i helti^1 za^3 %i$", jae, hea)
					}
				}
				cs_set_user_money(id, cs_get_user_money(id) - hea)
				bilo[id] = true
			}
			else
			{
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You have already bought^3 +%i^1 HP", jae)
					}
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Vec si kupio^3 +%i^1 HP-a", jae)
					}
				}
			}
		}
		else
		{
			switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
			{
				case 1:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You don't have enought money for this item, you need^3 %i$", hea)
				}
				case 2:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Nemas dovoljno para za ovaj item, potrebno je^3 %i$", hea)
				}
			}
		}
	}
	else
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 1:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server has turned of this^3 item")
			}
			case 2:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server je iskljucio ovaj^3 Item")
			}
		}
	}
	return PLUGIN_HANDLED
}

public armor(id)
{
	if(!is_user_alive(id))
	return PLUGIN_HANDLED
	new arma = get_pcvar_num( g_SviCvarovi[ CENA_ARMOR ] )
	if(get_pcvar_num( g_SviCvarovi[ ARMOR ] ) == 1)
	{
		if(cs_get_user_money(id) >= arma)
		{
			if(!bilow[id])
			{
				set_user_armor(id, get_user_armor(id) + get_pcvar_num( g_SviCvarovi[ KOLIKO_ARMOR ] ))
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You bought^4 %i armor^1 for^3 %i$", get_pcvar_num( g_SviCvarovi[ KOLIKO_ARMOR ] ), arma)
					}
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Kupio si^4 %i armor-a^1 za^3 %i$", get_pcvar_num( g_SviCvarovi[ KOLIKO_ARMOR ] ), arma)
					}
				}
				cs_set_user_money(id, cs_get_user_money(id) - arma)
				bilow[id] = true
			}
			else
			{
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You have already bought^3 +%i^1 Armor", get_pcvar_num( g_SviCvarovi[ KOLIKO_ARMOR ] ))
					}
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Vec si kupio^3 +%i^1 Armor-a", get_pcvar_num( g_SviCvarovi[ KOLIKO_ARMOR ] ))
					}
				}
			}
		}
		else
		{
			switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
			{
				case 2:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Nemas dovoljno para za ovaj item, potrebno je^3 %i$", arma)
				}
				case 1:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You don't have enought money for this item, you need^3 %i$", arma)
				}
			}
		}
	}
	else if(get_pcvar_num( g_SviCvarovi[ ARMOR ] ) == 0)
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 2:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server je iskljucio ovaj^3 Item")
			}
			case 1:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server has turned off this^3 Item")
			}
		}
	}
	return PLUGIN_HANDLED
}

public gravity(id)
{
	if(!is_user_alive(id))
	return PLUGIN_HANDLED
	new grav = get_pcvar_num( g_SviCvarovi[ CENA_NOGRAV ] )
	if(get_pcvar_num( g_SviCvarovi[ NO_GRAVITY ] ) == 1)
	{
		if(cs_get_user_money(id) >= grav)
		{
			if(!biloa[id])
			{
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 1:
					{
						set_user_gravity(id, 0.0)
						switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
						{
							case 2:
							{	
								ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Kupio si^4 No Gravity^1 koji traje^3 %i sekundi^1 za^3 %i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_NOGRAV ] ), grav)
							}
							case 1:
							{
								ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You bought^4 No Gravity^1, duration is^3 %i seconds^1, price:^3 %i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_NOGRAV ] ), grav)
							}
						}
						cs_set_user_money(id, cs_get_user_money(id) - grav)
						biloa[id] = true
						set_task( get_pcvar_float( g_SviCvarovi[ TRAJANJE_NOGRAV ] ),"gasi_gravi",id)
					}
				}
			}
			else
			{
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Vec si kupio^3 No Gravity")
					}
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You have already bought^3 No Gravity")
					}
				}
			}
		}
		else
		{
			switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
			{
				case 2:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Nemas dovoljno para za ovaj item, potrebno je^3 %i$", grav)
				}
				case 1:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You don't have enought money for this item, you need^3 %i$", grav)
				}
			}
		}
	}
	else
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 2:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server je iskljucio ovaj^3 Item")
			}
			case 1:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server has turned off this^3 Item")
			}
		}
	}
	return PLUGIN_HANDLED
}

public beskonacno(id)
{
	if(!is_user_alive(id))
	return PLUGIN_HANDLED
	new gra =  get_pcvar_num( g_SviCvarovi[ CENA_BESHP ] )
	if(get_pcvar_num( g_SviCvarovi[ BES_HP ] ) == 1)
	{
		if(cs_get_user_money(id) >= gra)
		{
			if(!bilos[id])
			{
				set_user_health(id,100000)
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Kupio si^4 Beskonacno helti^1 koji traje^3 %i sekundi^1 za^3 %i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_BESHP ] ) , gra)
					}
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You bought^4 Unlimited health^1, duration:^3 %i seconds^1, price:^3 %i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_BESHP ] ) , gra)
					}
				}
				cs_set_user_money(id, cs_get_user_money(id) - gra)
				bilos[id] = true
				set_task(get_pcvar_float( g_SviCvarovi[ TRAJANJE_BESHP ] ),"pojacaj",id)
			}
			else
			{
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Vec si kupio^3 No Beskonacno HP-a")
					}
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You have already bought^3 Unlimited health")
					}
				}
			}
		}
		else
		{
			switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
			{
				case 1:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You don't have enought money for this item, you need^3 %i$", gra)
				}
				case 2:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Nemas dovoljno para za ovaj item, potrebno je^3 %i$", gra)
				}
			}
					
		}
	}
	else
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 2:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server je iskljucio ovaj^3 Item")
			}
			case 1:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server has turned of this^3 Item")
			}
		}
	}
	return PLUGIN_HANDLED
}

public noclip(id)
{
	if(!is_user_alive(id))
	return PLUGIN_HANDLED
	new noc = get_pcvar_num( g_SviCvarovi[ CENA_NOCLIP ] ) 
	if(get_pcvar_num( g_SviCvarovi[ NOCLIP ] )  == 1)
	{
		if(cs_get_user_money(id) >= noc)
		{
			if(!bilod[id])
			{
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Kupio si^3 Noclip^1 koji traje^3 %i sekundi^1 za^3 %i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_NOCLIP ] ), noc)
					}
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You bought^3 Noclip^1, duration:^3 %i seconds^1, price:^3 %i$", get_pcvar_num( g_SviCvarovi[ TRAJANJE_NOCLIP ] ), noc)
					}
				}
				set_user_noclip(id,1)
				cs_set_user_money(id, cs_get_user_money(id) - noc)
				bilod[id] = true
				set_task(get_pcvar_float( g_SviCvarovi[ TRAJANJE_NOCLIP ] ),"gasi_noclip",id)
			}
			else
			{
				switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
				{
					case 2:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Vec si kupio^3 Noclip")
					}
					case 1:
					{
						ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You have already bought^3 Noclip")
					}
				}
			}
		}
		else
		{
			switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
			{
				case 2:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Nemas dovoljno para za ovaj item, potrebno je^3 %i$", noc)
				}
				case 1:
				{
					ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You don't have enought money for this item, you need^3 %i$", noc)
				}
			}
		}
	}
	else
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 2:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server je iskljucio ovaj^3 Item")
			}
			case 1:
			{
				ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Server has turned of this^3 Item")
			}
		}
	}
	return PLUGIN_HANDLED
}

public gasi_gravi(id)
{
	if(is_user_alive(id) && is_user_connected(id))
	set_user_gravity(id, 1.0)
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 2:
		{
			ColorChat(id, TEAM_COLOR, "^4[VIP]^3 Gravitacija^1 ti je vracena na default")
		}
		case 1:
		{
			ColorChat(id, TEAM_COLOR, "^4[VIP]^3 Gravity^1 is now default")
		}
	}
	return PLUGIN_HANDLED
}

public pojacaj(id)
{
	if(is_user_alive(id) && is_user_connected(id))
	set_user_health(id,100000)
	set_task(5.0,"gasi_bes",id)
	return PLUGIN_CONTINUE
}

public gasi_noclip(id)
{
	if(is_user_alive(id) && is_user_connected(id))
	set_user_noclip(id,0)
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 2:
		{
			ColorChat(id, TEAM_COLOR, "^4[VIP]^3 Noclip^1 ti je vracen na default")
		}
		case 1:
		{
			ColorChat(id, TEAM_COLOR, "^4[VIP]^3 Noclip^1 has been turned off")
		}
	}
	return PLUGIN_HANDLED
}

public gasi_bes(id)
{
	if(is_user_alive(id) && is_user_connected(id))
	set_user_health(id,100)
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 2:
		{
			ColorChat(id, TEAM_COLOR, "^4[VIP]^3 Helti^1 su ti vraceni na default")
		}
		case 1:
		{
			ColorChat(id, TEAM_COLOR, "^4[VIP]^3 Now you have^3 100 HP")
		}
	}
	return PLUGIN_HANDLED
}

public Death()
{
	new attacker = read_data(1)
	if(attacker > maxplayers) 
		return;
	if((get_user_flags(attacker) & ADMIN_LEVEL_H) && is_user_alive(attacker))
	{
		if(read_data(3))
		{
			set_user_health(attacker, get_user_health(attacker) + get_pcvar_num( g_SviCvarovi[ HS_HP ] ))
			cs_set_user_money(attacker, cs_get_user_money(attacker) + get_pcvar_num( g_SviCvarovi[ HS_MONEY ] ))
		}
		else
		{
			set_user_health(attacker, get_user_health(attacker) + get_pcvar_num( g_SviCvarovi[ HPKILL ] ))
			cs_set_user_money(attacker, cs_get_user_money(attacker) + get_pcvar_num( g_SviCvarovi[ MONEYKILL ] ))
		}
	}
}

public plugin_precache() 
{
	server_cmd("exec %s", g_ConfigFile)
	server_cmd("exec %s", VipShop)
	server_exec()
	if(!dir_exists(vipp))
	{
		mkdir(vipp)
	}
	if(!file_exists(g_ConfigFile)) 
	{
		write_file(g_ConfigFile, "; ENGLISH:")
		write_file(g_ConfigFile, "; Here are all settings of the ULTIMATE VIP Plugin [ 1= ON | 0= OFF ]")
		write_file(g_ConfigFile, "; SRPSKI:")
		write_file(g_ConfigFile, "; Ovde se nalaze sva podesavanja vezana za ULTIMATE VIP Plugin [ 1 = ukljuceno | 0 = iskljuceno ]")
		write_file(g_ConfigFile, " ")
		write_file(g_ConfigFile, "vip_language ^"1^" // language of plugin [ 1 = ENGLISH | 2 = SERBIAN] // jezik plugina [ 1 = ENGLESKI | 2 = SRPSKI]")
		write_file(g_ConfigFile, "vip_bombs ^"hsfd^" // h = He, s = Sg, f = First Fb, d = Second Fb // h = He, s = Sg, f = Prva Fb, d = Druga Fb")
		write_file(g_ConfigFile, "vip_gravity ^"0.2^" // how much will be weaker vip gravity // koliko je slabija vipova gravitacija")
		write_file(g_ConfigFile, "vip_money ^"2000^" // how much money vip get on spawn // koliko ce dodatno para VIP da dobija na Spawnu")
		write_file(g_ConfigFile, "vip_health ^"50^" // how much health vip gets on spawn // koliko ce dodatnih hp-a VIP da dobija na Spawnu")
		write_file(g_ConfigFile, "vip_speed ^"20^" // how much is vip faster than other players // koliko je VIP brzi od ostalih igraca")
		write_file(g_ConfigFile, "vip_glow ^"1^" // 0 = no glow | 1 = Vip may take glow if he want | 2 = Vip has to have glow // 0 = nema glow | 1 = Vip moze da stavi glow ako hoce | 2 = Vip mora da ima glow")
		write_file(g_ConfigFile, "vip_armor ^"100^" // how much armor vip gets on spawn // koliko armora VIP dobija na spawnu")
		write_file(g_ConfigFile, "vip_awp ^"1^" // only vip can buy awp // da li samo VIP moze da kupi AWP")
		write_file(g_ConfigFile, "vip_guns ^"1^" // can vip has to choose guns and rifles // da li ce VIP-u izlaziti menu sa puskama i pistoljima na spawnu")
		write_file(g_ConfigFile, "vip_connect ^"1^" // do players know when vip connect on server // da li igracima stize obavestenje kad VIP dodje na server")
		write_file(g_ConfigFile, "vip_connect_color ^"1^" // what is the color of vip connect hud message 1=RED | 2=GREEN | 3=BLUE // koje boje ce biti obavestenje o dolasku vipa na server 1=CRVENA | 2=ZELENA | 3=PLAVA")
		write_file(g_ConfigFile, "vip_c4 ^"1^" // 0 = No C4 buying, 1 = C4 can be purchased, 2 = vip gets C4 on spawn // 0 = C4 nece moci da se kupuje, 1 = C4 moze da se kupuje, 2 = Vip-ovi dobijaju C4 na Spawn-u")
		write_file(g_ConfigFile, "vip_c4_price ^"4000^" // Price of C4 for vips")
		write_file(g_ConfigFile, "vip_advert ^"120.0^" // the number of seconds for vip advertistments // na koliko sekundi ce izlaziti reklama o pluginu")
		write_file(g_ConfigFile, "vip_hp_kill ^"20^" // how much health vip gets by kill // koliko hp-a VIP dobija po kill-u")
		write_file(g_ConfigFile, "vip_hs_hp_kill ^"40^" // how much health vip gets by kill (HeadShot) // koliko hp-a VIP dobija po kill-u (HeadShot)")
		write_file(g_ConfigFile, "vip_money_kill ^"500^" // how much hmoney vip gets by kill // koliko ce VIP dobiti novca po ubistvu")
		write_file(g_ConfigFile, "vip_hs_money_kill ^"1000^" // how much hmoney vip gets by kill (HeadShot) // koliko ce VIP dobiti novca po ubistvu (HeadShot)")
		write_file(g_ConfigFile, "vip_prefix ^"1^" // has vip [VIP] prefix on say command // da li VIP ima svoj [VIP] prefix na chatu")
		write_file(g_ConfigFile, "vip_log_vips ^"1^" // login of vip chat // da li ce se logovati Vip Chat na sreveru")
		write_file(g_ConfigFile, "vip_log_all ^"0^" // login of chat all players // da li ce se Logovati Chat svih igraca na serveru")
		write_file(g_ConfigFile, "vip_shop ^"1^" // has vip VipShop // da li VIP ima svoj Shop")
		write_file(g_ConfigFile, "vip_vipinfo ^"1^" // Vip info Motd // Motd prozor (informacije o vipu)")
		write_file(g_ConfigFile, "vip_buyvip ^"1^" // How to buy Vip // Kako kupiti vipa (boost info)")
		write_file(g_ConfigFile, "vip_becamevip ^"1^" // Command say /becamevip // Aktivnost komande say /postanivip")
		write_file(g_ConfigFile, "vip_noreload ^"1^" // Has vip always full clip // Da li je vipu uvek pun sarzer")
		write_file(g_ConfigFile, "vip_heal ^"1^" // Whether to Heal VIP // Da li ce se vipu dopunjavati helti")
		write_file(g_ConfigFile, "vip_heal_max ^"120^" // With how many HP healing ends // Sa koliko HP-a se zavrsava Heal")
		write_file(g_ConfigFile, "vip_heal_speed ^"5.0^" // The number of secound to heal // Na koliko sekundi ce se dopunjavati HP")
		write_file(g_ConfigFile, "vip_flags ^"b^" // Addition VIP flags // Dodatni VIP flagovi")
		write_file(g_ConfigFile, "// a - Immunity (can't be slayed, baned, kicked) // Imunitet (ne moze da bude slay-ovan, kikovan, banovan)")
		write_file(g_ConfigFile, "// b - SLOT (Reserved slot on server) // SLOT (Rezervisano mesto na serveru)")
		write_file(g_ConfigFile, "// c - Kick Command (amx_kick) // Komanda za Kick-ovanje igraca (amx_kick)")
		write_file(g_ConfigFile, "// d - Ban Command (amx_ban) // Komanda za Banovanje igraca (amx_ban)")
		write_file(g_ConfigFile, "// e - Slay & Slap cmds (amx_slay & amx_slap) // Komande za slay i slap (amx_slap & amx_slay)")
		write_file(g_ConfigFile, "// i - Admin chat cmds (amx_say,amx_chat,amx_tsay...) // Admin chat komande (amx_say,amx_chat,amx_tsay...)")
	}
	if(!file_exists(naruciti))
	{
		write_file(naruciti, "ENGLISH:")
		write_file(naruciti, "In this file are nick and steam_id-a of player which boosted server")
		write_file(naruciti, "If player didn't boost server, ban him")
		write_file(naruciti, "SRPSKI:")
		write_file(naruciti, "U ovom fajlu stoje Nickovi onih koji su boost-ovali server (kupili vip-a)")
		write_file(naruciti, "Nakon ovoga proveri da li je navedeni igrac boost-ovao server, ako nije slobodno ga banuj")
		write_file(naruciti, "=========================================================================================")
		write_file(naruciti, " ")
	}
	if(!file_exists(log))
	{
		write_file(log, "ENGLISH:")
		write_file(log, "This file iz Chat Log on server (only say command)")
		write_file(log, "For settings visit Settings.cfg")
		write_file(log, "SRPSKI:")
		write_file(log, "Ovaj fajl je Log Chata na serveru (samo say komande)")
		write_file(log, "Za podesavanja poseti Podesavanja.cfg")
		write_file(log, "========================================================================================================")
		write_file(log, " ")
	}
	if(!file_exists(infos))
	{
		write_file(infos, "ENGLISH:")
		write_file(infos, "=======================================================")
		write_file(infos, " ")
		write_file(infos, "In this file are the most important information related to Ultimate VIP Plugin")
		write_file(infos, "Vip lis is located in vips.ini file. Do not use ; before and after Vips Steam ID")
		write_file(infos, "All plugin setup (Cvars) are located in Settings.cfg")
		write_file(infos, "In file VipShop.cfg are located all setting of vip shop, ^"say / vipshop^"")
		write_file(infos, "Next to each setting is the same explanation for cvar")
		write_file(infos, "In file Orders.txt are Nicks and Steam IDs players who boosted server")
		write_file(infos, "In file ChatLog.txt, is all chat-say commands (this is what is entered Vips write) The work of this file is set by Cvar")
		write_file(infos, "MotdENG.html file is an image that will display the player's command ^"say / vipinfo^"")
		write_file(infos, " ")
		write_file(infos, "Version of the plugin is 1.6")
		write_file(infos, "Keep up to date regarding the recent version of this plugin, visit forum.kgb-hosting.com")
		write_file(infos, " ")
		write_file(infos, " ")
		write_file(infos, "Greetings from the BS, author of the plugin")
		write_file(infos, " ")
		write_file(infos, " ")
		write_file(infos, "SRPSKI:")
		write_file(infos, "=======================================================")
		write_file(infos, " ")
		write_file(infos, "U ovom fajlu se nalaze najbitnija obavestenja vezana za Ultimate VIP Plugin")
		write_file(infos, "Lista vipova nalazi se u vips.ini fajlu. Ne koristi ; ni pre ni posle Steam ID-a Vip-a")
		write_file(infos, "Sva podesavanja plugina (cvarovi) nalaze se u Podesavanja.cfg")
		write_file(infos, "Fajl VipShop.cfg sluzi sa podesavanje VipShopa, komanda ^"say /vipshop^"")
		write_file(infos, "Pored svakog podesavanja stoji objasnjenje za isto")
		write_file(infos, "U fajlu Porudzbine.txt nalaze se Nick-ovi i Steam id-ovi igraca koji su navodno Boost-ovali server")
		write_file(infos, "U fajlu ChatLog.txt je istorija chat-a (tu se upisuje sta Vip-ovi pisu) Rad ovog fajla podesava se Cvarom")
		write_file(infos, "Fajl motd.html je slika koja ce se prikazati igracu komandom ^"say /vipinfo^"")
		write_file(infos, " ")
		write_file(infos, "Verzija plugina je 1.6")
		write_file(infos, "Budi u toku vezano za novije verzije ovog plugina, poseti forum.kgb-hosting.com")
		write_file(infos, " ")
		write_file(infos, " ")
		write_file(infos, "Pozdrav od BS-a, autora Plugina")
	}
	if(!file_exists(motddt))
	{
		write_file(motddt, "html>")
		write_file(motddt, "<head>")
		write_file(motddt, "<style type=^"text/css^">")
		write_file(motddt, "body	{")
		write_file(motddt, "background-color: #000000;")
		write_file(motddt, "font-family:Verdana,Tahoma;")
		write_file(motddt, "		}")
		write_file(motddt, "</style>")
		write_file(motddt, "	<meta http-equiv=^"Content-Type^" content=^"text/html; charset=windows-1257^">")
		write_file(motddt, "</head>")
		write_file(motddt, "<font size=^"2^" color=^"#e0a518^"><b><center>Sta dobijam ako sam VIP?</center></b></font><br />")
		write_file(motddt, "<font size=^"1^" color=^"#c0c0ff^">")
		write_file(motddt, "<UL>")
		write_file(motddt, "<LI TYPE=square>Vip dobija HP i Armor</LI><br>")
		write_file(motddt, "<LI TYPE=square>Dobija 500$ i 20hp-a po ubistvu.</LI><br>")
		write_file(motddt, "<LI TYPE=square>Dobija 1000$ i 40hp-a po ubistvu za HeadShot.</LI><br>")
		write_file(motddt, "<LI TYPE=square>Vip ima [VIP] Prefix na chatu</LI><br>")
		write_file(motddt, "<LI TYPE=square>Kada igraci kucaju ^"/vipovi^" vide njegov nick</LI><br>")
		write_file(motddt, "<LI TYPE=square>Samo Vip moze da kupi AWP</LI><br>")
		write_file(motddt, "<LI TYPE=square>VIP ima VIP tag u SCOREBOARDU</LI><br>")
		write_file(motddt, "<LI TYPE=square>Vip ima svoj /vipshop</LI><br>")
		write_file(motddt, "<LI TYPE=square>Vip ima uvek pun sarzer</LI><br>")
		write_file(motddt, "<LI TYPE=square>Vip ima SLOT na serveru</LI><br>")
		write_file(motddt, "<LI TYPE=square>Vipovi imaju VIP Chat na serveru</LI><br>")
		write_file(motddt, "<LI TYPE=square>Vip ima vecu brzinu, manju gravitaciju i jos dosta toga</LI><br>")
		write_file(motddt, "<font size=^"2^" color=#00c000><strong>Zelis da ga kupis?</strong></font><br></UL>")
		write_file(motddt, "kucaj /kupivipa za sve informacije<br>")
		write_file(motddt, "<font size=^"3^" color=^"#ffffff^"><strong>VIP by [BS]</strong></font><br />")
		write_file(motddt, "</body>")
		write_file(motddt, "</html>")
	}
	if(!file_exists(motddteng))
	{
		write_file(motddteng, "html>")
		write_file(motddteng, "<head>")
		write_file(motddteng, "<style type=^"text/css^">")
		write_file(motddteng, "body	{")
		write_file(motddteng, "background-color: #000000;")
		write_file(motddteng, "font-family:Verdana,Tahoma;")
		write_file(motddteng, "		}")
		write_file(motddteng, "</style>")
		write_file(motddteng, "	<meta http-equiv=^"Content-Type^" content=^"text/html; charset=windows-1257^">")
		write_file(motddteng, "</head>")
		write_file(motddteng, "<font size=^"2^" color=^"#e0a518^"><b><center>What are benefits of vip?</center></b></font><br />")
		write_file(motddteng, "<font size=^"1^" color=^"#c0c0ff^">")
		write_file(motddteng, "<UL>")
		write_file(motddteng, "<LI TYPE=square>Vip get Health and Armor</LI><br>")
		write_file(motddteng, "<LI TYPE=square>Vip get 500$ and 20hp by kill.</LI><br>")
		write_file(motddteng, "<LI TYPE=square>Vip get 1000$ and 40hp by kill - HeadShot.</LI><br>")
		write_file(motddteng, "<LI TYPE=square>Vip has [VIP] Prefix on chatu</LI><br>")
		write_file(motddteng, "<LI TYPE=square>When players say ^"/vips^", they see his nick</LI><br>")
		write_file(motddteng, "<LI TYPE=square>Just Vip can buy AWP</LI><br>")
		write_file(motddteng, "<LI TYPE=square>VIP has VIP tag in SCOREBOARD</LI><br>")
		write_file(motddteng, "<LI TYPE=square>Vip has VipShop, /vipshop</LI><br>")
		write_file(motddteng, "<LI TYPE=square>Vip has always full clip</LI><br>")
		write_file(motddteng, "<LI TYPE=square>Vip has slot on server</LI><br>")
		write_file(motddteng, "<LI TYPE=square>Vips has Vip Chat</LI><br>")
		write_file(motddteng, "<LI TYPE=square>Vip is faster, he has weaker gravity and more</LI><br>")
		write_file(motddteng, "<font size=^"2^" color=#00c000><strong>Do you want to be VIP?</strong></font><br></UL>")
		write_file(motddteng, "Say /buyvip for all info<br>")
		write_file(motddteng, "<font size=^"3^" color=^"#ffffff^"><strong>VIP by [BS]</strong></font><br />")
		write_file(motddteng, "</body>")
		write_file(motddteng, "</html>")
	}
	if(!file_exists(VipShop))
	{
		write_file(VipShop, "; ENGLISH:")
		write_file(VipShop, "; In this file are located all setings of VIP SHOP")
		write_file(VipShop, "; If cvar vip_shop set to 0, this settings has no effect")
		write_file(VipShop, "; [ 1 = ON | 0 = OFF ]")
		write_file(VipShop, "; SERBIAN:")
		write_file(VipShop, "; U ovom fajlu nalaze se sva podesavanja VIP SHOP-a")
		write_file(VipShop, "; Ako je cvar vip_shop = 0, ova podesavanja nemaju efekat")
		write_file(VipShop, "; [ 1 = Ukljuceno | 0 = Iskljuceno ]")
		write_file(VipShop, "; ============================================================")
		write_file(VipShop, " ")
		write_file(VipShop, "Health ^"1^" // First menu item // prvi item iz meni-a")
		write_file(VipShop, "Price_hp ^"2000^" // Price of item // Cena itema")
		write_file(VipShop, "How_hp ^"50^" // Quantity of item // kolicina itema")
		write_file(VipShop, " ")
		write_file(VipShop, "Armor ^"1^" // Second menu item // drugi item iz meni-a")
		write_file(VipShop, "Price_armor ^"3500^" // Price of item // Cena itema")
		write_file(VipShop, "How_armor ^"100^" // Quantity of item // kolicina itema")
		write_file(VipShop, " ")
		write_file(VipShop, "No_gravity ^"1^" // Third menu item // treci item iz meni-a")
		write_file(VipShop, "Price_no_gravity ^"4000^" // Price of item // Cena itema")
		write_file(VipShop, "Duration_no_gravity ^"35.0^" // Duration of item // trajanje itema")
		write_file(VipShop, " ")
		write_file(VipShop, "Unlimited_hp ^"1^" // Fourth menu item // cetvrti item iz meni-a")
		write_file(VipShop, "Price_unlimited_hp ^"7000^" // Price of item // Cena itema")
		write_file(VipShop, "Duration_unlimited_hp ^"10^" // Duration of item // trajanje itema")
		write_file(VipShop, " ")
		write_file(VipShop, "Noclip ^"1^" // Fifth menu item // prvi item iz meni-a")
		write_file(VipShop, "Price_noclip ^"8000^" // Price of item // Cena itema")
		write_file(VipShop, "Duration_noclip ^"15^" // Duration of item // trajanje itema")
	}
	if(!file_exists(users))
	{
		write_file(users, "; ENGLISH:")
		write_file(users, "; In this file are located Steam IDs of VIPs")
		write_file(users, "; If you use comment, use it under the Players Steam IDs")
		write_file(users, "; Example:")
		write_file(users, " ")
		write_file(users, "STEAM_0:0:2124822248")
		write_file(users, "; Beogradski Sindikat")
		write_file(users, " ")
		write_file(users, "; SERBIAN:")
		write_file(users, "; U ovom fajlu se nalaze Steam ID-ovi Vipova")
		write_file(users, "; Ako koristis komentar, napisi ga ispod igracevog Steam ID-a")
		write_file(users, "; Primer:")
		write_file(users, " ")
		write_file(users, "STEAM_0:0:2008670268")
		write_file(users, "; Beogradski Sindikat")
		write_file(users, " ")
		write_file(users, "; ==========================================")
	}
}

public postani(id)
{
	if(get_pcvar_num( g_SviCvarovi[ POSTANIVIP ] ) != 1)
	return PLUGIN_HANDLED
	if(!VIP(id))
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 2:
			{
				set_hudmessage(255, 0, 0, -1.0, 0.33, 0, 6.0, 12.0)
				show_hudmessage(id, "Zloupotrebljavanje ove komande kaznjava se BANOM")
				new szText[555 char]
				
				formatex(szText, charsmax(szText), "\yDa li si boost-ovao server? (poslao SMS poruku)")
				new boost = menu_create(szText, "boooost")
				
				formatex(szText, charsmax(szText), "\wNe, nisam boost-ovao.")
				menu_additem(boost, szText, "1", 0)
				
				formatex(szText, charsmax(szText), "\rDa, uspesno sam boost-ovao server.")
				menu_additem(boost, szText, "2", 0)
				
				menu_setprop(boost, MPROP_EXIT, MEXIT_ALL)
				menu_display(id, boost)
			}
			case 1:
			{
				set_hudmessage(255, 0, 0, -1.0, 0.33, 0, 6.0, 12.0)
				show_hudmessage(id, "Abuse of this command is punished by BAN")
				new szText[555 char]
				formatex(szText, charsmax(szText), "\yDid you boost this server? (sent sms message)")
				new boost = menu_create(szText, "boooost")
				
				formatex(szText, charsmax(szText), "\wNo, i didn't boost.")
				menu_additem(boost, szText, "1", 0)
				
				formatex(szText, charsmax(szText), "\rYeah, i boosted server successfully")
				menu_additem(boost, szText, "2", 0)
				
				menu_setprop(boost, MPROP_EXIT, MEXIT_ALL)
				menu_display(id, boost)
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public boooost(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	new data[6], iName[64], access, callback
	menu_item_getinfo(menu, item, access, data, charsmax(data), iName, charsmax(iName), callback )
	new key = str_to_num(data)
	switch(key)
	{ 
		case 1: neee(id)
		case 2: daaa(id)
	}
	return PLUGIN_HANDLED
}

public neee(id)
{
	return PLUGIN_HANDLED
}

public daaa(id)
{
	new name[33]
	get_user_name(id,name,32)
	new idd[33]
	get_user_authid(id,idd,32)
	new nesto[192]
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 2:
		{
			format(nesto, 191, "Igrac [ Nick: ^"%s^" ] [ STEAM_ID: ^"%s^" ]", name, idd)
		}
		case 1:
		{
			format(nesto, 191, "Player [ Nick: ^"%s^" ] [ STEAM_ID: ^"%s^" ]", name, idd)
		}
	}
	write_file(naruciti, nesto)
	write_file(naruciti, " ")
	switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
	{
		case 1:
		{
			client_cmd(id,"amx_chat ^"I have boosted server and ordered VIP^"")
			ColorChat(id, TEAM_COLOR, "^4[VIP]^1 You have just ordered^4 VIP^1, wait for Head-Admin")
			ColorChat(id, TEAM_COLOR, "^4[VIP]^1 If you didn't boost, run away from server !")
		}
		case 2:
		{
			client_cmd(id,"amx_chat ^"Ja sam Boost-ovao ovaj server i upravo sam porucio VIP-a^"")
			ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Uspesno si narucio^3 VIP-a^1, sacekaj da porudzbinu vidi Head-Admin")
			ColorChat(id, TEAM_COLOR, "^4[VIP]^1 Ako nisi stvarno Boost-ovao, bolje nemoj vise da dolazis na server...")
		}
	}
	return PLUGIN_HANDLED
}

public prefixe(id)
{
	if(VIP(id) && (get_pcvar_num( g_SviCvarovi[ PREFIX ] ) == 1))
	{
		new name[33]
		get_user_name(id,name,32)
		new kaze[192]
		read_args(kaze, 191)
		remove_quotes(kaze)
		if(is_user_alive(id))
		{
			ColorChat(0, TEAM_COLOR, "^4[VIP]^3 %s:^4 %s", name, kaze)
		}
		else if(!is_user_alive(id))
		{
			ColorChat(0, TEAM_COLOR, "^1*DEAD* ^4[VIP]^3 %s:^4 %s", name, kaze)
		}
		if(get_pcvar_num( g_SviCvarovi[ LOGVIPS ] ) == 1)
		{
			if(cs_get_user_team(id) == CS_TEAM_T)
			{
				new idde[33]
				get_user_authid(id,idde,32)
				new nestoe[192]
				format(nestoe, 192, "<<VIP>> [Team T] [ Nick: ^"%s^" ] [ STEAM_ID: ^"%s^" ] [ Say: ^"%s^" ]", name, idde, kaze)
				write_file(log, nestoe)
			}
			if(cs_get_user_team(id) == CS_TEAM_CT)
			{
				new idde[33]
				get_user_authid(id,idde,32)
				new nestoe[192]
				format(nestoe, 192, "<<VIP>> [Team CT] [ Nick: ^"%s^" ] [ STEAM_ID: ^"%s^" ] [ Say: ^"%s^" ]", name, idde, kaze)
				write_file(log, nestoe)
			}
			if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
			{
				new idde[33]
				get_user_authid(id,idde,32)
				new nestoe[192]
				format(nestoe, 192, "<<VIP>> [Team Spectator] [ Nick: ^"%s^" ] [ STEAM_ID: ^"%s^" ] [ Say: ^"%s^" ]", name, idde, kaze)
				write_file(log, nestoe)
			}
		}
		return PLUGIN_HANDLED
	}
	else
	{
		if(get_pcvar_num( g_SviCvarovi[ LOGALL ] )== 1)
		{
			if(cs_get_user_team(id) == CS_TEAM_CT)
			{
				new namer[33]
				get_user_name(id,namer,32)
				new kazer[192]
				read_argv(id,kazer,191)
				remove_quotes(kazer)
				new idder[33]
				get_user_authid(id,idder,32)
				new nestoer[192]
				format(nestoer, 192, "[Team CT] [ Nick: ^"%s^" ] [ STEAM_ID: ^"%s^" ] [ Say: ^"%s^" ]", namer, idder, kazer)
				write_file(log, nestoer)
			}
			if(cs_get_user_team(id) == CS_TEAM_T)
			{
				new namer[33]
				get_user_name(id,namer,32)
				new kazer[192]
				read_args(kazer, 191)
				remove_quotes(kazer)
				new idder[33]
				get_user_authid(id,idder,32)
				new nestoer[192]
				format(nestoer, 192, "[Team T] [ Nick: ^"%s^" ] [ STEAM_ID: ^"%s^" ] [ Say: ^"%s^" ]", namer, idder, kazer)
				write_file(log, nestoer)
			}
			if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
			{
				new namer[33]
				get_user_name(id,namer,32)
				new kazer[192]
				read_args(kazer, 191)
				remove_quotes(kazer)
				new idder[33]
				get_user_authid(id,idder,32)
				new nestoer[192]
				format(nestoer, 192, "[Team Spec] [ Nick: ^"%s^" ] [ STEAM_ID: ^"%s^" ] [ Say: ^"%s^" ]", namer, idder, kazer)
				write_file(log, nestoer)
			}
			
		}
	}
	return PLUGIN_CONTINUE
}

public vipchat(id)
{
	if(!VIP(id))
	{
		switch(get_pcvar_num( g_SviCvarovi[ JEZIK ] ))
		{
			case 2:
				ColorChat(id,TEAM_COLOR,"^4[VIP]^1 Nisi^3 VIP^1, nemas pristup^4 Vip Chatu")
			case 1:
				ColorChat(id,TEAM_COLOR,"^4[VIP]^1 You are not^3 VIP^1, you don't have access to^4 Vip Chat")
		}
		return PLUGIN_HANDLED
	}
	new poruka[191]
	read_args(poruka,190)  
	remove_quotes(poruka)
	new igraci[32],broj,name[33]
	get_user_name(id,name,32)
	get_players(igraci,broj)
	for(new i = 0; i < broj; ++i)
	if(igraci[i])
	{
		if(get_user_flags(igraci[i]) & ADMIN_LEVEL_H)
		{
			ColorChat(igraci[i],TEAM_COLOR,"^4[VIP]^3 %s^4 vipovima:^1 %s",name,poruka)
		}
	}
	return PLUGIN_HANDLED
}  
	

public reload()
{
	Vipovi = TrieCreate()
	new Directory [] = "addons/amxmodx/configs/vip/vips.ini"
	
	new Data[35],File
	File = fopen(Directory, "rt")
		
	while (!feof(File)) {
		fgets(File, Data, charsmax(Data))
			
		trim(Data)
			
		if (Data[0] == ';' || !Data[0]) 
			continue;
			
		remove_quotes(Data)
		TrieSetCell(Vipovi, Data, true)  
	}
		
	fclose(File)
}

public komandom(id,level,cid)
{
	if(cmd_access(id,level,cid,2))
	return PLUGIN_HANDLED
	Vipovi = TrieCreate()
	new Directory [] = "addons/amxmodx/configs/vip/vips.ini"
	
	new Data[35],File
	File = fopen(Directory, "rt")
		
	while (!feof(File)) {
		fgets(File, Data, charsmax(Data))
			
		trim(Data)
			
		if (Data[0] == ';' || !Data[0]) 
			continue;
			
		remove_quotes(Data)
		TrieSetCell(Vipovi, Data, true)  
	}
		
	fclose(File)
	return PLUGIN_HANDLED
}

public plugin_end()
	TrieDestroy(Vipovi)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0\\ deflang1033{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
