/*****************************************************************
*                            MADE BY
*
*   K   K   RRRRR    U     U     CCCCC    3333333      1   3333333
*   K  K    R    R   U     U    C     C         3     11         3
*   K K     R    R   U     U    C               3    1 1         3
*   KK      RRRRR    U     U    C           33333   1  1     33333
*   K K     R        U     U    C               3      1         3
*   K  K    R        U     U    C     C         3      1         3
*   K   K   R         UUUUU U    CCCCC    3333333      1   3333333
*
******************************************************************
*                       AMX MOD X Script                         *
*     You can modify the code, but DO NOT modify the author!     *
******************************************************************
*
* Description:
* ============
* This plugin is good for deathmatch servers, where you respawn immediately after death and cannot catch a break
* without being killed, so with this plugin, when you type /afk you became immortal, cannot move or shoot and
* you can go away from the PC, without being worried about kills/deads stats.
*
******************************************************************
*
* Special Thanks to:
* ==================
* <VeCo> - The code for player freeze.
* DaRk_StyLe - Idea to add cvar to set glow color (RGB).
* IMBA - Idea to add "AFK" icon above player's model.
* ardi - Idea to add glow color by team.
* independent - Idea to add auto AFK mode when player isn't moving.
* {HOJ} Batman - For his campcheck code from his Hero: Skeletor
*
*****************************************************************/

#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <Vexd_Utilities>

#define VERSION "2.0"
#define TAG "AFK Protection"

new afk_protection, afk_protection_nr, afk_protection_auto,
afk_camptime, afk_movedist,
afk_glow, afk_glow_color, afk_glow_amount,
afk_transparent, afk_transparent_amount,
afk_icon, afk_blind, afk_announce

new isAfk[33]
new g_SayText, Sprite

new gPlayerPosition[32][3]  // keeps track of last known origin
new gMoveTimer[32]          // incremented if player didn't move far enough

public plugin_init() {
	register_plugin("AFK Protection", VERSION, "kpuc313")
	register_cvar("afk_protection", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	
	register_clcmd("say /afk","afk")
	register_clcmd("say_team /afk","afk")
	register_clcmd("say /back","back")
	register_clcmd("say_team /back","back")
	
	register_logevent("RoundStart",2,"1=Round_Start")
	
	afk_protection = register_cvar("afk_protection","1")
	afk_protection_nr = register_cvar("afk_protection_new_round","1")
	afk_protection_auto = register_cvar("afk_protection_auto","1")
	
	afk_camptime = register_cvar("afk_camptime", "30")
	afk_movedist = register_cvar("afk_movedist", "1")
	
	afk_glow = register_cvar("afk_glow","1")
	afk_glow_color = register_cvar("afk_glow_color","255 0 0")
	afk_glow_amount = register_cvar("afk_glow_amount","0")
	
	afk_transparent = register_cvar("afk_transparent","0")
	afk_transparent_amount = register_cvar("afk_transparent_amount","120")
	
	afk_icon = register_cvar("afk_icon","1")
	afk_blind = register_cvar("afk_blind","1")
	afk_announce = register_cvar("afk_annouce","20")
	
	g_SayText = get_user_msgid("SayText")
	
	if(get_pcvar_num(afk_protection_auto))
		set_task(1.0,"campcheck",0,"",0,"b" )
}

public plugin_precache() {
	Sprite = precache_model("sprites/afk.spr")
}

public client_putinserver(id) {
	set_task(get_pcvar_float(afk_announce), "announce", id)
}

public announce(id)
{
	colormsg(id, "\g[%s] \tWrite /afk to be in AFK Mode", TAG, VERSION)
}

public client_connect(id) {
	isAfk[id] = false
}

public client_disconnect(id) {
	isAfk[id] = false
}

public RoundStart() {
	new players[32], num
	get_players(players,num,"h")
	for(new i=0;i<num;i++)
	{
		if(!get_pcvar_num(afk_protection) && !get_pcvar_num(afk_protection_nr))
			return
		
		if(isAfk[players[i]] && is_user_alive(players[i])) {
			new color[17], red[5],green[7],blue[5]
			new amount = get_pcvar_num(afk_glow_amount)
			new tamount = get_pcvar_num(afk_transparent_amount)
			get_pcvar_string(afk_glow_color,color,16)
			parse(color,red,4,green,6,blue,4)
			
			set_pev(players[i],pev_flags,pev(players[i],pev_flags) | FL_FROZEN)
			set_user_godmode(players[i], 1)
			
			if(get_pcvar_num(afk_glow) == 1) {
				set_user_rendering(players[i], kRenderFxGlowShell, str_to_num(red), str_to_num(green), str_to_num(blue), kRenderNormal, amount)
			}
			else if(get_pcvar_num(afk_glow) == 2) {
				if(get_user_team(players[i]) == 1) {
					set_user_rendering(players[i], kRenderFxGlowShell, 255, 0, 0, kRenderNormal, amount)
				}
				else if(get_user_team(players[i]) == 2) {
					set_user_rendering(players[i], kRenderFxGlowShell, 0, 0, 255, kRenderNormal, amount)
				}
			}
			
			if(get_pcvar_num(afk_transparent)) {
				set_user_rendering(players[i], kRenderFxNone,255,255,255,kRenderTransAlpha,tamount)
			}
			
			if(get_pcvar_num(afk_blind)) {
				message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, players[i])
				write_short(~0)
				write_short(~0)
				write_short(0x0004) // stay faded
				write_byte(0)
				write_byte(0)
				write_byte(0)
				write_byte(255)
				message_end()
			}
			
			if(get_pcvar_num(afk_icon)) {
				add_icon(players[i], 999999);
			}
		}
		if(is_user_alive(players[i])) {
			get_user_origin(players[i], gPlayerPosition[players[i]])
		}
	}
}

