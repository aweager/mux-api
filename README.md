# Unified Mux API

Nesting terminal multiplexers gets pretty complicated, especiallly when you
have different multiplexing applications (e.g., `kitty` and `tmux` and `nvim`) at the
same time. This API allows for a unified scripting setup to manipulate
a tree of muxes.

## Concepts and Terminology

### Scopes and Locations

There are four _scopes_, from largest to smallest. Terminology gets confusing
between different multiplexers, so this api attempts to unify those and give
analogy to `tmux` and `vim`.
- _session:_ the largest managed scope. Think `tmux` session or an open
  instance of `vim`
- _tab:_ fills almost the whole screen, with a tabbar of some kind usually
  visible. Think `tmux` windows or `vim` tabpages
- _pane:_ a rectangular chunk of the screen through which you can view a
  buffer. Think `tmux` panes or `vim` windows
- _buffer:_ the thing you look at inside of a pane. `tmux` does not support
  this concept, so it basically collapses into pane, but `vim` distinguishes
  between buffers (the chunk of text you interact with) and windows, which are
  viewports into a buffer

Session -> tab -> pane are organized in a strict tree structure, so a pane will
always have exactly one, constant parent tab, and a tab will have one, constant
parent session. Pane -> buffer, however, does not have to obey this structure. A
buffer may be visible in multiple panes at the same time, or not visible in any
pane at all. This follows `vim` conventions for buffers and windows.

A _location_ is a specific session, tab, pane, or buffer that you want to act
upon with a command. At each scope, one exactly location is the _active_
location (i.e., the one that receives keystrokes). So there is always exactly
one active tab, one active pane, and one active buffer. All commands, unless
otherwise specified, act upon the currently active location for the specified
scope.

Location IDs are:
- _fully scoped:_ given a location ID, you know exactly what its scope is
  - there is only one valid session location, `s:`
  - tab location IDs start with `t:`
  - pane location IDs start with `p:`
  - buffer location IDs start with `b:`
- _constant:_ no matter how you rearrange the tabs/panes/buffers, the ID stays
  the same

### Registers

Registers are storage locations used for copy-paste. In `tmux`, this concept is
called _buffers_, which conflicts with the `vim` idea of buffers... so I went
with registers to match `vim`.

`tmux` has special numbered buffers, as does `vim`, but those are not covered by
this API as manipulating them in a way that makes sense for both programs would
be challenging. `tmux` supports arbitrarily named buffers, but `vim` only
supports [a-z], unnamed, and OS registers. The OS registers (copy and selection)
should be handled by a dedicated tool for interacting with the OS (e.g. OSC esc
codes).

With this background, this API supports the following register names:
- Single-character, lowercase alphabetic characters [a-z]
- The special register "unnamed"

### Variables

At each scope, you can attach variables to help with arbitrary scripting.

In general, favor buffers over panes when setting variables.

### Local Information

Multiplexers usually have some mechanism for displaying information about a
session, tab, and pane:
- `tmux` has the status bar, which displays windows and other arbitrary info
- `vim` has the tabline and statusline
- `nvim` has the winbar

Most automatically-derived information is attached to a buffer, and based on
things like the current directory, actively running program, file name, etc.
Some statically-named information can be specified by the user, e.g. session
name, tab name, icons, styling, and the list goes on.

This API assumes the implementation of the defaults gets surfaced upward from
the currently active buffer, as that's what I usually want to happen, but it
also supports overriding that at subsequently higher scopes.

## API

`mux [--level <level> | --instance <instance>] <command> [<command options and args>]`

- `-L, --level`: the level in the stack to run the command on. The top of the
  stack is `0`, counting upward. Negative numbers can be used to reference the
  bottom of the stack starting at `-1`
- `-I, --instance`: the mux instance to run the command on. At most one of
  `--level` or `--instance` may be specified.

### Levels and the Mux Stack

Nested muxes are supported using the `MUX_STACK` environment variable, which in
`zsh` is linked to `mux_stack`. The values are split on ';'. Each entry is a
command which, when evaluated, allows manipulation of that mux session. The
`mux` command will, by default, use the mux session at the top of the stack.

### Common Options

Some options are reused in multiple commands and defined here for brevity.

#### Command Verbs

Some command names begin with a verb that has a consistent meaning across all
commands.

Retrieving data:
- _show_: displays one or more values in a way appropriate for interactive use
- _get_: gets a value without trailing newline (like `echo -n`)
- _has_: succeeds if the key exists, fails otherwise
- _list_: prints a list of keys separated by newlines

Modifying data:
- _set_: sets values to arguments passed into the command. For map-like set
  commands, deletes unspecified keys
