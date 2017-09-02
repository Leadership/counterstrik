
#include <amxmodx>
#include <cstrike>
 
enum
{
        TEAM_UNASSIGNED,
        TEAM_T,
        TEAM_CT,
        TEAM_SPECTATOR
};
 
public plugin_precache()
{
    precache_model("models/player/admin_onlydead4fun_ct/admin_onlydead4fun_ct.mdl")
    precache_model("models/player/admin_onlydead4fun_tr/admin_onlydead4fun_tr.mdl")
    precache_model("models/player/girl_onlydead4fun_ct/girl_onlydead4fun_ct.mdl")
    precache_model("models/player/girl_onlydead4fun_tr/girl_onlydead4fun_tr.mdl")
}
 
public plugin_init()
{
        register_plugin("Admin Models", "1.0", "hleV");
        register_event("ResetHUD", "ResetHUD", "be");
}
 
public ResetHUD(Client)
{
        if (!is_user_alive(Client))
                return;
 
        new CsTeams:Team = cs_get_user_team(Client);
 
        switch (Team)
        {
                case TEAM_T:
                {
                        if (get_user_flags(Client) & ADMIN_LEVEL_C) cs_set_user_model(Client, "admin_onlydead4fun_tr");
                        else if (get_user_flags(Client) & ADMIN_LEVEL_D) cs_set_user_model(Client, "girl_onlydead4fun_tr");
                        else cs_reset_user_model(Client);
                }
                case TEAM_CT:
                {
                        if (get_user_flags(Client) & ADMIN_LEVEL_C) cs_set_user_model(Client, "admin_onlydead4fun_ct");
                        else if (get_user_flags(Client) & ADMIN_LEVEL_D) cs_set_user_model(Client, "girl_onlydead4fun_ct");
                        else cs_reset_user_model(Client);
                }
        }
        
}