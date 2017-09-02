/*
xREDIRECT - redirect menu plugin - © 2006-2011 x0R (xor@x-base.org) - www.x-base.org
Original file: xredirect.sma/xredirect.amxx

License:
¯¯¯¯¯¯¯¯
This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

In addition, as a special exception, the author gives permission to
link the code of this program with the Half-Life Game Engine ("HL
Engine") and Modified Game Libraries ("MODs") developed by Valve,
L.L.C ("Valve"). You must obey the GNU General Public License in all
respects for all of the code used other than the HL Engine and MODs
from Valve. If you modify this file, you may extend this exception
to your version of the file, but you are not obligated to do so. If
you do not wish to do so, delete this exception statement from your
version.



Description/Features:
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
First of all, if you are too lazy to read all this don't bother me with problems or questions!

The plugin does several things that all can be turned on or off seperately by CVAR's:
- on startup it reads the available servers from SERVERFILE ("amxmodx/config/serverlist.ini" by default),
  see next section for an example
- saying /server shows a list of available servers (if redirect_manual > 0) - people can choose a
  number from the list and are immediately sent to that server
- when the server is full (one free slot left, that is) people are automatically forwarded to a random
  server from the list - redirect_auto enables or disables this
- when a server from the list is full or down the server is disabled in the menu and players are not
  redirected there automatically - to be able to check whether a server is down redirect_check_method
  must be > 0 and to check whether it is full redirect_check_method must be > 1
- the servers are announced every redirect_announce seconds - set to 0 to turn announcements off;
  the server list is shown as HUD message and for living players displayed at the top and for dead
  players displayed somewhere below the top so it is not covered by the "spectator bars"; how much
  information the announcements include depends on redirect_check_method
- depending on redirect_check_method servers can be checked for being down/full or even current map, number
  of current players and maximum players can be displayed in the menu and in the announcements
- when no server is available for automatic redirection the player is just dropped with an appropriate
  message
- when someone is redirected either manually or automatically this is shown to the other players
  telling who was redirected and to which server
- it is also announced that people can say /follow to follow this player to the server and they are
  redirected as well - both the announcements and the follow feature can be enabled or disabled by
  CVAR (redirect_follow)
- the plugin is language aware (thus you need to place the xredirect.txt in amxmodx/data/lang/)
- the server can show whether someone that just connects was redirected to the server and from what
  server he is coming from
- the own IP address is detected automatically and disabled in the server list - automatic detection
  does not work if you use DNS names in the SERVERFILE - in this case set the DNS address of the own
  server in redirect_external_address for the detection to work - detecting the own server is NECESSARY
  for the plugin to work correctly
- with CVAR redirect_retry set to 1 the server can put people into a retry queue to be redirected back to
  the last server (e.g. when they were automatically redirected but only want to play on the server they
  connected to)


Server List File:
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

The file is in ini format. The section name is the server name. The following attributes are recognized:
- address = server address (can be IP or DNS name)
- port = server port - a value between 1025 and 65536, default 27015
- cmdbackup = defines how often the UDP request is resent to the server (with redirect_check_method > 0), default 2
- noauto = overrides the redirect_auto setting for this server, default is redirect_auto
- nomanual = if set to 1, users can't manually redirect themselves to this server
- nodisplay = if this is set to 1 it will hide the server from the /server list and announcements, default 0
- adminslots = xREDIRECT will only redirect admins to that server if only adminslots or less slots are free, default 0
- password = the password that is needed to connect to the server, default <none>
- publicpassword = if set to 1, all players can connect to the passworded server, when set to 0 only admins, default 0
- category = category of the server, e.g. Fun Servers
- id = ID of the server - used to display where a player was redirected from or for statistics
- private =
  - 0 = not private, default
  - hide = server is not displayed for non-admins, like nodisplay=1 would be set, and also hidden from announcements
  - fullhide = like "hide" but also doesn't display "X was redirected to Y" message for that server


If a value is not specified the default value is used. The "address" attribute always must be specified and
doesn't have a default value

Here is an example how the server file could look like:

/¯¯¯¯¯¯¯¯¯¯ serverlist.ini ¯¯¯¯¯¯¯¯¯¯¯¯\
[my example server]
address=example.n-ice.org
localaddress=192.168.0.3
port=27015
cmdbackup=5
noauto=1
nomanual=0
nodisplay=0

[my 2nd example server]
address=example2.n-ice.org
port=27015
\______________________________________/


I recommend that all servers have the same SERVERFILE. This is not necessary with redirect_show 0 but it's still better,
because it could confuse users when not all servers are in the same place in the menu on every server.

Please be aware that when using more than 6 servers in SERVERFILE you have to change the define
MAX_SERVERFORWARDS and recompile the plugin. If there are more servers in the file than specified by
MAX_SERVERFORWARDS the other servers will be ignored.



Available CVAR's:
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
redirect_active			- 1/0 activate/deactivate redirect plugin - when this is set to 0 all other CVAR's are ignored, default 0
redirect_auto			- 0 = disable automatic redirection
					- 1 = only redirect when server is full, redirect to random server
					- 2 = only redirect when server is full, redirect to next server in list
					- 3 = always redirect except admins, redirect to random server
					- 4 = always redirect except admins, redirect to next server in list
					- 5 = always redirect including admins, redirect to random server
					- 6 = always redirect including admins, redirect to next server in list
redirect_manual			- controls behaviour of manual redirect menu:
					- 0 = disabled
					- 1 = selecting a server in main menu directly redirects there (if possible)
					- 2 = selecting a server in main menu directly redirects there, or if not possible brings up a sub menu with detail information, the reason why redirection does not work and a retry option (if redirect_retry 1)
					- 3 = selecting a server in main menu always brings up a sub menu with detail information, the reason why redirection does not work (if so) and a retry option (if redirect_retry 1)
redirect_follow			- 1/0 enable/disable following players with /follow to a server they were redirected to - people can still use /server to follow a player though, default 0
redirect_external_address	- own external server address - only needed when you use DNS names instead of IPs in SERVERFILE - this must match the name in SERVERFILE - include the port!
redirect_check_method		- check the servers in the list - 0 = no checks, 1 = ping only(to check whether a server is down), 2 = check active players and max. players as well, default 0
redirect_advertise		- advertise the availability of the /server command every redirect_advertise seconds, default 150
redirect_announce		- announce server list with stats (depends on redirect_check_method) in center every redirect_announce seconds - set to 0 for off, default 60
redirect_announce_mode		- control who announcements are displayed for: 1 = alive players , 2 = dead players, 3 = both
redirect_announce_alivepos_x	- the vertical position of the announcements displayed to living people, default -1.0
redirect_announce_alivepos_y	- the horizontal position of the announcements displayed to living people, default 0.01
redirect_announce_deadpos_x	- the vertical position of the announcements displayed to living people, default -1.0
redirect_announce_deadpos_y	- the horizontal position of the announcements displayed to living people, default 0.35
redirect_show			- 1/0 enable/disable redirection information in chat area, default 1
redirect_adminslots		- 1/0 enable/disable adminslots - when set to 1 people are redirected off the server when someone with a reserved slot connects, default 0
redirect_retry			- 1/0 enable/disable retry queue feature - when set to 1 players can say /retry and are redirected as soon as a slot on the target server is free, default 0
redirect_hidedown		- control hiding of servers that are down (not responding): 0 = don't hide, 1 = hide in menu, 2 = hide in announcements, 3 = hide in menu and announcements - has no effect with redirect_check_method 0, default 0
redirect_localslots		- 1/0 enable/disable slot reserving for local players - remote players are redirected off the server when a local player connects, default 0
redirect_countbots		- 1/0 enable/disable counting of bots for the active player count, default 1
redirect_categories		- control category feature: 0 = disabled, 1 = enabled and players have to choose a category first, 2 = enabled but also offer the option to list all servers

Advanced users should also check out the defines for more options, especially QUERY_INTERVAL could be interesting.



Available commands:
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Server console | Ingame console | Command - Description
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
      [X]      |       [ ]      | redirect_reload - Reloads all servers from the server list
      [X]      |       [X]      | redirect_stats - Shows server redirection statistics
      [X]      |       [ ]      | redirect_resetvault - Resets statistics that are stored in the vault
      [ ]      |       [X]      | redirect_user - <playername|playerid> [servernum] - redirect a player [to a given server]
      [ ]      |       [X]      | redirect_queue - Show the current redirection queue for every server
      [ ]      |       [X]      | pickserver - Same as writing /server in chat, opens the server menu

Note that the "Server console" commands listed here can as well be executed via rcon or amx_rcon from the ingame console.



Min. Requirements:
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
- Metamod v1.18
- HLDS v3.1.1.1
- AMXX v1.80



Modules:
¯¯¯¯¯¯¯¯¯
You can enable these in your modules.ini.

sockets:
The plugin requires the sockets module to be loaded by default.
The sockets module is needed by default for redirect_check_method > 0. So it can be removed if redirect_check_method
won't be set to anything else than 0. To do this search for the line containing require_module("sockets") and comment
it out or delete it.

nvault:
The nvault module isn't required by default. It is only needed when you enable statistics in the source code without
enabling SQL. You don't need to mess with require_module in this case, as this code is depending directly on the
STATISTICS and SQL settings and is only compiled when it is really needed.


Known issues:
¯¯¯¯¯¯¯¯¯¯¯¯¯
#1	as the length of menu items is limited don't specify too long server names - if an item is too long it is just truncated
 
 
Changelog:
¯¯¯¯¯¯¯¯¯¯

Note:
The first version that was released to the public was v0.3. v0.1 and v0.2  were only running on my
servers for some time before I started the next version.

v0.1:
- reads the available servers from a config file
- people can show a server menu by saying /server
- automatic server forwarding to the next server in the list when server is full
- announcing of redirection for other players on the server
- people can say /follow to follow the last forwarded player
- when redirect_external_address is set the own address is automatically detected

v0.2:
- external address is automatically detected without having redirect_external_address set, for DNS names redirect_external_address
  is still needed to be set though
- introduced CVAR redirect_check_method where
	0 = 	disabled
	1 = 	the servers in the list are pinged every QUERY_INTERVAL seconds to check whether they are online
	2 = 	the servers in the list are queried for actual and maximum players and map every QUERY_INTERVAL seconds
- depending on redirect_check_method the menu displays:
	0 =	own server as disabled, others as available in format: server name (server address)
	1 =	own server as disabled, others as available in format "server name (server address)" or down in format "server name (server address) (down)"
	2 =	own server as disabled, others as available in format "server name [current map] (active players/max. players)"
		or down in format "server name (server address) (down)"
- servers that are down are displayed as down in the list and people cannot have themselves redirected there (disabled in menu)
- random automatic forward instead of choosing the next free server from the list
- the server doesn't forward to servers considered being down when server is full
- if no server is available (due to being down) players are not redirected and have a message displayed that they couldn't be forwarded

v0.3
- for redirect_check_method 2:
	- no automatic redirection to full servers anymore (active players = maximum players)
	- full servers are displayed in the menu with red brackets surrounding the player numbers and can't be selected
- the plugin is now language system aware
- introduced CVAR redirect_send_tag where
	0 =	disabled
	1 =	when redirecting it prepends [R<server number>] to people's names with <server number> being the own server number in SERVERFILE
		indicating to the receive server that this player was redirected from this server
- introduced CVAR redirect_receive_tag where
	0 =	disabled
	1 =	when someone connects with prepended [R<server number>] to his name the server will show a message that the player was redirected
		from that server and remove the tag from the name
- introduced CVAR redirect_announce:
	The value of this CVAR can be 0 for turning announcements of. If set to a higher floating point
	value this is the time in seconds how often the announcements are shown.
- made status detection more stable by sending more UDP packets
- made status detection more stable through a completely new code for receive handling
- several small optimizations and bug fixes here and there I don't recall in detail :P

v0.4
- modified default messages for connect and team joining so that they display player names without redirect
  tags if redirect_receive_tag = 1
- modified the name change code to be more reliable
- HL1 steam server status querying is now working - this should make status information work for all HL1
  mods running on Steam
- plugin now uses the much faster cvar querying introduced with AMXX 1.70
- load routine now checks whether there are more servers in the file than can be loaded

v0.4.1
- name changes from tagged names are now hidden as well - this means with redirect_receive_tag = 1 the
  complete procedure of tagging is hidden

v0.4.7
- fixed a bug where automatic redirection didn't work with redirect_check_method 0
- fixed a bug where the PLUGIN_TAG was missing in the message MSG_NO_REDIRECT_SERVER
- fixed many messages that were still displayed with server's default language
- fixed code to display announcement in different height for dead and alive players
- introduced CVAR redirect_announce_mode where
	1 =	announcements while playing
	2 =	announcements while dead/spectator
	3 =	both
	default is 3 - only effective when redirect_announce > 0

v0.4.8
- added code to require_module sockets
- introduced cvar redirect_version for external version check

v0.5.0
- fixed an error that crashed the server when redirecting automatically
 
v0.6.0
- sorted out several unused variables
- redirect_auto 2 redirects to next server in list (1 = random server, like before)
- added new format for SERVERFILE - it is now an ini file
- server status (or ping) request should be more stable due to added cmdbackup of 2 (2 additional request packets are sent)
- the default cmdbackup value can be overridden in SERVERFILE for each server
- redirect_manual can be overriden in SERVERFILE for each server
- redirect_auto can be overriden in SERVERFILE for each server
- servers in the list can be hidden (from list + announcements) with a key in SERVERFILE
- added server command redirect_reload which will make the plugin reload the SERVERFILE

v0.6.3
- changed UDP timeout value to default with hope to fix crash problem with redirect_check_method > 0
- sockets are now initialized to 0 after freeing them
- fixed a bug where second server was displayed as being down
- fixed a bug where for first server the map of the second server was displayed
- changed default QUERY_INTERVAL to 20
- changed UDP receive code to be faster and handle responses more secure and reliable

v0.7.0
- UDP timeout value change didn't help and was changed back to 1
- fixed the "unknown command: pickserver" message when using pickserver command
- removed nick tagging
- server now displays where someone was redirected from without nick tagging
- removed text message hooks as they are not needed anymore
- removed CVAR redirect_send_tag
- removed CVAR redirect_receive_tag
- servers are not redirecting back to source servers anymore, thus preventing an endless loop
- fixed a bug where redirect_auto 2 wouldn't choose the next but the first server in list
- introduced CVAR redirect_show where
	0 = disabled
	1 = show redirection information in chat area when someone was redirected (default)
	
v0.7.5
- removed support for AMXX versions older than 1.70 to cleanup code
- added command redirect_announce_now which will immediately display server announcement to all players
- introduced CVAR redirect_announce_alivepos_x
- introduced CVAR redirect_announce_alivepos_y
- introduced CVAR redirect_announce_deadpos_x
- introduced CVAR redirect_announce_deadpos_y
- menues now don't have colors anymore when the mod does not support coloured menues
- added command redirect_user which can redirect a user
- added native redirect(id, nServer) which can be called by other plugins
- sentence "say /server..." is no longer displayed in announcement if redirect_manual is set to 0

v0.8.0
- introduced CVAR redirect_adminslots
- plugin will now redirect another user to free up a slot when someone with a reserved slot connects
- improved detection for coloured menues
- servers in server list can have a new setting "adminslots" to tell whether they have adminslots
- plugin will not allow to redirect manually anymore when there is only one free slot left on the target server,
  except when the target server has an admin slot and the player to be redirected has reservation flag
 - native redirect function got a new parameter to tell whether people are dropped when no valid target server is found
 
v0.8.2
 - setting redirect_announce to 0 will now stop the announcements from being displayed immediately
 - fixed a bug where announcements were displayed although  redirect_announce is set to 0
- plugin will not allow to redirect manually anymore when there is only one free slot left on the target server,
  except when the target server has an admin slot and the player to be redirected has reservation flag [should work now]

v0.8.4
- introduced CVAR redirect_maxadmins - with this the maximum number of admins can be limited
- if the maximum number of connected admins is reached the plugin acts like there were no admin slots
- fixed a bug where server parameters in server list beginning with "no" were always interpreted as "1"

v0.9.0
- added functionality for splitting up servers on several selection pages
- selection menu can now handle up to 999 servers
- server announcements now cycle through servers with same grouping like menu if servers are more than 8
- redirection to passworded servers is now possible, either for admins or even normal players
- introduced serverlist option "password" which sets the connect password needed for this server
- introduced serverlist option "publicpassword":
  0 = password not public, only admins can have themselves redirected to this server (if passworded)
  1 = password is public, all players can have themselves redirected to this server (if passworded)
- optimized performance of redirect_reload
- changed some messages that were displayed in console to be displayed in chat area
- added a retry queue people can add themselves to with /retry command to be redirected to the server they came from
- added command /stopretry to drop out of the retry queue
- added many messages and error messages
- moved some initialization code from client_putinserver to plugin_cfg to increase performance
- added debug messages (english only) that will show in server log when plugin is running in debug mode
- fixed a bug where message "player has been redirected to server..." was displayed to all others in
  the language of the player that has been redirected
- fixed a bug where message "player has been redirected here from..." was displayed to all others in
  the language of the player that has been redirected
- added welcome message when a player was redirected from another server
- added announcement that the player can use /retry (displayed only if redirected_retry 1 and redirect_show 1)

v0.9.1
- fixed a bug where the plugin would try to display a welcome message even if the player was not redirected,
  causing an error message in AMXX log

v1.0
- changed plugin name/tag to xREDIRECT and plugin file to xredirect.sma/xredirect.amxx, renamed dictionary file to xredirect.txt, renamed include file to xredirect.inc
- added a missing message to tell people when the own server was not detected
- added internal option MIN_ADMIN_LEVEL to define the level that is needed for a player to be treated as admin
- introduced cvar redirect_hidedown to control hiding of offline servers
- added a message that tells the player when he was redirected to free up a slot for an admin
- added a new sub menu that shows detail information about a server including the reason why redirection is not possible to this server
- by using the sub menu players can now retry all servers, not only the last
- added additional modes for redirect_auto:
	- 3 = always redirect except admins, redirect to random server
	- 4 = always redirect except admins, redirect to next server in list
	- 5 = always redirect including admins, redirect to random server
	- 6 = always redirect including admins, redirect to next server in list
- added additional modes for redirect_manual:
	- 2 = show a sub menu when player can't be redirected to server
	- 3 = always show a sub menu from which the player can choose to be redirected (if possible)
- added server option localaddress
- the plugin now detects local players and sends them to localaddress=, while remote players are still sent to address=
- fixed an issue that caused wrong menu numbering under certain circumstances (not very likely to happen though)
- completely rewrote menu creation code for better code readability and modularity
- changed menu coloring to be more straight forward
- queue functionality is not limited to the last server of a player anymore - a player can even queue himself for more than one server at a time!
- several internal code structure improvements
- introduced cvar redirect_localslots: controls slot reserving for local players - remote players are redirected off the server when the server is full and a local player connects
- for the menu without colors inactive menu entries are now displayed as being deactivated by putting a "_" instead of the number in front of the menu entry
- added XMLDoc documentation to source code
- removed client_putinserver() handler and integrated into client_authorized()
- fixed a bug where always on first startup with ./hlds_run the plugin could not detect the own server
- fixed an error with an internal array overflow on servers with 32 maximum players
- fixed a bug where admins would not be able to have themselves redirected to a full server
- removed server address from server name in annoucements - if someone wants this he can still add it to the server name
- annoucements now display server information for own server
- server menu now displays server information for own server
- fixed a bug where menu displayed incorrectly with redirect_check_method 0
- fixed a bug where redirecting was not possible with redirect_check_method 0
- fixed an error in the log message for socket errors
- completely rewritten redirection decision and menu build code for better maintainability
- fixed a still remaining error on servers with 32 slots
- changed menu to use integrated redirect function instead of direct code for better overall stability
- queue option is now no longer available  with redirect_check_method < 2
- refreshing a sub menu is no longer possible with redirect_check_method 0 (doesn't make sense) except for the current server
- fixed a bug where the plugin would not automatically redirect to a plugin that has the NOMANUAL flag set
- fixed a bug where a server would be displayed as having (-1/-1) players when the server is down and sub menues are enabled
- fixed a bug where the sub menu would display a servers as "server full" when it is down
- sub menu: admins can now also see the reason why redirecting is not possible to a server for non-admins, but in white instead of red
- the welcome message can no longer state that someone came from the server he currently is connected to
- fixed a bug where completely wrong information is shown in the menu when sub menues are enabled and redirect_check_method is set to 1
- automatic redirection didn't take MIN_ADMIN_LEVEL as admin level but REDIRECT_RESERVATION
- readded the message "Server full, redirecting you to..." in the console of a player that is auto redirected (it got lost over the update from 0.7.5 to 0.8.0)
- fixed a bug where the own server always would be hidden from the menu/announcements when redirect_hidedown is enabled
- slight speed optimization in socket query code
- fixed an array error that occurs when a player would disconnect within 20 seconds after connecting
- HLTVs will no longer be automatically redirected

 v1.0.1b
 - added debug messages for autoredirect decisions the plugin makes

 v1.0.2b
 - players with a local address were always redirected to the server local address parameter, even when it's empty
 
 v1.0.3
 - completely rewritten socket query code
 - plug-in now supports both old HL1 and new source protocol
 
 v1.0.3.1
 - added workaround for "Server tried to send invalid command" issue, making redirection work again

 v1.0.3.2
 - added workaround for "Server tried to send invalid command" issue, making redirection work again

 v1.1
 - added CVAR redirect_countbots - if set to 0 bots won't be counted as current players in menu and announcements
 - servers running a different mod or protocol can now be automatically detected and disabled for automatic and manual redirection
 - admins won't be automatically redirected to servers having the noauto option activated on them anymore
 - fixed missing colors in main menu server info for servers that were manually disabled
 - fixed follow announcement being displayed to all players in the language of the person that used the follow feature
 - fixed protocol parsing bug which caused some remote game information to be read wrong
 - fixed empty lines in server list file not being skipped correctly
 
 v2.0
 - added server category feature
 - adminslots parameter in server list now supports values > 1
 - availability of the /server command can now be advertised every X seconds (controlled by redirect_advertise, default every 150 seconds)
 - when someone is redirected (manual/auto/follow) target server information is shown (map, current players, max players)
 - added new command redirect_queue which admins can use to show the current redirection queues for each server
 - added statistics and commands redirect_stats and redirect_resetvault
 - added serverlist parameter "private" which will hide servers from announcements and non-admins
 - added SQL support for the server list
 - added SQL support for statistics
 - increased error tolerance when mod or protocol for any server weren't detected correctly
*/
 

