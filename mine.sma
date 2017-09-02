#include <amxmodx>
#include <fakemeta>
#include <engine> 
#include <fun>
#include <hamsandwich>
#include <amxmisc> 
#include <cstrike>

#define is_user_valid_alive(%1) (1 <= %1 <= g_MaxPlayers && is_user_alive(%1))
#define is_user_valid_connected(%1) (1 <= %1 <= g_MaxPlayers && is_user_connected(%1))
#define MINE_OWNER		pev_iuser2
#define TASK_FROST 		113435
#define TASK_FIRE 		114435
#define TASK_GUARD 		115435

// Настройки радиуса и урона
const Float:DEF_EXP_RADIUS 		= 100.0 	// O raio das minas simples explosão
const Float:DEF_EXP_DAMAGE 		= 80.0		// Max Damage das minas simples
const Float:DEF_INV 			= 150.0		// Minas de invisibilidade (quanto menor o valor, mais transparente a mina) // 255 // 0 total visibilidade nevidimst completa

const Float:FROST_EXP_RADIUS 	= 100.0		// Raio de congelação
const Float:FROST_EXP_DAMAGE 	= 80.0		// Danos congelamento
const Float:FROST_INV 			= 100.0		// Invisibilidade
const Float:FROST_TIME			= 2.0		// tempo de congelamento

const Float:FIRE_EXP_RADIUS 	= 100.0		// Raio de Fogo
const Float:FIRE_EXP_DAMAGE 	= 80.0		// inflamabilidade danos
const Float:FIRE_INV 			= 100.0		// invisibilidade
const FIRE_TIME					= 5			// tempo de queima
const Float:FIRE_DMG		 	= 5.0		// inflamabilidade danos

const Float:GUARD_EXP_RADIUS 	= 100.0		// o raio de protecção
const Float:GUARD_EXP_DAMAGE 	= 80.0		// inflamabilidade danos
const Float:GUARD_INV 			= 255.0		// invisibilidade
const Float:GUARD_TIME			= 3.0		// tempo invulnerabilidade

const Float:TEL_EXP_RADIUS 		= 100.0		// raio
const Float:TEL_INV 			= 255.0		// invisibilidade

const Float:GAL_EXP_RADIUS 		= 100.0		// raio
const Float:GAL_EXP_DAMAGE 		= 80.0		// dano 
const Float:GAL_INV 			= 255.0		// invisibilidade
const GAL_TIME					= 3			// tempo de agitação

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_0

new const MINE_CLASSNAME_DEF[] 		= "defmine"
new const MINE_CLASSNAME_FROST[]	= "frostmine"
new const MINE_CLASSNAME_FIRE[] 	= "firemine"
new const MINE_CLASSNAME_GUARD[] 	= "guardmine"
new const MINE_CLASSNAME_TEL[] 		= "telmine"
new const MINE_CLASSNAME_GAL[] 		= "galmine"

new const MINE_MODEL[] 		= "models/mine.mdl"
new const MINE_SETUP[] 		= "weapons/mine_deploy.wav"
new const MINE_EXPLODE[] 	= "sprites/mine_explode.spr"
new const MINE_EXPLODE_FROST[] 	= "sprites/mine_explode_frost.spr"
new const MINE_EXPLODE_GAL[] 	= "sprites/mine_explode_gal.spr"
new const GLASS_MODEL[]		= "models/glassgibs.mdl"
new const FLAME_SPR[] 		= "sprites/flame.spr"
new const SMOKE_SPR[] 		= "sprites/black_smoke3.spr"

new g_ent, g_SprExp, g_SprGlass, g_SmokeSpr, g_FlameSpr, g_SprExpFrost, g_SprExpGal

new pCvarCostDef, pCvarCostFrost, pCvarCostFire, pCvarBonus, pCvarBonusNum, pCvarMaxMine

new g_msgDeathMsg, g_MaxPlayers, g_msgSayText

new g_burning_duration[33], g_BuyNum[33], g_BonusMine[33], g_BuyTotal[33]

