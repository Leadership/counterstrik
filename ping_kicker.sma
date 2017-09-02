/* AMX Mod script. 
* 
* (c) 2002-2003, OLO 
* modified by shadow
* This file is provided as is (no warranties). 
* 
* Players with immunity won't be checked 
*/ 

#include <amxmodx> 
#include <amxmisc>

enum ChatColor
{
    CHATCOLOR_NORMAL = 1,
    CHATCOLOR_GREEN,
    CHATCOLOR_TEAM_COLOR,
    CHATCOLOR_GREY,
    CHATCOLOR_RED,
    CHATCOLOR_BLUE,
}

new g_TeamName[][] = 
{
    "",
    "TERRORIST",
    "CT",
    "SPECTATOR"
}

new g_msgSayText;
new g_msgTeamInfo;

new g_Ping[33]
new g_Samples[33]

public plugin_init()
{
	register_plugin("High Ping Kicker","0.16.2","by BahogaAa")
	register_concmd("amx_hpk","cmdHpk",ADMIN_KICK,"- configures high_ping_kicker plugin")
	register_cvar("amx_hpk_ping","150")
	register_cvar("amx_hpk_check","12")
	register_cvar("amx_hpk_tests","5")
	register_cvar("amx_hpk_delay","60")
  
	if ( get_cvar_num( "amx_hpk_check" ) < 5 ) set_cvar_num( "amx_hpk_check" , 5 )
	if ( get_cvar_num( "amx_hpk_tests" ) < 3 ) set_cvar_num( "amx_hpk_tests" , 3 )
  
  	g_msgSayText = get_user_msgid("SayText");
	g_msgTeamInfo = get_user_msgid("TeamInfo");
}

public client_disconnect(id) 
  remove_task( id )

public client_putinserver(id) 
{    
  g_Ping[id] = 0 
  g_Samples[id] = 0

  if ( !is_user_bot(id) ) 
  {
    new param[1]
    param[0] = id 
    set_task( 10.0 , "showWarn" , id , param , 1 )
    
    if (get_cvar_num("amx_hpk_tests") != 0) {
	    set_task( float(get_cvar_num("amx_hpk_delay")), "taskSetting", id, param , 1)
    }
    else {	    
    	set_task( float(get_cvar_num( "amx_hpk_tests" )) , "checkPing" , id , param , 1 , "b" )
	}
	
  }
} 

public showWarn(param[])
{
	colorChat(param[0], CHATCOLOR_RED, "^x01[^x04Only Dead^x01] Jogadores com pings maiores do que ^x04%d^x01 serao kickados!", get_cvar_num( "amx_hpk_ping" ) )
}
  
public taskSetting(param[]) {
	new name[32]
	get_user_name(param[0],name,31)
	set_task( float(get_cvar_num( "amx_hpk_tests" )) , "checkPing" , param[0] , param , 1 , "b" )
}

kickPlayer( id ) 
{ 
	new name[32],authid[32]
	get_user_name(id,name,31)
	get_user_authid(id,authid,31)

	colorChat(0, CHATCOLOR_RED, "^x01[^x04Only Dead^x01] Jogador ^x04%s^x01 Foi kickado devido esta com ping alto!",name)
	client_cmd(id,"echo ^"** Desculpe, mas o seu ping esta muito alto, tente novamente mais tarde....^";disconnect")
	remove_task(id)
	log_amx("Highpingkick: ^"%s<%d><%s>^" was kicked due highping (Average Ping ^"%d^")", 
    name,get_user_userid(id),authid,(g_Ping[id] / g_Samples[id]))

} 

public checkPing(param[]) 
{ 
  new id = param[ 0 ] 

  if ( get_user_flags(id) & ADMIN_IMMUNITY ) return

  new p, l 

  get_user_ping( id , p , l ) 

  g_Ping[ id ] += p
  ++g_Samples[ id ]

  if ( (g_Samples[ id ] > get_cvar_num( "amx_hpk_tests" )) && (g_Ping[id] / g_Samples[id] > get_cvar_num( "amx_hpk_ping" ))  )    
    kickPlayer(id) 
}

  
public cmdHpk(id,level,cid){
  if (!cmd_access(id,level,cid,1))
    return PLUGIN_HANDLED
    
  new ping[5]
  new check_arr[5]
  new tests_arr[5]
  new delay_arr[5]
  read_argv(1,ping,4)
  read_argv(2,check_arr,4)
  read_argv(3,tests_arr,4)
  read_argv(4,delay_arr,4)
  
  new check = str_to_num(check_arr)
  new tests = str_to_num(tests_arr)
  new delay = str_to_num(delay_arr)
  
  
  if ( check < 5 ) check = 5
  if ( tests < 3 ) tests = 3
  

  if (read_argc() > 1){
    set_cvar_string("amx_hpk_ping",ping)
  }
  if (read_argc() > 2) {
	set_cvar_num("amx_hpk_check",check)
  }
  if (read_argc() > 3) {
	set_cvar_num("amx_hpk_tests",tests)
  }
  if (read_argc() > 4) {
	  set_cvar_num("amx_hpk_delay",delay)
 }

  console_print(id,"Syntax: amx_hpk <ping to get kicked> <checks before kicks> <time between checks> <delay before first check in sec.>")
  console_print(id,"Current High_Ping_Kicker Settings:")
  console_print(id,"Maxping: %d  Time between checks: %d Checkcount: %d Delay: %d",get_cvar_num("amx_hpk_ping"),get_cvar_num("amx_hpk_check"),get_cvar_num("amx_hpk_tests"),get_cvar_num("amx_hpk_delay"))
  return PLUGIN_HANDLED    
}

colorChat(id, ChatColor:color, const msg[], {Float,Sql,Result,_}:...)
{
    new team, index, MSG_Type
    new bool:teamChanged = false
    static message[192]
    
    switch(color)
    {
        case CHATCOLOR_NORMAL:
        {
            message[0] = 0x01
        }
        case CHATCOLOR_GREEN:
        {
            message[0] = 0x04
        }
        default:
        {
            message[0] = 0x03
        }
    }
    
    vformat(message[1], 190, msg, 4)
    
    if(id == 0)
    {
        index = findAnyPlayer()
        MSG_Type = MSG_ALL
    }
    else
    {
        index = id
        MSG_Type = MSG_ONE
    }
    
    if(index != 0)
    {
        team = get_user_team(index)
        
        if(color == CHATCOLOR_RED && team != 1)
        {
            messageTeamInfo(index, MSG_Type, g_TeamName[1])
            teamChanged = true
        }
        else if(color == CHATCOLOR_BLUE && team != 2)
        {
            messageTeamInfo(index, MSG_Type, g_TeamName[2])
            teamChanged = true
        }
        else if(color == CHATCOLOR_GREY && team != 0)
        {
            messageTeamInfo(index, MSG_Type, g_TeamName[0])
            teamChanged = true
        }
        
        messageSayText(index, MSG_Type, message)
        
        if(teamChanged)
        {
            messageTeamInfo(index, MSG_Type, g_TeamName[team])
        }
    }
}

messageSayText(id, type, message[])
{
    message_begin(type, g_msgSayText, _, id)
    write_byte(id)        
    write_string(message)
    message_end()
}
    
messageTeamInfo(id, type, team[])
{
    message_begin(type, g_msgTeamInfo, _, id)
    write_byte(id)
    write_string(team)
    message_end()
}

findAnyPlayer()
{
	static players[32], inum, pid

	get_players(players, inum, "ch")

	for (new a = 0; a < inum; a++)
	{
		pid = players[a]

		if(is_user_connected(pid))
		return pid
	}

	return 0
}