// -----------------------------------------------------------------------------------------------------------------------------------------------------
 
 
// features
// uncomment (remove the "//" from) the following lines to enable SQL or statistics
//#define SQL
//#define STATISTICS

// don't change this!
#if defined STATISTICS && !defined SQL
	#define VAULT
#endif

// includes
#include <amxmodx>
#include <amxmisc>
#include <sockets>
#if defined VAULT
	#include <nvault>
#endif
#if defined SQL
	#include <sqlx>
#endif

// plugin defines
#define PLUGIN_NAME "xREDIRECT"
#define PLUGIN_VERSION "2.0RC2"
#define PLUGIN_AUTHOR "x0R"
#define PLUGIN_TAG "[ONLY DEAD]"

// SQL defines
#define SQL_PREFIX "xredirect_"
#define SQL_TABLENAME_SERVERS "servers"
#define SQL_TABLENAME_ATTRIBUTES "attributes"
#define SQL_TABLENAME_STATISTICS "statistics"


// Vault defines
#define VAULT_NAME "xREDIRECT"

// maximum values - don't change this if you don't know what you are doing!
#define MAX_FILE_LEN 256		// maximum length of file names
#define MAX_SERVERLINE_LEN 256		// maximum length of a line read from SERVERFILE
#define MAX_SERVERNAME_LEN 50		// maximum length of a server name read from SERVERFILE
#define MAX_SERVERADDRESS_LEN 100	// maximum length of a server address read from SERVERFILE
#define MAX_NAME_LEN 33			// maximum length of a player name
#define MAX_MENUBODY_LEN 512		// maximum length of a menu body
#define MAX_WELCOME_LEN 1024		// maximum length of the welcome message
#define MAX_INFO_LEN 1400		// maximum length of info reply - when longer than that the packet is fragmented (software side, not due to MTU)
#define MAX_INFO_FORMAT 100		// maximum length of a format string for an info reply
#define MAX_MAP_LEN 30			// maximum length of map names
#define MAX_IP_LEN 16			// maximum length of IP addresses
#define MAX_ID_LEN 35			// maximum length of a string containing a WON or Steam ID
#define MAX_PORT_LEN 6			// maximum length of port numbers (as strings of course)
#define MAX_ATTRIB_LEN 20		// maximum length of an attribute name in SERVERFILE or SQL_TABLENAME_ATTRIBUTES
#define MAX_PASSWORD_LEN 15		// maximum length of a password in SERVERFILE
#define MAX_VALUE_LEN 100		// maximum length of an attribute value in SERVERFILE or SQL_TABLENAME_ATTRIBUTES
#define MAX_PLAYERS 32			// maximum number of players on the server
#define MAX_VAULT_KEY_LEN 10		// maximum length a vault key can have (STATS_VAULT_TAG + ID number from a STATS_COUNT_ constant)
#define MAX_CATEGORIES 9		// maximum number of categories in the menu
#define MAX_SQL_TABLE_LEN 30	// maximum length of an SQL table name
#define MAX_SQL_ERROR_LEN 128	// maximum length of an SQL error message

// statistic count constants
#define STATS_VAULT_TAG "vault" // the tag prepended to the vault keys - remember to also change MAX_VAULT_KEY_LEN when you change this
enum eStatsCount
{
	STATS_COUNT_FOLLOW=0,				// count that the /follow feature was used
	STATS_COUNT_REDIRECT_AUTO,			// count that a user was auto-redirected
	STATS_COUNT_REDIRECT_MANUAL,		// count that a user was manually redirected
	STATS_COUNT_MENU,					// count that a user opened the server menu
	STATS_COUNT_ENQUEUE,				// count that a user enqueued himself for a server
	STATS_COUNT_DEQUEUE,				// count that a user dequeued himself
	STATS_COUNT_REDIRECTED,				// count that a user was redirected to this server
	STATS_COUNT_RETRY,					// count that the /retry feature was used
	STATS_COUNT_DROP,					// count that a user was dropped because there was no free slot on any server
}

// statistic info constants
enum eStatsInfo
{
	STATS_INFO_REDIRECT=0,
	STATS_INFO_ENQUEUE,
	STATS_INFO_RETRY,
	STATS_INFO_DEQUEUE,
}

// redirection type constants for statistics feature
enum eStats
{
	STATS_REDIRTYPE_DROP = 0,	// a user was dropped from the server because no free slot could be found
	STATS_REDIRTYPE_AUTO,		// a user was automatically redirected
	STATS_REDIRTYPE_MANUAL,		// a user manually redirected himself using the menu
	STATS_REDIRTYPE_FOLLOW,		// a user redirected himself by using /follow
	STATS_REDIRTYPE_QUEUED,		// a user redirected himself by using the queue (through menu or /retry command)
	STATS_REDIRTYPE_ADMIN,		// a user was redirected by an admin (redirect_user)
}

// unique task ID's - currently not needed but who knows when they will be
#define TASKID_QUERY 21934807
#define TASKID_QUERY_RECEIVE 21934808
#define TASKID_ANNOUNCE 21934809
#define TASKID_ADVERTISE 21934810

// options - these can be changed by the user, rememeber that you need to recompile for any changes here to take effect
#define SERVERFILE "serverlist.ini"		// name of file in /configs containing the server forwards - you can also prepend a subdirectory
#define STATSFILE "xredirect-actions.csv"	// name of file in /logs containing the redirection action statistics - you can also prepend a subdirectory
#define QUERY_INTERVAL 10.0			// interval of server querying (in seconds)
#define QUERY_TIMEOUT 1.0			// the maximum time to wait for a server answer (in seconds) before it is considered being down
#define MAX_SERVERFORWARDS 12			// maximum number of server forwards in forwards file
#define MAX_MENUPAGES 10			// maximum number of pages the server selection menu can have
#define DEFAULT_CMDBACKUP 2			// how often to resend the UDP request to servers by default
#define MENU_FORCENOCOLOR false			// false = display colored menues if the mod supports it; true = never display colored menues
#define CANCEL_IS_BACK_KEY false		// only when categories are enabled: true = "Cancel" key in server menu turns into a "Back" key and goes back to category menu
#define MIN_ADMIN_LEVEL ADMIN_RESERVATION 	// the minimum level a player must have to be treated as admin (= won't be automatically redirected, can use reserved slots, can join passworded servers with publicpassword=0...)
											// can be one of these listed here: http://www.amxmodx.org/funcwiki.php?go=module&id=1#const_admin
#define MOD_DETECTION true			// enable/disable automatic detection of mod and protocol of other servers - only disable this if you have problems with mod/protocol detection

// A2S_INFO definitions for source according to http://developer.valvesoftware.com/wiki/Server_Queries#Source_servers_2
#define A2S_INFO_SOURCE_REPLY_FORMAT "411ssss21111111s" // there are some extra flags after this but we don't care
#define A2S_INFO_SOURCE_IDX_HEADER 0 // Should be FF FF FF FF
#define A2S_INFO_SOURCE_IDX_TYPE 1 // Should be equal to 'I' (0x49)
#define A2S_INFO_SOURCE_IDX_VERSION 2 // Network version. 0x07 is the current Steam version. Goldsource games will return 48 (0x30), also referred to as protocol version.
#define A2S_INFO_SOURCE_IDX_SERVERNAME 3 // The Source server's name
#define A2S_INFO_SOURCE_IDX_MAP 4 // The current map being played, eg: "de_dust"
#define A2S_INFO_SOURCE_IDX_GAMEDIR 5 // The name of the folder containing the game files, eg: "cstrike"
#define A2S_INFO_SOURCE_IDX_GAMEDESC 6 // A friendly string name for the game type, eg: "Counter Strike: Source"
#define A2S_INFO_SOURCE_IDX_APPID 7 // Steam Application ID, see http://developer.valvesoftware.com/wiki/Steam_Application_IDs
#define A2S_INFO_SOURCE_IDX_NUMPLAYERS 8 // The number of players currently on the server
#define A2S_INFO_SOURCE_IDX_MAXPLAYERS 9 // Maximum allowed players for the server
#define A2S_INFO_SOURCE_IDX_NUMBOTS 10 // Number of bot players currently on the server
#define A2S_INFO_SOURCE_IDX_DEDICATED 11 // 'l' for listen, 'd' for dedicated, 'p' for SourceTV
#define A2S_INFO_SOURCE_IDX_OS 12 // Host operating system. 'l' for Linux, 'w' for Windows
#define A2S_INFO_SOURCE_IDX_PASSWORD 13 // If set to 0x01, a password is required to join this server
#define A2S_INFO_SOURCE_IDX_SECURE 14 // if set to 0x01, this server is VAC secured
#define A2S_INFO_SOURCE_IDX_GAMEVERSION 15 // The version of the game, eg: "1.0.0.22"

// A2S_INFO definitions for goldsource according to http://developer.valvesoftware.com/wiki/Server_Queries#Goldsource_servers_2
#define A2S_INFO_GOLD_REPLY_FORMAT "41sssss111111[ss14411]11"
#define A2S_INFO_GOLD_IDX_HEADER 0 // Should be FF FF FF FF
#define A2S_INFO_GOLD_IDX_TYPE 1 // Should be equal to 'm' (0x6D) - for older servers it's 'C' (0x43)
#define A2S_INFO_GOLD_IDX_IP 2 // Game Server IP address and port
#define A2S_INFO_GOLD_IDX_SERVERNAME 3 // The server's name
#define A2S_INFO_GOLD_IDX_MAP 4 //The current map being played, eg: "de_dust"
#define A2S_INFO_GOLD_IDX_GAMEDIR 5 // The name of the folder containing the game files, eg: "cstrike"
#define A2S_INFO_GOLD_IDX_GAMEDESC 6 // A friendly string name for the game type, eg: "Counter-Strike"
#define A2S_INFO_GOLD_IDX_NUMPLAYERS 7 // The number of players currently on the server
#define A2S_INFO_GOLD_IDX_MAXPLAYERS 8 // Maximum allowed players for the server
#define A2S_INFO_GOLD_IDX_VERSION 9 // Network version. 0x07 is the current Steam version.
#define A2S_INFO_GOLD_IDX_DEDICATED 10 // 'l' for listen, 'd' for dedicated, 'p' for HLTV
#define A2S_INFO_GOLD_IDX_OS 11 // Host operating system. 'l' for Linux, 'w' for Windows
#define A2S_INFO_GOLD_IDX_PASSWORD 12 // If set to 0x01, a password is required to join this server
#define A2S_INFO_GOLD_IDX_ISMOD 13 // If set to 0x01, this byte is followed by ModInfo (that is, all A2S_INFO_GOLD_IDX_MOD_ elements are included)
#define A2S_INFO_GOLD_IDX_SECURE 14 // if set to 0x01, this server is VAC secured - ATTENTION: if A2S_INFO_GOLD_IDX_ISMOD is set to 0x01 A2S_INFO_GOLD_IDX_MOD_SECURE has to be used instead
#define A2S_INFO_GOLD_IDX_NUMBOTS 15 // Number of bot players currently on the server - ATTENTION: if A2S_INFO_GOLD_IDX_ISMOD is set to 0x01 A2S_INFO_GOLD_IDX_MOD_NUMBOTS has to be used instead
#define A2S_INFO_GOLD_IDX_MOD_URLINFO 14 // URL containing information about this mod
#define A2S_INFO_GOLD_IDX_MOD_URLDL 15 // URL to download this mod
#define A2S_INFO_GOLD_IDX_MOD_NUL 16 // 0x00
#define A2S_INFO_GOLD_IDX_MOD_MODVERSION 17 // Version of the installed mod
#define A2S_INFO_GOLD_IDX_MOD_MODSIZE 18 // The download size of this mod
#define A2S_INFO_GOLD_IDX_MOD_SVONLY 19 // If 1 this is a server side only mod
#define A2S_INFO_GOLD_IDX_MOD_CIDLL 20 // If 1 this mod has a custom client dll
// the wiki specification is wrong about these two, they are switched:
#define A2S_INFO_GOLD_IDX_MOD_NUMBOTS 21 // Number of bot players currently on the server - ATTENTION: if A2S_INFO_GOLD_IDX_ISMOD is not set to 0x01 A2S_INFO_GOLD_IDX_NUMBOTS has to be used instead
#define A2S_INFO_GOLD_IDX_MOD_SECURE 22 // if set to 0x01, this server is VAC secured - ATTENTION: if A2S_INFO_GOLD_IDX_ISMOD is not set to 0x01 A2S_INFO_GOLD_IDX_SECURE has to be used instead

// flags
#define SERVERFLAG_NOAUTO 0
#define SERVERFLAG_NOMANUAL 1
#define SERVERFLAG_NODISPLAY 2

// defines for "private" attribute
#define PRIVATE_NONE 0
#define PRIVATE_HIDE 1
#define PRIVATE_FULLHIDE 2


// --------------------------------------- end of defines ---------------------------------------

// -=[ global variables -  remember to add an initialization in srvcmd_reload() for all variables you add here! ]=-
/// <summary>Defines whether the plugin was completely initialized.</summary>
new g_bInitialized = false // no srvcmd_reload() initialization needed for this one, as it's not directly related to the server list
/// <summary>Server ID.</summary>
new g_naServerIds[MAX_SERVERFORWARDS] = {-1, ...}
/// <summary>Server name.</summary>
new g_saServerNames[MAX_SERVERFORWARDS][MAX_SERVERNAME_LEN]
/// <summary>Server address.</summary>
new g_saServerAddresses[MAX_SERVERFORWARDS][MAX_SERVERADDRESS_LEN]
/// <summary>Server port.</summary>
new g_naServerPorts[MAX_SERVERFORWARDS] = {27015, ...}
/// <summary>Server password.</summary>
new g_saServerPasswords[MAX_SERVERFORWARDS][MAX_PASSWORD_LEN]
/// <summary>Is the server password public?</summary>
new g_naServerPublicPassword[MAX_SERVERFORWARDS] = {0, ...}
/// <summary>Currently active player count.</summary>
new g_naServerActivePlayers[MAX_SERVERFORWARDS] = {-1, ...}
/// <summary>Maximum number of players the server accepts. Does not take reserved slots into account.</summary>
new g_naServerMaxPlayers[MAX_SERVERFORWARDS] = {-1, ...}
/// <summary>Currently running map on server.</summary>
new g_saServerMap[MAX_SERVERFORWARDS][MAX_MAP_LEN]
/// <summary>The socket for the server to handle requests.</summary>
new g_naServerSockets[MAX_SERVERFORWARDS] = {0, ...}
/// <summary>The number how often server queries should be resent to that server.</summary>
new g_naServerCmdBackup[MAX_SERVERFORWARDS] = {DEFAULT_CMDBACKUP, ...}
/// <summary>Flags with several server options. Use the constant defines starting with SERVERFLAG_ to access these.</summary>
new g_naServerFlags[MAX_SERVERFORWARDS] = {0, ...}
/// <summary>Are admin slots reserved on this server?</summary>
new g_naServerReserveSlots[MAX_SERVERFORWARDS] = {0, ...}
/// <summary>Local server address.</summary>
new g_saServerLocalAddresses[MAX_SERVERFORWARDS][MAX_SERVERADDRESS_LEN]
/// <summary>The short name of the mod running on the server, e.g. "cstrike", "ns" or "dod".</summary>
new g_saServerMod[MAX_SERVERFORWARDS][MAX_NAME_LEN]
/// <summary>The network protocol version of the server, e.g. protocol 46 (CS 1.5), 47 (No-Steam Goldsource servers), 48 (Steam Source and Goldsource servers).</summary>
new g_naServerProtocol[MAX_SERVERFORWARDS]
/// <summary>At which real index does the menu page start? It is shifted because of hidden servers or servers filtered out by category.</summary>
new g_naMenuPageStart[MAX_PLAYERS][MAX_MENUPAGES]
/// <summary>The category the server belongs to.</summary>
new g_naServerCategory[MAX_SERVERFORWARDS] = {-1, ...}
/// <summary>The "private" setting for this server. Contains one of the PRIVATE_ constants.</summary>
new g_naServerPrivate[MAX_SERVERFORWARDS]
/// <summary>Is the server responding?</summary>
new bool:g_baServerResponding[MAX_SERVERFORWARDS] = {false, ...}
/// <summary>Number of servers found in server list file.</summary>
new g_nServerCount = 0
/// <summary>The last server someone has been redirected to. Needed for <seealso name="cmd_follow_player"/>.</summary>
new g_nLastRedirectServer = -1
/// <summary>The nick of the person who has been redirected at last. Needed for <seealso name="cmd_follow_player"/>.</summary>
new g_sLastRedirectName[MAX_NAME_LEN] = ""
/// <summary>The index of the current server. This is neccessary for the server to check its own data.</summary>
new g_nOwnServer = -1
/// <summary>The ID number of the current server as it was assigned in the serverlist.</summary>
new g_nOwnServerId = -1
/// <summary>The page number for each user which he had open last time, needed for switching back from sub menu to server menu.</summary>
new g_naLastMenuPages[MAX_PLAYERS] = {1, ...}
/// <summary>The category ID for each user which he had selected last time, needed for switching back from sub menu to server menu.</summary>
new g_naLastCategory[MAX_PLAYERS] = {-1, ...}
/// <summary>Hidden servers cause a difference between shown and real server numbers - this array associates the real server index with a given key - different for each user as some users can see servers that others don't.</summary>
new g_naServerSelections[MAX_PLAYERS][8]
/// <summary>This is the cycle variable that holds which server to begin from in <seealso name="announce_servers"/>.</summary>
new g_nNextAnnounceServer = 0
/// <summary>The last server the player came from through redirection. Needed in case he wants to send himself back with /retry.</summary>
new g_nLastServer[MAX_PLAYERS] = {-1, ...}
/// <summary>The last server the player has accessed the sub menu of. Needed when the player refreshes the sub menu.</summary>
new g_nLastSelected[MAX_PLAYERS] = {-1, ...}
/// <summary>This array contains the retry queue consisting of a player ID and a server number for each record.</summary>
new g_nRetryQueue[MAX_PLAYERS*MAX_SERVERFORWARDS][2]
/// <summary>Counter for global number of queue entries.</summary>
new g_nRetryCount = 0
/// <summary>Controls whether certain debug messages are shown. It is automatically set to true when the plugin has debug mode set in plugins.ini.</summary>
new bool:g_bDebug = false
/// <summary>List of categories found in SERVERFILE.</summary>
new g_saCategories[MAX_CATEGORIES][MAX_VALUE_LEN]
/// <summary>Number of categories found in SERVERFILE.</summary>
new g_nCategoryCount = 0

/// <summary>Are server IDs used in SERVERFILE? Will be set to true on the first found ID if file is used.</summary>
#if defined SQL
new bool:g_bUseIds = true
#else
new bool:g_bUseIds = false
#endif

/// <summary>The name of the mod this server is running.</summary>
new g_sMod[MAX_NAME_LEN] = ""


#if defined VAULT
new g_nVaultId = -1
#endif

// -=[ global SQL variables ]=-
#if defined SQL
new sSqlError[MAX_SQL_ERROR_LEN]
new nSqlError
new Handle:hSqlInfo
new Handle:hSql
new SQL_TABLE_STATISTICS[MAX_SQL_TABLE_LEN]
#endif

// -=[ global CVAR's ]=-
new cvar_active
new cvar_auto
new cvar_manual
new cvar_follow
new cvar_external_address
new cvar_check_method
new cvar_advertise
new cvar_announce
new cvar_announce_mode
new cvar_announce_alivepos_x
new cvar_announce_alivepos_y
new cvar_announce_deadpos_x
new cvar_announce_deadpos_y
new cvar_show
new cvar_adminslots
new cvar_maxadmins
new cvar_retry
new cvar_hidedown
new cvar_localslots
new cvar_countbots
new cvar_categories

// --------------------------------------- end of global vars ---------------------------------------

#if AMXX_VERSION_NUM >= 180