public plugin_init()
{
	register_plugin("Mine", "1.0", "ill")
	
	register_event("HLTV", "EV_RoundStart", "a", "1=0", "2=0")
	
	register_clcmd("say /mine", "buy_mine")
	
	register_menu("Mine Menu", KEYSMENU, "mine_menu")
	
	RegisterHam(Ham_Killed, "player", "fw_HamKilled")
	
	register_touch(MINE_CLASSNAME_DEF, "player", "Hook_Touch")
	register_touch(MINE_CLASSNAME_FROST, "player", "Hook_Touch")
	register_touch(MINE_CLASSNAME_FIRE, "player", "Hook_Touch")
	register_touch(MINE_CLASSNAME_GUARD, "player", "Hook_Touch")
	register_touch(MINE_CLASSNAME_TEL, "player", "Hook_Touch")
	register_touch(MINE_CLASSNAME_GAL, "player", "Hook_Touch")
	
	pCvarCostDef = register_cvar("mine_cost_def", "10000")
	pCvarCostFrost = register_cvar("mine_cost_frost", "15000")
	pCvarCostFire = register_cvar("mine_cost_fire", "20000")
	pCvarBonus = register_cvar("mine_to_bonus", "3")
	pCvarBonusNum = register_cvar("mine_bonus_count", "5")
	pCvarMaxMine = register_cvar("mine_limit", "10")
	
	g_ent = engfunc(EngFunc_AllocString, "info_target")
	g_MaxPlayers = get_maxplayers()
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgSayText = get_user_msgid("SayText")
}

public plugin_precache()
{
	precache_model(MINE_MODEL)
	precache_sound(MINE_SETUP)
	g_SprExp = precache_model(MINE_EXPLODE)
	g_SprGlass = precache_model(GLASS_MODEL)
	g_SmokeSpr = precache_model(SMOKE_SPR)
	g_FlameSpr = precache_model(FLAME_SPR)
	g_SprExpFrost = precache_model(MINE_EXPLODE_FROST)
	g_SprExpGal = precache_model(MINE_EXPLODE_GAL)
}

public client_connect(id)
{
	g_BuyNum[id] = 0
	g_BonusMine[id] = 0
	g_BuyTotal[id] = 0
}

public client_disconnect(id)
{
	RemoveAllMines(id)
}

public EV_RoundStart()
{
	for(new id = 0; id < g_MaxPlayers; id++)
		g_BuyTotal[id] = 0
}

public fw_HamKilled(victim, attacker, shouldgib) 
{
	if(!is_user_connected(victim))
		return
	
	if(pev(victim, pev_flags) & FL_FROZEN) 
	{
		remove_task(victim+TASK_FROST)
		set_pev(victim, pev_flags, pev(victim, pev_flags) & ~FL_FROZEN)
		set_rendering(victim)
	}
	remove_task(victim+TASK_FIRE)
	remove_task(victim+TASK_GUARD)
}

public buy_mine(id)
{
	if(g_BuyTotal[id] >= get_pcvar_num(pCvarMaxMine))
	{
		ChatColor(id, "^4[Mine] ^1Limites esgotados")
		return PLUGIN_HANDLED
	}
	
	static menu[512], len
	len = 0
	
	len += formatex(menu[len], charsmax(menu) - len, "\rMinas Terrestre^n^n")
	
	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Simples \r[\y%d$\r]^n", get_pcvar_num(pCvarCostDef))
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Congelamento \r[\y%d$\r]^n", get_pcvar_num(pCvarCostFrost))
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Fogo \r[\y%d$\r]^n^n \y - Minas Bonus \w(%d):^n", get_pcvar_num(pCvarCostFire), g_BonusMine[id])
	if(g_BonusMine[id])
	{
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\w Defesa^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\w Тeleporte^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r6.\w Alucinante^n")
	}
	else
	{
		len += formatex(menu[len], charsmax(menu) - len, "\d4. Defesa^n")
		len += formatex(menu[len], charsmax(menu) - len, "\d5. Teleporte^n")
		len += formatex(menu[len], charsmax(menu) - len, "\d6. Alucinante^n")
	}
	len += formatex(menu[len], charsmax(menu) - len, "^n\r0. \wSair")
    
	show_menu(id, KEYSMENU, menu, -1, "Mine Menu")
	
	return PLUGIN_HANDLED
}

