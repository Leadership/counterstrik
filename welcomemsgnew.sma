#include <amxmodx>
#include <dhudmessage>

   public client_putinserver(id) {
       new ids[1]
       ids[0] = id
       set_task(10.0,"msg1",0,ids,1)
       set_task(20.0,"msg2",0,ids,1)
       set_task(30.0,"msg3",0,ids,1)
       return PLUGIN_CONTINUE
   }
   public msg1(ids[]){
       new motm[192],hostname[64],name[32],id = ids[0]
       get_cvar_string("amx_welcome_msg1",motm,191)
       get_cvar_string("hostname",hostname,63)
       replace(motm,191,"%hostname%",hostname)
       get_user_name(id,name,31)
       replace(motm,191,"%name%",name)
       set_dhudmessage(0, 255, 0)
       show_dhudmessage(id,motm)
       return PLUGIN_CONTINUE
   }
   public msg2(ids[]){
       new motm[192],id = ids[0]
       get_cvar_string("amx_welcome_msg2",motm,191)
       set_dhudmessage(66, 170, 255)
       show_dhudmessage(id,motm)
       return PLUGIN_CONTINUE
   }
   public msg3(ids[]){
       new motm[192],id = ids[0]
       get_cvar_string("amx_welcome_msg3",motm,191)
       set_dhudmessage(255, 165, 0)
       show_dhudmessage(id,motm)
       return PLUGIN_CONTINUE
   }
   public plugin_init() {
       register_plugin("Welcome HudMsg","1.0","DeSeRt^^")
       register_cvar("amx_welcome_msg1","Bem Vindo %name%, ao servidor %hostname%")
       register_cvar("amx_welcome_msg2","KKKK eai men")
       register_cvar("amx_welcome_msg3","Salva nosso IP nos favoritos")
       return PLUGIN_CONTINUE
   }