/// <summary>Initialize CVARs, load servers, register commands, register menues, register dictionaries, start tasks...</summary>
public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_cvar("redirect_version", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	set_cvar_string("redirect_version", PLUGIN_VERSION)
	
	// please see the description at top if you want to know what these CVAR's do
	cvar_active = register_cvar("redirect_active", "1")
	cvar_auto = register_cvar("redirect_auto", "0")
	cvar_manual = register_cvar("redirect_manual", "3")
	cvar_follow = register_cvar("redirect_follow", "1")
	cvar_external_address = register_cvar("redirect_external_address", "")
	cvar_check_method = register_cvar("redirect_check_method", "2")
	cvar_advertise = register_cvar("redirect_advertise", "70")
	cvar_announce = register_cvar("redirect_announce", "60")
	cvar_announce_mode = register_cvar("redirect_announce_mode", "2")
	cvar_announce_alivepos_x = register_cvar("redirect_announce_alivepos_x", "-1.0")
	cvar_announce_alivepos_y = register_cvar("redirect_announce_alivepos_y", "0.01")
	cvar_announce_deadpos_x = register_cvar("redirect_announce_deadpos_x", "-1.0")
	cvar_announce_deadpos_y = register_cvar("redirect_announce_deadpos_y", "0.35")
	cvar_show = register_cvar("redirect_show", "1")
	cvar_adminslots = register_cvar("redirect_adminslots", "0")
	cvar_maxadmins = register_cvar("redirect_maxadmins", "0")
	cvar_retry = register_cvar("redirect_retry", "0")
	cvar_hidedown = register_cvar("redirect_hidedown", "0")
	cvar_localslots = register_cvar("redirect_localslots", "0")
	cvar_countbots = register_cvar("redirect_countbots", "1")
	cvar_categories = register_cvar("redirect_categories", "0")
	
	register_dictionary("xredirect.txt")
	register_dictionary("common.txt")
	#if defined SQL
	register_dictionary("admin.txt")
	#endif // SQL

	// check whether we are in debug mode or not
	new saDummy[2]
	new saStatus[6]
	get_plugin(-1, saDummy, 0, saDummy, 0, saDummy, 0, saDummy, 0, saStatus, 5)
	g_bDebug = bool:equal(saStatus, "debug")
	
	// load servers from the SERVERLIST or SQL database
	#if defined SQL
	sql_connect()
	load_servers_sql()
	#else
	load_servers_file()
	#endif // SQL

	if (g_nServerCount < 2)
		log_amx("%L", LANG_SERVER, "MSG_ERROR_NOT_ENOUGH_SERVERS")
	
	register_menu("Category Menu", 1023, "category_menu_select")
	register_menu("Redirect Menu", 1023, "server_menu_select")
	register_menu("Detail Menu", 1023, "sub_menu_select")
	
	register_srvcmd("redirect_reload", "srvcmd_reload", -1, "- reload redirect servers")
	#if defined VAULT
	register_srvcmd("redirect_resetvault", "srvcmd_resetvault", -1, "- reset all vault statistics to 0")
	#endif // VAULT
	register_clcmd("say /server", "cmd_show_server_menu", 0, "- show server redirection menu")
	register_clcmd("say_team /server", "cmd_show_server_menu", 0, "- show server redirection menu")
	register_clcmd("pickserver", "cmd_pickserver", 0, "show server redirection menu")
	register_clcmd("say /follow", "cmd_follow_player", 0, "- follow the last redirected player to his server")
	register_clcmd("say_team /follow", "cmd_follow_player", 0, "- follow the last redirected player to his server")
	register_clcmd("say /retry", "cmd_retry", 0, "- redirect back as soon as the foregoing server has a free slot")
	register_clcmd("say_team /retry", "cmd_retry", 0, "- redirect back as soon as the foregoing server has a free slot")
	register_clcmd("say /stopretry", "cmd_stopretry", 0, "- stop retrying the foregoing server")
	register_clcmd("say_team /stopretry", "cmd_stopretry", 0, "- stop retrying the foregoing server")
	register_clcmd("redirect_announce_now", "announce_servers", ADMIN_KICK , "- announce server list immediately")
	register_clcmd("redirect_user", "cmd_redirect_user", ADMIN_KICK , "<playername|playerid> [servernum] - redirect a player [to a given server]")
	register_clcmd("redirect_queue", "cmd_redirect_queue", ADMIN_KICK , "- show the current redirect queue")
	
	#if defined VAULT
	register_srvcmd("redirect_stats", "srvcmd_stats", -1, "- show redirection statistics")
	register_clcmd("redirect_stats", "cmd_stats", ADMIN_KICK , "- show redirection statistics")
	#endif // VAULT
	
	set_task(QUERY_INTERVAL, "query_servers", TASKID_QUERY, "", 0, "b")
	
	#if defined VAULT
	g_nVaultId = nvault_open(VAULT_NAME)
	#endif //VAULT
	#if defined SQL
	formatex(SQL_TABLE_STATISTICS, MAX_SQL_TABLE_LEN-1, "%s%s", SQL_PREFIX, SQL_TABLENAME_STATISTICS)
	#else
	#if defined STATISTICS
	new sBaseDir[MAX_FILE_LEN], sStatsFile[MAX_FILE_LEN]
	get_basedir(sBaseDir, MAX_FILE_LEN-1)
	format(sStatsFile, MAX_FILE_LEN-1, "%s/logs/%s", sBaseDir, STATSFILE)
	// log a CSV header to the file if it doesn't exist yet
	if (!file_exists(sStatsFile))
		log_to_file(STATSFILE, ",User Name,User IP,User Auth-ID,Action,Server-ID,Target-Server-ID")
	#endif // STATISTICS
	#endif // SQL
	
	// get and save the current mod
	get_modname(g_sMod, MAX_NAME_LEN -1)
}

/// <summary>More initializations that have to be done here, because when <seealso name="plugin_init"/> is called CVARs are not yet set. They are in plugin_cfg(), but not for the first start of the game server with ./hlds_run so we use this extra function called once when the first player connects.</summary>
public plugin_postinit()
{
	g_bInitialized = true
	new sFullAddress[MAX_SERVERADDRESS_LEN]
	new sTmpServerIP[MAX_IP_LEN]
	new sTmpServerPort[MAX_PORT_LEN]
	new sTmpServerAddress[MAX_IP_LEN + MAX_PORT_LEN], sTmpServerAddress2[MAX_IP_LEN + MAX_PORT_LEN]
	new sTmpOwnAddress[MAX_SERVERADDRESS_LEN]
	
	get_cvar_string("net_address", sTmpServerAddress, MAX_IP_LEN + MAX_PORT_LEN - 1)
	get_cvar_string("ip", sTmpServerIP, MAX_IP_LEN - 1)
	get_cvar_string("port", sTmpServerPort, MAX_PORT_LEN - 1)
	formatex(sTmpServerAddress, MAX_IP_LEN + MAX_PORT_LEN - 1, "%s:%s", sTmpServerIP, sTmpServerPort)
	get_pcvar_string(cvar_external_address, sTmpOwnAddress, MAX_SERVERADDRESS_LEN - 1)

	// determine the own server
	new nServerCount = 0
	while (nServerCount < g_nServerCount)
	{
		formatex(sFullAddress, MAX_SERVERADDRESS_LEN - 1, "%s:%d", g_saServerAddresses[nServerCount], g_naServerPorts[nServerCount])
		if (equal(sFullAddress, sTmpOwnAddress) || equal(sFullAddress, sTmpServerAddress) || equal(sFullAddress, sTmpServerAddress2))
		{
			g_nOwnServer = nServerCount
			if (g_bUseIds)
				g_nOwnServerId = g_naServerIds[nServerCount]
			else
				g_nOwnServerId = nServerCount
		}
		if (g_bUseIds && (g_naServerIds[nServerCount] == -1))
			log_amx("%L", LANG_SERVER, "MSG_ID_MISSING", g_saServerNames[nServerCount])
		nServerCount++
	}

	if (g_nOwnServer == -1)		// we have not been able to detect the own server - inform the user about this
	{
		log_amx("%L", LANG_SERVER, "MSG_OWN_DETECTION_ERROR")
		return PLUGIN_CONTINUE
	}
	
	// we need to know our own server index to be able to load attributes from SQL - so now we can do that
	#if defined SQL
	load_attributes_sql()
	#endif // SQL
	
	if (get_pcvar_float(cvar_announce) > 0.0)
		if (!task_exists(TASKID_ANNOUNCE))
			set_task(get_pcvar_float(cvar_announce), "announce_servers", TASKID_ANNOUNCE, "", 0, "b")
	
	if (get_pcvar_float(cvar_advertise) > 0.0)
		if (!task_exists(TASKID_ADVERTISE))
			set_task(get_pcvar_float(cvar_advertise), "advertise_server_command", TASKID_ADVERTISE, "", 0, "b")
	
	if ((get_pcvar_num(cvar_categories) >= 1) && (g_nCategoryCount == 0))
		log_amx("%L", LANG_SERVER, "MSG_WARN_NO_CATEGORIES", "redirect_categories", SERVERFILE)
		
	return PLUGIN_CONTINUE
}

/// <summary>Cleanup. Close open sockets, vaults, database handles...</summary>
public plugin_end()
{
	// close all open sockets
	for (new nCounter = 0; nCounter < MAX_SERVERFORWARDS; nCounter++)
	{
		if (g_naServerSockets[nCounter] > 0)
		{
			socket_close(g_naServerSockets[nCounter])
			g_naServerSockets[nCounter] = 0
		}
	}
	
	#if defined VAULT
	nvault_close(g_nVaultId)
	#endif //VAULT

	#if defined SQL
	sql_disconnect()
	#endif // SQL
	
	return PLUGIN_CONTINUE
}

/// <summary>This is used to register the native redirect() function.</summary>
public plugin_natives()
{
	register_native("redirect", "native_redirect", 1)
}

/// <summary>Tells AMXX which modules are required.</summary>
/// <remarks>The code to require sockets can be safely removed from the code when only redirect_check_method 0 will be used.</remarks>
public plugin_modules()
{
	require_module("sockets")
	#if defined VAULT
	require_module("nvault")
	#endif // VAULT
}

/// <summary>Gets the server index based on a server ID.</summary>
/// <param name="nServerId">The ID of the server.</param>
public get_server_index(nServerId)
{
	new nServer = 0
	while (nServer < g_nServerCount)
	{
		if (g_naServerIds[nServer] == nServerId)
			return nServer
		nServer++
	}
	return -1
}

/// <summary>Set an attribute for a server.</summary>
/// <param name="nServer">The internal server index.</param>
/// <param name="sAttribute">The attribute name.</param>
/// <param name="sValue">The attribute value.</param>
public set_server_attribute(nServer, sAttribute[MAX_ATTRIB_LEN], sValue[MAX_VALUE_LEN])
{
	if (nServer < 0)
		return
	strtoupper(sAttribute)
	if (strcmp(sAttribute, "ADDRESS") == 0)
		copy(g_saServerAddresses[nServer], MAX_SERVERADDRESS_LEN - 1, sValue)
	else
	if (strcmp(sAttribute, "LOCALADDRESS") == 0)
		copy(g_saServerLocalAddresses[nServer], MAX_SERVERADDRESS_LEN - 1, sValue)
	else
	if (strcmp(sAttribute, "PASSWORD") == 0)
		copy(g_saServerPasswords[nServer], MAX_PASSWORD_LEN - 1, sValue)
	else
	if (strcmp(sAttribute, "PUBLICPASSWORD") == 0)
	{
		if (is_str_num(sValue))
			if (str_to_num(sValue) == 1)
				g_naServerPublicPassword[nServer] = 1
	}
	else
	if (strcmp(sAttribute, "PORT") == 0)
	{
		if (is_str_num(sValue))
			g_naServerPorts[nServer] = str_to_num(sValue)
		else
			g_naServerPorts[nServer] = 27015
		if ((g_naServerPorts[nServer] > 65536) || (g_naServerPorts[nServer] < 1024))
			g_naServerPorts[nServer] = 27015
	}
	else
	if (strcmp(sAttribute, "CMDBACKUP") == 0)
	{
		if (is_str_num(sValue))
			g_naServerCmdBackup[nServer] = str_to_num(sValue)
		else
			g_naServerCmdBackup[nServer] = DEFAULT_CMDBACKUP
		// protect from insane values
		if ((g_naServerCmdBackup[nServer] > 100) || (g_naServerCmdBackup[nServer] < 0))
			g_naServerCmdBackup[nServer] = DEFAULT_CMDBACKUP
	}
	else
	if (strcmp(sAttribute, "NOAUTO") == 0)
	{
		if (is_str_num(sValue))
			if (str_to_num(sValue) == 1)
				g_naServerFlags[nServer] = g_naServerFlags[nServer] | (1<<SERVERFLAG_NOAUTO)
	}
	else
	if (strcmp(sAttribute, "NOMANUAL") == 0)
	{
		if (is_str_num(sValue))
			if (str_to_num(sValue) == 1)
				g_naServerFlags[nServer] = g_naServerFlags[nServer] | (1<<SERVERFLAG_NOMANUAL)
	
	}
	else
	if (strcmp(sAttribute, "NODISPLAY") == 0)
	{
		if (is_str_num(sValue))
			if (str_to_num(sValue) == 1)
				g_naServerFlags[nServer] = g_naServerFlags[nServer] | (1<<SERVERFLAG_NODISPLAY)
	}
	else
	if (strcmp(sAttribute, "ADMINSLOTS") == 0)
	{
		if (is_str_num(sValue))
			g_naServerReserveSlots[nServer] = str_to_num(sValue)
		else
			g_naServerReserveSlots[nServer] = 0
		if ((g_naServerReserveSlots[nServer] > MAX_PLAYERS) || (g_naServerReserveSlots[nServer] < 0))
			g_naServerReserveSlots[nServer] = 0
	}
	else
	if (strcmp(sAttribute, "CATEGORY") == 0)
	{
		// adds a category to the internal category list and stores the index of it for the current server
		g_naServerCategory[nServer] = get_category_index(sValue)
	}
	else
	if (strcmp(sAttribute, "ID") == 0)
	{
		g_bUseIds = true
		g_naServerIds[nServer] = str_to_num(sValue)
	}
	else
	if (strcmp(sAttribute, "PRIVATE") == 0)
	{
		strtoupper(sValue)
		if (equal(sValue, "HIDE"))
			g_naServerPrivate[nServer] = PRIVATE_HIDE
		else if (equal(sValue, "FULLHIDE"))
			g_naServerPrivate[nServer] = PRIVATE_FULLHIDE
		else
			g_naServerPrivate[nServer] = PRIVATE_NONE
	}
}


#if defined SQL
/// <summary>Load server attributes from SQL database.</summary>
public load_attributes_sql()
{
	new sSqlAttribTable[MAX_SQL_TABLE_LEN]
	formatex(sSqlAttribTable, MAX_SQL_TABLE_LEN-1, "%s%s", SQL_PREFIX, SQL_TABLENAME_ATTRIBUTES)
	
	new Handle:hQuery = SQL_PrepareQuery(hSql, "SELECT `target_id`, `attrib`, `value` FROM `%s` WHERE `source_id` = '%d' ORDER BY `target_id`", sSqlAttribTable, g_nOwnServerId)
	if (!SQL_Execute(hQuery))
	{
		SQL_QueryError(hQuery, sSqlError, MAX_SQL_ERROR_LEN-1)
		log_amx("%L", LANG_SERVER, "MSG_ERROR_SQL_TABLE", sSqlAttribTable)
	}
	else
	{
		new sAttribute[MAX_ATTRIB_LEN]
		new sValue[MAX_VALUE_LEN]
		new nTargetId
		new cTargetId = SQL_FieldNameToNum(hQuery, "target_id")
		new cAttribute = SQL_FieldNameToNum(hQuery, "attrib")
		new cValue = SQL_FieldNameToNum(hQuery, "value")
		while (SQL_MoreResults(hQuery))
		{
			SQL_ReadResult(hQuery, cTargetId, sValue, MAX_VALUE_LEN-1)
			nTargetId = str_to_num(sValue)
			SQL_ReadResult(hQuery, cAttribute, sAttribute, MAX_VALUE_LEN-1)
			SQL_ReadResult(hQuery, cValue, sValue, MAX_VALUE_LEN-1)
			set_server_attribute(get_server_index(nTargetId), sAttribute, sValue)
			SQL_NextRow(hQuery)
		}
	}
	SQL_FreeHandle(hQuery)
}

/// <summary>Load servers from SQL database.</summary>
public load_servers_sql()
{
	new sPort[MAX_PORT_LEN]
	new sSqlServerTable[MAX_SQL_TABLE_LEN]
	formatex(sSqlServerTable, MAX_SQL_TABLE_LEN-1, "%s%s", SQL_PREFIX, SQL_TABLENAME_SERVERS)
	
	new Handle:hQuery = SQL_PrepareQuery(hSql, "SELECT * FROM `%s`", sSqlServerTable)
	if (!SQL_Execute(hQuery))
	{
		SQL_QueryError(hQuery, sSqlError, MAX_SQL_ERROR_LEN-1)
		log_amx("%L", LANG_SERVER, "MSG_ERROR_SQL_TABLE", sSqlServerTable)
	}
	else
	{
		new cId = SQL_FieldNameToNum(hQuery, "id")
		new cName = SQL_FieldNameToNum(hQuery, "name")
		new cAddress = SQL_FieldNameToNum(hQuery, "address")
		new cLocalAddress = SQL_FieldNameToNum(hQuery, "localaddress")
		new cPassword = SQL_FieldNameToNum(hQuery, "password")
		new cPublicPassword = SQL_FieldNameToNum(hQuery, "publicpassword")
		new cPort = SQL_FieldNameToNum(hQuery, "port")
		new cCmdBackup = SQL_FieldNameToNum(hQuery, "cmdbackup")
		new cNoAuto = SQL_FieldNameToNum(hQuery, "noauto")
		new cNoManual = SQL_FieldNameToNum(hQuery, "nomanual")
		new cNoDisplay = SQL_FieldNameToNum(hQuery, "nodisplay")
		new cAdminSlots = SQL_FieldNameToNum(hQuery, "adminslots")
		new cCategory = SQL_FieldNameToNum(hQuery, "category")
		new cPrivate = SQL_FieldNameToNum(hQuery, "private")
		
		new sValue[MAX_VALUE_LEN]
		while ((SQL_MoreResults(hQuery)) && (g_nServerCount < MAX_SERVERFORWARDS))
		{
			SQL_ReadResult(hQuery, cId, sValue, MAX_VALUE_LEN-1)
			g_naServerIds[g_nServerCount] = str_to_num(sValue)
			SQL_ReadResult(hQuery, cName, g_saServerNames[g_nServerCount], MAX_SERVERNAME_LEN-1)
			SQL_ReadResult(hQuery, cAddress, g_saServerAddresses[g_nServerCount], MAX_SERVERADDRESS_LEN-1)
			SQL_ReadResult(hQuery, cLocalAddress, g_saServerLocalAddresses[g_nServerCount], MAX_SERVERADDRESS_LEN-1)
			SQL_ReadResult(hQuery, cPassword, g_saServerPasswords[g_nServerCount], MAX_PASSWORD_LEN-1)
			SQL_ReadResult(hQuery, cPublicPassword, sValue, MAX_VALUE_LEN-1)
			g_naServerPublicPassword[g_nServerCount] = str_to_num(sValue)
			SQL_ReadResult(hQuery, cPort, sValue, MAX_VALUE_LEN-1)
			g_naServerPorts[g_nServerCount] = str_to_num(sValue)
			SQL_ReadResult(hQuery, cCmdBackup, sValue, MAX_VALUE_LEN-1)
			g_naServerCmdBackup[g_nServerCount] = str_to_num(sValue)
			SQL_ReadResult(hQuery, cNoAuto, sValue, MAX_VALUE_LEN-1)
			if (is_str_num(sValue))
				if (str_to_num(sValue) == 1)
					g_naServerFlags[g_nServerCount] = g_naServerFlags[g_nServerCount] | (1<<SERVERFLAG_NOAUTO)
			SQL_ReadResult(hQuery, cNoManual, sValue, MAX_VALUE_LEN-1)
			if (is_str_num(sValue))
				if (str_to_num(sValue) == 1)
					g_naServerFlags[g_nServerCount] = g_naServerFlags[g_nServerCount] | (1<<SERVERFLAG_NOMANUAL)
			SQL_ReadResult(hQuery, cNoDisplay, sValue, MAX_VALUE_LEN-1)
			if (is_str_num(sValue))
				if (str_to_num(sValue) == 1)
					g_naServerFlags[g_nServerCount] = g_naServerFlags[g_nServerCount] | (1<<SERVERFLAG_NODISPLAY)
			SQL_ReadResult(hQuery, cAdminSlots, sValue, MAX_VALUE_LEN-1)
			g_naServerReserveSlots[g_nServerCount] = str_to_num(sValue)
			SQL_ReadResult(hQuery, cCategory, sValue, MAX_VALUE_LEN-1)
			g_naServerCategory[g_nServerCount] = get_category_index(sValue)
			SQL_ReadResult(hQuery, cPrivate, sValue, MAX_VALUE_LEN-1)
			strtoupper(sValue)
			if (equal(sValue, "HIDE"))
				g_naServerPrivate[g_nServerCount] = PRIVATE_HIDE
			else if (equal(sValue, "FULLHIDE"))
				g_naServerPrivate[g_nServerCount] = PRIVATE_FULLHIDE
			else
				g_naServerPrivate[g_nServerCount] = PRIVATE_NONE
			
			// at least a valid server address is required, otherwise ignore the server
			if (!equal(g_saServerAddresses[g_nServerCount], ""))
			{
				num_to_str(g_naServerPorts[g_nServerCount], sPort, MAX_PORT_LEN - 1)
				log_amx("%L", LANG_SERVER, "MSG_LOADED_SERVER", g_saServerNames[g_nServerCount], g_saServerAddresses[g_nServerCount], sPort)
				g_nServerCount++
			}
			SQL_NextRow(hQuery)
		}
	}
	SQL_FreeHandle(hQuery)
}
#endif // SQL

