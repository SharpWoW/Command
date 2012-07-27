--[[
	* Copyright (c) 2011-2012 by Adam Hellberg.
	*
	* This file is part of Command.
	*
	* Command is free software: you can redistribute it and/or modify
	* it under the terms of the GNU General Public License as published by
	* the Free Software Foundation, either version 3 of the License, or
	* (at your option) any later version.
	*
	* Command is distributed in the hope that it will be useful,
	* but WITHOUT ANY WARRANTY; without even the implied warranty of
	* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	* GNU General Public License for more details.
	*
	* You should have received a copy of the GNU General Public License
	* along with Command. If not, see <http://www.gnu.org/licenses/>.
--]]

local L = {
	-------------------
	-- LocaleManager --
	-------------------

	LOCALE_NOT_LOADED = "Det specifierade språket är inte initialiserat.",
	LOCALE_UPDATE = "Nytt språk inställt till: %s",
	LOCALE_PI_ACTIVE = "Språkinställning per-användare är nu aktivt.",
	LOCALE_PI_INACTIVE = "Språkinställning per-användare är nu inaktivt.",

	-------------
	-- General --
	-------------

	YES = "Ja",
	NO = "Nej",

	------------------
	-- WoW Specific --
	---------------------------------------------------------------------------
	-- ONLY translate these if the locale has official support on the client --
	---------------------------------------------------------------------------

	USE_SOULSTONE = "Use Soulstone",
	REINCARNATION = "Reincarnation",
	TWISTING_NETHER = "Twisting Nether",

	----------
	-- Core --
	----------

	ADDON_LOAD = "AddOn initialiserad! Använd /cmd help eller !help för hjälp.",
	SVARS_OUTDATED = "Sparade variabler inaktuella, återställer...",
	NEWVERSION_NOTICE = "\124cffFF0000En ny version av \124cff00FFFF%s\124cffFF0000 är tillgänglig! \124cffFFFF00Gå till sidan där du laddade ned Command för att installera den.",
	ENABLED = "AddOn \124cff00FF00aktiverad\124r.",
	DISABLED = "AddOn \124cffFF0000avaktiverad\124r.",
	DEBUGENABLED = "Debugging \124cff00FF00aktiverat\124r.",
	DEBUGDISABLED = "Debugging \124cffFF0000avaktiverat\124r.",

	---------------
	-- AddonComm --
	---------------

	AC_ERR_PREFIX = "[KRITISK] Misslyckades med att registrera AddOn prefix %q. Maximalt antal prefix har nåtts på klienten.",
	AC_ERR_MSGTYPE = "Ogiltig meddelandetyp: %s",
	AC_ERR_MALFORMED_DATA = "Ogiltig data från %s. Deras AddOn är antagligen inaktuell.",
	AC_ERR_MALFORMED_DATA_SEND = "[AddonComm] Malformed data detected (\"%s\"). Aborting Send...",

	AC_GROUP_NORESP = "Inget svar från grupp, uppdaterar...",
	AC_GROUP_R_UPDATE = "Gruppmedlemmar uppdaterade, kontrollerare: %s",
	AC_GROUP_LEFT = "Grupp lämnad, återställer gruppvariabler...",
	AC_GROUP_WAIT = "Väntar på gruppsvar...",
	AC_GROUP_REMOVE = "Upptäckte att %s inte längre är i gruppen, tar bort och uppdaterar gruppmedlemmar...",
	AC_GROUP_SYNC = "Grupphanterare inaktuella! Skickar synkmeddelande...",

	AC_GUILD_NORESP = "Inget svar från guild, uppdaterar...",
	AC_GUILD_R_UPDATE = "Guildmedlemmar uppdaterade, kontrollerare: %s",
	AC_GUILD_WAIT = "Väntar på guildsvar...",

	-----------------
	-- ChatManager --
	-----------------

	CHAT_ERR_CMDCHAR = "Kommandotecken måste vara ett tecken.",
	CHAT_CMDCHAR_SUCCESS = "Nytt kommandotecken inställt till: %s",
	CHAT_HANDLE_NOTCONTROLLER = "Ej kontroller för \124cff00FFFF%s\124r, avbryter.",

	--------------------
	-- CommandManager --
	--------------------

	CM_ERR_NOTALLOWED = "%s är inte tillåtet att användas, %s.",
	CM_ERR_NOACCESS = "Du har inte tillåtelse att använda det kommandot, %s. Behörighet som krävs: %d. Din behörighet: %d.",
	CM_ERR_NOTREGGED = "%q är inte ett registrerat kommando.",
	CM_ERR_NOCMDCHAR = "Inget kommandotecken angivet.",
	CM_ERR_NOCHAT = "Det här kommandot kan inte användas från chatten.",
	CM_ERR_CHATONLY = "Det här kommandot kan endast användas från chatten.",
	CM_ERR_DISABLED = "Det här kommandot har blivit avstängt.",
	CM_ERR_PERMDISABLED = "Det här kommandot har blivit permanent avstängt.",
	CM_ERR_TEMPDISABLED = "Det här kommandot har blivit temporärt avstängt.",

	CM_NO_HELP = "Ingen hjälp tillgänglig.",

	CM_DEFAULT_HELP = "Visar det här hjälpmeddelandet.",
	CM_DEFAULT_HELPCOMMAND = "Use \"help <command>\" to get help on a specific command.",
	CM_DEFAULT_CHAT = "Skriv !commands för en lista över kommandon. Skriv !help <command> för hjälp med ett specifikt kommando.",
	CM_DEFAULT_END = "Slut på hjälpmeddelandet.",

	CM_HELP_HELP = "Gets help about the addon or a specific command.",
	CM_HELP_USAGE = "Användning: help <command>",

	CM_COMMANDS_HELP = "Visa alla registrerade kommandon.",

	CM_VERSION_HELP = "Visa versionen av Command",
	CM_VERSION = "%s",

	CM_SET_HELP = "Ändra inställningarna i Command.",
	CM_SET_USAGE = "Användning: set cmdchar|groupinvite",
	CM_SET_GROUPINVITE_USAGE = "Användning: set groupinvite enable|disable|<tid>",
	CM_SET_DM_ISENABLED = "DeathManager is enabled.",
	CM_SET_DM_ISDISABLED = "DeathManager is disabled.",
	CM_SET_DM_USAGE = "Usage: set dm [enable|disable]",

	CM_LOCALE_HELP = "Change locale settings.",
	CM_LOCALE_USAGE ="Användning: locale [set|reset|usemaster|playerindependent]",
	CM_LOCALE_CURRENT = "Current locale: %s.",
	CM_LOCALE_SET_USAGE = "Användning: locale set <locale>",

	CM_MYLOCALE_HELP = "Låter användare ställa in sitt eget språk.",
	CM_MYLOCALE_SET = "Ditt språk är nu inställt till %s.",

	CM_LOCK_HELP = "Lås en användare.",
	CM_UNLOCK_HELP = "Lås upp en användare.",

	CM_GETACCESS_HELP = "Visa en användares behörighetsnivå.",
	CM_GETACCESS_STRING = "%ss behörighet är %d (%s)",

	CM_SETACCESS_HELP = "Ändra en användares behörighetsnivå/grupp.",
	CM_SETACCESS_USAGE = "Användning: setaccess [namn] <grupp>",

	CM_OWNER_HELP = "Befordra en användare till ägarnivå.",

	CM_ADMIN_HELP = "Befordra en användare till adminnivå.",
	CM_ADMIN_USAGE = "Användning: admin <namn>",

	CM_OP_HELP = "Befordra en användare till operatörnivå.",

	CM_USER_HELP = "Befordra en användare till användarnivå.",

	CM_BAN_HELP = "Bannlys en användare.",
	CM_BAN_USAGE = "Användning: ban <namn>",

	CM_AUTH_HELP = "Add/Remove/Enable/Disable auths.",
	CM_AUTH_USAGE = "Användning: auth add|remove|enable|disable <target>",
	CM_AUTH_ADDUSAGE = "Användning: auth add <target> <level> [password]",
	CM_AUTH_ERR_SELF = "Cannot modify myself in auth list.",

	CM_AUTHME_HELP = "Authenticates the sender if the correct pass is specified.",
	CM_AUTHME_USAGE = "Användning: authme <password>",

	CM_ACCEPTINVITE_HELP = "Accepterar en pågående gruppinbjudan.",
	CM_ACCEPTINVITE_NOTACTIVE = "Inga aktiva inbjudningar just nu.",
	CM_ACCEPTINVITE_EXISTS = "Jag är redan i en grupp.",
	CM_ACCEPTINVITE_SUCCESS = "Accepterade gruppinbjudningen!",

	CM_INVITE_HELP = "Bjuder in en användare till gruppen.",

	CM_INVITEME_HELP = "Användaren som skickar kommandot bjuds in till gruppen.",

	CM_DENYINVITE_HELP = "Användare som använder det här kommandot kommer inte längre att få gruppinbjudningar.",

	CM_ALLOWINVITE_HELP = "Användare som använder det här kommandot kommer att få gruppinbjudningar.",

	CM_KICK_HELP = "Sparka ut en spelare från gruppen med valfri anledning (Kräver konfirmation).",
	CM_KICK_USAGE = "Användning: kick <spelare> [anledning]",

	CM_KINGME_HELP = "Player issuing this command will be promoted to group leader.",

	CM_OPME_HELP = "Player issuing this command will be promoted to raid assistant.",

	CM_DEOPME_HELP = "Player issuing this command will be demoted from assistant status.",

	CM_LEADER_HELP = "Promote a player to group leader.",
	CM_LEADER_USAGE = "Användning: leader <name>",

	CM_PROMOTE_HELP = "Promote a player to raid assistant.",
	CM_PROMOTE_USAGE = "Användning: promote <name>",

	CM_DEMOTE_HELP = "Demote a player from assistant status.",
	CM_DEMOTE_USAGE = "Användning: demote <name>",

	CM_QUEUE_HELP = "Enter the LFG queue for the specified category.",
	CM_QUEUE_USAGE = "Användning: queue <type>",
	CM_QUEUE_INVALID = "No such dungeon type: %q.",

	CM_LEAVELFG_HELP = "Lämna LFG-kön.",
	CM_LEAVELFG_FAIL = "Not queued by command, unable to cancel.",

	CM_ACCEPTLFG_HELP = "Causes you to accept the LFG invite.",
	CM_ACCEPTLFG_FAIL = "Not currently queued by command.",
	CM_ACCEPTLFG_NOEXIST = "There is currently no LFG proposal to accept.",

	CM_CONVERT_HELP = "Convert group to party or raid.",
	CM_CONVERT_USAGE = "Användning: convert party||raid",
	CM_CONVERT_LFG = "LFG groups cannot be converted.",
	CM_CONVERT_NOGROUP = "Cannot convert if not in a group.",
	CM_CONVERT_NOLEAD = "Cannot convert group, not leader.",
	CM_CONVERT_PARTY = "Converted raid to party.",
	CM_CONVERT_PARTYFAIL = "Group is already a party.",
	CM_CONVERT_RAID = "Converted party to raid.",
	CM_CONVERT_RAIDFAIL = "Group is already a raid.",
	CM_CONVERT_INVALID = "Invalid group type, only \"party\" or \"raid\" allowed.",

	CM_LIST_HELP = "Toggle status of a command on the blacklist/whitelist.",
	CM_LIST_USAGE = "Användning: list <command>",

	CM_LISTMODE_HELP = "Toggle list between being a blacklist and being a whitelist.",

	CM_GROUPALLOW_HELP = "Allow a group to use a specific command.",
	CM_GROUPALLOW_USAGE = "Användning: groupallow <group> <command>",

	CM_GROUPDENY_HELP = "Deny a group to use a specific command.",
	CM_GROUPDENY_USAGE = "Användning: groupdeny <group> <command>",

	CM_RESETGROUPACCESS_HELP = "Reset the group's access to a specific command.",
	CM_RESETGROUPACCESS_USAGE = "Användning: resetgroupaccess <group> <command>",

	CM_USERALLOW_HELP = "Allow a user to use a specific command.",
	CM_USERALLOW_USAGE = "Användning: userallow <player> <command>",

	CM_USERDENY_HELP = "Deny a user to use a specific command.",
	CM_USERDENY_USAGE = "Användning: userdeny <player> <command>",

	CM_RESETUSERACCESS_HELP = "Reset the user's access to a specific command.",
	CM_RESETUSERACCESS_USAGE = "Användning: resetuseraccess <player> <command>",

	CM_TOGGLE_HELP = "Toggle AddOn on and off.",

	CM_TOGGLEDEBUG_HELP = "Toggle debugging mode on and off.",

	CM_READYCHECK_HELP = "Respond to ready check or initiate a new one.",
	CM_READYCHECK_ISSUED = "%s issued a ready check!",
	CM_READYCHECK_NOPRIV = "Cannot initiate ready check when not leader or assistant.",
	CM_READYCHECK_INACTIVE = "Ready check not running or I have already responded.",
	CM_READYCHECK_ACCEPTED = "Accepted ready check.",
	CM_READYCHECK_DECLINED = "Declined ready check.",
	CM_READYCHECK_INVALID = "Invalid argument: %s",
	CM_READYCHECK_FAIL = "Failed to accept or decline ready check.",

	CM_LOOT_HELP = "Provides various loot functions.",
	CM_LOOT_USAGE = "Användning: loot type||threshold||master||pass",
	CM_LOOT_LFG = "Cannot use loot command in LFG group.",
	CM_LOOT_NOMETHOD = "No loot method specified.",
	CM_LOOT_NOTHRESHOLD = "No loot threshold specified.",
	CM_LOOT_NOMASTER = "No master looter specified.",

	CM_ROLL_HELP = "Provides tools for managing or starting/stopping rolls.",
	CM_ROLL_USAGE = "Användning: roll [start||stop||pass||time||do||set]",
	CM_ROLL_START_USAGE = "Användning: roll start <[time] [item]>",
	CM_ROLL_SET_USAGE = "Användning: roll set min||max||time <amount>",

	CM_RAIDWARNING_HELP = "Sends a raid warning.",
	CM_RAIDWARNING_USAGE = "Användning: raidwarning <message>",
	CM_RAIDWARNING_NORAID = "Cannot send raid warning when not in a raid group.",
	CM_RAIDWARNING_NOPRIV = "Cannot send raid warning: Not raid leader or assistant.",
	CM_RAIDWARNING_SENT = "Sent raid warning.",

	CM_DUNGEONMODE_HELP = "Set the dungeon difficulty.",
	CM_DUNGEONMODE_USAGE = "Användning: dungeondifficulty <difficulty>",

	CM_RAIDMODE_HELP = "Set the raid difficulty.",
	CM_RAIDMODE_USAGE = "Användning: raiddifficulty <difficulty>",

	CM_RELEASE_HELP = "Player will release corpse.",

	CM_RESURRECT_HELP = "Player will accept pending resurrect request.",

	------------
	-- Events --
	------------

	E_LFGPROPOSAL = "Group has been found, type !accept to make me accept the invite.",
	E_LFGFAIL = "LFG failed, use !queue <type> to requeue.",
	E_READYCHECK = "%s issued a ready check, type !rc accept to make me accept it or !rc deny to deny it.",
	E_GROUPINVITE = "Type !acceptinvite to make me accept the group invite.",

	------------------
	-- EventHandler --
	------------------

	EH_REGISTERED = "%q registered.",

	----------------------------
	-- GroupInvite (Core-Sub) --
	----------------------------

	GI_ENABLED = "Group Invite (Announce) enabled.",
	GI_DISABLED = "Group Invite (Announce) disabled.",
	GI_DELAY_NUM = "Delay has to be a number.",
	GI_DELAY_MAX = "Delay cannot be greater than 50 seconds.",
	GI_DELAY_SET = "Group Invite (Announce) delay set to %d seconds.",
	GI_DELAY_DISABLED = "Group Invite (Announce) delay disabled.",

	------------
	-- Logger --
	------------

	LOGGER_ERR_UNDEFINED = "Undefined logger level passed (%q)",
	LOGGER_PREFIX_MAIN = "\124cff00FF00[%s]\124r",
	LOGGER_PREFIX_DEBUG = " \124cffBBBBFFDebug\124r",
	LOGGER_PREFIX_NORMAL = "",
	LOGGER_PREFIX_WARNING = " \124cffFFFF00Warning\124r",
	LOGGER_PREFIX_ERROR = " \124cffFF0000ERROR\124r",

	-----------------
	-- LootManager --
	-----------------

	LOOT_METHOD_GROUP = "Group Loot",
	LOOT_METHOD_FFA = "Free For All",
	LOOT_METHOD_MASTER = "Master Looter",
	LOOT_METHOD_NEEDGREED = "Need Before Greed",
	LOOT_METHOD_ROUNDROBIN = "Round Robin",

	LOOT_THRESHOLD_UNCOMMON = "Uncommon",
	LOOT_THRESHOLD_RARE = "Rare",
	LOOT_THRESHOLD_EPIC = "Epic",
	LOOT_THRESHOLD_LEGENDARY = "Legendary",
	LOOT_THRESHOLD_ARTIFACT = "Artifact",
	LOOT_THRESHOLD_HEIRLOOM = "Heirloom",
	LOOT_THRESHOLD_UNKNOWN = "Unknown",

	LOOT_MASTER_NOEXIST = "%q is not in the group and cannot be set as the master looter.",

	LOOT_SM_NOLEAD = "Unable to change loot method, not group leader.",
	LOOT_SM_DUPE = "The loot method is already set to %s!",
	LOOT_SM_SUCCESS = "Successfully set the loot method to %s!",
	LOOT_SM_SUCCESSMASTER = "Successfully set the loot method to %s (%s)!",

	LOOT_SLM_NOLOEAD = "Unable to change master looter, not group leader.",
	LOOT_SLM_METHOD = "Cannot set master looter when loot method is set to %s.",
	LOOT_SLM_SPECIFY = "Master looter not specified.",
	LOOT_SLM_SUCCESS = "Successfully set %s as the master looter!",

	LOOT_ST_NOLEAD = "Unable to change loot threshold, not group leader.",
	LOOT_ST_INVALID = "Invalid loot threshold specified, please specify a loot threshold between 2 and 7 (inclusive).",
	LOOT_ST_SUCCESS = "Successfully set the loot threshold to %s!",

	LOOT_SP_PASS = "%s is now passing on loot.",
	LOOT_SP_ROLL = "%s is not passing on loot.",

	-------------------
	-- PlayerManager --
	-------------------

	PM_ERR_NOCOMMAND = "No command specified.",
	PM_ERR_LOCKED = "Target player is locked and cannot be modified.",
	PM_ERR_NOTINGROUP = "%s is not in the group.",

	PM_MATCH_INVITEACCEPTED_PARTY = "(%w+) joins the party.",
	PM_MATCH_INVITEACCEPTED_RAID = "(%w+) has joined the raid group.",
	PM_MATCH_INVITEDECLINED = "(%w+) declines your group invitation.",
	PM_MATCH_INGROUP = "(%w+) is already in a group.",

	PM_ACCESS_ALLOWED = "%q is now allowed for %s.",
	PM_ACCESS_DENIED = "%q is now denied for %s.",

	PM_KICK_REASON = "%s has been kicked on %s's request. (Reason: %s)",
	PM_KICK = "%s has been kicked on %s's request.",
	PM_KICK_NOTIFY = "%s was kicked on your request.",
	PM_KICK_TARGET = "You have ben kicked out of the group by %s.",
	PM_KICK_DENIED = "%s's request to kick %s has been denied.",
	PM_KICK_POPUP = "%s wants to kick %s. Confirm?",
	PM_KICK_SELF = "Cannot kick myself.",
	PM_KICK_FRIEND = "Cannot kick my friend.",
	PM_KICK_DEFAULTREASON = "%s used !kick command.",
	PM_KICK_WAIT = "Awaiting confirmation to kick %s...",
	PM_KICK_NOPRIV = "Unable to kick %s from group. Not group leader or assistant.",
	PM_KICK_TARGETASSIST = "Unable to kick %s, assistants cannot kick other assistants from group.",

	PM_PLAYER_CREATE = "Created player %q with default settings.",
	PM_PLAYER_UPDATE = "Updated player %q.",

	PM_GA_REMOVED = "%q removed from group %s.",
	PM_GA_EXISTSALLOW = "%q already has that command on the allow list.",
	PM_GA_EXISTSDENY = "%q already has that command on the deny list.",

	PM_PA_REMOVED = "%q removed from %s.",
	PM_PA_EXISTSALLOW = "%s already has that command on the allow list.",
	PM_PA_EXISTSDENY = "%s already has that command on the deny list.",

	PM_LOCKED = "Player %s has been locked.",
	PM_UNLOCKED = "Player %s has been unlocked",

	PM_SAG_SELF = "Cannot modify my own access level.",
	PM_SAG_NOEXIST = "No such access group: %q",
	PM_SAG_SET = "Set the access level of %q to %d (%s).",

	PM_INVITE_SELF = "Cannot invite myself to group.",
	PM_INVITE_INGROUP = "%s is already in the group.",
	PM_INVITE_FULL = "The group is already full.",
	PM_INVITE_ACTIVE = "%s already has an active invite.",
	PM_INVITE_DECLINED = "%s has declined the group invite.",
	PM_INVITE_INOTHERGROUP = "%s is already in a group.",
	PM_INVITE_NOTIFYTARGET = "Invited you to the group.",
	PM_INVITE_NOTIFY = "%s invited you to the group, %s. Whisper !blockinvites to block these invites.",
	PM_INVITE_SUCCESS = "Invited %s to group.",
	PM_INVITE_BLOCKED = "%s does not wish to be invited.",
	PM_INVITE_NOPRIV = "Unable to invite %s to group. Not group leader or assistant.",

	PM_DI_BLOCKING = "You are now blocking invites, whisper !allowinvites to receive them again.",
	PM_DI_SUCCESS = "%s is no longer receiving invites.",
	PM_DI_FAIL = "You are already blocking invites.",

	PM_AI_ALLOWING = "You are now allowing invites, whisper !blockinvites to block them.",
	PM_AI_SUCCESS = "%s is now receiving invites.",
	PM_AI_FAIL = "You are already allowing invites.",

	PM_LEADER_SELF = "Cannot promote myself to leader.",
	PM_LEADER_DUPE = "%s is already leader.",
	PM_LEADER_SUCCESS = "Promoted %s to group leader.",
	PM_LEADER_NOPRIV = "Cannot promote %s to group leader, insufficient permissions.",

	PM_ASSIST_SELF = "Cannot promote myself to assistant.",
	PM_ASSIST_DUPE = "%s is already assistant.",
	PM_ASSIST_NORAID = "Cannot promote to assistant when not in a raid.",
	PM_ASSIST_SUCCESS = "Promoted %s to assistant.",
	PM_ASSIST_NOPRIV = "Cannot promote %s to assistant, insufficient permissions.",

	PM_DEMOTE_SELF = "Cannot demote myself.",
	PM_DEMOTE_INVALID = "%s is not an assistant, can only demote assistants.",
	PM_DEMOTE_NORAID = "Cannot demote when not in a raid.",
	PM_DEMOTE_SUCCESS = "Demoted %s.",
	PM_DEMOTE_NOPRIV = "Cannot demote %s, insufficient permissions.",

	PM_LIST_ADDWHITE = "Added %s to whitelist.",
	PM_LIST_ADDBLACK = "Added %s to blacklist.",
	PM_LIST_REMOVEWHITE = "Removed %s from whitelist.",
	PM_LIST_REMOVEBLACK = "Removed %s from blacklist.",
	PM_LIST_SETWHITE = "Now using list as whitelist.",
	PM_LIST_SETBLACK = "Now using list as blacklist.",

	------------------
	-- DeathManager --
	------------------

	DM_ERR_NOTDEAD = "I am not dead.",

	DM_ENABLED = "DeathManager has been enabled.",
	DM_DISABLED = "DeathManager has been disabled.",
	DM_RELEASE_ENABLED = "DeathManager (Release) has been enabled.",
	DM_RELEASE_DISABLED = "DeathManager (Release) has been disabled.",
	DM_RESURRECT_ENABLED = "DeathManager (Resurrect) has been enabled.",
	DM_RESURRECT_DISABLED = "DeathManager (Resurrect) has been disabled.",

	DM_ONDEATH = "I have died! Type !release to make me release spirit.",
	DM_ONDEATH_SOULSTONE = "Died with active soulstone, type !ress to make me ress!",
	DM_ONDEATH_REINCARNATE = "Died with reincarnate off cooldown, type !ress to make me ress!",
	DM_ONDEATH_CARD = "Died with proc from Twisted Nether active, type !ress to make me ress!",

	DM_ONRESS = "I have received a ress from %s! Type !ress to make me accept it.",

	DM_RELEASE_NOTDEAD = "I am not dead or have already released.",
	DM_RELEASED = "Released corpse!",

	DM_RESURRECT_NOTACTIVE = "I have no pending resurrection request or it has expired.",
	DM_RESURRECTED = "Successfully resurrected!",
	DM_RESURRECTED_SOULSTONE = "Resurrected with soulstone!",
	DM_RESURRECTED_REINCARNATE = "Resurrected with reincarnate!",
	DM_RESURRECTED_CARD = "Resurrected with Darkmoon Card: Twisting Nether proc!",
	DM_RESURRECTED_PLAYER = "Accepted resurrect from %s!",

	-----------------
	-- AuthManager --
	-----------------

	AM_ERR_NOEXISTS = "%q does not exist in the auth list.",
	AM_ERR_USEREXISTS = "%q is already in the auth list, please authenticate with authme.",
	AM_ERR_DISABLED = "%q is disabled in the auth list.",
	AM_ERR_NOLEVEL = "No access level specified.",
	AM_ERR_AUTHED = "%q is already authenticated!",

	AM_AUTH_ERR_INVALIDPASS = "Invalid password.",
	AM_AUTH_SUCCESS = "%q successfully authenticated for access level %d!",

	AM_ADD_SUCCESS = "Added %q to auth list for access level %d, password: %s. Authenticate with !authme.",
	AM_ADD_WHISPER = "Added you to the auth list for access level %d, password: %s. Authenticate with !authme.",

	AM_REMOVE_SUCCESS = "Removed %q from auth list.",

	AM_ENABLE_SUCCESS = "Enabled %q for authentication.",

	AM_DISABLE_SUCCESS = "Disabled %q from authenticating.",

	----------------
	-- GroupTools --
	----------------

	GT_DUNGEON_NORMAL = "Normal",
	GT_DUNGEON_HEROIC = "Heroic",
	GT_RAID_N10 = "Normal (10)",
	GT_RAID_N25 = "Normal (25)",
	GT_RAID_H10 = "Heroic (10)",
	GT_RAID_H25 = "Heroic (25)",

	GT_DIFF_INVALID = "%q is not a valid difficulty.",

	GT_DD_DUPE = "Dungeon difficulty is already set to %s.",
	GT_DD_SUCCESS = "Successfully set the dungeon difficulty to %s!",

	GT_RD_DUPE = "Raid difficulty is already set to %s.",
	GT_RD_SUCCESS = "Successfully set raid difficulty to %s!",

	------------------
	-- QueueManager --
	------------------

	QM_QUEUE_START = "Starting queue for %s, please select your role(s)... Type !cancel to cancel.",
	QM_CANCEL = "Left the LFG queue.",
	QM_ACCEPT = "Accepted LFG invite.",
	QM_ANNOUNCE_QUEUEING = "Now queueing for %s, type !cancel to cancel.",
	QM_ANNOUNCE_ROLECANCEL = "Role Check cancelled.",
	QM_ANNOUNCE_LFGCANCEL = "LFG cancelled.",

	-----------------
	-- RollManager --
	-----------------

	RM_ERR_INVALIDAMOUNT = "Invalid amount passed: %s.",
	RM_ERR_NOTRUNNING = "No roll is currently in progress.",
	RM_ERR_INVALIDROLL = "%s specified too high or too low roll region, not including their roll.",

	RM_MATCH = "(%w+) rolls (%d+) %((%d+)-(%d+)%)", -- Same as enUS since svSE has no official client support.

	RM_ROLLEXISTS = "%s has already rolled! (%d)",
	RM_ROLLPROGRESS = "%d/%d spelare har rolled!",

	RM_UPDATE_TIMELEFT = "%d seconds left to roll!",

	RM_SET_MINFAIL = "Minimum roll number cannot be higher than maximum roll number!",
	RM_SET_MINSUCCESS = "Successfully set minimum roll number to %d!",
	RM_SET_MAXFAIL = "Maximum roll number cannot be higher than minimum roll number!",
	RM_SET_MAXSUCCESS = "Successfully set maximum roll number to %d!",
	RM_SET_TIMEFAIL = "Amount must be larger than zero (0).",
	RM_SET_TIMESUCCESS = "Successfully set default roll time to %d!",

	RM_START_RUNNING = "A roll is already in progress, wait for it to complete or use roll stop.",
	RM_START_SENDER = "Could not identify sender: %s. Aborting roll...",
	RM_START_MEMBERS = "Could not start roll, not enough group members!",
	RM_START_SUCCESS = "%s started a roll, ends in %d seconds! Type /roll %d %d. Type !roll pass to pass.",
	RM_START_SUCCESSITEM = "%s started a roll for %s, ends in %d seconds! Type /roll %d %d. Type !roll pass to pass.",

	RM_STOP_SUCCESS = "Roll has been stopped.",

	RM_DO_SUCCESS = "Done! Executed RandomRoll(%d, %d)",

	RM_PASS_SUCCESS = "%s has passed on the roll.",

	RM_TIME_LEFT = "%d seconds remaining!",

	RM_ANNOUNCE_EXPIRE = "Roll time expired! Results...",
	RM_ANNOUNCE_FINISH = "Everyone has rolled! Results...",
	RM_ANNOUNCE_EMPTY = "Noone rolled, there is no winner!",
	RM_ANNOUNCE_PASS = "Everyone passed on the roll, there is no winner!",
	RM_ANNOUNCE_PASSITEM = "Everyone passed on the roll, there is no winner for %s!",
	RM_ANNOUNCE_WIN = "The winner is: %s! With a roll of %d.",
	RM_ANNOUNCE_WINITEM = "The winner is: %s! With a roll of %d for %s.",
	RM_ANNOUNCE_MULTIPLE = "There are multiple winners:",
	RM_ANNOUNCE_MULTIPLEITEM = "There are multiple winners for %s:",
	RM_ANNOUNCE_WINNER = "%s with a roll of %d."
}

Command.LocaleManager:Register("svSE", L)