public mine_menu(id, key)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED
		
	switch(key)
	{
		case 0:
		{
			if(cs_get_user_money(id) < get_pcvar_num(pCvarCostDef))
			{
				ChatColor(id, "^4[Mina] ^1Falta de dinheiro")
				return PLUGIN_HANDLED
			}
			
			CreateMine(id, key)
			cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(pCvarCostDef))
		}
		case 1:
		{
			if(!(get_user_flags(id) & ADMIN_LEVEL_H))
			{
				buy_mine(id)
				ChatColor(id, "^4[Mina] ^1Este tipo de minas para ^4VIP ^1Jogadores")
				return PLUGIN_HANDLED
			}	
			if(cs_get_user_money(id) < get_pcvar_num(pCvarCostFrost))
			{
				ChatColor(id, "^4[Mina] ^1Falta de dinheiro")
				return PLUGIN_HANDLED
			}
			CreateMine(id, key)
			cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(pCvarCostFrost))
		}
		case 2:
		{
			if(!(get_user_flags(id) & ADMIN_LEVEL_H))
			{
				buy_mine(id)
				ChatColor(id, "^4[Mina] ^1Este tipo de minas exclusiva ^4VIP ^1игроков")
				return PLUGIN_HANDLED
			}	
			if(cs_get_user_money(id) < get_pcvar_num(pCvarCostFire))
			{
				ChatColor(id, "^4[Mina] ^1Falta de dinheiro")
				return PLUGIN_HANDLED
			}
			CreateMine(id, key)
			cs_set_user_money(id, cs_get_user_money(id) - get_pcvar_num(pCvarCostFire))
		}
		case 3:
		{
			if(!g_BonusMine[id])
			{
				buy_mine(id)
				ChatColor(id, "^4[Mina] ^1Esta mina estara disponivel apos^3 %d ^1compras", get_pcvar_num(pCvarBonus))
				return PLUGIN_HANDLED
			}
			CreateMine(id, key)
		}
		case 4:
		{
			if(!g_BonusMine[id])
			{
				buy_mine(id)
				ChatColor(id, "^4[Mina] ^1Esta mina estara disponivel apos^3 %d ^1compras", get_pcvar_num(pCvarBonus))
				return PLUGIN_HANDLED
			}
			CreateMine(id, key)
		}
		case 5:
		{
			if(!(get_user_flags(id) & ADMIN_LEVEL_H))
			{
				buy_mine(id)
				ChatColor(id, "^4[Mina] ^1Este tipo de minas exclusiva ^4VIP ^1jogadores")
				return PLUGIN_HANDLED
			}	
			if(!g_BonusMine[id])
			{
				buy_mine(id)
				ChatColor(id, "^4[Mina] ^1Esta mina estara disponivel apos^3 %d ^1compras", get_pcvar_num(pCvarBonus))
				return PLUGIN_HANDLED
			}
			CreateMine(id, key)
		}
	}
	return PLUGIN_HANDLED
}