/// <summary>Load servers from server list file.</summary>
public load_servers_file()
{
	new sConfigDir[MAX_FILE_LEN], sServerFile[MAX_FILE_LEN]

	get_configsdir(sConfigDir, MAX_FILE_LEN-1)
	format(sServerFile, MAX_FILE_LEN-1, "%s/%s", sConfigDir, SERVERFILE)

	if (!file_exists(sServerFile))
	{
		log_amx("%L", LANG_SERVER, "MSG_ERROR_NO_FILE", sServerFile)
		return
	}

	new nFilePos = 0
	new sFileLine[MAX_SERVERLINE_LEN], sFileLineTrim[MAX_SERVERLINE_LEN]
	new nReadLen
	new sPort[MAX_PORT_LEN]
	
	new sAttribute[MAX_ATTRIB_LEN]
	new sValue[MAX_VALUE_LEN]
	
	new nCurrentServer = -1

	while (read_file(sServerFile, nFilePos++, sFileLine, MAX_SERVERLINE_LEN-1, nReadLen))
	{
		sFileLineTrim = sFileLine
		trim(sFileLineTrim)
		if ((sFileLine[0] == ';') || (strlen(sFileLineTrim) == 0)) continue // skip comments and empty lines

		if ((sFileLine[0] == '[') && (sFileLine[strlen(sFileLine) - 1] == ']'))	// a section starts
		{
			nCurrentServer++
			if (nCurrentServer > 0)
			{
				// check whether the previous server was valid
				if ((g_naServerPorts[nCurrentServer - 1] != 0) && (strcmp(g_saServerAddresses[nCurrentServer - 1], "") != 0))
				{
					g_nServerCount++
					num_to_str(g_naServerPorts[nCurrentServer - 1], sPort, MAX_PORT_LEN - 1)
					log_amx("%L", LANG_SERVER, "MSG_LOADED_SERVER", g_saServerNames[nCurrentServer - 1], g_saServerAddresses[nCurrentServer - 1], sPort)
				}
				else
					nCurrentServer--
			}
			
			if (nCurrentServer >= MAX_SERVERFORWARDS)
				break;
			
			copy(g_saServerNames[nCurrentServer], strlen(sFileLine) - 2, sFileLine[1])

			continue
		}

		if (nCurrentServer >= 0)	// do we already have found a section?
		{
			strtok(sFileLine, sAttribute, MAX_ATTRIB_LEN - 1, sValue, MAX_VALUE_LEN - 1, '=', 1)
			set_server_attribute(nCurrentServer, sAttribute, sValue)
		}
	}
	
	if ((nCurrentServer >= MAX_SERVERFORWARDS) || (nCurrentServer == -1))
		return

	// check whether the previous server was valid
	if ((g_naServerPorts[nCurrentServer] != 0) && (strcmp(g_saServerAddresses[nCurrentServer], "") != 0))
	{
		g_nServerCount++
		num_to_str(g_naServerPorts[nCurrentServer], sPort, MAX_PORT_LEN - 1)
		log_amx("%L", LANG_SERVER, "MSG_LOADED_SERVER", g_saServerNames[nCurrentServer], g_saServerAddresses[nCurrentServer], sPort)
	}
}

/// <summary>Gets the index of a category in the internal list. It is added to the list if it doesn't exist there already.</summary>
/// <param name="sCategory">The string containing the category name. Not case-sensitive when it comes to searching in the list.</param>
/// <returns>The zero-based array index of the category in the internal list or -1 if called with an empty category name.</returns>
public get_category_index(sCategory[MAX_VALUE_LEN])
{
	if (equal(sCategory, ""))
		return -1
		
	for (new nCategoryIndex = 0; nCategoryIndex < g_nCategoryCount; nCategoryIndex++)
	{
		if (equali(g_saCategories[nCategoryIndex], sCategory))
			return nCategoryIndex
	}
	
	// don't assign a category if we already reached the maximum number
	if (g_nCategoryCount >= MAX_CATEGORIES - (get_pcvar_num(cvar_categories) - 1)) // if cvar_categories is set to 2 it's one category less we can use
		return -1
	
	if (g_bDebug)
		log_amx("Found new category '%s'", sCategory)
	g_saCategories[g_nCategoryCount] = sCategory
	g_nCategoryCount++
	return g_nCategoryCount - 1
}

/// <summary>Checks whether the IP in <paramref name="sCheckAddress"/> is a local address according to RFC 1918.</summary>
/// <summary>10.0.0.0 - 10.255.255.255 - single class A</summary>
/// <summary>172.16.0.0 - 172.31.255.255 - 16 contiguous class Bs</summary>
/// <summary>192.168.0.0 - 192.168.255.255 - 256 contiguous class Cs</summary>
/// <summary>169.254.0.0 - 169.254.255.255 - zeroconf</summary>
/// <param name="sCheckAddress">The IP address to check passed as a string.</param>
/// <returns>true if <paramref name="sCheckAddress"/> is a local IP address, false if not.</returns>
public bool:is_local_address(sCheckAddress[MAX_IP_LEN])
{
	new sIPPart1[4]
	new sIPPart2[4]
	new nIPPart[4]
	new sCompareIP[MAX_IP_LEN]
	sCompareIP = sCheckAddress
	strtok(sCheckAddress, sIPPart1, 3, sCheckAddress, MAX_IP_LEN - 1, '.')
	nIPPart[0] = str_to_num(sIPPart1);
	strtok(sCheckAddress, sIPPart1, 3, sCheckAddress, MAX_IP_LEN - 1, '.')
	nIPPart[1] = str_to_num(sIPPart1);
	strtok(sCheckAddress, sIPPart1, 3, sIPPart2, 3, '.')
	nIPPart[2] = str_to_num(sIPPart1);
	nIPPart[3] = str_to_num(sIPPart2);
	return ((nIPPart[0] == 10) || ((nIPPart[0] == 192) && (nIPPart[1] == 168)) || ((nIPPart[0] == 172) && (nIPPart[1] > 15) && (nIPPart[1] < 32)) || ((nIPPart[0] == 169) && (nIPPart[1] == 254)))
}

/// <summary>Checks whether the given server differs from the current server with mod or protocol.</summary>
/// <param name="nServer">The server number which shall be checked whether it's having the same mod and protocol as the current server.</param>
/// <returns>true if the server's mod and protocol match that of the current server, otherwise false.</returns>
public bool:compare_mod(nServer)
{
#if defined MOD_DETECTION
	// compensate for errors in protocol detection
	if ((g_naServerProtocol[g_nOwnServer] <= 0) || (g_naServerProtocol[nServer] <= 0))
		return true
	// compensate for errors in mod detection
	if ((equal(g_sMod, "")) || (equal(g_saServerMod[nServer], "")))
		return true
	// compare protocol and mod
	return ((strcmp(g_sMod, g_saServerMod[nServer], 1) == 0) && (g_naServerProtocol[g_nOwnServer] == g_naServerProtocol[nServer]))
#elseif
	return true
#endif
}

/// <summary>Checks whether the player with ID <paramref name="nPlayerID"/> can be redirected to the server with server number <paramref name="nServerNum"/>.</summary>
/// <param name="nServer">The server number which shall be checked whether it is currently a valid redirection target.</param>
/// <param name="nPlayerID">The internal player ID which shall be checked for access to <paramref name="nServerNum"/>.</param>
/// <param name="nMode">Defines the redirection mode - 1 = automatic, 2 = manual.</param>
/// <param name="bIgnoreAdmin">Set to true, when the plugin should not tread admins as special, otherwise false.</param>
/// <returns>0 if redirection is possible, otherwise an error code: 1 = current server, 2 = no permission(passworded), 3 = manual redirection disabled. 4 = server full, 5 = server down, 6 = automatic redirection disabled.</returns>
public can_redirect_player(nServer, nPlayerID, nMode, bIgnoreAdmin)
{
	if (nServer == -1)
		return 0
	get_modname(g_sMod, MAX_NAME_LEN - 1)
	
	new nCheckMethod = get_pcvar_num(cvar_check_method)
	
	new bool:bCanRedirectByPassword = !(!equal(g_saServerPasswords[nServer], "") && (g_naServerPublicPassword[nServer] == 0))
	
	if (g_bDebug)
		log_amx("Mod comparison: local protocol/mod: %i/^"%s^", remote protocol/mod: (server %d): %i/^"%s^"", g_naServerProtocol[g_nOwnServer], g_sMod, nServer, g_naServerProtocol[nServer], g_saServerMod[nServer])
	
	if (nServer == g_nOwnServer)
		return 1
	else if ((nCheckMethod == 2) && (!compare_mod(nServer)))
		return 7
	else if (access(nPlayerID, MIN_ADMIN_LEVEL) && (!bIgnoreAdmin)) // even for admins it doesn't make sense to redirect to the current server or to servers with a different mod/protocol so check admin rights from here
		return 0
	else if ((nCheckMethod > 0) && (!g_baServerResponding[nServer]))
		return 5
	else if (!bCanRedirectByPassword)
		return 2
	else if ((g_naServerFlags[nServer] & (1<<SERVERFLAG_NOMANUAL)) && (nMode == 2))
		return 3
	else if ((g_naServerFlags[nServer] & (1<<SERVERFLAG_NOAUTO)) && (nMode == 1))
		return 6
	else if ((nCheckMethod == 2) && (g_naServerReserveSlots[nServer] >= (g_naServerMaxPlayers[nServer] - g_naServerActivePlayers[nServer])) )
		return 4
	
	return 0
}


/// <summary>Checks whether the player with ID <paramref name="nPlayerID"/> can be queued to redirect to the server with server number <paramref name="nServerNum"/>.</summary>
/// <param name="nServer">The server number which shall be checked whether it is currently a valid redirection queue target.</param>
/// <param name="nPlayerID">The internal player ID which shall be checked for access to <paramref name="nServerNum"/>.</param>
/// <returns>true if queueing is possible, otherwise false.</returns>
public bool:can_queue_player(nServer, nPlayerID)
{
	if (nServer == -1)
		return false
	
	new bIsAdmin = access(nPlayerID, MIN_ADMIN_LEVEL)
	
	if ((get_pcvar_num(cvar_retry) == 0) && (!bIsAdmin)) // admin always can enqueue themselves, even when this feature is disabled
		return false
	
	new bool:bCanRedirectByPassword = !(!equal(g_saServerPasswords[nServer], "") && (g_naServerPublicPassword[nServer] == 0))
	if (nServer == g_nOwnServer)
		return false
	if (bIsAdmin)
		return true
	if ((!bCanRedirectByPassword) || (g_naServerFlags[nServer] & (1<<SERVERFLAG_NOMANUAL)))
		return false
	if ((get_pcvar_num(cvar_check_method) == 2) && (!compare_mod(nServer)))
		return false
	
	return true
}

/// <summary>Checks whether the player with ID <paramref name="id"/> is already in redirection queue for server with number <paramref name="nServer"/>.</summary>
/// <param name="nServer">The server number which shall be checked whether player with <paramref name="id"/> is in its queue.</param>
/// <param name="id">The internal player ID which shall be checked whether it is queued for server <paramref name="nServer"/>.</param>
/// <remarks>A player can be in more than one queue but not twice in the queue for one server, <seealso name="queue_add"/> prevents double adding.</remarks>
/// <returns>true if player is in queue, false if not.</returns>
/// <seealso name="queue_add"/>
/// <seealso name="queue_remove"/>
public bool:is_queued(id, nServer)
{
	new nCount = 0
	while (nCount < g_nRetryCount)
	{
		if ((g_nRetryQueue[nCount][0] == id) && (g_nRetryQueue[nCount][1] == nServer))
			return true
		nCount++
	}
	return false
}

/// <summary>Adds the player with ID <paramref name="id"/> to the redirection queue for server with number <paramref name="nServer"/>.</summary>
/// <param name="nServer">The server number to add the player with <paramref name="id"/> to its queue.</param>
/// <param name="id">The internal player ID which shall be added to the queue for server <paramref name="nServer"/>.</param>
/// <remarks>A player can be in more than one queue but not twice in the queue for one server, <seealso name="queue_add"/> prevents double adding.</remarks>
/// <seealso name="is_queued"/>
/// <seealso name="queue_remove"/>
public queue_add(id, nServer)
{
	if (get_pcvar_num(cvar_retry) > 0)
	{
		// first check whether the server-player-combination is not already in queue
		new nCount = 0
		new nServerQueue = 0
		while (nCount < g_nRetryCount)
		{
			// count how many people are in the queue for the target server
			if (g_nRetryQueue[nCount][1] == nServer)
			{
				nServerQueue++
				// no need to continue when he already is in the queue
				if (g_nRetryQueue[nCount][0] == id)
					return
			}
			nCount++
		}
		
		new sUserNick[MAX_NAME_LEN]
		get_user_name(id, sUserNick, MAX_NAME_LEN - 1)
		
		if (get_pcvar_num(cvar_show) == 1)
		{
			new naPlayers[MAX_PLAYERS]
			new nPlayerNum, nPlayerCount, nCurrentPlayer
			get_players(naPlayers, nPlayerNum, "c")
			for (nPlayerCount = 0; nPlayerCount < nPlayerNum; nPlayerCount++)
			{
				nCurrentPlayer = naPlayers[nPlayerCount]
				if (nCurrentPlayer != id)	// he has his own message
					client_print(nCurrentPlayer, print_chat, "%s: %L", PLUGIN_TAG, nCurrentPlayer, "MSG_QUEUE_ANNOUNCE", sUserNick, g_saServerNames[nServer])
			}
		}
		
		#if defined STATISTICS
			stats_redirect(STATS_INFO_ENQUEUE, id, -1, nServer)
		#endif // STATISTICS
		
		if (g_bDebug)
			log_amx("added player %i to queue for server %i in slot %i", id, nServer, g_nRetryCount)
		
		
		g_nRetryQueue[g_nRetryCount][0] = id
		g_nRetryQueue[g_nRetryCount][1] = nServer
		g_nRetryCount++
		
		client_print(id, print_chat, "%s: %L", PLUGIN_TAG, id, "MSG_QUEUE_ADD", ++nServerQueue, g_saServerNames[nServer])
	}
	else
		client_print(id, print_chat, "%s: %L", PLUGIN_TAG, id, "MSG_QUEUE_DEACTIVATED")
}

/// <summary>Removes the player with ID <paramref name="id"/> from the redirection queue for server with number <paramref name="nServer"/>.</summary>
/// <param name="nServer">The server number to remove the player with <paramref name="id"/> from its queue.</param>
/// <param name="id">The internal player ID which shall be removed from the queue for server <paramref name="nServer"/>.</param>
/// <remarks>A player can be in more than one queue but not twice in the queue for one server, <seealso name="queue_add"/> prevents double adding.</remarks>
/// <seealso name="is_queued"/>
/// <seealso name="add_remove"/>
public queue_remove(id, nServer)
{
	new nCount = 0
	while (nCount < g_nRetryCount)
	{
		if ((g_nRetryQueue[nCount][0] == id) && ((nServer == -1) || (g_nRetryQueue[nCount][1] == nServer)))
		{	// ok, remove from queue and let all others go one place up
		
			// in case it's the last entry in queue where the following loop would never be executed:
			g_nRetryQueue[nCount][0] = -1
			g_nRetryQueue[nCount][1] = -1
			
			// move other entries up
			while ((nCount + 1) < g_nRetryCount)
			{
				g_nRetryQueue[nCount][0] = g_nRetryQueue[nCount + 1][0]
				g_nRetryQueue[nCount][1] = g_nRetryQueue[nCount + 1][1]
				nCount++
			}
			g_nRetryCount--
			break
		}
		nCount++
	}
}

/// <summary>Resets the setinfo string of the player with <paramref name="id"/> by removing tags that xREDIRECT used.</summary>
/// <param name="id">The internal player ID of the player that shall have the setinfo data resetted. It is passed as an array so that this function can easily be called from <seealso name="set_task"/>.</param>
public reset_info(id[])
{
	client_cmd(id[0], "setinfo ^"xredir^" ^"^"")
	client_cmd(id[0], "setinfo ^"password^" ^"^"")
}

#if defined VAULT
/// <summary>Converts a string to a value that can be written to a CSV file. Basically it handles escaping delimiters (,) and quotes (").</summary>
public csv_value(value[])
{
	new sReturnValue[51]
	copy(sReturnValue, 50, value)
	
	if (containi(sReturnValue, "^"") || containi(sReturnValue, ","))
	{
		replace_all(sReturnValue, 50, "^"", "^"^"") // double all quotes
		format(sReturnValue, 50, "^"%s^"", sReturnValue) // surround the whole term with quotes
	}
	return sReturnValue
}

/// <summary>Displays the current count stats to the given user ID.</summary>
public cmd_stats(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	if (g_bDebug)
		log_amx("showstats")
	new sVaultKey[MAX_VAULT_KEY_LEN]
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_REDIRECT_AUTO)
	console_print(id, "%L: %d", id, "MSG_STATS_REDIRECT_AUTO", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_REDIRECT_MANUAL)
	console_print(id, "%L: %d", id, "MSG_STATS_REDIRECT_MANUAL", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_DROP)
	console_print(id, "%L: %d", id, "MSG_STATS_DROP", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_MENU)
	console_print(id, "%L: %d", id, "MSG_STATS_MENU", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_ENQUEUE)
	console_print(id, "%L: %d", id, "MSG_STATS_ENQUEUE", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_DEQUEUE)
	console_print(id, "%L: %d", id, "MSG_STATS_DEQUEUE", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_REDIRECTED)
	console_print(id, "%L: %d", id, "MSG_STATS_REDIRECTED", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_RETRY)
	console_print(id, "%L: %d", id, "MSG_STATS_RETRY", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_FOLLOW)
	console_print(id, "%L: %d", id, "MSG_STATS_FOLLOW", nvault_get(g_nVaultId, sVaultKey))
	
	return PLUGIN_HANDLED
}

/// <summary>Displays the current count stats to the server console.</summary>
public srvcmd_stats()
{
	new sVaultKey[MAX_VAULT_KEY_LEN]
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_REDIRECT_AUTO)
	server_print("%L: %d", LANG_SERVER, "MSG_STATS_REDIRECT_AUTO", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_REDIRECT_MANUAL)
	server_print("%L: %d", LANG_SERVER, "MSG_STATS_REDIRECT_MANUAL", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_DROP)
	server_print("%L: %d", LANG_SERVER, "MSG_STATS_DROP", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_MENU)
	server_print("%L: %d", LANG_SERVER, "MSG_STATS_MENU", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_ENQUEUE)
	server_print("%L: %d", LANG_SERVER, "MSG_STATS_ENQUEUE", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_DEQUEUE)
	server_print("%L: %d", LANG_SERVER, "MSG_STATS_DEQUEUE", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_REDIRECTED)
	server_print("%L: %d", LANG_SERVER, "MSG_STATS_REDIRECTED", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_RETRY)
	server_print("%L: %d", LANG_SERVER, "MSG_STATS_RETRY", nvault_get(g_nVaultId, sVaultKey))
	
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, STATS_COUNT_FOLLOW)
	server_print("%L: %d", LANG_SERVER, "MSG_STATS_FOLLOW", nvault_get(g_nVaultId, sVaultKey))
}

/// <summary>Resets all vault statistics to 0.</summary>
public srvcmd_resetvault()
{
	new sVaultKey[MAX_VAULT_KEY_LEN]
	new nStatsCountCount = eStatsCount
	for (new nStatsType = 0; nStatsType < nStatsCountCount; nStatsType++)
	{
		formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, nStatsType)
		nvault_pset(g_nVaultId, sVaultKey, "0")
	}
}

/// <summary>Increases a statistics counter.</summary>
public stats_count(stats_type, server_id)
{
	new sVaultKey[MAX_VAULT_KEY_LEN]
	new sVaultValue[11] // 10 digits should be enough
	formatex(sVaultKey, MAX_VAULT_KEY_LEN-1, "%s%d", STATS_VAULT_TAG, stats_type)
	formatex(sVaultValue, 10, "%d", nvault_get(g_nVaultId, sVaultKey) + 1)
	nvault_pset(g_nVaultId, sVaultKey, sVaultValue)
}
#endif // VAULT

#if defined STATISTICS
#if defined SQL
public sql_callback(nFailState, Handle:hQuery, sError[], nErrNum, aData[], nSize, Float:fQueueTime)
{
	if (nFailState != TQUERY_SUCCESS)
		log_amx("SQLx error #%d: %s", nErrNum, sError);
}
#endif // SQL

