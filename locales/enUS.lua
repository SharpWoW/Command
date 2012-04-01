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

	LOCALE_NOT_LOADED = "The specified locale has not been loaded.",
	LOCALE_UPDATE = "Set new locale to: %s",
	LOCALE_PI_ACTIVE = "Player independent locale settings is now active.",
	LOCALE_PI_INACTIVE = "Player independent locale settings is now inactive.",
	
	-------------
	-- General --
	-------------
	
	YES = "Yes",
	NO = "No",
	
	----------
	-- Core --
	----------
	
	ADDON_LOAD = "AddOn loaded! Use /cmd help or !help for help.",
	SVARS_OUTDATED = "Saved Variables out of date, resetting...",
	NEWVERSION_NOTICE = "\124cffFF0000A new version of \124cff00FFFF%s\124cffFF0000 is available! \124cffFFFF00Check the site you downloaded from for the updated version.",
	ENABLED = "AddOn \124cff00FF00enabled\124r.",
	DISABLED = "AddOn \124cffFF0000disabled\124r.",
	DEBUGENABLED = "Debugging \124cff00FF00enabled\124r.",
	DEBUGDISABLED = "Debugging \124cffFF0000disabled\124r.",
	
	---------------
	-- AddonComm --
	---------------
	
	AC_ERR_PREFIX = "[FATAL] Failed to register AddOn prefix %q. Maximum number of prefixes reached on client.",
	AC_ERR_MSGTYPE = "Invalid message type specified: %s",
	
	AC_GROUP_NORESP = "No response from group, running updater...",
	AC_GROUP_R_UPDATE = "Updated group members, controller: %s",
	AC_GROUP_LEFT = "Left group, resetting group variables...",
	AC_GROUP_WAIT = "Waiting for group response...",
	AC_GROUP_REMOVE = "Detected that %s is no longer in the group, removing and updating group members...",
	AC_GROUP_SYNC = "Detected group handlers out of date! Sending sync message...",
	
	AC_GUILD_NORESP = "No response from guild, running updater...",
	AC_GUILD_R_UPDATE = "Updated guild members, controller: %s",
	AC_GUILD_WAIT = "Waiting for guild response...",
	
	-----------------
	-- ChatManager --
	-----------------
	
	CHAT_ERR_CMDCHAR = "Command char has to be of type string.",
	CHAT_CMDCHAR_SUCCESS = "Successfully set the command char to: %s",
	CHAT_HANDLE_NOTCONTROLLER = "Not controller instance for \124cff00FFFF%s\124r, aborting.",
	
	--------------------
	-- CommandManager --
	--------------------
	
	CM_ERR_NOTALLOWED = "%s is not allowed to be used, %s.",
	CM_ERR_NOACCESS = "You do not have permission to use that command, %s. Required access level: %d. Your access level: %d.",
	CM_ERR_NOTREGGED = "%q is not a registered command.",
	CM_ERR_NOCMDCHAR = "No command character specified.",
	CM_ERR_NOCHAT = "This command is not allowed to be used from the chat.",
	CM_ERR_CHATONLY = "This command can only be used from the chat.",
	
	CM_NO_HELP = "No help available.",
	
	CM_DEFAULT_HELP = "Prints this help message.",
	CM_DEFAULT_CHAT = "Type !commands for a listing of commands available.",
	CM_DEFAULT_END = "End of help message.",
	
	CM_COMMANDS_HELP = "Print all registered commands.",
	
	CM_VERSION_HELP = "Print the version of Command.",
	CM_VERSION = "%s",
	
	CM_SET_HELP = "Control the settings of Command.",
	CM_SET_USAGE = "Usage: set cmdchar|groupinvite|setlocale|locale",
	CM_SET_GROUPINVITE_USAGE = "Usage: set groupinvite enable|disable|<time>",
	CM_SET_SETLOCALE_USAGE = "Usage: set setlocale <locale>",
	CM_SET_LOCALE_USAGE = "Usage: set locale reset|usemaster",
	
	CM_MYLOCALE_HELP = "Let's users set their own locale.",
	CM_MYLOCALE_SET = "Successfully set your locale to %s.",
	
	CM_LOCK_HELP = "Lock a player.",
	CM_UNLOCK_HELP = "Unlock a player.",
	
	CM_GETACCESS_HELP = "Get the access level of a user.",
	CM_GETACCESS_STRING = "%s's access is %d (%s)",
	
	CM_SETACCESS_HELP = "Set the access level of a user.",
	CM_SETACCESS_USAGE = "Usage: setaccess [player] <group>",
	
	CM_OWNER_HELP = "Promote a player to owner rank.",
	
	CM_ADMIN_HELP = "Promote a player to admin rank.",
	CM_ADMIN_USAGE = "Usage: admin <name>",
	
	CM_OP_HELP = "Promote a player to op rank.",
	
	CM_USER_HELP = "Promote a player to user rank.",
	
	CM_BAN_HELP = "Ban a player.",
	CM_BAN_USAGE = "Usage: ban <name>",
	
	CM_ACCEPTINVITE_HELP = "Accepts a pending group invite.",
	CM_ACCEPTINVITE_NOTACTIVE = "No pending invites active.",
	CM_ACCEPTINVITE_EXISTS = "I am already in a group.",
	CM_ACCEPTINVITE_SUCCESS = "Accepted group invite!",
	
	CM_INVITE_HELP = "Invite a player to group.",
	
	CM_INVITEME_HELP = "Player who issued the command will be invited to group.",
	
	CM_DENYINVITE_HELP = "Player issuing this command will no longer be sent invites from this AddOn.",
	
	CM_ALLOWINVITE_HELP = "Player issuing this command will receive invites sent from this AddOn.",
	
	CM_KICK_HELP = "Kick a player from group with optional reason (Requires confirmation).",
	CM_KICK_USAGE = "Usage: kick <player> [reason]",
	
	CM_KINGME_HELP = "Player issuing this command will be promoted to group leader.",
	
	CM_OPME_HELP = "Player issuing this command will be promoted to raid assistant.",
	
	CM_DEOPME_HELP = "Player issuing this command will be demoted from assistant status.",
	
	CM_LEADER_HELP = "Promote a player to group leader.",
	CM_LEADER_USAGE = "Usage: leader <name>",
	
	CM_PROMOTE_HELP = "Promote a player to raid assistant.",
	CM_PROMOTE_USAGE = "Usage: promote <name>",
	
	CM_DEMOTE_HELP = "Demote a player from assistant status.",
	CM_DEMOTE_USAGE = "Usage: demote <name>",
	
	CM_QUEUE_HELP = "Enter the LFG queue for the specified category.",
	CM_QUEUE_USAGE = "Usage: queue <type>",
	CM_QUEUE_INVALID = "No such dungeon type: %q.",
	
	CM_LEAVELFG_HELP = "Leave the LFG queue.",
	CM_LEAVELFG_FAIL = "Not queued by command, unable to cancel.",
	
	CM_ACCEPTLFG_HELP = "Causes you to accept the LFG invite.",
	CM_ACCEPTLFG_FAIL = "Not currently queued by command.",
	
	CM_CONVERT_HELP = "Convert group to party or raid.",
	CM_CONVERT_USAGE = "Usage: convert party||raid",
	CM_CONVERT_LFG = "LFG groups cannot be converted.",
	CM_CONVERT_NOGROUP = "Cannot convert if not in a group.",
	CM_CONVERT_NOLEAD = "Cannot convert group, not leader.",
	CM_CONVERT_PARTY = "Converted raid to party.",
	CM_CONVERT_PARTYFAIL = "Group is already a party.",
	CM_CONVERT_RAID = "Converted party to raid.",
	CM_CONVERT_RAIDFAIL = "Group is already a raid.",
	CM_CONVERT_INVALID = "Invalid group type, only \"party\" or \"raid\" allowed.",
	
	CM_LIST_HELP = "Toggle status of a command on the blacklist/whitelist.",
	CM_LIST_USAGE = "Usage: list <command>",
	
	CM_LISTMODE_HELP = "Toggle list between being a blacklist and being a whitelist.",
	
	CM_GROUPALLOW_HELP = "Allow a group to use a specific command.",
	CM_GROUPALLOW_USAGE = "Usage: groupallow <group> <command>",
	
	CM_GROUPDENY_HELP = "Deny a group to use a specific command.",
	CM_GROUPDENY_USAGE = "Usage: groupdeny <group> <command>",
	
	CM_RESETGROUPACCESS_HELP = "Reset the group's access to a specific command.",
	CM_RESETGROUPACCESS_USAGE = "Usage: resetgroupaccess <group> <command>",
	
	CM_USERALLOW_HELP = "Allow a user to use a specific command.",
	CM_USERALLOW_USAGE = "Usage: userallow <player> <command>",
	
	CM_USERDENY_HELP = "Deny a user to use a specific command.",
	CM_USERDENY_USAGE = "Usage: userdeny <player> <command>",
	
	CM_RESETUSERACCESS_HELP = "Reset the user's access to a specific command.",
	CM_RESETUSERACCESS_USAGE = "Usage: resetuseraccess <player> <command>",
	
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
	CM_LOOT_USAGE = "Usage: loot type||threshold||master||pass",
	CM_LOOT_LFG = "Cannot use loot command in LFG group.",
	CM_LOOT_NOMETHOD = "No loot method specified.",
	CM_LOOT_NOTHRESHOLD = "No loot threshold specified.",
	CM_LOOT_NOMASTER = "No master looter specified.",
	
	CM_ROLL_HELP = "Provides tools for managing or starting/stopping rolls.",
	CM_ROLL_USAGE = "Usage: roll [start||stop||pass||time||do||set]",
	CM_ROLL_START_USAGE = "Usage: roll start <[time] [item]>",
	CM_ROLL_SET_USAGE = "Usage: roll set min||max||time <amount>",
	
	CM_RAIDWARNING_HELP = "Sends a raid warning.",
	CM_RAIDWARNING_USAGE = "Usage: raidwarning <message>",
	CM_RAIDWARNING_NORAID = "Cannot send raid warning when not in a raid group.",
	CM_RAIDWARNING_NOPRIV = "Cannot send raid warning: Not raid leader or assistant.",
	CM_RAIDWARNING_SENT = "Sent raid warning.",
	
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
	
	RM_MATCH = "(%w+) rolls (%d+) %((%d+)-(%d+)%)",
	
	RM_ROLLEXISTS = "%s has already rolled! (%d)",
	RM_ROLLPROGRESS = "%d/%d players have rolled!",
	
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

Command.LocaleManager:Register("enUS", L)