public CreateMine(id, type)
{
	new Float:origin[3]
	pev(id, pev_origin, origin)
	
	new ent = engfunc(EngFunc_CreateNamedEntity, g_ent)
	if (!ent)
		return PLUGIN_HANDLED
	
	switch(type)
	{
		case 0: set_pev(ent, pev_classname, MINE_CLASSNAME_DEF)
		case 1: set_pev(ent, pev_classname, MINE_CLASSNAME_FROST)
		case 2: set_pev(ent, pev_classname, MINE_CLASSNAME_FIRE)
		case 3: set_pev(ent, pev_classname, MINE_CLASSNAME_GUARD)
		case 4: set_pev(ent, pev_classname, MINE_CLASSNAME_TEL)
		case 5: set_pev(ent, pev_classname, MINE_CLASSNAME_GAL)
	}
		
	engfunc(EngFunc_SetOrigin, ent, origin)
	engfunc(EngFunc_SetModel, ent, MINE_MODEL)
	engfunc(EngFunc_SetSize, ent, Float:{-4.0, -4.0, -1.0}, Float:{4.0, 4.0, 1.0})
	set_pev(ent,pev_movetype, MOVETYPE_NOCLIP)
	set_pev(ent,pev_solid, SOLID_TRIGGER) 	
	
	set_pev(ent,pev_renderfx, kRenderFxNone)
	switch(type)
	{
		case 0: set_pev(ent,pev_renderamt, DEF_INV)
		case 1: set_pev(ent,pev_renderamt, FROST_INV)
		case 2: set_pev(ent,pev_renderamt, FIRE_INV)
		case 3: set_pev(ent,pev_renderamt, GUARD_INV)
		case 4: set_pev(ent,pev_renderamt, TEL_INV)
		case 5: set_pev(ent,pev_renderamt, GAL_INV)
	}
	set_pev(ent,pev_rendermode, kRenderTransAlpha)
	set_pev(ent,pev_rendercolor,Float:{0.0,0.0,0.0})
	set_pev(ent,pev_owner, id)
	set_pev(ent,MINE_OWNER, id)
	drop_to_floor(ent)
	
	emit_sound(ent, CHAN_VOICE, MINE_SETUP, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	ChatColor(id, "^4[Mine] ^1Mina instalada!")
	
	g_BuyTotal[id]++
	
	switch(type)
	{
		case 0..2:
		{
			g_BuyNum[id]++
				
			if(g_BuyNum[id] >= get_pcvar_num(pCvarBonus))
			{
				g_BonusMine[id] = get_pcvar_num(pCvarBonusNum)
				ChatColor(id, "^4[Mine] ^1voce tem ^3%d ^1minas de bonus!", g_BonusMine[id])
				g_BuyNum[id] = 0
			}
		}
		case 3..5:
		{
			g_BonusMine[id]--
		}
	}
	
	return PLUGIN_HANDLED
}

public Hook_Touch(Entity, id)
{
	if(!pev_valid(Entity) || !is_user_alive(id)) 
		return
	
	static attacker
	attacker = pev(Entity, pev_owner)
	
	if(cs_get_user_team(id) == cs_get_user_team(attacker))
		return
	
	static entclass[32]
	pev(Entity, pev_classname, entclass, charsmax(entclass))
    
	if (equali(entclass, MINE_CLASSNAME_DEF))
		explosion_mine_def(Entity)
	else if (equali(entclass, MINE_CLASSNAME_FROST))
		explosion_mine_frost(Entity)
	else if (equali(entclass, MINE_CLASSNAME_FIRE))
		explosion_mine_fire(Entity)
	else if (equali(entclass, MINE_CLASSNAME_GUARD))
		explosion_mine_guard(Entity)
	else if (equali(entclass, MINE_CLASSNAME_TEL))
		explosion_mine_tel(Entity)
	else if (equali(entclass, MINE_CLASSNAME_GAL))
		explosion_mine_gal(Entity)
}

public explosion_mine_def(Entity)
{
	if(!pev_valid(Entity))
		return
	
	static Float:originF[3]
	pev(Entity, pev_origin, originF)
	explode_eff(originF)
	
	static attacker
	attacker = pev(Entity, pev_owner)
	
	if (!is_user_valid_connected(attacker))
	{
		UTIL_RemoveEntity(Entity)
		return
	}
	
	g_BuyTotal[attacker]--
	
	static Victim, Float:flDistance, Damage, Health
	Victim  = -1;
	while((Victim = engfunc( EngFunc_FindEntityInSphere, Victim, originF, DEF_EXP_RADIUS)) != 0)
	{
		if(!is_user_valid_alive(Victim))
			continue;
		
		if(cs_get_user_team(Victim) == cs_get_user_team(attacker) || Victim == attacker)
			continue;
		
		flDistance = fm_entity_range( Entity, Victim)
		Damage = floatround(UTIL_FloatRadius(DEF_EXP_RADIUS, DEF_EXP_RADIUS, flDistance))
		Health = get_user_health(Victim)
		
		if(Damage >= Health) 
			SendDeathMsg(attacker, Victim)
		else
		{
			set_user_health(Victim, Health - Damage)
		}
	}
	
	UTIL_RemoveEntity(Entity)
}

public explosion_mine_frost(Entity)
{
	if(!pev_valid(Entity))
		return
	
	static Float:originF[3]
	pev(Entity, pev_origin, originF)
	explode_eff(originF, 1)
	
	static attacker
	attacker = pev(Entity, pev_owner)
	
	if (!is_user_valid_connected(attacker))
	{
		UTIL_RemoveEntity(Entity)
		return
	}
	
	g_BuyTotal[attacker]--
	
	static Victim, Float:flDistance, Damage, Health
	Victim  = -1;
	while((Victim = engfunc( EngFunc_FindEntityInSphere, Victim, originF, FROST_EXP_RADIUS)) != 0)
	{
		if(!is_user_valid_alive(Victim))
			continue;
		
		if(cs_get_user_team(Victim) == cs_get_user_team(attacker) || Victim == attacker)
			continue;
		
		flDistance = fm_entity_range( Entity, Victim)
		Damage = floatround(UTIL_FloatRadius(FROST_EXP_DAMAGE, FROST_EXP_RADIUS, flDistance))
		Health = get_user_health(Victim)
		
		if(Damage >= Health) 
			SendDeathMsg(attacker, Victim)
		else
		{
			set_user_health(Victim, Health - Damage)
			set_rendering(Victim, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 60)
			set_pev(Victim, pev_flags, pev(Victim, pev_flags) | FL_FROZEN) 
			set_task(FROST_TIME, "UnFrozen", TASK_FROST + Victim)
		}
	}
	
	UTIL_RemoveEntity(Entity)
}

public UnFrozen(taskid) {
	new id = taskid - TASK_FROST
	set_rendering(id)
	
	new origin[3]
	get_user_origin(id, origin)
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_BREAKMODEL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2] + 24)
	write_coord(16)
	write_coord(16)
	write_coord(16)
	write_coord(random_num(-50, 50))
	write_coord(random_num(-50, 50))
	write_coord(25)
	write_byte(10)
	write_short(g_SprGlass)
	write_byte(10)
	write_byte(25)
	write_byte(0x01)
	message_end()
	
	if(pev(id, pev_flags) & FL_FROZEN) 
		set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN)
}