/// <summary>Stores an info line in the statistics.</summary>
/// <param name="statstype">One of the STATS_INFO_ defines defining the type of the action.</param>
/// <param name="id">The slot ID of the user that triggered the information line by being directly involved/affected.</param>
/// <param name="redirtype">The redirection type. 0 = drop, 1 = auto, 2 = manual, 3 = manual/follow, 4 = manual/queue, 5 = manual/admin (redirect_user).</param>
/// <param name="server">The target server number.</param>
/// <remarks>Unused parameters are ignored but should still always be set to -1 for better code readability.</remarks>
public stats_redirect(statstype, id, redirtype, server)
{
	new sUserIp[MAX_IP_LEN]
	new sUserNick[MAX_NAME_LEN]
	new sUserId[MAX_ID_LEN]
	new nServerId = server
	if ((g_bUseIds) && (server >= 0))
		nServerId = g_naServerIds[server]
	
	get_user_ip(id, sUserIp, MAX_IP_LEN-1, 1)
	get_user_name(id, sUserNick, MAX_NAME_LEN-1)
	get_user_authid(id, sUserId, MAX_ID_LEN-1)
	
	switch (statstype)
	{
		// File header:
		// log_to_file(STATSFILE, ",User Name,User IP,User Auth-ID,Action,Server-ID,Target-Server-ID")
		case STATS_INFO_ENQUEUE:
		{
			#if defined SQL
			SQL_QueryAndIgnore(hSql, "INSERT INTO `%s` (`user_name`, `user_ip`, `user_authid`, `action`, `server_id`, `target_server_id`) VALUES ('%s', '%s', '%s', '%s', '%d', '%d')", SQL_TABLE_STATISTICS, sUserNick, sUserIp, sUserId, "Enqueue", g_nOwnServerId, nServerId)
			#else
			log_to_file(STATSFILE, ",%s,%s,%s,%s,%d,%d", csv_value(sUserNick), sUserIp, sUserId, "Enqueue", g_nOwnServerId, nServerId)
			stats_count(STATS_COUNT_ENQUEUE, nServerId)
			#endif // SQL
		}
		case STATS_INFO_RETRY:
		{
			#if defined SQL
			SQL_QueryAndIgnore(hSql, "INSERT INTO `%s` (`user_name`, `user_ip`, `user_authid`, `action`, `server_id`, `target_server_id`) VALUES ('%s', '%s', '%s', '%s', '%d', '%d')", SQL_TABLE_STATISTICS, sUserNick, sUserIp, sUserId, "Retry", g_nOwnServerId, nServerId)
			#else
			log_to_file(STATSFILE, ",%s,%s,%s,%s,%d,%d", csv_value(sUserNick), sUserIp, sUserId, "Retry", g_nOwnServerId, nServerId)
			stats_count(STATS_COUNT_RETRY, nServerId)
			#endif // SQL
		}
		case STATS_INFO_DEQUEUE:
		{
			#if defined SQL
			SQL_QueryAndIgnore(hSql, "INSERT INTO `%s` (`user_name`, `user_ip`, `user_authid`, `action`, `server_id`, `target_server_id`) VALUES ('%s', '%s', '%s', '%s', '%d', '%d')", SQL_TABLE_STATISTICS, sUserNick, sUserIp, sUserId, "Dequeue", g_nOwnServerId, nServerId)
			#else
			log_to_file(STATSFILE, ",%s,%s,%s,%s,%d,%d", csv_value(sUserNick), sUserIp, sUserId, "Dequeue", g_nOwnServerId, nServerId)
			stats_count(STATS_COUNT_DEQUEUE, nServerId)
			#endif // SQL
		}
		case STATS_INFO_REDIRECT:
		{
			switch (redirtype)
			{
				case STATS_REDIRTYPE_DROP:
				{
					#if defined SQL
					SQL_QueryAndIgnore(hSql, "INSERT INTO `%s` (`user_name`, `user_ip`, `user_authid`, `action`, `server_id`, `target_server_id`) VALUES ('%s', '%s', '%s', '%s', '%d', '%d')", SQL_TABLE_STATISTICS, sUserNick, sUserIp, sUserId, "Redirect: Drop", g_nOwnServerId, nServerId)
					#else
					log_to_file(STATSFILE, ",%s,%s,%s,%s,%d,%d", csv_value(sUserNick), sUserIp, sUserId, "Redirect: Drop", g_nOwnServerId, nServerId)
					stats_count(STATS_COUNT_DROP, nServerId)
					#endif // SQL
				}
				case STATS_REDIRTYPE_AUTO:
				{
					#if defined SQL
					SQL_QueryAndIgnore(hSql, "INSERT INTO `%s` (`user_name`, `user_ip`, `user_authid`, `action`, `server_id`, `target_server_id`) VALUES ('%s', '%s', '%s', '%s', '%d', '%d')", SQL_TABLE_STATISTICS, sUserNick, sUserIp, sUserId, "Redirect: Auto", g_nOwnServerId, nServerId)
					#else
					log_to_file(STATSFILE, ",%s,%s,%s,%s,%d,%d", csv_value(sUserNick), sUserIp, sUserId, "Redirect: Auto", g_nOwnServerId, nServerId)
					stats_count(STATS_COUNT_REDIRECT_AUTO, nServerId)
					#endif // SQL
				}
				case STATS_REDIRTYPE_MANUAL:
				{
					#if defined SQL
					SQL_QueryAndIgnore(hSql, "INSERT INTO `%s` (`user_name`, `user_ip`, `user_authid`, `action`, `server_id`, `target_server_id`) VALUES ('%s', '%s', '%s', '%s', '%d', '%d')", SQL_TABLE_STATISTICS, sUserNick, sUserIp, sUserId, "Redirect: Manual", g_nOwnServerId, nServerId)
					#else
					log_to_file(STATSFILE, ",%s,%s,%s,%s,%d,%d", csv_value(sUserNick), sUserIp, sUserId, "Redirect: Manual", g_nOwnServerId, nServerId)
					stats_count(STATS_COUNT_REDIRECT_MANUAL, nServerId)
					#endif // SQL
				}
				case STATS_REDIRTYPE_FOLLOW:
				{
					#if defined SQL
					SQL_QueryAndIgnore(hSql, "INSERT INTO `%s` (`user_name`, `user_ip`, `user_authid`, `action`, `server_id`, `target_server_id`) VALUES ('%s', '%s', '%s', '%s', '%d', '%d')", SQL_TABLE_STATISTICS, sUserNick, sUserIp, sUserId, "Redirect: Follow", g_nOwnServerId, nServerId)
					#else
					log_to_file(STATSFILE, ",%s,%s,%s,%s,%d,%d", csv_value(sUserNick), sUserIp, sUserId, "Redirect: Follow", g_nOwnServerId, nServerId)
					stats_count(STATS_COUNT_REDIRECT_MANUAL, nServerId)
					stats_count(STATS_COUNT_FOLLOW, nServerId)
					#endif // SQL
				}
				case STATS_REDIRTYPE_QUEUED:
				{
					#if defined SQL
					SQL_QueryAndIgnore(hSql, "INSERT INTO `%s` (`user_name`, `user_ip`, `user_authid`, `action`, `server_id`, `target_server_id`) VALUES ('%s', '%s', '%s', '%s', '%d', '%d')", SQL_TABLE_STATISTICS, sUserNick, sUserIp, sUserId, "Redirect: Queued", g_nOwnServerId, nServerId)
					#else
					log_to_file(STATSFILE, ",%s,%s,%s,%s,%d,%d", csv_value(sUserNick), sUserIp, sUserId, "Redirect: Queued", g_nOwnServerId, nServerId)
					stats_count(STATS_COUNT_REDIRECT_MANUAL, nServerId)
					#endif // SQL
				}
				case STATS_REDIRTYPE_ADMIN:
				{
					#if defined SQL
					SQL_QueryAndIgnore(hSql, "INSERT INTO `%s` (`user_name`, `user_ip`, `user_authid`, `action`, `server_id`, `target_server_id`) VALUES ('%s', '%s', '%s', '%s', '%d', '%d')", SQL_TABLE_STATISTICS, sUserNick, sUserIp, sUserId, "Redirect: Admin", g_nOwnServerId, nServerId)
					#else
					log_to_file(STATSFILE, ",%s,%s,%s,%s,%d,%d", csv_value(sUserNick), sUserIp, sUserId, "Redirect: Admin", g_nOwnServerId, nServerId)
					stats_count(STATS_COUNT_REDIRECT_MANUAL, nServerId)
					#endif // SQL
				}
			}
		}
	}
}
#endif // STATISTICS

/// <summary>Advertises the availability of the /server command.</summary>
public advertise_server_command()
{
	client_print(0, print_chat, "%s: %L", PLUGIN_TAG, LANG_PLAYER, "MSG_ADVERTISE")
}

/// <summary>Announce the servers on top of the screen. The position and interval for announcements can be set by CVARs.</summary>
public announce_servers()
{
	if (get_pcvar_num(cvar_active) == 1)
	{
		if (g_nServerCount > 0)
		{
			new nCheckMethod = get_pcvar_num(cvar_check_method)
			new sAnnounceBody[MAX_MENUBODY_LEN] = ""
			new nDisplayCount = 0
			new nServerCount = g_nNextAnnounceServer
			if (nServerCount >= g_nServerCount)
				nServerCount = 0
				
			while ((nServerCount < g_nServerCount) && (nDisplayCount < 8))
			{
				if (!((g_naServerPrivate[nServerCount] >= PRIVATE_HIDE) || (g_naServerFlags[nServerCount] & (1<<SERVERFLAG_NODISPLAY)) || ((get_pcvar_num(cvar_hidedown) > 1) && (!g_baServerResponding[nServerCount]) && (nServerCount != g_nOwnServer))))
				{
					if (nServerCount == g_nOwnServer)
					{
						new sMap[MAX_MAP_LEN]
						get_mapname(sMap, MAX_MAP_LEN - 1)
						format(sAnnounceBody, MAX_MENUBODY_LEN - 1, "%s^n%s [%s] (%d/%d)", sAnnounceBody, g_saServerNames[nServerCount], sMap, get_current_players(), get_maxplayers())
					}
					else
					{
						if (nCheckMethod == 0)
							format(sAnnounceBody, MAX_MENUBODY_LEN - 1, "%s^n%s", sAnnounceBody, g_saServerNames[nServerCount])
						else
							if (g_baServerResponding[nServerCount])
							{
								if (nCheckMethod == 1)
									format(sAnnounceBody, MAX_MENUBODY_LEN - 1, "%s^n%s", sAnnounceBody, g_saServerNames[nServerCount])
								else if (nCheckMethod == 2)
									format(sAnnounceBody, MAX_MENUBODY_LEN - 1, "%s^n%s [%s] (%d/%d)", sAnnounceBody, g_saServerNames[nServerCount], g_saServerMap[nServerCount], g_naServerActivePlayers[nServerCount], g_naServerMaxPlayers[nServerCount])
							}
							else
								format(sAnnounceBody, MAX_MENUBODY_LEN - 1, "%s^n%s (down)", sAnnounceBody, g_saServerNames[nServerCount])
					}
				}
				nServerCount++
				nDisplayCount++
			}
			g_nNextAnnounceServer = nServerCount
			set_hudmessage(000, 100, 255, -1.0, 0.01, 0, 0.0, 10.0, 0.5, 0.10, 1)
			
			if (get_pcvar_float(cvar_announce) > 0.0)
			{
				new nAnnounceMode = get_pcvar_num(cvar_announce_mode)
				if (nAnnounceMode > 0)
				{
					new naPlayers[MAX_PLAYERS]
					new nPlayerNum, nPlayerCount
					new sAnnounceText[MAX_MENUBODY_LEN]
					if ((nAnnounceMode == 1) || (nAnnounceMode == 3))
					{
						get_players(naPlayers, nPlayerNum, "ac")	// alive players
						set_hudmessage(000, 100, 255, get_pcvar_float(cvar_announce_alivepos_x), get_pcvar_float(cvar_announce_alivepos_y), 0, 0.0, 10.0, 0.5, 0.10, 1)
						for (nPlayerCount = 0; nPlayerCount < nPlayerNum; nPlayerCount++)
						{
							if (get_pcvar_num(cvar_manual) >= 1)
								format(sAnnounceText, MAX_MENUBODY_LEN - 1, "%L^n%s", naPlayers[nPlayerCount], "MSG_SAY_SERVER", sAnnounceBody)
							else
								sAnnounceText = sAnnounceBody
							show_hudmessage(naPlayers[nPlayerCount], sAnnounceText)
						}
					}
					if ((nAnnounceMode == 2) || (nAnnounceMode == 3))
					{
						get_players(naPlayers, nPlayerNum, "bc") // dead players
						set_hudmessage(000, 100, 255, get_pcvar_float(cvar_announce_deadpos_x), get_pcvar_float(cvar_announce_deadpos_y), 0, 0.0, 10.0, 0.5, 0.10, 1)	// show list at lower position for them so it is not covered by the "spectator bars"
						for (nPlayerCount = 0; nPlayerCount < nPlayerNum; nPlayerCount++)
						{
							if (get_pcvar_num(cvar_manual) >= 1)
								format(sAnnounceText, MAX_MENUBODY_LEN - 1, "%L^n%s", naPlayers[nPlayerCount], "MSG_SAY_SERVER", sAnnounceBody)
							else
								sAnnounceText = sAnnounceBody
							show_hudmessage(naPlayers[nPlayerCount], sAnnounceText)
						}
					}
				}
			}
		}
	}
	return PLUGIN_HANDLED
}


/// <summary>Shows the sub menu for server with number <paramref name="nServer"/> to the the player with ID <paramref name="id"/>.</summary>
/// <param name="nServer">The server to show the sub menu for.</param>
/// <param name="id">The ID of the player to show the sub menu.</param>
/// <seealso name="server_menu_select"/>
/// <seealso name="sub_menu_select"/>
/// <seealso name="show_server_menu"/>
public show_sub_menu(id, nServer)
{
	new nCanRedirect = can_redirect_player(nServer, id, 2, false)
	new nCanRedirectIgnoreAdmin = can_redirect_player(nServer, id, 2, true);
	new bool:bCanQueue = can_queue_player(nServer, id)
	new bColorMenu = (colored_menus() && !MENU_FORCENOCOLOR)
	new nCheckMethod = get_pcvar_num(cvar_check_method)
	new sMenuBody[MAX_MENUBODY_LEN]
	new nCurrentCategory = g_naServerCategory[nServer]
	new sCurrentCategory[MAX_VALUE_LEN] = ""
	if (nCurrentCategory >= 0)
		sCurrentCategory = g_saCategories[g_naServerCategory[nServer]]
	
	// can we display colors?
	if (bColorMenu)
	{
		formatex(sMenuBody, MAX_MENUBODY_LEN - 1, "\y%L^n", id, "MSG_SRVINFO_CAPTION")
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y%L \w%s", sMenuBody, id, "MSG_SRVINFO_NAME", g_saServerNames[nServer])
		if (get_pcvar_num(cvar_categories) >= 1)
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y%L \w%s", sMenuBody, id, "MSG_SRVINFO_CATEGORY", sCurrentCategory)
	}
	else
	{
		formatex(sMenuBody, MAX_MENUBODY_LEN - 1, "%L^n", id, "MSG_SRVINFO_CAPTION")
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n%L %s", sMenuBody, id, "MSG_SRVINFO_NAME", g_saServerNames[nServer])
		if (get_pcvar_num(cvar_categories) >= 1)
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n%L %s", sMenuBody, id, "MSG_SRVINFO_CATEGORY", sCurrentCategory)
	}
	
	// can we display map and player information?
	if (((nCheckMethod == 2) && ((g_baServerResponding[nServer])) || (nServer == g_nOwnServer)))
	{
		if (bColorMenu)
		{
			if (nServer == g_nOwnServer)
			{
				new sMap[MAX_MAP_LEN]
				get_mapname(sMap, MAX_MAP_LEN - 1)
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y%L \w%s", sMenuBody, id, "MSG_SRVINFO_MAP", sMap)
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y%L \w%d/%d", sMenuBody, id, "MSG_SRVINFO_PLAYERS", get_current_players(), get_maxplayers())
			}
			else
			{
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y%L \w%s", sMenuBody, id, "MSG_SRVINFO_MAP", g_saServerMap[nServer])
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y%L \w%d/%d", sMenuBody, id, "MSG_SRVINFO_PLAYERS", g_naServerActivePlayers[nServer], g_naServerMaxPlayers[nServer])
			}
		}
		else
		{
			if (nServer == g_nOwnServer)
			{
				new sMap[MAX_MAP_LEN]
				get_mapname(sMap, MAX_MAP_LEN - 1)
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n%L %s", sMenuBody, id, "MSG_SRVINFO_MAP", sMap)
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n%L %d/%d", sMenuBody, id, "MSG_SRVINFO_PLAYERS", get_current_players(), get_maxplayers())
			}
			else
			{
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n%L %s", sMenuBody, id, "MSG_SRVINFO_MAP", g_saServerMap[nServer])
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n%L %d/%d", sMenuBody, id, "MSG_SRVINFO_PLAYERS", g_naServerActivePlayers[nServer], g_naServerMaxPlayers[nServer])
			}
		}
	}
	
	// make the next line red if colors are supported and (the user is no admin or it's the current server)
	if ((bColorMenu) && ((!access(id, MIN_ADMIN_LEVEL)) || (nCanRedirect == 1)))
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\r", sMenuBody)
	else
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n", sMenuBody)
		
	// now display reason why we can't redirect there
	switch (nCanRedirectIgnoreAdmin)
	{
		case 1:
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s%L", sMenuBody, id, "MSG_SRVINFO_ERR_CURRENT")
		case 2:
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s%L", sMenuBody, id, "MSG_SRVINFO_ERR_PERMISSION")
		case 3:
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s%L", sMenuBody, id, "MSG_SRVINFO_ERR_NOMANUAL")
		case 4:
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s%L", sMenuBody, id, "MSG_SRVINFO_ERR_FULL")
		case 5:
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s%L", sMenuBody, id, "MSG_SRVINFO_ERR_DOWN")
		case 7:
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s%L", sMenuBody, id, "MSG_SRVINFO_ERR_PROT")
	}

	// enable/disable key for redirection/queue functionality
	new key = (1<<9)	// cancel
	key = key | (1<<8)	// back
	if ((nCheckMethod > 0) || (nServer == g_nOwnServer))
		key = key | (1<<2)	// refresh
	if (nCanRedirect == 0)
		key = key | (1<<0)	// redirect
	if (bCanQueue && (nCheckMethod > 1))
		key = key | (1<<1)	// enqueue
	
	new sQueueMsg[30]
	if (is_queued(id, nServer))
		sQueueMsg = "MSG_LEAVEQUEUE"
	else
		sQueueMsg = "MSG_QUEUE"
	
	// display the last menu items according to availability
	if (bColorMenu)
	{
		if (nCanRedirect == 0)
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n\y1. \w %L", sMenuBody, id, "MSG_REDIRECT")
		else
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n\y1. \d %L", sMenuBody, id, "MSG_REDIRECT")
		if (bCanQueue && (nCheckMethod > 1))
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y2. \w %L", sMenuBody, id, sQueueMsg)
		else
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y2. \d %L", sMenuBody, id, sQueueMsg)
		if ((nCheckMethod > 0) || (nServer == g_nOwnServer))
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y3. \w %L", sMenuBody, id, "MSG_REFRESH")
		else
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y3. \d %L", sMenuBody, id, "MSG_REFRESH")
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n\y9. \w %L", sMenuBody, id, "MSG_BACK")
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y0. \w %L", sMenuBody, id, "MSG_CANCEL")
	}
	else
	{
		if (nCanRedirect == 0)
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n1. %L", sMenuBody, id, "MSG_REDIRECT")
		else
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n_. %L", sMenuBody, id, "MSG_REDIRECT")
		if (bCanQueue && (nCheckMethod > 1))
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n2. %L", sMenuBody, id, sQueueMsg)
		else
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n_. %L", sMenuBody, id, sQueueMsg)
		if ((nCheckMethod > 0) || (nServer == g_nOwnServer))
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n3. %L", sMenuBody, id, "MSG_REFRESH")
		else
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n_. %L", sMenuBody, id, "MSG_REFRESH")
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n9. %L", sMenuBody, id, "MSG_BACK")
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n0. %L", sMenuBody, id, "MSG_CANCEL")
	}
	g_nLastSelected[id - 1] = nServer
	show_menu(id, key, sMenuBody, -1, "Detail Menu")
}

/// <summary>Shows a selection menu with all server categories.</summary>
/// <param name="id">The ID of the player to show the category menu to.</param>
/// <seealso name="server_menu_select"/>
/// <seealso name="sub_menu_select"/>
/// <seealso name="show_sub_menu"/>
/// <seealso name="show_server_menu"/>
public show_category_menu(id)
{
	new bool:bColorMenu = (colored_menus() && !MENU_FORCENOCOLOR)
	new sMenuBody[MAX_MENUBODY_LEN]
	new nCategorySetting = get_pcvar_num(cvar_categories)
	new key = (1<<9)	// cancel key is always enabled
	if (nCategorySetting == 2)
		key = key | (1<<0) //  enable key for the "all categories"
	
	if (bColorMenu)
	{
		formatex(sMenuBody, MAX_MENUBODY_LEN - 1, "\y%L^n", id, "MSG_SELECT_CATEGORY")
		if (nCategorySetting == 2)
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s\y1. \w%L^n", sMenuBody, id, "MSG_ALL_CATEGORIES")
	}
	else
	{
		formatex(sMenuBody, MAX_MENUBODY_LEN - 1, "%L^n", id, "MSG_SELECT_CATEGORY")
		if (nCategorySetting == 2)
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s1. %L^n", sMenuBody, id, "MSG_ALL_CATEGORIES")
	}
	
	for (new nCategoryIndex = 0; nCategoryIndex < g_nCategoryCount; nCategoryIndex++)
	{
		key = key | (1<<(nCategoryIndex + (nCategorySetting - 1)))
		if (bColorMenu)
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s\y%d. \w%s^n", sMenuBody, nCategoryIndex + nCategorySetting, g_saCategories[nCategoryIndex])
		else
			format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s%d. %s^n", sMenuBody, nCategoryIndex + nCategorySetting, g_saCategories[nCategoryIndex])
	}
	if (bColorMenu)
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y0.\w  %L", sMenuBody, id, "MSG_CANCEL")
	else
		format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n0.  %L", sMenuBody, id, "MSG_CANCEL")
	
	show_menu(id, key, sMenuBody, -1, "Category Menu")
}

