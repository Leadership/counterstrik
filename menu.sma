#include <amxmodx> 
#include <amxmisc> 

public plugin_init() 
{ 
    register_plugin("CTF Menu", "1.0", "Jhow Markuz"); 
    register_clcmd("say /ctfmenu", "ShowMenu", _, "Menu Pega bandeira"); 
    register_clcmd("nightvision" , "ShowMenu") 
} 

public ShowMenu(id) 
{ 
    new menu = menu_create("\mMenu Pega Bandeira :", "menu"); 

    menu_additem(menu, "Adrenaline", "", 0); // case 0 
    menu_additem(menu, "Sentinela", "", 0); // case 1 
    menu_additem(menu, "Minas Terrestre", "", 0); // case 2 
    menu_additem(menu, "Distribuidor", "", 0); // case 3 
    menu_additem(menu, "Torre Tesla", "", 0); // case 4     
    menu_additem(menu, "Dropar bandeira", "", 0); // case 5 
    menu_additem(menu, "Desativar skin armas", "", 0); // case 6 
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL); 

    menu_display(id, menu, 0); 

    return PLUGIN_HANDLED; 
} 

public menu(id, menu, item) 
{ 
    if(item == MENU_EXIT) 
    { 
        menu_cancel(id); 
        return PLUGIN_HANDLED; 
    } 

    new command[6], name[64], access, callback; 

    menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback); 

    switch(item) 
    { 
        case 0:  client_cmd(id, "adrenaline");
        case 1:  client_cmd(id, "sentry_build");
        case 2:  client_cmd(id, "say /mine");
        case 3:  client_cmd(id, "build_dispenser");
        case 4:  client_cmd(id, "build_tesla");
        case 5:  client_cmd(id, "dropflag");
        case 6:  client_cmd(id, "say /armas");
    } 

    menu_destroy(menu); 
} 