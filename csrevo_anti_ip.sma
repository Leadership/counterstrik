#include <amxmodx>
#include <regex>
#include <fakemeta>

#define PLUGIN "CS Revo: Anti IP"
#define VERSION "1.0"
#define AUTHOR "Wilian M."

#define PATTERN_IP "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
#define PREFIXCHAT "!t[!gOnly Dead!t]"

new Regex:xResult, xReturnValue, xError[64], xAllArgs[1024]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say", "xFilterSayIP")
	register_clcmd("say_team", "xFilterSayIP")
	
	register_forward(FM_ClientUserInfoChanged, "xFM_ClientUserInfoChanged")
}

public xFilterSayIP(id)
{	
	read_args(xAllArgs, 1023)
	
	xResult = regex_match(xAllArgs, PATTERN_IP, xReturnValue, xError, 63)
	
	if(xResult)
	{
		new xName[32]; get_user_name(id, xName, 31);
		
		xClientPrintColor(0, "%s !yJogador !t%s !yfoi banido por Divulgar !gIP's !yno servidor.", PREFIXCHAT, xName)
		server_cmd("amx_ban ^"#%d^" ^"15^" ^"Divulgando IP's^"", get_user_userid(id))
				
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public xFM_ClientUserInfoChanged(id)
{
	if(is_user_connected(id))
	{
		static szOldName[32]
		pev(id, pev_netname, szOldName, charsmax(szOldName))
		
		if(szOldName[0])
		{
			static const name[] = "name"
			static szNewName[32]
			get_user_info(id, name, szNewName, charsmax(szNewName))
			
			xResult = regex_match(szNewName, PATTERN_IP, xReturnValue, xError, 63)
			
			if(xResult)
			{
				set_user_info(id, name, "Anti-IP Mude seu nick ou sera punido")
					
				return FMRES_HANDLED
			}
		
		}
	}
	
	return FMRES_SUPERCEDE
}

stock xClientPrintColor(const id, const input[], any:...)
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	replace_all(msg, 190, "!t2", "^0")
	
	if (id) players[0] = id; else get_players(players, count, "ch")

	for (new i = 0; i < count; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
			write_byte(players[i])
			write_string(msg)
			message_end()
		}
	}
}