/// <summary>Shows the server menu page <paramref name="menupage"/> to the the player with ID <paramref name="id"/>.</summary>
/// <param name="id">The ID of the player to show the server menu to.</param>
/// <param name="menupage">The menu page number to show to the player. Offset is 0.</param>
/// <param name="category">The category of servers to show. -1 or unspecified to show all servers regardless of their category.</param>
/// <seealso name="server_menu_select"/>
/// <seealso name="sub_menu_select"/>
/// <seealso name="show_sub_menu"/>
/// <seealso name="show_category_menu"/>
public show_server_menu(id, menupage, category)
{
	new nServerCount
	if (get_pcvar_num(cvar_active) == 1)
	{
		if (g_nServerCount > 0)
		{
			new bool:bSubMenu = (get_pcvar_num(cvar_manual) >= 2)
			new bool:bColorMenu = (colored_menus() && !MENU_FORCENOCOLOR)
			new bool:bShowServer
			new nCheckMethod = get_pcvar_num(cvar_check_method)
			new sMenuBody[MAX_MENUBODY_LEN]
			if (bColorMenu)
				formatex(sMenuBody, MAX_MENUBODY_LEN - 1, "^n\y%L", id, "MSG_SELECT_SERVER")
			else
				formatex(sMenuBody, MAX_MENUBODY_LEN - 1, "^n%L", id, "MSG_SELECT_SERVER")
			
			
			if (menupage <= 1)
				nServerCount = 0
			else
				nServerCount = g_naMenuPageStart[id - 1][menupage - 2]
			
			new nDisplayNumber = 1
			
			new key = (1<<9)	// cancel key is always enabled
			
			new nHideDown = get_pcvar_num(cvar_hidedown)
			if (nHideDown == 1)
				nHideDown = 3
			
			// the 3 parts of a menu item, third part only displayed with redirect_check_method >= 2
			new sMenuNumber[10]
			new sMenuSrvName[50]
			new sMenuInfo[50]
			if (nCheckMethod < 2)
				sMenuInfo = ""
			
			while ((nDisplayNumber < 8) && (nServerCount < g_nServerCount))
			{
				// don't show the server if it's not the own server, the server is not responding and hidedown is set to a value > 2
				bShowServer = (!((nHideDown > 2) && (!g_baServerResponding[nServerCount]) && (nServerCount != g_nOwnServer)))
				// don't show the server if it has the SERVERFLAG_NODISPLAY flag set
				if (bShowServer)
					bShowServer = (!(g_naServerFlags[nServerCount] & (1<<SERVERFLAG_NODISPLAY)))
				// don't show the server if it has the SERVERFLAG_PRIVATE flag set and user is no admin
				if (bShowServer && (!access(id, MIN_ADMIN_LEVEL)) && (g_naServerPrivate[nServerCount] >= PRIVATE_HIDE))
					bShowServer = false
				// don't show the server if categories are enabled and this server doesn't belong to the currently selected category
				if (bShowServer && (category >= 0))
					bShowServer = (category == g_naServerCategory[nServerCount])
				
				if (bShowServer)
				{
					new bool:bCanRedirectByPassword = !(!equal(g_saServerPasswords[nServerCount], "") && (g_naServerPublicPassword[nServerCount] == 0) && (!access(id, MIN_ADMIN_LEVEL)))
			
					if (bColorMenu)
					{
						formatex(sMenuNumber, 9, "\y%d. ", nDisplayNumber)
						if (bSubMenu)
							formatex(sMenuSrvName, 49, "\w %s", g_saServerNames[nServerCount])
						else
							formatex(sMenuSrvName, 49, "\d %s", g_saServerNames[nServerCount])
					}
					else
					{
						formatex(sMenuNumber, 9, "%d. ", nDisplayNumber)
						formatex(sMenuSrvName, 49, " %s", g_saServerNames[nServerCount])
					}
						
					new bool:bCanRedirect = true
					sMenuInfo = ""
					
					// manual redirection to that server is disabled or server is passworded but password is not public and user has insufficent admin rights
					if ((nCheckMethod == 2) && (((g_naServerFlags[nServerCount] & (1<<SERVERFLAG_NOMANUAL)) || !bCanRedirectByPassword)))
					{
						bCanRedirect = false
						if ((!bColorMenu) && (!bSubMenu))
							sMenuNumber = "_. "
						if (nCheckMethod == 2)
						{
							if (bColorMenu)
								formatex(sMenuInfo, 49, " \y[\w%s\y] \y(\w%d/%d\y)", g_saServerMap[nServerCount], g_naServerActivePlayers[nServerCount], g_naServerMaxPlayers[nServerCount])
							else
								formatex(sMenuInfo, 49, " [%s] (%d/%d)", g_saServerMap[nServerCount], g_naServerActivePlayers[nServerCount], g_naServerMaxPlayers[nServerCount])
						}
					}
					new nFreeSlotsAdmin = (g_naServerMaxPlayers[nServerCount] - g_naServerActivePlayers[nServerCount])
					new nFreeSlots = nFreeSlotsAdmin - g_naServerReserveSlots[nServerCount] // normal players can't use the admin slots, so subtract them
					// server is full? (and player has insufficient rights to join on an admin slot/not enough admin slots?)
					if ((nCheckMethod == 2) && ((nFreeSlots <= 0) && (!access(id, MIN_ADMIN_LEVEL)) || nFreeSlotsAdmin <= 0))
					{
						bCanRedirect = false
						if ((!bColorMenu) && (!bSubMenu))
							sMenuNumber = "_. "
						if (bColorMenu)
							formatex(sMenuInfo, 49, " [%s] \r(\w%d/%d\r)", g_saServerMap[nServerCount], g_naServerActivePlayers[nServerCount], g_naServerMaxPlayers[nServerCount])
						else
							formatex(sMenuInfo, 49, " [%s] (%d/%d)", g_saServerMap[nServerCount], g_naServerActivePlayers[nServerCount], g_naServerMaxPlayers[nServerCount])
					}
					// server is down
					if ((nCheckMethod > 0) && (!g_baServerResponding[nServerCount]))
					{
						if ((!bColorMenu) && (!bSubMenu))
							sMenuNumber = "_. "
						bCanRedirect = false
						if (bColorMenu)
							sMenuInfo = " \r(\wdown\r)"
						else
							sMenuInfo = " (down)"
					}
					// server is current server
					if (nServerCount == g_nOwnServer)
					{
						if ((!bColorMenu) && (!bSubMenu))
							sMenuNumber = "_. "
						bCanRedirect = false
						new sMap[MAX_MAP_LEN]
						get_mapname(sMap, MAX_MAP_LEN - 1)
						if (bSubMenu && bColorMenu)
							formatex(sMenuInfo, 49, " \y[\w%s\y] \y(\w%d/%d\y)", sMap, get_current_players(), get_maxplayers())
						else	
							formatex(sMenuInfo, 49, " [%s] (%d/%d)", sMap, get_current_players(), get_maxplayers())
					}
					
					// everything's fine, we can redirect here
					if (bCanRedirect)
					{
						if (bColorMenu)
						{
							formatex(sMenuSrvName, 49, "\w %s", g_saServerNames[nServerCount])
							if (nCheckMethod > 1)
								formatex(sMenuInfo, 49, " \y[\w%s\y] \y(\w%d/%d\y)", g_saServerMap[nServerCount], g_naServerActivePlayers[nServerCount], g_naServerMaxPlayers[nServerCount])
						}
						else
						{
							if (nCheckMethod > 1)
								formatex(sMenuInfo, 49, " [%s] (%d/%d)", g_saServerMap[nServerCount], g_naServerActivePlayers[nServerCount], g_naServerMaxPlayers[nServerCount])
						}
						
						key = key | (1<<(nDisplayNumber - 1))
						g_naServerSelections[id - 1][nDisplayNumber - 1] = nServerCount
					}
					else if ((bSubMenu) && (nServerCount != g_nOwnServer))	// display server like it was enabled when submenues are enabled
						if (bColorMenu)
						{
							formatex(sMenuSrvName, 49, "\w %s", g_saServerNames[nServerCount])
							if ((nCheckMethod == 0) && (g_baServerResponding[nServerCount]))
								formatex(sMenuInfo, 49, " \y[\w%s\y] \y(\w%d/%d\y)", g_saServerMap[nServerCount], g_naServerActivePlayers[nServerCount], g_naServerMaxPlayers[nServerCount])
						}

					// assemble the menu item and append it to menu body
					format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n%s%s%s", sMenuBody, sMenuNumber, sMenuSrvName, sMenuInfo)
					
					// if enabled a submenu is always possible to be displayed, regardless of the server's redirection status
					if (bSubMenu)
					{
						key = key | (1<<(nDisplayNumber - 1))
						g_naServerSelections[id - 1][nDisplayNumber - 1] = nServerCount
					}
					
					nDisplayNumber++
				}
				nServerCount++
			}
			
			if (nServerCount < g_nServerCount)
			{
				if (bColorMenu)
					format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n\y9.\w  %L", sMenuBody, id, "MSG_MORE")
				else
					format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n9.  %L", sMenuBody, id, "MSG_MORE")
				key = key | (1<<8)
			}
			else
			{
				if (bColorMenu)
					format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n\y9.\d  %L", sMenuBody, id, "MSG_MORE")
				else
					format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n^n_.  %L", sMenuBody, id, "MSG_MORE")
			}
			
			#if CANCEL_IS_BACK_KEY
			if (bColorMenu)
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y0.\w  %L", sMenuBody, id, (get_pcvar_num(cvar_categories) >= 1) ? "MSG_BACK" : "MSG_CANCEL")
			else
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n0.  %L", sMenuBody, id, (get_pcvar_num(cvar_categories) >= 1) ? "MSG_BACK" : "MSG_CANCEL")
			#else
			if (bColorMenu)
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n\y0.\w  %L", sMenuBody, id, "MSG_CANCEL")
			else
				format(sMenuBody, MAX_MENUBODY_LEN - 1, "%s^n0.  %L", sMenuBody, id, "MSG_CANCEL")
			#endif

			show_menu(id, key, sMenuBody, -1, "Redirect Menu")
		}
	}
	g_naMenuPageStart[id - 1][menupage - 1] = nServerCount
	
	g_naLastMenuPages[id - 1] = menupage
}


/// <summary>Reloads the servers from server list. Takes care of variable and array reinitialization.</summary>
/// <remarks>To be able to rely on this in the future make sure to add an initialization here for all variables you add!</remarks>
public srvcmd_reload()
{
	new nCounter
	
	// clear all global arrays and variables before reloading
	for (nCounter = 0; nCounter < MAX_SERVERFORWARDS; nCounter++)
	{
		if (g_naServerSockets[nCounter] > 0)
		{
			socket_close(g_naServerSockets[nCounter])
			g_naServerSockets[nCounter] = 0
		}
		g_naServerIds[nCounter] = -1
		g_naServerPorts[nCounter] = 27015
		g_naServerActivePlayers[nCounter] = -1
		g_naServerMaxPlayers[nCounter] = -1
		g_naServerCmdBackup[nCounter] = DEFAULT_CMDBACKUP
		g_naServerFlags[nCounter] = 0
		g_naServerReserveSlots[nCounter] = 0
		g_baServerResponding[nCounter] = false
		g_saServerMap[nCounter] = ""
		g_saServerNames[nCounter] = ""
		g_saServerAddresses[nCounter] = ""
		g_saServerPasswords[nCounter] = ""
		g_naServerPublicPassword[nCounter] = 0
		g_naServerCategory[nCounter] = -1
		g_naServerPrivate[nCounter] = PRIVATE_NONE
		
		// don't reset these for the own server, as they are only queried once at plugin_postinit()
		if (nCounter != g_nOwnServer)
		{
			g_saServerMod[nCounter] = ""
			g_naServerProtocol[nCounter] = 0
		}
	}
	
	// reset global variables
	g_nNextAnnounceServer = 0
	g_nServerCount = 0
	g_nCategoryCount = 0
	g_nLastRedirectServer = -1
	g_sLastRedirectName = ""
	g_nOwnServer = -1
	g_nRetryCount = 0
	
	for (new nPlrCnt = 0; nPlrCnt < MAX_PLAYERS; nPlrCnt++)
	{
		// server IDs might change and thus render all currently saved server IDs invalid, so remove them, to be sure
		g_nRetryQueue[nPlrCnt][0] = -1
		g_nRetryQueue[nPlrCnt][1] = -1
		g_nLastServer[nPlrCnt] = -1
		g_nLastSelected[nPlrCnt] = -1
	}
	
	#if defined SQL
	load_servers_sql()
	#else
	load_servers_file()
	#endif // SQL

	if (g_nServerCount < 2)
		log_amx("%L", LANG_SERVER, "MSG_ERROR_NOT_ENOUGH_SERVERS")
	
	new sFullAddress[MAX_SERVERADDRESS_LEN]
	new sTmpServerIP[MAX_IP_LEN]
	new sTmpServerPort[MAX_PORT_LEN]
	new sTmpServerAddress[MAX_IP_LEN + MAX_PORT_LEN], sTmpServerAddress2[MAX_IP_LEN + MAX_PORT_LEN]
	new sTmpOwnAddress[MAX_SERVERADDRESS_LEN]
	get_cvar_string("net_address", sTmpServerAddress, MAX_IP_LEN + MAX_PORT_LEN - 1)
	get_cvar_string("ip", sTmpServerIP, MAX_IP_LEN - 1)
	get_cvar_string("port", sTmpServerPort, MAX_PORT_LEN - 1)
	formatex(sTmpServerAddress, MAX_IP_LEN + MAX_PORT_LEN - 1, "%s:%s", sTmpServerIP, sTmpServerPort)
	get_pcvar_string(cvar_external_address, sTmpOwnAddress, MAX_SERVERADDRESS_LEN - 1)

	
	// determine the own server
	new nServerCount = 0
	while (nServerCount < g_nServerCount)
	{
		formatex(sFullAddress, MAX_SERVERADDRESS_LEN - 1, "%s:%d", g_saServerAddresses[nServerCount], g_naServerPorts[nServerCount])
		if (equal(sFullAddress, sTmpOwnAddress) || equal(sFullAddress, sTmpServerAddress) || equal(sFullAddress, sTmpServerAddress2))
		{
			g_nOwnServer = nServerCount
			if (g_bUseIds)
				g_nOwnServerId = g_naServerIds[nServerCount]
			else
				g_nOwnServerId = nServerCount
		}
		if (g_bUseIds && (g_naServerIds[nServerCount] == -1))
			log_amx("%L", LANG_SERVER, "MSG_ID_MISSING", g_saServerNames[nServerCount])
		nServerCount++
	}
	if (g_nOwnServer == -1)
		log_amx("%L", LANG_SERVER, "MSG_OWN_DETECTION_ERROR")
	
	// we need to know our own server index to be able to load attributes from SQL - so now we can do that
	#if defined SQL
	load_attributes_sql()
	#endif // SQL
	
	// query all servers again
	nServerCount = g_nOwnServer
	g_nOwnServer = -1 // make sure the own server is queried too (for its protocol), maybe someone just corrected its address
	query_servers()
	g_nOwnServer = nServerCount
}


/// <summary>This is needed so server doesn't display "unknown command: pickserver". Returning PLUGIN_HANDLED directly in cmd_show_server_menu would supress the chat message so we use this workaround.</summary>
public cmd_pickserver(id, level, cid)
{
	cmd_show_server_menu(id, level, cid)
	return PLUGIN_HANDLED
}

/// <summary>This function does the actual redirection. It is also what <seealso name="native_redirect"/> is a wrapper for with <paramref name="nServer"/> preset to -1 (the external plugin does not know about our server list and numbers anyway) and <paramref name="bIgnoreSource"/> preset to true (an external plugin does not care whether this would mean redirecting the player back to where he came from).</summary>
/// <summary>It is aware of user permissions and has several options which are set via parameters.</summary>
/// <param name="id">ID of player to redirect.</param>
/// <param name="nServer">Target server, -1 for automatic choosing according to redirect_auto.</param>
/// <param name="bCanOther">If nServer is no valid redirect target can we use another server instead?</param>
/// <param name="bCanDrop">Drop user if no server was found?</param>
/// <param name="bIgnoreSource>"Redirect regardless of redirecting would be back to source server.</param>
/// <seealso name="native_redirect"/>
/// <seealso name="cmd_redirect_user"/>
public redirect(id, nServer, bCanOther, bCanDrop, bIgnoreSource)
{
	new nForwardServer = -1
	new bool:bFoundServer = false
	new nRedirType
	if (nServer == -1)
		nRedirType = 1
	else
		nRedirType = 2
	
	new nSourceServer
	
	if (bIgnoreSource)
	{
		nSourceServer = -1
	}
	else
	{
		//TODO: actually we got that information in g_nLastServer[] already, unfortunately in some cases this is set AFTER redirect() is called -> find a solution
		new sSourceServer[4] // maximum is 999 servers, so we have a maximum of 3 digits
		get_user_info(id, "xredir", sSourceServer, 3) 
		if (!is_str_num(sSourceServer))
			nSourceServer = -1
		else
			nSourceServer = str_to_num(sSourceServer)
		if ((nSourceServer < 0) || (nSourceServer >= g_nServerCount))
			nSourceServer = -1
		if (g_bUseIds && (nSourceServer != -1))
			nSourceServer = g_naServerIds[nSourceServer]
	}
	
	if ((can_redirect_player(nServer, id, nRedirType, false) > 0) || (nServer == -1))
	{
		if (!bCanOther)
		{
			if (bCanDrop)
			{
				client_cmd(id, "echo %s: %L", PLUGIN_TAG, id, "MSG_NO_REDIRECT_SERVER")
				client_cmd(id, "disconnect")
				#if defined STATISTICS
					stats_redirect(STATS_INFO_REDIRECT, id, STATS_REDIRTYPE_DROP, -1)
				#endif // STATISTICS
			}
			return false
		}
		
		nForwardServer = 0
		
		// make sure at least one valid server exists or the second loop could be endless
		while (nForwardServer < g_nServerCount)
		{
			if ((can_redirect_player(nForwardServer, id, nRedirType, false) == 0) && (nForwardServer != nSourceServer))
			{
				bFoundServer = true
				break
			}
			nForwardServer++
		}
		new nAutoMode = get_pcvar_num(cvar_auto)
		if ((nAutoMode == 1) || (nAutoMode == 3) || (nAutoMode == 5)) // redirect to random server
			nForwardServer = -1
	}
	else
	{
		nForwardServer = nServer
		bFoundServer = true
	}
	
	if (bFoundServer)
	{
		while (nForwardServer == -1)
		{
			nForwardServer = random_num(0, g_nServerCount - 1)
			if ((can_redirect_player(nForwardServer, id, nRedirType, true) > 0) || ((nForwardServer == nSourceServer)))
				nForwardServer = -1
		}

		new sUserNick[MAX_NAME_LEN]
		get_user_name(id, sUserNick, MAX_NAME_LEN - 1)
		if (!equal(g_saServerPasswords[nForwardServer], ""))		// set the user's server connect password if needed
			client_cmd(id, "setinfo ^"password^" ^"%s^"", g_saServerPasswords[nForwardServer])
		if (g_bUseIds)
 			client_cmd(id, "setinfo ^"xredir^" ^"%d^"", g_nOwnServerId)
		else
			client_cmd(id, "setinfo ^"xredir^" ^"%d^"", g_nOwnServer)

		new sCheckAddress[MAX_IP_LEN]
		get_user_ip(id, sCheckAddress, MAX_IP_LEN - 1, 1)
		new sFullAddress[MAX_SERVERADDRESS_LEN]
		if (is_local_address(sCheckAddress) && (!equal(g_saServerLocalAddresses[nForwardServer], "")))
			formatex(sFullAddress, MAX_SERVERADDRESS_LEN - 1, "%s:%d", g_saServerLocalAddresses[nForwardServer], g_naServerPorts[nForwardServer])
		else
			formatex(sFullAddress, MAX_SERVERADDRESS_LEN - 1, "%s:%d", g_saServerAddresses[nForwardServer], g_naServerPorts[nForwardServer])
		if (nRedirType == 1)
			client_cmd(id, "echo %s: %L", PLUGIN_TAG, id, "MSG_SERVER_FULL_REDIRECTING", g_saServerNames[nForwardServer])
		
		client_cmd(id, "Connect %s", sFullAddress)
		#if defined STATISTICS
			if (nServer == -1) // is this an automatic redirection (because the target server is random)?
				stats_redirect(STATS_INFO_REDIRECT, id, STATS_REDIRTYPE_AUTO, nForwardServer)
		#endif // STATISTICS
		

		if (g_naServerPrivate[nForwardServer] < PRIVATE_FULLHIDE) // dont' announce anything if this server is set to fullhide, also don't save it as the last target for /follow
		{
			if (get_pcvar_num(cvar_show) == 1)
			{
				if (get_pcvar_num(cvar_check_method) == 2)
					client_print(0, print_chat, "%s: %L [%s] (%d/%d)", PLUGIN_TAG, LANG_PLAYER, "MSG_REDIRECTED", sUserNick, g_saServerNames[nForwardServer], g_saServerMap[nForwardServer], g_naServerActivePlayers[nForwardServer], g_naServerMaxPlayers[nForwardServer])
				else
					client_print(0, print_chat, "%s: %L", PLUGIN_TAG, LANG_PLAYER, "MSG_REDIRECTED", sUserNick, g_saServerNames[nForwardServer])
				if (get_pcvar_num(cvar_follow) == 1)
					client_print(0, print_chat, "%s: %L", PLUGIN_TAG, LANG_PLAYER, "MSG_FOLLOW")
			}
			g_nLastRedirectServer = nForwardServer
			g_sLastRedirectName = sUserNick
		}
	}
	else if (bCanDrop)
	{
		client_cmd(id, "echo %s: %L", PLUGIN_TAG, id, "MSG_NO_REDIRECT_SERVER")
		client_cmd(id, "disconnect")
		#if defined STATISTICS
			stats_redirect(STATS_INFO_REDIRECT, id, STATS_REDIRTYPE_DROP, -1)
		#endif // STATISTICS
	}
	return true
}

