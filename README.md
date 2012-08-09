== Command ==

This addon will provide players with the ability to whisper special commands to you (or send them via guild/raid/party chat).

The style of the commands is much like the one used for IRC bots, !<command> <args>. The ability to control the command prefix (in the previous example: "!") is available, so you could actually choose any character (or string of characters) as a prefix, e.g.:
.<command> <args>
prefix<command> <args>

Etc, etc. The main aim of this addon is to enable your group to function while you (the group leader) is AFK or simply not paying attention. Or maybe you want to give some control to the players, but not as much as the raid assistant rank would give them.

The Command AddOn will have a permission system (currently rather primitive), where you can give players different access levels and control what commands are available on a per-group and per-user system. Blacklisting or whitelisting of commands is also available (blacklisting and whitelisting of players is not yet implemented, but banning players is possible).

=== Permission System ===

More information here when permission system is finished...

=== Command List ===

Command list can be found on the [[https://github.com/F16Gaming/Command/wiki/Commands|wiki]].

=== Limitations ===

Due to the limitations in the WoW API, there are certain things this AddOn can't do, or things that are more complicated to do.

As an example we can look at the !kick command, Blizzard does not allow an AddOn to kick players without that action being in response to a hardware event (such as clicking a button). Due to this, when a player issues the !kick command, a confirmation window will pop up asking you to confirm the kick.

=== Documentation ===

Documentation of the AddOn is available on [[http://f16gaming.github.com/Command|GitHub Pages]] (**OUTDATED**).

In theory you could create a "plugin" for this AddOn by making sure your AddOn loads after Command and use the Register method in the CommandManager to register your commands. This, however, is not recommended. If the need arises and enough people want it, I might try to create a proper module system.