public explosion_mine_fire(Entity)
{
	if(!pev_valid(Entity))
		return
	
	static Float:originF[3]
	pev(Entity, pev_origin, originF)
	explode_eff(originF)
	
	static attacker
	attacker = pev(Entity, pev_owner)
	
	if (!is_user_valid_connected(attacker))
	{
		UTIL_RemoveEntity(Entity)
		return
	}
	
	g_BuyTotal[attacker]--
	
	static Victim, Float:flDistance, Damage, Health
	Victim  = -1;
	while((Victim = engfunc( EngFunc_FindEntityInSphere, Victim, originF, FIRE_EXP_RADIUS)) != 0)
	{
		if(!is_user_valid_alive(Victim))
			continue;
		
		if(cs_get_user_team(Victim) == cs_get_user_team(attacker) || Victim == attacker)
			continue;
		
		flDistance = fm_entity_range( Entity, Victim)
		Damage = floatround(UTIL_FloatRadius(FIRE_EXP_DAMAGE, FIRE_EXP_RADIUS, flDistance))
		Health = get_user_health(Victim)
		
		if(Damage >= Health) 
			SendDeathMsg(attacker, Victim)
		else
		{
			set_user_health(Victim, Health - Damage)
			g_burning_duration[Victim] = FIRE_TIME	
			if (!task_exists(Victim+TASK_FIRE)) set_task(0.2, "burning_flame", Victim+TASK_FIRE, _, _, "b")
		}
	}
	
	UTIL_RemoveEntity(Entity)
}

public burning_flame(taskid)
{
	new id = taskid - TASK_FIRE
	static origin[3], flags
	get_user_origin(id, origin)
	flags = pev(id, pev_flags)
	
	if ((flags & FL_INWATER) || g_burning_duration[id] < 1)
	{
		message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
		write_byte(TE_SMOKE) 
		write_coord(origin[0]) 
		write_coord(origin[1]) 
		write_coord(origin[2]-50) 
		write_short(g_SmokeSpr)  
		write_byte(random_num(15, 20)) 
		write_byte(random_num(10, 20)) 
		message_end()
		
		remove_task(taskid)
		return
	}
	
	static health
	health = pev(id, pev_health)
	
	if (health - floatround(FIRE_DMG, floatround_ceil) > 0)
		fm_set_user_health(id, health - floatround(FIRE_DMG, floatround_ceil))
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_SPRITE) 
	write_coord(origin[0]+random_num(-5, 5))
	write_coord(origin[1]+random_num(-5, 5)) 
	write_coord(origin[2]+random_num(-10, 10)) 
	write_short(g_FlameSpr) 
	write_byte(random_num(5, 10)) 
	write_byte(200)
	message_end()
	
	g_burning_duration[id]--
}

stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}
	
public explosion_mine_guard(Entity)
{
	if(!pev_valid(Entity))
		return
	
	static Float:originF[3]
	pev(Entity, pev_origin, originF)
	explode_eff(originF)
	
	static attacker
	attacker = pev(Entity, pev_owner)
	
	g_BuyTotal[attacker]--

	if (!is_user_valid_connected(attacker))
	{
		UTIL_RemoveEntity(Entity)
		return
	}
	
	static Victim, Float:flDistance, Damage, Health
	Victim  = -1;
	while((Victim = engfunc( EngFunc_FindEntityInSphere, Victim, originF, GUARD_EXP_RADIUS)) != 0)
	{
		if(!is_user_valid_alive(Victim))
			continue;
		
		if(cs_get_user_team(Victim) == cs_get_user_team(attacker) || Victim == attacker)
		{
			set_rendering(Victim, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 60)
			set_user_godmode(Victim, 1)
			set_task(GUARD_TIME, "UnGod", TASK_GUARD + Victim)
		}
		else
		{
			flDistance = fm_entity_range( Entity, Victim)
			Damage = floatround(UTIL_FloatRadius(GUARD_EXP_DAMAGE, GUARD_EXP_RADIUS, flDistance))
			Health = get_user_health(Victim)
			
			if(Damage >= Health) 
				SendDeathMsg(attacker, Victim)
			else
				set_user_health(Victim, Health - Damage)
		}
	}
	
	UTIL_RemoveEntity(Entity)
}
	
public UnGod(taskid)
{
	new id = taskid - TASK_GUARD
	if(is_user_alive(id))
	{
		set_rendering(id)
		set_user_godmode(id, 0)
	}
}

public explosion_mine_tel(Entity)
{
	if(!pev_valid(Entity))
		return
	
	static Float:originF[3]
	pev(Entity, pev_origin, originF)
	explode_eff(originF)
	
	static attacker
	attacker = pev(Entity, pev_owner)
	
	if (!is_user_valid_connected(attacker))
	{
		UTIL_RemoveEntity(Entity)
		return
	}
	
	g_BuyTotal[attacker]--
	
	static Victim
	Victim  = -1;
	while((Victim = engfunc( EngFunc_FindEntityInSphere, Victim, originF, TEL_EXP_RADIUS)) != 0)
	{
		if(!is_user_valid_alive(Victim))
			continue;
		
		if(cs_get_user_team(Victim) == cs_get_user_team(attacker) || Victim == attacker)
			continue;
		
		ExecuteHamB(Ham_CS_RoundRespawn, Victim)
	}
	
	UTIL_RemoveEntity(Entity)
}

public explosion_mine_gal(Entity)
{
	if(!pev_valid(Entity))
		return
	
	static Float:originF[3]
	pev(Entity, pev_origin, originF)
	explode_eff(originF, 2)
	
	static attacker
	attacker = pev(Entity, pev_owner)
	
	if (!is_user_valid_connected(attacker))
	{
		UTIL_RemoveEntity(Entity)
		return
	}
	
	g_BuyTotal[attacker]--

	static Victim
	Victim  = -1;
	while((Victim = engfunc( EngFunc_FindEntityInSphere, Victim, originF, GAL_EXP_RADIUS)) != 0)
	{
		if(!is_user_valid_alive(Victim))
			continue;
		
		if(cs_get_user_team(Victim) == cs_get_user_team(attacker) || Victim == attacker)
			continue;
		
		ScreenShake(Victim, GAL_TIME, GAL_TIME)
	}
	
	UTIL_RemoveEntity(Entity)
}

UTIL_RemoveEntity( pEntity )
{
	set_pev(pEntity, pev_flags, FL_KILLME)
	set_pev(pEntity, pev_targetname, "")
}