/// <summary>Basically a wrapper for <seealso name="redirect"/> to make it available to other pugins as native.</summary>
/// <seealso name="redirect"/>
/// <seealso name="cmd_redirect_user"/>
public native_redirect(id, nServer, bCanDrop)
{
	redirect(id, nServer, (nServer == -1), bCanDrop, true)
	return PLUGIN_HANDLED
}

/// <summary>Show the list of players in current queue.</summary>
public cmd_redirect_queue(id, level, cid)
{
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	
	new nSlot
	
	for (new nServer = 0; nServer < g_nServerCount; nServer++)
	{
		nSlot = 1
		client_cmd(id, "echo %s: %s:", PLUGIN_TAG, g_saServerNames[nServer])
		for (new nQueueIndex = 0; nQueueIndex < g_nRetryCount; nQueueIndex++)
		{
			if (g_nRetryQueue[nQueueIndex][1] == nServer)
			{
				new sUserNick[MAX_NAME_LEN]
				get_user_name(g_nRetryQueue[nQueueIndex][0], sUserNick, MAX_NAME_LEN - 1)
				client_cmd(id, "echo %s: %d. %s", PLUGIN_TAG, nSlot++, sUserNick)
			}
		}
	}
	return PLUGIN_HANDLED
}

/// <summary>Handler for in-game command <paramref name="redirect_user"/>, checks user permissions for this command and uses <seealso name="redirect"/> to do the redirection.</summary>
/// <seealso name="redirect"/>
/// <seealso name="native_redirect"/>
public cmd_redirect_user(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new nForwardServer = -1
	new sName[32]
	read_argv(1, sName, 31)
	new nCmdID = cmd_target(id, sName, 8)

	if (!nCmdID)
		return PLUGIN_HANDLED
	
	// contains destination server number?
	if (read_argc() > 2)
	{
		new argtmp[3]
		read_argv(2, argtmp, 2)
		if (is_str_num(argtmp))
			nForwardServer = (str_to_num(argtmp) - 1)
	}

	redirect(nCmdID, nForwardServer, (nForwardServer == -1), true, true)
	#if defined STATISTICS
		stats_redirect(STATS_INFO_REDIRECT, nCmdID, STATS_REDIRTYPE_ADMIN, nForwardServer)
	#endif // STATISTICS

	return PLUGIN_HANDLED
}

/// <summary>Handler for in-game command <paramref name="pickserver"/> or chat command <paramref name="/server"/>. Shows the server menu to the player using <seealso name="show_server_menu"/>.</summary>
/// <seealso name="show_server_menu"/>
public cmd_show_server_menu(id, level, cid)
{
	if (get_pcvar_num(cvar_manual) >= 1)
	{
		#if defined VAULT
		stats_count(STATS_COUNT_MENU, -1)
		#endif // VAULT
		if (get_pcvar_num(cvar_categories) >= 1)
			show_category_menu(id)
		else
			show_server_menu(id, 1, -1)
	}
	else
		client_print(id, print_chat, "%s: %L", PLUGIN_TAG, id, "MSG_MANUAL_DISABLED")
	return PLUGIN_CONTINUE
}

/// <summary>Handler for chat command <paramref name="/retry"/>. Adds the user to the retry queue using <seealso name="queue_add"/>.</summary>
/// <seealso name="queue_add"/>
public cmd_retry(id, level, cid)
{
	if (g_nLastServer[id - 1] > -1)
	{
		#if defined STATISTICS
			stats_redirect(STATS_INFO_RETRY, id, -1, g_nLastServer[id - 1])
		#endif // STATISTICS
		queue_add(id, g_nLastServer[id - 1])
	}
	else
		client_print(id, print_chat, "%s: %L", PLUGIN_TAG, id, "MSG_QUEUE_NO_LAST")
	return PLUGIN_CONTINUE
}

/// <summary>Handler for chat command <paramref name="/stopretry"/>. Removes the user from the retry queue using <seealso name="queue_remove"/>.</summary>
/// <seealso name="queue_remove"/>
public cmd_stopretry(id, level, cid)
{
	client_print(id, print_chat, "%s: %L", PLUGIN_TAG, id, "MSG_QUEUE_REMOVE_ALL", g_saServerNames[g_nLastServer[id - 1]])
	queue_remove(id, -1)
	return PLUGIN_CONTINUE
}

/// <summary>Handler for chat command <paramref name="/follow"/>. Sends a player after the last player that was redirected using <seealso name="redirect"/>.</summary>
/// <seealso name="redirect"/>
public cmd_follow_player(id, level, cid)
{
	if (get_pcvar_num(cvar_active) == 1)
	{
		if (get_pcvar_num(cvar_follow) == 1)
		{
			if (g_nLastRedirectServer >= 0)
			{
				console_print(id, "%s: %L", PLUGIN_TAG, id, "MSG_REDIRECTING", g_saServerNames[g_nLastRedirectServer])
				new sFullAddress[MAX_SERVERADDRESS_LEN]
				new sCheckAddress[MAX_IP_LEN]
				get_user_ip(id, sCheckAddress, MAX_IP_LEN - 1, 1)
				if (is_local_address(sCheckAddress) && (!equal(g_saServerLocalAddresses[g_nLastRedirectServer], "")))
					formatex(sFullAddress, MAX_SERVERADDRESS_LEN - 1, "%s:%d", g_saServerLocalAddresses[g_nLastRedirectServer], g_naServerPorts[g_nLastRedirectServer])
				else
					formatex(sFullAddress, MAX_SERVERADDRESS_LEN - 1, "%s:%d", g_saServerAddresses[g_nLastRedirectServer], g_naServerPorts[g_nLastRedirectServer])
				client_cmd(id, "Connect %s", sFullAddress)
				#if defined STATISTICS
					stats_redirect(STATS_INFO_REDIRECT, id, STATS_REDIRTYPE_FOLLOW, g_nLastRedirectServer)
				#endif // STATISTICS
				new sUserNick[MAX_NAME_LEN]
				get_user_name(id, sUserNick, MAX_NAME_LEN - 1)
				if (get_pcvar_num(cvar_show) == 1)
				{
					if (get_pcvar_num(cvar_check_method) == 2)
						client_print(0, print_chat, "%s: %L [%s] (%d/%d)", PLUGIN_TAG, LANG_PLAYER, "MSG_FOLLOWED", sUserNick, g_sLastRedirectName, g_saServerNames[g_nLastRedirectServer], g_saServerMap[g_nLastRedirectServer], g_naServerActivePlayers[g_nLastRedirectServer], g_naServerMaxPlayers[g_nLastRedirectServer])
					else
						client_print(0, print_chat, "%s: %L", PLUGIN_TAG, LANG_PLAYER, "MSG_FOLLOWED", sUserNick, g_sLastRedirectName, g_saServerNames[g_nLastRedirectServer])
					client_print(0, print_chat, "%s: %L", PLUGIN_TAG, LANG_PLAYER, "MSG_FOLLOW")
				}
				g_sLastRedirectName = sUserNick
			}
			else
				client_print(id, print_chat, "%s: %L", PLUGIN_TAG, id, "MSG_CANT_FOLLOW")

		}
		else
			client_print(id, print_chat, "%s: %L", PLUGIN_TAG, id, "MSG_FOLLOW_DISABLED")
	}
	return PLUGIN_CONTINUE
}

/// <summary>Event handler for category menu selection.</summary>
/// <param name="id">Slot ID of player that selected a menu item.</param>
/// <param name="key">Key that was pressed, number between 0 and 9.</param>
/// <seealso name="server_menu_select"/>
/// <seealso name="show_category_menu"/>
/// <seealso name="show_server_menu"/>
/// <seealso name="show_sub_menu"/>
public category_menu_select(id, key)
{
	if (key < 9)
	{
		new nCategorySetting = get_pcvar_num(cvar_categories)
		new nSelectedCategory = key - (nCategorySetting - 1)
		g_naLastCategory[id - 1] = nSelectedCategory
		show_server_menu(id, 1, nSelectedCategory)
	}
	else
		g_naLastCategory[id - 1] = -1
}

/// <summary>Event handler for sub menu selection.</summary>
/// <summary>When the user presses a number key in the sub menu this handler is called.</summary>
/// <param name="id">Slot ID of player that selected a menu item.</param>
/// <param name="key">Key that was pressed, number between 0 and 9.</param>
/// <seealso name="server_menu_select"/>
/// <seealso name="show_server_menu"/>
/// <seealso name="show_sub_menu"/>
public sub_menu_select(id, key)
{
	new nServer = g_nLastSelected[id - 1]
	if (key == 0)		// redirect
	{
		// check if meanwhile the redirection is not possible anymore - if so, refresh the detail menu
		if (can_redirect_player(nServer, id, 2, false) > 0)
			show_sub_menu(id, nServer)
		else
		{
			redirect(id, nServer, false, false, true)
			#if defined STATISTICS
				stats_redirect(STATS_INFO_REDIRECT, id, STATS_REDIRTYPE_MANUAL, nServer)
			#endif // STATISTICS
		}
	}
	else if (key == 1)	// queue
	{
		if (is_queued(id, nServer))
		{
			queue_remove(id, nServer)
			#if defined STATISTICS
				stats_redirect(STATS_INFO_DEQUEUE, id, -1, nServer)
			#endif // STATISTICS
			client_print(id, print_chat, "%s: %L", PLUGIN_TAG, id, "MSG_QUEUE_REMOVE", g_saServerNames[nServer])
		}
		else
		{
			queue_add(id, nServer)
		}
	}
	else if (key == 2)	// refresh
	{
		show_sub_menu(id, nServer)
	}
	else if (key == 8)	// go back to where the user was before in main menu
		show_server_menu(id, g_naLastMenuPages[id - 1], g_naLastCategory[id - 1])
}

/// <summary>Event handler for server menu selection.</summary>
/// <summary>When the user presses a number key in the server menu this handler is called.</summary>
/// <summary>Depending on settings it will display a sub menu or redirect the user.</summary>
/// <param name="id">Slot ID of player that selected a menu item.</param>
/// <param name="key">Key that was pressed, number between 0 and 9.</param>
/// <seealso name="sub_menu_select"/>
/// <seealso name="show_server_menu"/>
/// <seealso name="show_sub_menu"/>
public server_menu_select(id, key)
{
	if (key < 8)
	{
		new nServerIdx = g_naServerSelections[id - 1][key]
		
		new nManualMode = get_pcvar_num(cvar_manual)
		// show the detail menu?
		if (((nManualMode == 2) && (can_redirect_player(nServerIdx, id, 2, false) > 0)) || (nManualMode == 3))
			show_sub_menu(id, nServerIdx)
		else
		{
			redirect(id, nServerIdx, false, false, true)
			#if defined STATISTICS
				stats_redirect(STATS_INFO_REDIRECT, id, STATS_REDIRTYPE_MANUAL, nServerIdx)
			#endif // STATISTICS
		}
	}
	else
	{
		if (key == 8) // "more" button
			show_server_menu(id, g_naLastMenuPages[id - 1] + 1, g_naLastCategory[id - 1])
		#if CANCEL_IS_BACK_KEY
		if ((get_pcvar_num(cvar_categories) >= 1) && (key == 9))
			show_category_menu(id)
		#endif
	}
}


/// <summary>Sends the information query packets to all other servers.</summary>
/// <summary>This sends the UDP server information query packets in old and new style HL format to all servers in the list.</summary>
/// <summary>Receiving of server data is handled by <seealso name="receive_serverquery_answers"/>.</summary>
/// <seealso name="receive_serverquery_answers"/>
public query_servers()
{
	new nCheckMethod = get_pcvar_num(cvar_check_method)
	if (nCheckMethod == 0)
		return PLUGIN_HANDLED
	new socket_error
	new sOldRequest[12]
	new sNewRequest[26]

	if (nCheckMethod == 1)
	{
		// we don't know what server it is so send both old and new style query
		formatex(sOldRequest, 8, "%c%c%c%c%s", 255, 255, 255, 255, "ping")
		formatex(sNewRequest, 5, "%c%c%c%c%c", 255, 255, 255, 255, 105)
	}
	else if (nCheckMethod == 2)
	{
		// we don't know what server it is so send both old and new style query
		formatex(sOldRequest, 11, "%c%c%c%c%s", 255, 255, 255, 255, "details")
		formatex(sNewRequest, 25, "%c%c%c%c%c%s%c", 255, 255, 255, 255, 84, "Source Engine Query", 0)
	}

	new nServerCount = 0
	new nQuerySocket
	new nCmdBackup
	new nSendCount
	while (nServerCount < g_nServerCount)
	{
		if (nServerCount != g_nOwnServer)
		{
			nQuerySocket = g_naServerSockets[nServerCount]
			// first we clear the current receive buffer - we are sending a new request and don't care for old data anymore
			if (nQuerySocket > 0)
			{
				new sEmptyBufferDummy[512]
				new nEndlessProtection = 0
				while ((socket_change(nQuerySocket, 1)) && (nEndlessProtection < 500))
				{
					//log_amx("emptying socket %i (%s)", nQuerySocket, g_saServerNames[nServerCount])
					socket_recv(nQuerySocket, sEmptyBufferDummy, 512)
					nEndlessProtection++
				}
				if (nEndlessProtection >= 500)
				{
					socket_close(nQuerySocket)
					log_amx("WARNING: endless protection triggered for socket %i (%s)", nQuerySocket, g_saServerNames[nServerCount])
				}
				
			}
			else
			{
				// socket debug
				//log_amx("opening socket for server %i (%s)", nServerCount, g_saServerNames[nServerCount])
				if (!equal(g_saServerLocalAddresses[nServerCount], ""))
					nQuerySocket = socket_open(g_saServerLocalAddresses[nServerCount], g_naServerPorts[nServerCount], SOCKET_UDP, socket_error)
				else
					nQuerySocket = socket_open(g_saServerAddresses[nServerCount], g_naServerPorts[nServerCount], SOCKET_UDP, socket_error)
				// socket debug
				//log_amx("opened socket %i for server %i (%s)", nQuerySocket, nServerCount, g_saServerNames[nServerCount])
			}
			
			if ((nQuerySocket > 0) && (socket_error == 0))
			{
				g_naServerSockets[nServerCount] = nQuerySocket
				nCmdBackup = g_naServerCmdBackup[nServerCount]
				// socket debug
				//log_amx("sending query on socket %i for server %i (%s)", nQuerySocket, nServerCount, g_saServerNames[nServerCount])
				if (nCheckMethod == 1)
				{
					for (nSendCount = -1; nSendCount < nCmdBackup; nSendCount++)
						socket_send2(nQuerySocket, sOldRequest, 8)
					for (nSendCount = -1; nSendCount < nCmdBackup; nSendCount++)
						socket_send2(nQuerySocket, sNewRequest, 5)
				}
				else if (nCheckMethod == 2)
				{
					for (nSendCount = -1; nSendCount < nCmdBackup; nSendCount++)
						socket_send2(nQuerySocket, sOldRequest, 11)
					for (nSendCount = -1; nSendCount < nCmdBackup; nSendCount++)
						socket_send2(nQuerySocket, sNewRequest, 25)
				}
			}
			else
			{
				g_naServerSockets[nServerCount] = 0
				log_amx("%L", LANG_SERVER, "MSG_SOCKET_ERROR", socket_error, nServerCount)
			}
		}
		nServerCount++
	}
	set_task(QUERY_TIMEOUT, "receive_serverquery_answers", TASKID_QUERY_RECEIVE)
	
	return PLUGIN_HANDLED
}


/// <summary>Index an incoming UDP data packet.</summary>
/// <param name="sData">The raw UDP data string that was received.</param>
/// <param name="nDataLen">Length of the raw UDP data string as reported by the socket receive function.</param>
/// <param name="sFormatString">The string containing the format. It can contain the elements 124 and s. A digit just declares the number of bytes the element (type) has, "s" declares a string. An opening square bracket declares a byte option followed by a sequence of sub options. The sequence ends with a closing square bracket. Such options can occur more than once but may not be nested.</param>
/// <param name="aIndexes">The function stores the resulting character offsets of each index in this array.</param>
/// <remarks>This function assumes the given format string is correct as it is only created internally by a programmer, so there is no error checking whatsoever (e.g. an unsupported format character would lead the function into an endless loop).</remarks>
/// <returns>The number of indexes that were written (= the number of format elements).</returns>
public index_create(sData[MAX_INFO_LEN], nDataLen, sFormatString[100], aIndexes[MAX_INFO_FORMAT])
{
	//log_amx("---------------------- indexing %s ----------------------", sFormatString)
	new nFormatPos = 0 // current position within the format array
	new nIndexPos = 0 // current position within the data array
	new nDataIndex = 0 // current chracter index within the data stream
	new nFormatPosMax = strlen(sFormatString)
	while ((nIndexPos < nFormatPosMax) && (nDataIndex <= nDataLen))
	{
		switch (sFormatString[nFormatPos])
		{
			case '1': // "byte"
			{
				//log_amx("indexed byte <%d> at %d, element %d, format position %d", sData[nDataIndex], nDataIndex, nIndexPos, nFormatPos)
				aIndexes[nIndexPos] = nDataIndex
				nDataIndex++
				nIndexPos++
			}
			case '2': // "short"
			{
				//log_amx("indexed short <%d %d> at %d, element %d, format position %d", sData[nDataIndex], sData[nDataIndex + 1], nDataIndex, nIndexPos, nFormatPos)
				aIndexes[nIndexPos] = nDataIndex
				nDataIndex += 2
				nIndexPos++
			}
			case '4': // "long"
			{
				//log_amx("indexed long <%d %d %d %d> at %d, element %d, format position %d", sData[nDataIndex], sData[nDataIndex + 1], sData[nDataIndex + 2], sData[nDataIndex + 3], nDataIndex, nIndexPos, nFormatPos)
				aIndexes[nIndexPos] = nDataIndex
				nDataIndex += 4
				nIndexPos++
			}
			case 's': // string
			{
				new sDebugString[250]
				arrayset(sDebugString, 0, 250)
				copyc(sDebugString, 250, sData[nDataIndex], 0)
				//log_amx("indexed string <%s> at %d, element %d, format position %d", sDebugString, nDataIndex, nIndexPos, nFormatPos)
				aIndexes[nIndexPos] = nDataIndex
				do { nDataIndex++; } while ((sData[nDataIndex] != 0) && (nDataIndex < nDataLen)) // find the end of the string by searching a 0 character
				nDataIndex++
				nIndexPos++
			}
			case '[': // byte switch and start of optional formats
			{
				//log_amx("indexed switch <%d> at %d, element %d, format position %d", sData[nDataIndex], nDataIndex, nIndexPos, nFormatPos)
				if (sData[nDataIndex] != 1) // skip options
				{
					do { nFormatPos++; } while ((sFormatString[nFormatPos] != ']') && (nFormatPos < nFormatPosMax))
					//log_amx("skipped optional formats, now at format position %d")
				}
				else
					//log_amx("----------- start of optional formats -----------")
				aIndexes[nIndexPos] = nDataIndex
				nDataIndex++
				nIndexPos++
			}
			case ']': // end of optional formats
			{
				//log_amx("----------- end of optional formats -----------")
				//nDataIndex++
			}
			default:
				nDataIndex++
		}
		nFormatPos++
	}
	//log_amx("---------------------- end of indexing ----------------------")
	//log_amx("%d < %d - %d <= %d", nIndexPos, nFormatPosMax, nDataIndex, nDataLen)
	return nIndexPos
}

/// <summary>Gets a byte from the element at the given index.</summary>
/// <param name="sData">The raw UDP data string that was received.</param>
/// <param name="nIndex">The format index of the data to be requested, e.g. 3 for the third data element.</param>
/// <returns>The requested byte value.</returns>
public index_get_byte(sData[MAX_INFO_LEN], nIndex)
{
	return sData[nIndex]
}