public afk(id) {
	if(!get_pcvar_num(afk_protection))
		return
	
	if(isAfk[id])
		return
	
	if(is_user_alive(id)) {
		new color[17], red[5],green[7],blue[5]
		get_pcvar_string(afk_glow_color,color,16)
		parse(color,red,4,green,6,blue,4)
		new amount = get_pcvar_num(afk_glow_amount)
		new tamount = get_pcvar_num(afk_transparent_amount)
			
		set_pev(id,pev_flags,pev(id,pev_flags) | FL_FROZEN)
		set_user_godmode(id, 1)
			
		if(get_pcvar_num(afk_glow) == 1) {
			set_user_rendering(id, kRenderFxGlowShell, str_to_num(red), str_to_num(green), str_to_num(blue), kRenderNormal, amount)
		}
		else if(get_pcvar_num(afk_glow) == 2) {
			if(get_user_team(id) == 1) {
				set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, amount)
			}
			else if(get_user_team(id) == 2) {
				set_user_rendering(id, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, amount)
			}
		}
			
		if(get_pcvar_num(afk_transparent)) {
			set_user_rendering(id, kRenderFxNone,255,255,255,kRenderTransAlpha,tamount)
		}
			
		if(get_pcvar_num(afk_blind)) {
			message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
			write_short(~0)
			write_short(~0)
			write_short(0x0004) // stay faded
			write_byte(0)
			write_byte(0)
			write_byte(0)
			write_byte(255)
			message_end()
		}
			
		if(get_pcvar_num(afk_icon)) {
			add_icon(id, 999999);
		}
			
		colormsg(id, "\g[%s] \tYou are in AFK Mode! To remove AFK Mode write /back", TAG)
		isAfk[id] = true
	} else {
		colormsg(id, "\g[%s] \tYou can't use it when you dead", TAG)
	}
}

public back(id) {
	if(!get_pcvar_num(afk_protection))
		return
		
	if(!isAfk[id])
		return
		
	if(is_user_alive(id)) {
		set_pev(id,pev_flags,pev(id,pev_flags) & ~FL_FROZEN)
		set_user_godmode(id, 0)
			
		if(get_pcvar_num(afk_glow)) {
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 0)
		}
			
		if(get_pcvar_num(afk_transparent)) {
			set_user_rendering(id,0,0,0,kRenderTransAlpha,0)
		}
			
		if(get_pcvar_num(afk_blind)) {
			message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, id)
			write_short(1<<10)
			write_short(1<<10)
			write_short(0x0000) // stay faded
			write_byte(0)
			write_byte(0)
			write_byte(0)
			write_byte(100)
			message_end()
		}
			
		if(get_pcvar_num(afk_icon)) {
			remove_icon(id);
		}
		
		colormsg(id, "\g[%s] \tYou remove AFK Mode", TAG)
		isAfk[id] = false
	} else {
		colormsg(id, "\g[%s] \tYou can't use it when you dead", TAG)
	}
}

public campcheck()
{
	if(!get_pcvar_num(afk_protection_auto))
		return
	
	// Check all players to see if they've moved...
	new origin[3]
	new dx,dy,dz

	for(new i = 1; i <= 32; i++) {
		if (!is_user_alive(i)) continue
		if (Entvars_Get_Int(i, EV_INT_flags)&FL_NOTARGET) continue

		get_user_origin(i,origin)
		dx = gPlayerPosition[i][0] - origin[0]
		dy = gPlayerPosition[i][1] - origin[1]
		dz = gPlayerPosition[i][2] - origin[2]
		new d = sqrt( dx*dx + dy*dy + dz*dz )
		if (d <= get_pcvar_num(afk_movedist)) {
			gMoveTimer[i]++
			if(gMoveTimer[i] > get_pcvar_num(afk_camptime)) {
				gMoveTimer[i]=0
				afk(i)
			}
		} else {
			gMoveTimer[i] = 0
		}
		gPlayerPosition[i][0] = origin[0]
		gPlayerPosition[i][1] = origin[1]
		gPlayerPosition[i][2] = origin[2]
	}
}

stock colormsg(const id, const string[], {Float, Sql, Resul,_}:...) {
	
	new msg[191], players[32], count = 1;
	vformat(msg, sizeof msg - 1, string, 3);
	
	replace_all(msg,190,"\g","^4");
	replace_all(msg,190,"\y","^1");
	replace_all(msg,190,"\t","^3");
	
	if(id)
		players[0] = id;
	else
		get_players(players,count,"ch");
	
	for (new i = 0 ; i < count ; i++)
	{
		if (is_user_connected(players[i]))
		{
			message_begin(MSG_ONE_UNRELIABLE, g_SayText,_, players[i]);
			write_byte(players[i]);
			write_string(msg);
			message_end();
		}		
	}
}

stock add_icon(index, HoldTime)
{
	if(!is_user_connected(index))
		return;
	
	message_begin(MSG_ALL, SVC_TEMPENTITY);
	write_byte(TE_PLAYERATTACHMENT);
	write_byte(index);
	write_coord(60);
	write_short(Sprite);
	write_short(HoldTime);
	message_end();
}

stock remove_icon(index)
{
	if(!is_user_connected(index))
		return;
	
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_KILLPLAYERATTACHMENTS);
	write_byte(index);
	message_end();
}

stock sqrt(num)
{
	if (num > 0)	return sqroot(num)
	return 0
}
