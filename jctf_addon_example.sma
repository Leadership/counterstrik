#include <amxmodx>
#include <jctf>

/* Just Capture The Flag - example addon-plugin */

public plugin_init()
{
	register_plugin("jCTF example addon-plugin", "0.2", "Digi")

	/* below version check code should ALWAYS be included */

	new szVersion[6]

	get_cvar_string("jctf_version", szVersion, charsmax(szVersion))

	if(str_to_float(szVersion) < 1.21)
		set_fail_state("jCTF is required at least v1.21 !")


	/* adrenaline giving example */

	register_clcmd("test", "cmd_giveadrenaline")
}

public jctf_flag(iEvent, id, iFlagTeam, bool:bAssist)
{
	/* Basic info about each event and it's usable variables */

	switch(iEvent)
	{
		case FLAG_STOLEN: client_print(0, print_chat, "[debug] %d stole team %d flag", id, iFlagTeam)

		case FLAG_PICKED: client_print(0, print_chat, "[debug] %d picked up team %d flag", id, iFlagTeam)

		case FLAG_DROPPED: client_print(0, print_chat, "[debug] %d dropped team %d flag", id, iFlagTeam)

		case FLAG_MANUALDROP: client_print(0, print_chat, "[debug] %d intentionally dropped team %d flag", id, iFlagTeam)

		case FLAG_RETURNED: client_print(0, print_chat, "[debug] %d %s team %d flag", id, (bAssist ? "assisted on returning" : "returned"), iFlagTeam)

		case FLAG_CAPTURED: client_print(0, print_chat, "[debug] %d %s team %d flag", id, (bAssist ? "assisted on capturing" : "captured"), iFlagTeam)

		case FLAG_AUTORETURN: client_print(0, print_chat, "[debug] team %d flag auto-returned", iFlagTeam)
	}

	if(iEvent == FLAG_CAPTURED)
	{
		if(bAssist)
		{
			/* id = player that assisted on capturing the enemy flag */
		}
		else
		{
			/* id = player who captured the enemy (iFlagTeam) flag */
		}
	}

	if(iEvent == FLAG_RETURNED)
	{
		if(bAssist)
		{
			/* id = player that assisted on returning his team's flag */
		}
		else
		{
			/* id = player who returned his team's (iFlagTeam) flag */
		}
	}

	if(iEvent == FLAG_MANUALDROP)
	{
		/* id = player who dropped the flag intentionally using /dropflag ! */
	}

	if(iEvent == FLAG_DROPPED)
	{
		/* id = player who dropped the flag by dying, disconnecting OR using /dropflag */
	}

	if(iEvent == FLAG_AUTORETURN)
	{
		/* id = 0 since the flag returned itself with this event */
	}
}

public cmd_giveadrenaline(id)
{
	client_print(0, print_chat, "[debug] (player #%d) adrenaline +5 = %d", id, jctf_add_adrenaline(id, 5))

	return PLUGIN_HANDLED
}