<h1 align="center">AFK Protection v2.0</h1>

<p align="center">
<img src="https://raw.githubusercontent.com/kpuc313/AMXX-AFK_Protection/main/preview/logo2.png">
<br />
<img src="https://github.com/kpuc313/AMXX-AFK_Protection/blob/main/preview/preview_01.png" width="400px"><img src="https://github.com/kpuc313/AMXX-AFK_Protection/blob/main/preview/preview_02.png" width="400px">
</p>

<br />

# :page_facing_up: Description:
This plugin is good for deathmatch servers, where you respawn immediately after death and cannot catch a break without being killed, so with this plugin, when you type /afk you became immortal, cannot move or shoot and you can go away from the PC, without being worried about kills/deads stats. 

<br />

# :computer: Chat Commands:
**/afk** - Enables AFK mode.<br />
**/back** - Disables AFK mode.

<br />

# :hammer_and_wrench: Cvars:
```
afk_protection "1" // Enable AFK Protection [0=Disable | 1=Enable]
afk_protection_new_round "1" // Keep AFK Protection when new round start [0=Disable | 1=Enable]
afk_protection_auto "1" // Auto AFK Protection [0=Disable | 1=Enable]

afk_camptime "30" // Seconds without moving to enable AFK Protection
afk_movedist "1" // Distance allowed to move without being enabled auto AFK Protection
	
afk_glow "1" // Enabled player glow while AFK Protection is on [0=Disable | 1=Cvar color | 1=Team Color]
afk_glow_color "255 0 0" // Glow color cvar in RGB
afk_glow_amount "0" // Glow amount
	
afk_transparent "0" // Enable transparent effect [0=Disable | 1=Enable]
afk_transparent_amount "120" // Transparent effect amount
	
afk_icon "1" // Enable AFK icon above player [0=Disable | 1=Enable]
afk_blind "1" // Blind player in AFK Protection mode [0=Disable | 1=Enable]
afk_annouce "20" // Announce every 'X' seconds with message to players for AFK Protection
```

<br />

# :books: Requirements:
**fun**<br />
**fakemeta**<br />
**Vexd_Utilities**

<br />

# :handshake: Thanks to:

**VeCo** - The code for player freeze.<br />
**DaRk_StyLe** - Idea to add cvar to set glow color (RGB).<br />
**IMBA** - Idea to add "AFK" icon above player's model.<br />
**ardi** - Idea to add glow color by team.<br />
**independent** - Idea to add auto AFK mode when player isn't moving.<br />
**{HOJ} Batman** - For his campcheck code from his Hero: Skeletor.

<br />

# :scroll: Changelog:
    - v1.0: First Release.
    - v2.0:
    [+] Added cvar to set glow color.
    [+] Added "AFK" icon above player's model.
    [+] Added glow color by team.
    [+] Added auto AFK mode when player isn't moving.