/// <summary>Gets a short from the element at the given index.</summary>
/// <param name="sData">The raw UDP data string that was received.</param>
/// <param name="nIndex">The format index of the data to be requested, e.g. 3 for the third data element.</param>
/// <returns>The requested short value.</returns>
public index_get_short(sData[MAX_INFO_LEN], nIndex)
{
	return ((sData[nIndex] << 8) | (sData[nIndex + 1] & 0x00FF))
}

/// <summary>Gets a long from the element at the given index.</summary>
/// <param name="sData">The raw UDP data string that was received.</param>
/// <param name="nIndex">The format index of the data to be requested, e.g. 3 for the third data element.</param>
/// <returns>The requested long value.</returns>
public index_get_long(sData[MAX_INFO_LEN], nIndex)
{
	return ((sData[nIndex] << 24) | (sData[nIndex + 1] << 16) | (sData[nIndex + 2] << 8) | (sData[nIndex + 3] & 0x000000FF))
}

/// <summary>Gets a string from the element at the given index.</summary>
/// <param name="sData">The raw UDP data string that was received.</param>
/// <param name="nIndex">The format index of the data to be requested, e.g. 3 for the third data element.</param>
/// <returns>The requested string value.</returns>
public index_get_string(sData[MAX_INFO_LEN], nIndex)
{
	new aRet[MAX_INFO_LEN]
	arrayset(aRet, 0, MAX_INFO_LEN)
	copyc(aRet, MAX_INFO_LEN, sData[nIndex], 0)
	return aRet
}

/// <summary>Handler for parsing the answers to server query packet.</summary>
/// <summary>This handler parses the UDP information answer packets from the servers that have been queried with <seealso name="query_servers"/>.</summary>
/// <seealso name="query_servers"/>
public receive_serverquery_answers()
{
	new nCheckMethod = get_pcvar_num(cvar_check_method)

	new sRcvBuf[MAX_INFO_LEN]
	new nRcvLen
	new nRecvCount
	new sMap[MAX_MAP_LEN]
	new sMod[MAX_NAME_LEN]
	new nServerCount = 0
	while (nServerCount < g_nServerCount)
	{
		if (!g_naServerSockets[nServerCount])
		{
			g_baServerResponding[nServerCount] = false
			/*
			should only happen for the g_nOwnServer
			
			client_print(0, print_chat, "%s no socket", g_saServerNames[nServerCount])
			*/
		}
		else
		{
			nRecvCount = 0
			new nCmdBackup = g_naServerCmdBackup[nServerCount]
			g_baServerResponding[nServerCount] = false
			new nSocket = g_naServerSockets[nServerCount]
			while (socket_change(nSocket, 1) && (nRecvCount <= nCmdBackup))
			{
				// socket debug
				//log_amx("socket changed: %i (%s)", nSocket, g_saServerNames[nServerCount])
				nRecvCount++
				
				// initialize our receive buffer
				setc(sRcvBuf, MAX_INFO_LEN, 0);
				// socket debug
				//log_amx("receiving from socket: %i (%s)", nSocket, g_saServerNames[nServerCount])
				nRcvLen = socket_recv(nSocket, sRcvBuf, MAX_INFO_LEN)
				// socket debug
				//log_amx("finished receiving from socket %i (%s), received %i bytes", nSocket, g_saServerNames[nServerCount], nRcvLen)
				
				//TODO: handle fragmented packets
				
				if (nRcvLen > 5)	// shortest reply is a ping response with length of 6
				{
					if (nCheckMethod == 1)
					{
						//   ping response
						if (equal(sRcvBuf, {-1,-1,-1,-1,'j'}, 5))
						{
							g_baServerResponding[nServerCount] = true
							break
						}
					}
					else if (nCheckMethod == 2)
					{
						new aIndexes[MAX_INFO_FORMAT]
						if (equal(sRcvBuf, {-1,-1,-1,-1}, 4))
						{
							g_baServerResponding[nServerCount] = true
							if (sRcvBuf[4] == 'm') // old HL1 or "goldsource" protocol
							{
								index_create(sRcvBuf, nRcvLen, A2S_INFO_GOLD_REPLY_FORMAT, aIndexes)
								copyc(sMap, MAX_MAP_LEN - 1, sRcvBuf[aIndexes[A2S_INFO_GOLD_IDX_MAP]], 0)
								g_saServerMap[nServerCount] = sMap
								copyc(sMod, MAX_NAME_LEN - 1, sRcvBuf[aIndexes[A2S_INFO_GOLD_IDX_GAMEDIR]], 0)
								g_saServerMod[nServerCount] = sMod
								g_naServerProtocol[nServerCount] = index_get_byte(sRcvBuf, aIndexes[A2S_INFO_GOLD_IDX_VERSION])
								g_naServerActivePlayers[nServerCount] = index_get_byte(sRcvBuf, aIndexes[A2S_INFO_GOLD_IDX_NUMPLAYERS])
								g_naServerMaxPlayers[nServerCount] = index_get_byte(sRcvBuf, aIndexes[A2S_INFO_GOLD_IDX_MAXPLAYERS])
								if (get_pcvar_num(cvar_countbots) == 0)
								{
									if (index_get_byte(sRcvBuf, aIndexes[A2S_INFO_GOLD_IDX_ISMOD]) == 1)
										g_naServerActivePlayers[nServerCount] -= index_get_byte(sRcvBuf, aIndexes[A2S_INFO_GOLD_IDX_MOD_NUMBOTS])
									else
										g_naServerActivePlayers[nServerCount] -= index_get_byte(sRcvBuf, aIndexes[A2S_INFO_GOLD_IDX_NUMBOTS])
								}
							}
							else if (sRcvBuf[4] == 'I') // source protocol
							{
								index_create(sRcvBuf, nRcvLen, A2S_INFO_SOURCE_REPLY_FORMAT, aIndexes)
								copyc(sMap, MAX_MAP_LEN - 1, sRcvBuf[aIndexes[A2S_INFO_SOURCE_IDX_MAP]], 0)
								g_saServerMap[nServerCount] = sMap
								copyc(sMod, MAX_NAME_LEN - 1, sRcvBuf[aIndexes[A2S_INFO_SOURCE_IDX_GAMEDIR]], 0)
								g_naServerProtocol[nServerCount] = index_get_byte(sRcvBuf, aIndexes[A2S_INFO_SOURCE_IDX_VERSION])
								g_saServerMod[nServerCount] = sMod
								g_naServerActivePlayers[nServerCount] = index_get_byte(sRcvBuf, aIndexes[A2S_INFO_SOURCE_IDX_NUMPLAYERS])
								g_naServerMaxPlayers[nServerCount] = index_get_byte(sRcvBuf, aIndexes[A2S_INFO_SOURCE_IDX_MAXPLAYERS])
								if (get_pcvar_num(cvar_countbots) == 0)
								{
									g_naServerActivePlayers[nServerCount] -= index_get_byte(sRcvBuf, aIndexes[A2S_INFO_SOURCE_IDX_NUMBOTS])
								}
							}
						}
					}
				}
			}
			/*
			if (nRecvCount == 0)
				log_amx("no change on socket %i (%s)", g_naServerSockets[nServerCount], g_saServerNames[nServerCount])
			*/
			//socket_close(nSocket)
			//g_naServerSockets[nServerCount] = 0
		}
		nServerCount++
	}
	
	if (get_pcvar_num(cvar_retry) > 0)
	{
		// now search for players who queued themselves to be redirected
		new nServer
		new nPlrCnt = 0
		
		while (nPlrCnt < g_nRetryCount)
		{
			nServer = g_nRetryQueue[nPlrCnt][1]
			if (nServer > -1)	// just to be sure
			{
				new nPlr = g_nRetryQueue[nPlrCnt][0]
				if (can_redirect_player(nServer, nPlr, 2, false) == 0)
				{
					console_print(nPlr, "%s: %L", PLUGIN_TAG, nPlr, "MSG_RETRY_SUCCESS")
					#if defined STATISTICS
						stats_redirect(STATS_INFO_REDIRECT, nPlr, STATS_REDIRTYPE_QUEUED, nServer)
					#endif // STATISTICS
					redirect(nPlr, nServer, false, false, true)
					g_naServerActivePlayers[nServer]++
				}
			}
			nPlrCnt++
		}
	}

	return PLUGIN_HANDLED
}

/// <summary>Retrieves number of bots currently on the server.</summary>
/// <returns>Number of bots currently on server.</returns>
public get_bot_count()
{
	new nBotCount = 0
	new const nMaxPlayers = get_maxplayers()
	for (new nCount = 0; nCount <= nMaxPlayers; ++nCount)
	{
		// "We don't really support get_players() with flags anymore. It was a bad idea and if it was our choice, it would have never been added to the original AMX Mod." - BAILOPAN (http://www.amxmodx.org/funcwiki.php?go=func&id=174)
		// ok, so instead of using get_players() with flag c we will rather check each player with is_user_bot()
		if (is_user_bot(nCount))
			nBotCount++
  }
	return nBotCount
}

/// <summary>Retrieves number of admins currently on the server.</summary>
/// <returns>Number of admins currently on server.</returns>
public get_admin_count()
{
	new nPlayers[MAX_PLAYERS]
	new nPlayerNum, nPlayerCount
	get_players(nPlayers, nPlayerNum, "ch")
	new nAdmins = 0
	for (nPlayerCount = 0; nPlayerCount < nPlayerNum; nPlayerCount++)
	{
		if (access(nPlayers[nPlayerCount], MIN_ADMIN_LEVEL))
			nAdmins++
	}
	return nAdmins
}

/// <summary>Retrieves number of current players being aware of the redirect_countbots CVAR.</summary>
/// <returns>The number of current players being aware of the redirect_countbots CVAR.</returns>
public get_current_players()
{
	new nCurrentPlayers = get_playersnum(1)
	if (get_pcvar_num(cvar_countbots) == 0)
		nCurrentPlayers -= get_bot_count()
	return nCurrentPlayers
}

/// <summary>Event handler for client disconnect event.</summary>
/// <summary>This handler makes sure people that have been in queue while disconnecting are removed from it.</summary>
/// <summary>Furthermore it resets the "last server" information for this now empty player slot.</summary>
/// <param name="id">Slot ID of player that was disconnected.</param>
public client_disconnect(id)
{
	queue_remove(id, -1)
	g_nLastServer[id - 1] = -1
}

/// <summary>Event handler for client authorized event.</summary>
/// <summary>This handler is called as soon as a connecting client was authenticated with WON/Steam system and received a WON/Steam ID.</summary>
/// <summary>It is used in favor of client_connected(), because here the client already logged in to AMXX user system and it can be determined whether the user is an admin, which is not the case for client_connected() event.</summary>
/// <param name="id">Slot ID of player that was authorized.</param>
public client_authorized(id)
{
	if (is_user_bot(id) || is_user_hltv(id))
		return PLUGIN_CONTINUE
		
	if ((g_nOwnServer == -1) && (!g_bInitialized))
	{
		plugin_postinit()
	}
	
	g_naLastMenuPages[id - 1] = 1
	g_naLastCategory[id - 1] = -1
	
	new nAutoMode = get_pcvar_num(cvar_auto)
	if (get_pcvar_num(cvar_active) == 1)
	{
		if (nAutoMode > 0)
		{
			if (((get_maxplayers() - get_playersnum(1)) == 0) || (nAutoMode > 2))
			{
				if (g_nServerCount > 0)
				{
					new bool:bLocalPriority = false
					// if local slot reservation is enabled we need to check whether this is a local player
					if (get_pcvar_num(cvar_localslots) == 1)
					{
						new sCheckAddress[MAX_IP_LEN]
						get_user_ip(id, sCheckAddress, MAX_IP_LEN - 1, 1)
						if (is_local_address(sCheckAddress))
							bLocalPriority = true
					}
					new nMaxAdmins = get_pcvar_num(cvar_maxadmins)
					if (nMaxAdmins == 0)
						nMaxAdmins = MAX_PLAYERS
					new bool:bRedirect = false // to keep some better overview assemble the if-comparison part by part in bRedirect
					// redirect if automode is 1 or 2, user is no admin or is admin but there are no admin slots (disabled or max admin slots in use already)
					bRedirect = bRedirect | (((nAutoMode == 1) || (nAutoMode == 2)) && ((!access(id, MIN_ADMIN_LEVEL)) || (get_pcvar_num(cvar_adminslots) == 0) || (get_admin_count() > nMaxAdmins)))
					// redirect if automode is 3 or 4 and user is no admin
					bRedirect = bRedirect | (((nAutoMode == 3) || (nAutoMode == 4)) && (!access(id, MIN_ADMIN_LEVEL)))
					// redirect if automode is 5 or 6
					bRedirect = bRedirect | ((nAutoMode == 5) || (nAutoMode == 6))
					if (g_bDebug)
					{
						new sPlayerName[MAX_NAME_LEN]
						get_user_name(id, sPlayerName, MAX_NAME_LEN - 1)
						log_amx("Auto-redirect check for <%s> (%d), auto-redirect: %s, automode: %d, local priority: %s, admin: %s, admin slots: %s, admins/max: %d/%d, current players/bots/max: %d/%d/%d", sPlayerName, id, bRedirect ? "yes" : "no", nAutoMode, bLocalPriority ? "yes" : "no", access(id, MIN_ADMIN_LEVEL) ? "yes" : "no", (get_pcvar_num(cvar_adminslots) == 1) ? "yes" : "no", get_admin_count(), nMaxAdmins, get_playersnum(1), get_bot_count(), get_maxplayers())
					}
					if (bRedirect)
					{
						//TODO: code in many parts redundant to what the redirect() function does except for the local-priority stuff - rather extend the redirect() function
						if (bLocalPriority)
						{
							// find the remote user that is connected for the shortest time and redirect him
							
							new nPlayers[MAX_PLAYERS]
							new nPlayerNum, nPlayerCount
							new nMinConnectedTime = 0x7FFFFFFF // make sure the first time value found will always be lower
							new nMinTimePlayer = -1
							new nUserTime
							get_players(nPlayers, nPlayerNum, "ch")
							new nCurID
							new sCheckPlayerAddress[MAX_IP_LEN]
							for (nPlayerCount = 0; nPlayerCount < nPlayerNum; nPlayerCount++)
							{
								nCurID = nPlayers[nPlayerCount]
								get_user_ip(nCurID, sCheckPlayerAddress, MAX_IP_LEN - 1, 1)
								
								nUserTime = get_user_time(nCurID)
								if ((nUserTime < nMinConnectedTime) && (!access(nCurID, MIN_ADMIN_LEVEL)) && (!is_local_address(sCheckPlayerAddress)))
								{
									nMinTimePlayer = nCurID
									nMinConnectedTime = nUserTime
								}
							}
							if (nMinTimePlayer >= 0)
							{
								client_cmd(nMinTimePlayer, "echo %s: %L", PLUGIN_TAG, nMinTimePlayer, "MSG_REDIRFORLOCAL")
								redirect(nMinTimePlayer, -1, true, true, true)
								return PLUGIN_CONTINUE
							}
							else
								if (g_bDebug)
									log_amx("no valid redirect target to free up slot for local player %i", id)
								
						}
						else
						{
							redirect(id, -1, true, (nAutoMode < 3), false)
							return PLUGIN_CONTINUE
						}
					}
					else
					{
						// find the user that is connected for the shortest time and redirect him away
						
						new nPlayers[MAX_PLAYERS]
						new nPlayerNum, nPlayerCount
						new nMinConnectedTime = 0x7FFFFFFF
						new nMinTimePlayer = -1
						new nUserTime
						get_players(nPlayers, nPlayerNum, "ch")
						new nCurID
						for (nPlayerCount = 0; nPlayerCount < nPlayerNum; nPlayerCount++)
						{
							nCurID = nPlayers[nPlayerCount]
							
							nUserTime = get_user_time(nCurID)
							if ((nUserTime < nMinConnectedTime) && (!access(nCurID, MIN_ADMIN_LEVEL)))
							{
								nMinTimePlayer = nCurID
								nMinConnectedTime = nUserTime
							}
						}
						if (nMinTimePlayer >= 0)
						{
							client_cmd(nMinTimePlayer, "echo %s: %L", PLUGIN_TAG, nMinTimePlayer, "MSG_REDIRFORADMIN")
							redirect(nMinTimePlayer, -1, true, true, true)
							return PLUGIN_CONTINUE
						}
						else
							if (g_bDebug)
								log_amx("no valid redirect target to free up slot for admin %i", id)
					}
					
				}
			}
			else
			{
				if (g_bDebug)
				{
					new sPlayerName[MAX_NAME_LEN]
					get_user_name(id, sPlayerName, MAX_NAME_LEN - 1)
					log_amx("Not auto-redirecting <%s> (%d), automode: %d, current players/bots/max: %d/%d/%d", sPlayerName, id, nAutoMode, get_playersnum(1), get_bot_count(), get_maxplayers())
				}
			}
		}
	}

	new sSourceServer[4]	// maximum is 999 servers, so we have a maximum of 3 digits
	get_user_info(id, "xredir", sSourceServer, 3)
	if (strcmp(sSourceServer, "") != 0)
	{
		new nSourceServer = str_to_num(sSourceServer)
		
		// show the welcome message delayed to that player
		new sID[1]
		sID[0] = id
		set_task(20.0, "welcome_message", 0, sID, 1)
		
		if (g_bUseIds && (nSourceServer != -1))
			g_nLastServer[id - 1] = g_naServerIds[nSourceServer]
		else
			g_nLastServer[id - 1] = nSourceServer
		#if defined VAULT
		stats_count(STATS_COUNT_REDIRECTED, g_nLastServer[id - 1])
		#endif // VAULT
		if (g_bDebug)
			log_amx("saved last server for player %i as server %i", id, g_nLastServer[id - 1])

		if ((nSourceServer >= 0) && (nSourceServer < g_nServerCount))
		{
			if (get_pcvar_num(cvar_show) == 1)
			{
				new nPlayers[MAX_PLAYERS]
				new nPlayerNum, nPlayerCount, nCurrentPlayer
				new sConnectNick[MAX_NAME_LEN]
				get_user_name(id, sConnectNick, MAX_NAME_LEN - 1)
				get_players(nPlayers, nPlayerNum, "c")
				set_hudmessage(000, 100, 255, get_pcvar_float(cvar_announce_alivepos_x), get_pcvar_float(cvar_announce_alivepos_y), 0, 0.0, 10.0, 0.5, 0.10, 1)
				for (nPlayerCount = 0; nPlayerCount < nPlayerNum; nPlayerCount++)
				{
					nCurrentPlayer = nPlayers[nPlayerCount]
					client_print(nCurrentPlayer, print_chat, "%s: %L", PLUGIN_TAG, nCurrentPlayer, "MSG_REDIRECT_RECEIVE", sConnectNick, g_saServerNames[nSourceServer])
				}
			}
		}
		
		client_cmd(id, "setinfo ^"xredir^" ^"^"")
		client_cmd(id, "setinfo ^"password^" ^"^"")
		
		set_task(10.0, "reset_info", 0, sID, 1)
	}
	return PLUGIN_CONTINUE
}


/// <summary>This function shows a message to the player that has connected, to tell him that he was redirected and how he can use /retry to get back (if so).</summary>
/// <summary>welcome_message is called with a set_task to show the welcome message delayed, so that the player has usually already chosen a team and his screen is clear to read it.</summary>
/// <summary>This message is only displayed to players that have been redirected from another server in the chain. If redirect_retry is enabled, it also tells the player</summary>
/// <summary>that he can use /retry command to have himself queued to redirect back to the source server.</summary>
/// <param name="id">The slot ID of the player that should have the welcome message displayed. It is passed as array, because it is called with set_task.</param>
public welcome_message(id[])
{
	new nID = id[0]
	if (is_user_connected(nID)) // make sure the player didn't already disconnect within the set_task delay
	{
		new nLastServer = g_nLastServer[nID - 1]
		if ((nLastServer >= 0) && (nLastServer != g_nOwnServer) && (nLastServer < MAX_SERVERFORWARDS))
		{
			new sAnnounceText[MAX_WELCOME_LEN]
			formatex(sAnnounceText, MAX_WELCOME_LEN - 1, "%L", nID, "MSG_REDIRFROM", g_saServerNames[g_nOwnServer], g_saServerNames[nLastServer])
			if ((get_pcvar_num(cvar_retry) == 1) && (get_pcvar_num(cvar_show) == 1))
				format(sAnnounceText, MAX_WELCOME_LEN - 1, "%s^n%L", sAnnounceText, nID, "MSG_RETRY_BACK_ANNOUNCE")
			
			set_hudmessage(000, 100, 255, -1.0, -1.0, 0, 0.0, 10.0, 0.5, 2.0, 1)
			show_hudmessage(nID, sAnnounceText)
		}
	}
}

#if defined SQL
public sql_connect()
{
	hSqlInfo = SQL_MakeStdTuple()
	hSql = SQL_Connect(hSqlInfo, nSqlError, sSqlError, MAX_SQL_ERROR_LEN-1)
	
	if (hSql == Empty_Handle)
	{
		log_amx("%s %L", PLUGIN_TAG, LANG_SERVER, "SQL_CANT_CON", sSqlError)
	}
}

public sql_disconnect()
{
	SQL_FreeHandle(hSql)
	SQL_FreeHandle(hSqlInfo)
}
#endif // SQL


#else

/// <summary>Dummy handler to catch the case where a user tried to compile the plugin with a too old compiler.</summary>
public plugin_init()
{
	log_amx("ERROR: Your AMXX version is too old for this plugin. You need at least version 1.80", )
}
#endif
