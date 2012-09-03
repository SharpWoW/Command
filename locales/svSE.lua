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

-- Swedish translation by Stefano Bianque (Santisimos on CurseForge)
-- Corrections/Modifications by Adam Hellberg (F16Gaming, Fuskare01 on CurseForge)

local L = {
	-------------------
	-- LocaleManager --
	-------------------

	LOCALE_NOT_LOADED = "Det specificerade språket är ej initialiserat.",
	LOCALE_UPDATE = "Nytt språk inställt till: %s",
	LOCALE_PI_ACTIVE = "Språkinställning per-användare är nu aktivt.",
	LOCALE_PI_INACTIVE = "Språkinställning per-användare är nu inaktivt.",

	-------------
	-- General --
	-------------

	YES = "Ja",
	NO = "Nej",
	UNKNOWN = "Okänd",
	SECONDS = "Sekund(er)",

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

	ADDON_LOAD = "Tillägget initialiserad! Använd /cmd help eller !help för hjälp.",
	SVARS_OUTDATED = "Sparade variabler inaktuella, återställer...",
	NEWVERSION_NOTICE = "\124cffFF0000En ny version av \124cff00FFFF%s\124cffFF0000 är tillgänglig! \124cffFFFF00Gå till sidan där du laddade ned Command för att hämta den uppdaterade versionen.",
	ENABLED = "Tillägget \124cff00FF00aktiverad\124r.",
	DISABLED = "Tillägget \124cffFF0000avaktiverad\124r.",
	DEBUGENABLED = "Felsökning \124cff00FF00aktiverat\124r.",
	DEBUGDISABLED = "Felsökning \124cffFF0000avaktiverat\124r.",

	---------------
	-- AddonComm --
	---------------

	AC_ERR_PREFIX = "[KRITISK] Misslyckades med att registrera Tillägget prefix %q. Maximalt antal prefix har nåtts på klienten.",
	AC_ERR_MSGTYPE = "Ogiltig meddelandetyp: %s",
	AC_ERR_MALFORMED_DATA = "Ogiltig data från %s. Deras Tillägg är antagligen inaktuell.",
	AC_ERR_MALFORMED_DATA_SEND = "[AddonComm] Felaktigt data hittad (\"%s\"). Avbryter sändning...",

	AC_GROUP_NORESP = "Inget svar från grupp, uppdaterar...",
	AC_GROUP_R_UPDATE = "Gruppmedlemmar uppdaterade, kontroller: %s",
	AC_GROUP_LEFT = "Grupp lämnad, återställer gruppvariabler...",
	AC_GROUP_WAIT = "Väntar på gruppsvar...",
	AC_GROUP_REMOVE = "Upptäckte att %s ej längre är i gruppen, tar bort och uppdaterar gruppmedlemmar...",
	AC_GROUP_SYNC = "Grupphanterare inaktuella! Skickar synkmeddelande...",

	AC_GUILD_NORESP = "Inget svar från Guild, uppdaterar...",
	AC_GUILD_R_UPDATE = "Guildmedlemmar uppdaterade, kontroller: %s",
	AC_GUILD_WAIT = "Väntar på Guildsvar...",

	-----------------
	-- ChatManager --
	-----------------

	CHAT_ERR_CMDCHAR = "Kommandotecken måste vara ett tecken.",
	CHAT_CMDCHAR_SUCCESS = "Nytt kommandotecken inställt till: %s",
	CHAT_HANDLE_NOTCONTROLLER = "Ej kontroller för \124cff00FFFF%s\124r, avbryter.",

	--------------------
	-- CommandManager --
	--------------------

	CM_ERR_UNKNOWN = "Okänt fel inträffade, kontakta tilläggskapare.",
	CM_ERR_NOTALLOWED = "%s kan ej användas, %s.",
	CM_ERR_NOACCESS = "Du saknar behörighet att använda det kommandot, %s. Behörighet som krävs: %d. Din behörighet: %d.",
	CM_ERR_NOTREGGED = "%q är ej ett registrerat kommando.",
	CM_ERR_NOCMDCHAR = "Inget kommandotecken angivet.",
	CM_ERR_NOCHAT = "Det här kommandot kan ej användas från chatten.",
	CM_ERR_CHATONLY = "Det här kommandot kan endast användas från chatten.",
	CM_ERR_DISABLED = "Det här kommandot har blivit avstängt.",
	CM_ERR_PERMDISABLED = "Det här kommandot har blivit permanent avstängt.",
	CM_ERR_TEMPDISABLED = "Det här kommandot har blivit temporärt avstängt.",

	CM_NO_HELP = "Ingen hjälp tillgängligt.",

	CM_DEFAULT_HELP = "Visar det här hjälpmeddelandet.",
	CM_DEFAULT_HELPCOMMAND = "Använd \"help <command>\" för att få hjälp med ett specifikt kommando.",
	CM_DEFAULT_CHAT = "Skriv !commands för en lista över kommandon. Skriv !help <command> för hjälp med ett specifikt kommando.",
	CM_DEFAULT_END = "Slut på hjälpmeddelandet.",

	CM_HELP_HELP = "Får hjälp om tillägget eller ett specifikt kommando.",
	CM_HELP_USAGE = "Användning: help <command>",

	CM_COMMANDS_HELP = "Visa alla registrerade kommandon.",

	CM_VERSION_HELP = "Visa versionen av Command",
	CM_VERSION = "%s",

	CM_SET_HELP = "Ändra inställningarna i Command.",
	CM_SET_USAGE = "Användning: set cmdchar|deathmanager|summonmanager|invitemanager|duelmanager",
	CM_SET_DM_ISENABLED = "DeathManager är aktiverat.",
	CM_SET_DM_ISDISABLED = "DeathManager är avaktiverat.",
	CM_SET_DM_USAGE = "Användning: set dm [enable|disable|toggle|enableress|disableress|toggleress|enablerel|disablerel|togglerel]",
	CM_SET_SM_ISENABLED = "SummonManager är aktiverat.",
	CM_SET_SM_ISDISABLED = "SummonManager är avaktiverat.",
	CM_SET_SM_DELAY_CURRENT = "Den nuvarande fördröjningen för sammankallningsmeddelanden är %s.",
	CM_SET_SM_DELAY_USAGE = "Användning: set sm delay <delay>",
	CM_SET_SM_USAGE = "Användning: set sm [enable|disable|toggle|delay]",
	CM_SET_IM_ISENABLED = "InviteManager är aktiverat.",
	CM_SET_IM_ISDISABLED = "InviteManager är avaktiverat.",
	CM_SET_IM_GROUP_DELAY_CURRENT = "Gruppmeddelandet är inställt på %d sekund(er).",
	CM_SET_IM_GROUP_DELAY_USAGE = "Användning: set im groupdelay [delay]",
	CM_SET_IM_GUILD_DELAY_CURRENT = "Guildmeddelandet fördröjningen är inställt på %d sekund(er).",
	CM_SET_IM_GUILD_DELAY_USAGE = "Användning: set im guilddelay [delay]",
	CM_SET_IM_USAGE = "Användning: set im [enable|disable|toggle|groupenable|groupdisable|grouptoggle|groupenableannounce|groupdisableannounce|grouptoggleannounce|groupdelay|groupdisabledelay|guildenable|guilddisable|guildtoggle|guildenableannounce|guilddisableannounce|guildtoggleannounce|guildenableoverride|guilddisableoverride|guildtoggleoverride|guilddelay|guilddisabledelay]",
	CM_SET_CDM_ISENABLED = "DuelManager är aktiverat.",
	CM_SET_CDM_ISDISABLED = "DuelManager är avaktiverat.",
	CM_SET_CDM_DELAY_CURRENT = "Meddelande fördröjning är inställt på %d sekund(er).",
	CM_SET_CDM_DELAY_USAGE = "Användning: set duelmanager delay [delay]",
	CM_SET_CDM_USAGE = "Användning: set duelmanager [enable|disable|toggle|enableannounce|disableannounce|toggleannounce|delay]",
	CM_SET_CRM_ISENABLED = "RoleManager är aktiverat.",
	CM_SET_CRM_ISDISABLED = "RoleManager är avaktiverat.",
	CM_SET_CRM_DELAY_CURRENT = "Meddelande fördröjning är inställt på %s.",
	CM_SET_CRM_DELAY_USAGE = "Användning: set rm delay [delay]",
	CM_SET_CRM_USAGE = "Användning: set rm [enable|disable|toggle|enableannounce|disableannounce|toggleannounce|setdelay]",

	CM_LOCALE_HELP = "Ändra språkinställningar.",
	CM_LOCALE_USAGE ="Användning: locale [set|reset|usemaster|playerindependent]",
	CM_LOCALE_CURRENT = "Nuvarande språk: %s.",
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

	CM_ADMIN_HELP = "Befordra en användare till administratörnivå.",
	CM_ADMIN_USAGE = "Användning: admin <namn>",

	CM_OP_HELP = "Befordra en användare till operatörnivå.",

	CM_USER_HELP = "Befordra en användare till användarnivå.",

	CM_BAN_HELP = "Bannlys en användare.",
	CM_BAN_USAGE = "Användning: ban <namn>",

	CM_AUTH_HELP = "Lägg till/Ta bort/Aktivera/Avaktivera autentiseringar.",
	CM_AUTH_USAGE = "Användning: auth add|remove|enable|disable <target>",
	CM_AUTH_ADDUSAGE = "Användning: auth add <target> <level> [password]",
	CM_AUTH_ERR_SELF = "Kan ej ändra mig själv i autentiseringslistan.",

	CM_AUTHME_HELP = "Autentiserar sändaren om det rätta lösenordet är angivet.",
	CM_AUTHME_USAGE = "Användning: authme <password>",

	CM_ACCEPTINVITE_HELP = "Accepterar en inväntad gruppinbjudan.",
	CM_DECLINEINVITE_HELP = "Avböjer en inväntad gruppinbjudan.",
	CM_ACCEPTGUILDINVITE_HELP = " Accepterar en inväntad guildinbjudan.",
	CM_DECLINEGUILDINVITE_HELP = "Avböjer en inväntad guildinbjudan.",

	CM_INVITE_HELP = "Bjuder in en användare till gruppen.",

	CM_INVITEME_HELP = "Användaren som utfärdade kommandot bjuds in till gruppen.",

	CM_DENYINVITE_HELP = "Användare som utfärdar det här kommandot kommer inte längre att få gruppinbjudningar från tillägget.",

	CM_ALLOWINVITE_HELP = "Användare som använder det här kommandot kommer att få gruppinbjudningar från tillägget.",

	CM_KICK_HELP = "Sparka ut en spelare från gruppen med valfri anledning (Bekräftelse krävs).",
	CM_KICK_USAGE = "Användning: kick <spelare> [anledning]",

	CM_KINGME_HELP = "Användaren som utfärdar kommandot kommer att bli befordrad till gruppledare.",

	CM_OPME_HELP = " Användaren som utfärdar kommandot kommer att bli befordrad till raidassistent.",

	CM_DEOPME_HELP = "Användaren som utfärdar kommandot kommer att bli degraderad från assistent befattningen.",

	CM_LEADER_HELP = "Befordra en spelare till gruppledare.",
	CM_LEADER_USAGE = "Användning: leader <name>",

	CM_PROMOTE_HELP = "Befordra en spelare till raid assistent.",
	CM_PROMOTE_USAGE = "Användning: promote <name>",

	CM_DEMOTE_HELP = "Degradera en spelare från assistent befattningen.",
	CM_DEMOTE_USAGE = "Användning: demote <name>",

	CM_QUEUE_HELP = "Gå in i LFG-kön med den specificerade kategorin.",
	CM_QUEUE_USAGE = "Användning: queue <type>",
	CM_QUEUE_INVALID = " Ogiltig dungeon typ: %q.",

	CM_LEAVELFG_HELP = "Lämna LFG-kön.",
	CM_LEAVELFG_FAIL = "Ej köade genom kommandot, kan ej avbrytas.",

	CM_ACCEPTLFG_HELP = "Får dig att acceptera LFG-inbjudan.",
	CM_ACCEPTLFG_FAIL = "För närvarande, ej köade genom kommandot",
	CM_ACCEPTLFG_NOEXIST = "Ingen tillgänglig LFG-begäran att acceptera.",

	CM_CONVERT_HELP = "Omvandla gruppen till grupp eller raid.",
	CM_CONVERT_USAGE = "Användning: convert party||raid",
	CM_CONVERT_LFG = "LFG kan ej omvandlas .",
	CM_CONVERT_NOGROUP = "Kan ej omvandla, om ej i en grupp.",
	CM_CONVERT_NOLEAD = "Kan ej omvandla, ej ledaren .",
	CM_CONVERT_PARTY = "Omvandlat raid till grupp",
	CM_CONVERT_PARTYFAIL = "Gruppen är redan omvandlat till en grupp.",
	CM_CONVERT_RAID = "Omvandlat gruppen till en raid.",
	CM_CONVERT_RAIDFAIL = "Gruppen är redan omvandlat till raid.",
	CM_CONVERT_INVALID = "Ogiltig grupp kategori, endast \"party\" eller \"raid\" tillåtna.",

	CM_LIST_HELP = "Växla kommandostatus på svartlistan/vitlistan.",
	CM_LIST_USAGE = "Användning: list <command>",

	CM_LISTMODE_HELP = "Växla mellan listor från att vara en svartlista eller en vitlista.",

	CM_GROUPALLOW_HELP = "Tillåt en grupp att använda specifika kommandon.",
	CM_GROUPALLOW_USAGE = "Användning: groupallow <group> <command>",

	CM_GROUPDENY_HELP = "Neka en grupp att använda specifika kommandon.",
	CM_GROUPDENY_USAGE = "Användning: groupdeny <group> <command>",

	CM_RESETGROUPACCESS_HELP = "Återställ gruppens åtkomst i ett specifikt kommando.",
	CM_RESETGROUPACCESS_USAGE = "Användning: resetgroupaccess <group> <command>",

	CM_USERALLOW_HELP = "Tillåt en användare att använda ett specifikt kommando.",
	CM_USERALLOW_USAGE = "Användning: userallow <player> <command>",

	CM_USERDENY_HELP = "Neka en användare att använda ett specifikt kommando.",
	CM_USERDENY_USAGE = "Användning: userdeny <player> <command>",

	CM_RESETUSERACCESS_HELP = "Återställ användarens åtkomst i ett specifikt kommando.",
	CM_RESETUSERACCESS_USAGE = "Användning: resetuseraccess <player> <command>",

	CM_TOGGLE_HELP = "Aktivera och avaktivera tillägget.",

	CM_TOGGLEDEBUG_HELP = "Aktivera och avaktivera felsökningsläge.",

	CM_READYCHECK_HELP = "Besvara en ready check eller starta en ny.",
	CM_READYCHECK_USAGE = "Användning: rc [accept|decline]",

	CM_LOOT_HELP = "Förser med diverse loot-funktioner.",
	CM_LOOT_USAGE = "Användning: loot type||threshold||master||pass",
	CM_LOOT_LFG = "Kan ej använda loot-kommandot i LFG-grupp.",
	CM_LOOT_NOMETHOD = "Ingen specificerad loot-system.",
	CM_LOOT_NOTHRESHOLD = "Ingen loot-gräns specificerad.",
	CM_LOOT_NOMASTER = "Ingen loot-ledarskap specificerad.",

	CM_ROLL_HELP = "Förser verktyg för hantering eller start/stopp av lottdragning .",
	CM_ROLL_USAGE = "Användning: roll [start||stop||pass||time||do||set]",
	CM_ROLL_START_USAGE = "Användning: roll start <[time] [item]>",
	CM_ROLL_SET_USAGE = "Användning: roll set min||max||time <amount>",

	CM_RAIDWARNING_HELP = "Skickar en raid varning.",
	CM_RAIDWARNING_USAGE = "Användning: raidwarning <message>",
	CM_RAIDWARNING_NORAID = "Kan ej skicka raid varningar om ej in i en grupp .",
	CM_RAIDWARNING_NOPRIV = " Kan ej skicka raid varningar: Ej raid ledaren eller raid assistent",
	CM_RAIDWARNING_SENT = "Raid varning skickad.",

	CM_DUNGEONMODE_HELP = "Anger dungeon svårighetsgraden.",
	CM_DUNGEONMODE_USAGE = "Användning: dungeondifficulty <difficulty>",

	CM_RAIDMODE_HELP = "Anger raid svårighetsgraden.",
	CM_RAIDMODE_USAGE = "Användning: raiddifficulty <difficulty>",

	CM_RELEASE_HELP = "Spelaren kommer att lämna sitt lik.",

	CM_RESURRECT_HELP = "Spelaren kommer att acceptera en inväntad återuppväckningsbegäran.",

	CM_ACCEPTSUMMON_HELP = " Spelaren kommer att acceptera en inväntad sammankallningsbegäran.",

	CM_DECLINESUMMON_HELP = "Spelaren kommer att avböja en inväntad sammankallningsbegäran.",

	CM_ACCEPTDUEL_HELP = "Accepterar en inväntad duellbegäran.",

	CM_DECLINEDUEL_HELP = "Avböjer en inväntad duellbegäran eller avbryter en aktiv duell.",

	CM_STARTDUEL_HELP = "Utmanar en annan spelare till en duell.",
	CM_STARTDUEL_USAGE = "Usage: startduel <target>",

	CM_ROLE_HELP = "Förser med diverse kommando för att kontrollera rolltilldelning.",
	CM_ROLE_USAGE = "Användning: role start|set|confirm",
	CM_ROLE_CURRENT = "Min nuvarande roll är %s.",
	CM_ROLE_SET_USAGE = "Användning: role set tank|healer|dps",
	CM_ROLE_CONFIRM_USAGE = "Användning: role confirm [tank|healer|dps]",

	CM_FOLLOW_HELP = "Börjar följa specificerade spelaren(eller sändaren om ingen spelare angiven).",
	CM_FOLLOW_STARTED = "Börjat följa %s!",
	CM_FOLLOW_SELF = "Jag kan inte följa mig själv.",

	------------
	-- Events --
	------------

	E_LFGPROPOSAL = "Gruppen har hittats, skriv !accept för att få mig att acceptera inbjudan.",
	E_LFGFAIL = "LFG misslyckades, använd !queue <type> för att köa igen.",
	E_READYCHECK = "%s utfärdade en ready check, skriv !rc accept för att få mig att acceptera eller !rc deny för att avböja.",

	------------------
	-- EventHandler --
	------------------

	EH_REGISTERED = "%q registrerad.",

	------------
	-- Logger --
	------------

	LOGGER_ERR_UNDEFINED = "Odefinierad loggnivå överskridit (%q)",
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

	LOOT_MASTER_NOEXIST = "%q är ej i gruppen och kan ej bli tilldelad loot-ledarskap.",

	LOOT_SM_NOLEAD = "Kan ej byta loot-system, ej gruppledare.",
	LOOT_SM_DUPE = "Loot-system är redan inställd på %s!",
	LOOT_SM_SUCCESS = "Loot-system är nu inställd på  %s!",
	LOOT_SM_SUCCESSMASTER = "Loot-ledarskapen är nu tilldelad till %s (%s)!",

	LOOT_SLM_NOLEAD = "Kan ej byta loot-ledarskap, ej gruppledare.",
	LOOT_SLM_METHOD = "Kan ej byta loot-system när inställd på %s.",
	LOOT_SLM_SPECIFY = "Loot-ledarskap ej specificerad.",
	LOOT_SLM_SUCCESS = "Nu är %s tilldelad loot-ledarskap!",

	LOOT_ST_NOLEAD = "Kan ej byta loot-gräns, ej gruppledare.",
	LOOT_ST_INVALID = "Ogiltig loot-gräns angiven, var vänlig ange en loot-gräns mellan 2 och 7 (inklusive).",
	LOOT_ST_SUCCESS = "Nu är loot-gränsen inställd på %s!",

	LOOT_SP_PASS = "%s ignorerar loot.",
	LOOT_SP_ROLL = "%s ignorerar ej loot.",

	-------------------
	-- PlayerManager --
	-------------------

	PM_ERR_NOCOMMAND = "Inget specificerat kommandot.",
	PM_ERR_LOCKED = "Markerad spelare är låst och kan ej modifieras.",
	PM_ERR_NOTINGROUP = "%s är inte i gruppen.",

	PM_MATCH_INVITEACCEPTED_PARTY = "(%w+) går med i gruppen.",
	PM_MATCH_INVITEACCEPTED_RAID = "(%w+) går med i raidgruppen.",
	PM_MATCH_INVITEDECLINED = "(%w+) avböjde din gruppinbjudan.",
	PM_MATCH_INGROUP = "(%w+) är redan i en grupp.",

	PM_ACCESS_ALLOWED = "%q är beviljad åtkomst till %s.",
	PM_ACCESS_DENIED = "%q är nekad åtkomst till %s.",

	PM_KICK_REASON = "%s har sparkats ut med %ss begäran. (Anledning: %s)",
	PM_KICK = "%s har sparkats ut med %ss begäran.",
	PM_KICK_NOTIFY = "%s sparkades ut av din begäran.",
	PM_KICK_TARGET = "Du har blivit utsparkad av %s.",
	PM_KICK_DENIED = "%ss begäran att sparka ut %s har nekats.",
	PM_KICK_POPUP = "%s vill sparka ut %s. Bekräfta?",
	PM_KICK_SELF = "Kan ej sparka ut mig själv.",
	PM_KICK_FRIEND = "Kan ej sparka ut vän.",
	PM_KICK_DEFAULTREASON = "%s använde !kick kommandot.",
	PM_KICK_WAIT = "Avvaktar bekräftelse för att sparka ut %s...",
	PM_KICK_NOPRIV = "Kan ej sparka ut %s från gruppen. Ej gruppledare eller assistent.",
	PM_KICK_TARGETASSIST = "Kan ej sparka ut %s, assistenter kan ej sparka ut andra assistenter.",

	PM_PLAYER_CREATE = "Skapade spelare %q (%s) med standardinställningar.",
	PM_PLAYER_UPDATE = "Uppdaterade spelare %q (%s).",

	PM_GA_REMOVED = "%q borttagen from gruppen %s.",
	PM_GA_EXISTSALLOW = "%q har redan det kommandot i den beviljad lista.",
	PM_GA_EXISTSDENY = "%q har redan det kommandot i den nekad lista.",

	PM_PA_REMOVED = "%q borttagen from gruppen %s.",
	PM_PA_EXISTSALLOW = "%s har redan det kommandot i den beviljad lista.",
	PM_PA_EXISTSDENY = "%s har redan det kommandot i den nekad lista.",

	PM_LOCKED = "Spelaren %s har blivit låst.",
	PM_UNLOCKED = "Spelaren %s har blivit upplåst",

	PM_SAG_SELF = "Kan ej ändra min egen åtkomstnivå.",
	PM_SAG_NOEXIST = "Ogiltig åtkomstgrupp: %q",
	PM_SAG_SET = "Ställ in åtkomstnivån från %q till %d (%s).",

	PM_INVITE_SELF = "Kan ej bjuda in mig själv till gruppen.",
	PM_INVITE_INGROUP = "%s är redan i gruppen.",
	PM_INVITE_FULL = "Gruppen är redan full.",
	PM_INVITE_LFG = "Kan ej bjuda in spelare till en LFG-grupp.",
	PM_INVITE_ACTIVE = "%s har redan en pågående inbjudan.",
	PM_INVITE_DECLINED = "%s har Avböjtt gruppinbjudan.",
	PM_INVITE_INOTHERGROUP = "%s är redan i en grupp.",
	PM_INVITE_NOTIFYTARGET = "Inbjöd dig till gruppen.",
	PM_INVITE_NOTIFY = "%s inbjöd dig till gruppen, %s. Viska !blockinvites för att blockera flera inbjudningar.",
	PM_INVITE_SUCCESS = "Inbjöd %s till gruppen.",
	PM_INVITE_BLOCKED = "%s önskar att bli inbjuden.",
	PM_INVITE_NOPRIV = "Kan ej inbjuda %s till gruppen. Ej ledaren eller assistent.",

	PM_DI_BLOCKING = "Du blockerar nu inbjudningar, viska !allowinvites för att få dem igen.",
	PM_DI_SUCCESS = "%s får nu inte längre inbjudningar.",
	PM_DI_FAIL = "Du blockerar redan inbjudningar.",

	PM_AI_ALLOWING = "Du tillåter redan inbjudningar, viska !blockinvites för att blockera dem.",
	PM_AI_SUCCESS = "%s får nu inbjudningar.",
	PM_AI_FAIL = "Du får redan inbjudningar.",

	PM_LEADER_SELF = "Kan ej befordra mig till ledaren.",
	PM_LEADER_DUPE = "%s är redan ledaren.",
	PM_LEADER_SUCCESS = "Befordrade %s till gruppledaren.",
	PM_LEADER_NOPRIV = "Kan ej befordra %s till gruppledare, behörighet saknas.",

	PM_ASSIST_SELF = "Kan ej befordra mig till assistent.",
	PM_ASSIST_DUPE = "%s är redan assistent.",
	PM_ASSIST_NORAID = "Kan ej befordra till assistent när ej in en raidgrupp.",
	PM_ASSIST_SUCCESS = "Befordrade %s till assistent.",
	PM_ASSIST_NOPRIV = "Kan ej befordra %s till assistent, behörighet saknas.",

	PM_DEMOTE_SELF = "Kan ej degradera mig.",
	PM_DEMOTE_INVALID = "%s är ej en assistent, kan endast degradera assistenter.",
	PM_DEMOTE_NORAID = "Kan ej degradera mig när ej i en raidgrupp.",
	PM_DEMOTE_SUCCESS = "Degraderade %s.",
	PM_DEMOTE_NOPRIV = "Kan ej degradera %s, behörighet saknas.",

	PM_LIST_ADDWHITE = "La till %s i vitlistan.",
	PM_LIST_ADDBLACK = "La till %s i svartlistan.",
	PM_LIST_REMOVEWHITE = "Tog bort %s i vitlistan.",
	PM_LIST_REMOVEBLACK = "Tog bort %s i svartlistan.",
	PM_LIST_SETWHITE = "Använder nu listan som vitlista.",
	PM_LIST_SETBLACK = "Använder nu listan som svartlista.",

	------------------
	-- DeathManager --
	------------------

	DM_ERR_NOTDEAD = "Jag är ej död.",

	DM_ENABLED = "DeathManager har aktiverats.",
	DM_DISABLED = "DeathManager har avaktiverats.",
	DM_RELEASE_ENABLED = "DeathManager (Release) har aktiverats.",
	DM_RELEASE_DISABLED = "DeathManager (Release) har avaktiverats.",
	DM_RESURRECT_ENABLED = "DeathManager (Resurrect) har aktiverats ",
	DM_RESURRECT_DISABLED = "DeathManager (Resurrect) har avaktiverats.",

	DM_ONDEATH = "Jag har dött! Skriv !release för att få mig att släppa iväg min själ.",
	DM_ONDEATH_SOULSTONE = "Dog med ett aktivt Soulstone, skriv !ress för att återuppväcka mig!",
	DM_ONDEATH_REINCARNATE = "Dog med Reincarnate utan Cooldown, skriv !ress för att återuppväcka mig!",
	DM_ONDEATH_CARD = "Dog med ett Proc från Twisted Nether, skriv !ress för att återuppväcka mig!",

	DM_ONRESS = "Jag fick en uppståndelse från %s! Skriv !ress för att acceptera den.",

	DM_RELEASE_NOTDEAD = "Jag är ej död eller har redan släppt iväg min själv.",
	DM_RELEASED = "Släppte iväg min själ!",

	DM_RESURRECT_NOTACTIVE = "Jag har inga inväntade uppståndelsebegäran eller det har löpt ut.",
	DM_RESURRECTED = "Lyckades med uppståndelsen!",
	DM_RESURRECTED_SOULSTONE = "Återuppväckt med Soulstone!",
	DM_RESURRECTED_REINCARNATE = "Återuppväckt med Reincarnate!",
	DM_RESURRECTED_CARD = "Återuppväckt med Darkmoon Card: Twisting Nether proc!",
	DM_RESURRECTED_PLAYER = "Accepterade uppståndelse från %s!",

	-------------------
	-- SummonManager --
	-------------------

	SM_ERR_NOSUMMON = " Jag har inga inväntade sammankallningsbegäran eller det har löpt ut.",

	SM_ENABLED = "Summon Manager har aktiverats!",

	SM_DISABLED = "Summon Manager har avaktiverats!",

	SM_ONSUMMON = "Jag har fått en sammankallning från %s till %s, löper ut om %s! Skriv !acceptsummon eller !declinesummon för att få mig att acceptera eller avböja begäran.",

	SM_ACCEPTED = "Accepterade sammankallningsbegäran %s!",

	SM_DECLINED = "Avböjde sammankallningsbegäran from %s!",

	SM_SETDELAY_SUCCESS = "Sammankallningsmeddelande är nu fördröjda till %s!",
	SM_SETDELAY_INSTANT = "Sammankallningar meddelas direkt när mottagna.",

	-------------------
	-- InviteManager --
	-------------------

	IM_GUILD_CONFIRM_OVERRIDE_POPUP = " Aktivering av detta ger användarna möjlighet att utfärda !acceptguild även om du har ett rykte med en tidigare guild, vilket leder till att du förlorar ditt rykte. \nÄr du säker på att du vill aktivera den här inställningen? ",

	IM_ENABLED = "InviteManager har aktiverats!",
	IM_DISABLED = "InviteManager har avaktiverats!",

	IM_GROUP_ENABLED = "InviteManager (Group) har aktiverats!",
	IM_GROUP_DISABLED = "InviteManager (Group) har avaktiverats!",

	IM_GROUPANNOUNCE_ENABLED = "Group invite announcement har aktiverats!",
	IM_GROUPANNOUNCE_DISABLED = "Group invite announcement har avaktiverats!",

	IM_GROUPDELAY_NUM = "Fördröjningen på gruppmeddelande måste vara ett nummer.",
	IM_GROUPDELAY_OUTOFRANGE = "Fördröjningen på gruppmeddelande måste vara mellan 0 och %d sekunder.",
	IM_GROUPDELAY_SET = "Fördröjningen på gruppmeddelande inställd på %d sekund(er)!",
	IM_GROUPDELAY_DISABLED = "Fördröjningen på gruppmeddelande avaktiverat, meddelande skickas direkt!",

	IM_GUILD_ENABLED = "InviteManager (Guild) har aktiverats!",
	IM_GUILD_DISABLED = "InviteManager (Guild) har avaktiverats!",

	IM_GUILDANNOUNCE_ENABLED = "Meddelande på gruppinbjudningar har aktiverats!",
	IM_GUILDANNOUNCE_DISABLED = "Meddelande på gruppinbjudningar har avaktiverats!",

	IM_GUILDOVERRIDE_PENDING = "Guild överskridinställningen genomgår ändringar, var vänlig avsluta dina ändringar innan Du utfärdar kommandot igen.",
	IM_GUILDOVERRIDE_WAITING = "Avvaktar på användarinmatning på Guild överskridinställningen poppuppfönstret...",
	IM_GUILDOVERRIDE_ENABLED = " Guild överskridinställningen har aktiverats, användare får nu tillgång för att utfärda !acceptguildinvite även om de har ett rykte med en tidigare Guild. !! ANVÄNDS MED FÖRSIKTIGHET !!",
	IM_GUILDOVERRIDE_DISABLED = " Guild överskridinställningen har avaktiverats, användare får nu ej tillgång för att utfärda !acceptguildinvite om de har ett rykte med en tidigare Guild.",

	IM_GUILDDELAY_NUM = "Fördröjningen på Guildmeddelande måste vara ett nummer.",
	IM_GUILDDELAY_OUTOFRANGE = "Fördröjningen på Guildmeddelande måste vara mellan 0 och %d sekunder.",
	IM_GUILDDElAY_SET = " Fördröjningen på Guildmeddelande inställd på %d sekund(er)!",
	IM_GUILDDELAY_DISABLED = " Fördröjningen på Guildmeddelande avaktiverat, meddelande skickas direkt!",

	IM_GROUP_ANNOUNCE = "Skriv !accept för att få mig att acceptera gruppinbjudan eller !decline för att avböja den!",
	IM_GUILD_ANNOUNCE = "Skriv !acceptguildinvite för att få mig att acceptera Guildinbjudan eller !declineguildinvite för att avböja den!",

	IM_GROUP_NOINVITE = "Jag har ingen pågående gruppinbjudan.",
	IM_GROUP_ACCEPTED = "Accepterade gruppinbjudan!",
	IM_GROUP_DECLINED = "Avböjde gruppinbjudan.",

	IM_GUILD_NOINVITE = "Jag har ingen pågående Guildinbjudan.",
	IM_GUILD_HASREP = "Kan ej automatiskt acceptera Guildinbjudningar, jag har fortarande ett rykte med min tidigare Guild som då skulle gå förlorad.",
	IM_GUILD_ACCEPTED = "Accepterade Guildinbjudan!",
	IM_GUILD_DECLINED = "Avböjde Guildinbjudan.",

	-----------------
	-- DuelManager --
	-----------------

	CDM_ERR_NODUEL = "Jag har ingen pågående duellbegäran.",

	CDM_ANNOUNCE = "Skriv !acceptduel för att få mig att acceptera duellbegäran eller !declineduel för att avböja den!",

	CDM_ACCEPETED = "Accepterade duellbegäran!",

	CDM_DECLINED = "Avböjde duellbegäran.",

	CDM_CANCELLED = "Avbröt pågående duell (om någon).",

	CDM_CHALLENGED = "Skickade duellbegäran till %s!",

	CDM_ENABLED = "DuelManager har aktiverats!",

	CDM_DISABLED = "DuelManager har avaktiverats.",

	CDM_ANNOUNCE_ENABLED = "DuelManager meddelande har aktiverats!",

	CDM_ANNOUNCE_DISABLED = "DuelManager meddelande har avaktiverats.",

	CDM_DELAY_NUM = "Fördröjningen måste vara ett nummer.",
	CDM_DELAY_OUTOFRANGE = "Fördröjningen måste vara mellan 0 och %d sekunder.",
	CDM_DELAY_SET = "Fördröjningsmeddelande inställd på %d sekund(er)!",
	CDM_DELAY_DISABLED = "Fördröjningsmeddelande har avaktiverats, meddelas nu direkt.",

	-----------------
	-- RoleManager --
	-----------------

	CRM_ENABLED = "RoleManager aktiverat.",
	CRM_DISABLED = "RoleManager avaktiverat.",


	CRM_TANK = "Tank",
	CRM_HEALER = "Healer",
	CRM_DAMAGE = "DPS",
	CRM_UNDEFINED = "Undefined",

	CRM_ANNOUNCE_HASROLE = "Rollkontroll startat! Bekräfta min nuvarande roll (%s) med !role confirm eller ange en ny roll med !role confirm tank|healer|dps",
	CRM_ANNOUNCE_NOROLE = " Rollkontroll startat! Ange min roll med !role confirm tank|healer|dps",

	CRM_SET_INVALID = "Jag kan ej utföra rollen som %s, var vänlig ange en annan roll.",
	CRM_SET_SUCCESS = "Min roll är nu inställd som %s!",

	CRM_CONFIRM_NOROLE = "Ingen roll inställd, bekräftelse behövs med !role confirm tank|healer|dps",

	CRM_START_ACTIVE = "Det finns redan en inväntad rollkontroll, var vänlig och dröj tills den är avslutad.",
	CRM_START_NOPRIV = "Kan ej starta en rollkontroll, ej ledare eller assistent.",
	CRM_START_NOGROUP = "Rollkontroller kan endast startas inom en grupp.",

	CRM_STARTDELAY_SUCCESS = "RoleManager meddelandefördröjning är nu inställd på %s!",
	CRM_STARTDELAY_INSTANT = "RoleManager meddelar nu direkt.",

	-----------------------
	-- ReadyCheckManager --
	-----------------------
	RCM_INACTIVE = "Ingen kontroll om gruppen är redo pågår just nu.",
	RCM_RESPONDED = "Jag har redan besvarat om jag är redo.",

	RCM_ENABLED = "ReadyCheckManager har aktiverats.",
	RCM_DISABLED = "ReadyCheckManager har avaktiverats.",

	RCM_ANNOUNCE = "%s undrar om jag är redo! Skriv !rc accept för att få mig att acceptera eller !rc deny för att avböja den.",

	RCM_ACCEPTED = "Accepterade att jag är redo!",
	RCM_DECLINED = "Avböjde att jag är redo!",

	RCM_START_ISSUED = "%s undrar om alla är redo!",
	RCM_START_NOPRIV = "Kan ej kontrollera om alla är redo, ej ledare eller assistent.",

	RCM_ANNOUNCE_ENABLED = "ReadyCheckManager meddelar nu skickade kontroller om gruppen är redo.",
	RCM_ANNOUNCE_DISABLED = "ReadyCheckManager meddelar ej nu skickade kontroller om gruppen är redo.",

	RCM_SETDELAY_SUCCESS = "ReadyCheckManager meddelandefördröjningen är inställd på %d sekund(er)!",
	RCM_SETDELAY_INSTANT = "ReadyCheckManager meddelar nu direkt!",

	-----------------
	-- AuthManager --
	-----------------

	AM_ERR_NOEXISTS = "%q finns ej in autentiseringslistan.",
	AM_ERR_USEREXISTS = "%q är redan i autentiseringslistan, var vänlig autentisera med authme.",
	AM_ERR_DISABLED = "%q är avaktiverat i autentiseringslistan.",
	AM_ERR_NOLEVEL = "Ingen åtkomstnivå specificerad.",
	AM_ERR_AUTHED = "%q är redan autentiserad!",

	AM_AUTH_ERR_INVALIDPASS = "Ogiltigt lösenord.",
	AM_AUTH_SUCCESS = "%q är nu autentiserad med %d åtkomstnivå!",

	AM_ADD_SUCCESS = "Lade till %q i autentiseringslistan med %d åtkomstnivå, lösenord: %s. Autentisera med !authme.",
	AM_ADD_WHISPER = "Lade till dig i autentiseringslistan med %d åtkomstnivå, lösenord: %s. Autentisera med !authme.",

	AM_REMOVE_SUCCESS = "Tog bort %q från autentiseringslistan.",

	AM_ENABLE_SUCCESS = "Aktiverade %q för autentisering.",

	AM_DISABLE_SUCCESS = "Avaktiverad %q från autentisering",

	----------------
	-- GroupTools --
	----------------

	GT_DUNGEON_NORMAL = "Normal",
	GT_DUNGEON_HEROIC = "Heroic",
	GT_DUNGEON_CHALLENGE = "Challenge",
	GT_RAID_N10 = "Normal (10)",
	GT_RAID_N25 = "Normal (25)",
	GT_RAID_H10 = "Heroic (10)",
	GT_RAID_H25 = "Heroic (25)",

	GT_DIFF_INVALID = "%q är en ogiltig svårighetsgrad.",

	GT_DD_DUPE = "Dungeon svårighetsgraden är redan inställd på %s.",
	GT_DD_SUCCESS = "Svårighetsgraden är nu inställd på %s!",

	GT_RD_DUPE = "Raid svårighetsgraden är redan inställd på %s.",
	GT_RD_SUCCESS = "Svårighetsgraden är nu inställd på %s!",

	------------------
	-- QueueManager --
	------------------

	QM_QUEUE_START = "Startar för att köa för %s, var vänlig ange din(a) roll(er)... Skriv !cancel för att avbryta.",
	QM_CANCEL = "Lämnade LFG-kön.",
	QM_ACCEPT = "Accepterade LFG-inbjudan.",
	QM_ANNOUNCE_QUEUEING = "Köar nu för %s, skriv !cancel för att avbryta.",
	QM_ANNOUNCE_ROLECANCEL = "Rollkontroll avbruten.",
	QM_ANNOUNCE_LFGCANCEL = "LFG avbruten.",

	-----------------
	-- RollManager --
	-----------------

	RM_ERR_INVALIDAMOUNT = "Ogiltig antal överskridit: %s.",
	RM_ERR_NOTRUNNING = "Ingen lottdragning pågår just nu.",
	RM_ERR_INVALIDROLL = "%s specificerade en för hög eller för låg region, det inkluderar ej deras lottdragning.",

	RM_MATCH = "(%w+) rolls (%d+) %((%d+)-(%d+)%)", -- Same as enUS since svSE has no official client support.

	RM_ROLLEXISTS = "%s drog redan en lott! (%d)",
	RM_ROLLPROGRESS = "%d/%d spelare har dragit en lott!",

	RM_UPDATE_TIMELEFT = "%d sekunder kvar för att dra en lott!",

	RM_SET_MINFAIL = "Lägsta lottnumret kan ej vara högre än högsta lottnumret!",
	RM_SET_MINSUCCESS = "Lägsta lottnumret är nu inställd på %d!",
	RM_SET_MAXFAIL = "Högsta lottnumret kan ej vara lägre än lägsta lottnumret!",
	RM_SET_MAXSUCCESS = "Högsta lottnumret är nu inställd på %d!",
	RM_SET_TIMEFAIL = "Antalet måste vara store än noll (0).",
	RM_SET_TIMESUCCESS = "Lottdragningstiden är nu inställd på %d!",

	RM_START_RUNNING = "En lottdragning pågår just nu, var vänlig och dröj tills den avslutas eller använd roll stop.",
	RM_START_SENDER = "Kan ej identifiera sändaren: %s. Avbryter lottdragning...",
	RM_START_MEMBERS = "Kan ej starta lottdragning, gruppmedlemmar saknas!",
	RM_START_SUCCESS = "%s startade en lottdragning, avslutas om %d sekunder! Skriv /roll %d %d. Skriv !roll pass för att ignorera.",
	RM_START_SUCCESSITEM = "%s startade en lottdragning för %s, avslutats om %d sekunder! Skriv /roll %d %d. Skriv !roll pass för att ignorera.",

	RM_STOP_SUCCESS = "Lottdragningen avbröts.",

	RM_DO_SUCCESS = "Klart! Utförde RandomRoll(%d, %d)",

	RM_PASS_SUCCESS = "%s har ignorerat lottdragningen.",

	RM_TIME_LEFT = "%d sekunder kvar!",

	RM_ANNOUNCE_EXPIRE = "Lottdragningen avslutat! Resultaten...",
	RM_ANNOUNCE_FINISH = "Alla har dragit lotter! Resultaten...",
	RM_ANNOUNCE_EMPTY = "Ingen drog lotter, det blev inga vinnare!",
	RM_ANNOUNCE_PASS = "Alla ignorerade lottdragningen, det blev inga vinnare!",
	RM_ANNOUNCE_PASSITEM = " Alla ignorerade lottdragningen, det blev inga vinnare för %s!",
	RM_ANNOUNCE_WIN = "Vinnaren är: %s! Med lottnumret %d.",
	RM_ANNOUNCE_WINITEM = "Vinnaren är: %s! Med lottnumret %d för %s.",
	RM_ANNOUNCE_MULTIPLE = "Det finns flera vinnare:",
	RM_ANNOUNCE_MULTIPLEITEM = "Det finns flera vinnare för %s:",
	RM_ANNOUNCE_WINNER = "%s med lottnumret %d."
}

Command.LocaleManager:Register("svSE", L)