- _update_: merges map-like values specified in the arguments into the stored
  data
- _delete_: unsets one or more values

Piping data to and from files (usually fifos):
- _save_: saves multiple values, specified as a map from key -> file to write
  to. Analogous to "get"
- _replace_: replaces the value store with the contents of the files specified
  in the arguments. Analogous to "set"
- _load_: loads multiple values into the store, specified as a map from key ->
  file to read from. Analogous to "update"

#### Scopes

Scopes are specified using `--scope`, and must take a value of:
- session
- tab
- pane
- buffer

Alternatively, these short options may be used to specify scope:
- `-s`: session
- `-t`: tab
- `-p`: pane
- `-b`: buffer

#### Locations

Locations are specified using `-l` or `--location`. By default, the currently
active location for the specified scope is used. If both scope and location
are specified, they must match.

### Variables

In the below commands, `<varname>` must consist only of alphanumeric characters,
and is case sensitive.

#### set-var

`set-var [scope/location] <varname> <value>`

#### delete-var

`delete-var [scope/location] <scope> <varname>`

#### show-var

`show-var [scope/location] <scope> <varname>`

Prints the value of the specified variable, including a trailing newline like
`echo`

#### get-var

`get-var [scope/location] <scope> <varname>`

Prints the value of the specified variable, excluding the trailing newline like
`echo -n`

### Registers

In the below commands, `${regname}` must be `unnamed` or a single character
`[a-z]`

#### Retrieving Register Values

```zsh
show-register ${regname}
get-register ${regname}
has-register ${regname}
list-registers
```

#### Modifying Register Values

```zsh
set-register ${regname} ${value}
delete-registers ${regname} ...
```

#### Piping Registers to/from Files

```zsh
save-registers ${regname} ${file} ...
replace-registers ${regname} ${file} ...
load-registers ${regname} ${file} ...
```

### Info

When info is changed, the mux should redraw its status indicators.

#### set-info and update-info

```zsh
{set,update}-info [scope/location] <scope> \
    [--icon <icon>] \
    [--icon-color <iconcolor>] \
    [--title <title>] \
    [--title-style <titlestyle>]
```

`set-info` clears out the existing info and sets only the specified values.

`update-info` merges the specified values into the existing info.

#### resolve-info

`resolve-info [scope/location] <scope>`

Resolves info at the given scope, inheriting upward from the active child scope
if the value is unset. Info is printed in the form `infoentry value`, each on a
new line.

#### set-<infoentry>

`set-icon [scope/location] <scope> <value>`

#### get-<infoentry>

`get-icon [scope/location] <scope>`

#### resolve-<infoentry>

`resolve-icon [scope/location] <scope>`


### Mux Tree

Mux sessions exist in a tree structure -- the buffer of one mux might be
running a mux session of a child. So each buffer can point to its child
mux session, and each mux session can point to its parent mux session.

#### get-child-mux

`get-child-mux [location]`

Gets the command that can be used to interact with the child mux session at the
specified location.

#### get-parent-mux

`get-parent-mux` (no arguments)

Gets the command that can be used to interact with the parent mux session.

#### get-mux-cmd

`get-mux-cmd` (no arguments)

Gets the command that can be used to interact with this mux session.

### System Calls

These calls are used to coordinate interactions between muxes in a tree.

#### Linking Muxes

A link between parent and child is established by making two calls, one
on the parent and one on the child:

```
parent-mux link-child [location] <muxcmd>
child-mux link-parent <muxcmd>
```

A link is removed by making these two calls:

```
child-mux unlink-parent <muxcmd>
parent-mux unlink-child [location]
```

##### link-child

`link-child [location] <muxcmd>`

Links this mux to a new child at the given location, setting the buffer-level
info to match the child's session-level info.

##### link-parent

`link-parent <muxcmd>`

Links this mux under a new parent, performing an initial downward data sync.

##### unlink-child

`unlink-child [location]`

Removes the link to the child at the specified location, clearing the buffer-
level info.

##### unlink-parent

`unlink-parent` (no arguments)

Removes the link to the parent.

#### Syncing Data

##### sync-registers-down

`sync-registers-down` (no arguments)

Sets the values of the registers in this mux session to the values stored by
the parent mux.

##### sync-registers-up

`sync-registers-up [location]`

Sets the values of the registers in this mux session to the values stored by
the child mux at the specified location.

##### sync-child-info

`sync-child-info [location]`

Sets the info at the specified buffer location to the session-level info of the
child mux it is running.

#### redraw-status

`redraw-status` (no arguments)

Instructs this mux to redraw / refresh any status indicators that depend on mux
info or variables.