public RemoveAllMines(id)
{
	new iEnt = g_MaxPlayers + 1
	new clsname[32];
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", MINE_CLASSNAME_DEF)))
	{
		if(id)
		{
			if(pev(iEnt, pev_owner) != id) continue
			pev(iEnt, pev_classname, clsname, 31)	
			if(equali(clsname, MINE_CLASSNAME_DEF))
				UTIL_RemoveEntity(iEnt)
		}
		else
			set_pev(iEnt, pev_flags, FL_KILLME)
	}
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", MINE_CLASSNAME_FIRE)))
	{
		if(id)
		{
			if(pev(iEnt, pev_owner) != id) continue
			pev(iEnt, pev_classname, clsname, 31)	
			if(equali(clsname, MINE_CLASSNAME_FIRE))
			UTIL_RemoveEntity(iEnt)
		}
		else
		set_pev(iEnt, pev_flags, FL_KILLME)
	}
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", MINE_CLASSNAME_FROST)))
	{
		if(id)
		{
			if(pev(iEnt, pev_owner) != id) continue
			pev(iEnt, pev_classname, clsname, 31)	
			if(equali(clsname, MINE_CLASSNAME_FROST))
			UTIL_RemoveEntity(iEnt)
		}
		else
		set_pev(iEnt, pev_flags, FL_KILLME)
	}
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", MINE_CLASSNAME_GAL)))
	{
		if(id)
		{
			if(pev(iEnt, pev_owner) != id) continue
			pev(iEnt, pev_classname, clsname, 31)	
			if(equali(clsname, MINE_CLASSNAME_GAL))
			UTIL_RemoveEntity(iEnt)
		}
		else
		set_pev(iEnt, pev_flags, FL_KILLME)
	}
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", MINE_CLASSNAME_GUARD)))
	{
		if(id)
		{
			if(pev(iEnt, pev_owner) != id) continue
			pev(iEnt, pev_classname, clsname, 31)	
			if(equali(clsname, MINE_CLASSNAME_GUARD))
			UTIL_RemoveEntity(iEnt)
		}
		else
		set_pev(iEnt, pev_flags, FL_KILLME)
	}
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", MINE_CLASSNAME_TEL)))
	{
		if(id)
		{
			if(pev(iEnt, pev_owner) != id) continue
			pev(iEnt, pev_classname, clsname, 31)	
			if(equali(clsname, MINE_CLASSNAME_TEL))
			UTIL_RemoveEntity(iEnt)
		}
		else
		set_pev(iEnt, pev_flags, FL_KILLME)
	}
}

Float:UTIL_FloatRadius( Float:flMaxAmount, Float:flRadius, Float:flDistance )
{
	return floatsub( flMaxAmount, floatmul( floatdiv( flMaxAmount, flRadius ), flDistance ) );
}

stock Float:fm_entity_range(ent1, ent2) 
{
	new Float:origin1[3], Float:origin2[3];
	pev(ent1, pev_origin, origin1);
	pev(ent2, pev_origin, origin2);

	return get_distance_f(origin1, origin2);
}

public SendDeathMsg(attacker, victim)
{
	set_msg_block(g_msgDeathMsg, BLOCK_SET)
	ExecuteHamB(Ham_Killed, victim, attacker, 2)
	set_msg_block(g_msgDeathMsg, BLOCK_NOT)
	
	message_begin(MSG_BROADCAST, g_msgDeathMsg)
	write_byte(attacker)
	write_byte(victim) 
	write_byte(1) 
	write_string("grenade") 
	message_end()
}

explode_eff(Float:originF[3], eff = 0)
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, originF[0])
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2])
	switch(eff)
	{
		case 0:	write_short(g_SprExp)
		case 1:	write_short(g_SprExpFrost)
		case 2:	write_short(g_SprExpGal)
	}
	write_byte(45)
	write_byte(15)
	write_byte(0)
	message_end()
}

stock ScreenShake(id, duration, frequency) {	
	message_begin(MSG_ONE_UNRELIABLE , get_user_msgid("ScreenShake"), _, id );
	write_short(1<<14)
	write_short((1<<12) * duration)
	write_short((1<<12) * frequency)
	message_end();
}

stock ChatColor(const id, const input[], any:...) {
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	replace_all(msg, 190, "!g", "^4") 
	replace_all(msg, 190, "!y", "^1") 
	replace_all(msg, 190, "!t", "^3") 
	if (id) players[0] = id; else get_players(players, count, "ch"); {
		for (new i = 0; i < count; i++) {
			if (is_user_connected(players[i])) {
				message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, players[i])
				write_byte(players[i]);
				write_string(msg);
				message_end();
			}
		}
	}
}