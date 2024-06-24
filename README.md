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

In the below commands, `<regname>` must be `unnamed` or a single character
`[a-z]`

#### set-register

`set-register <regname> <value>`

#### load-register

`load-register <regname>`

Sets the value of `<regname>` from stdin. Useful for piping in scripts and
communicating with other processes.

#### delete-register

`delete-register <regname>`

#### show-register

`show-register <regname>`

Similar to `show-var`, mimics `echo` with trailing newline.

#### get-register

`get-register <regname>`

Gets the value of a register, similar to `get-var`, without trailing newline,
like `echo -n`

#### list-registers

`list-registers` (no arguments)

Lists the names of all currently stored registers, each on a new line.

#### dump-registers

`dump-registers <regname> <fifo> ...`

Writes the values of all specified registers into FIFOs to be read by another
process.

The positional arguments define a map from `regname` -> `fifo`, repeated for as
many registers as desired.

### Info

When info is changed, the mux should redraw its status indicators.

#### set-info

```
set-info [scope/location] <scope> \
    [--icon <icon>] \
    [--icon-color <iconcolor>] \
    [--title <title>] \
    [--title-style <titlestyle>]
```

Sets the specified information at the given scope. Anything not specified
present is unset.

#### update-info

Updates (merges) the specified information at the given scope. Anything not set
is left unchanged.

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

#### register-child-mux

`register-child-mux [location] <muxcmd>`

Informs this mux session that the specified buffer is running a mux session.

- `<muxcmd>`: a command which can be used to interact with child session
  through this API

#### unregister-child-mux

`unregister-child-mux [location]`

Informs this mux session that the specified buffer is not running a mux session.

#### get-child-mux

`get-child-mux [location]`

Gets the command set with `register-child-mux`

#### get-mux-cmd

`get-mux-cmd` (no arguments)

Gets the command that can be used to interact with this mux session.

### System Calls

These calls are used to coordinate interactions between muxes in a tree.

#### redraw-status

`redraw-status` (no arguments)

Instructs this mux to redraw / refresh any status indicators that depend on mux
info or variables.

#### sync-registers-down

`sync-registers-down` (no arguments)

Sets the values of the registers in this mux session to the values stored by
the parent mux.

#### sync-registers-up

`sync-registers-up [location]`

Sets the values of the registers in this mux session to the values stored by
the child mux at the specified location.

#### sync-child-info

`sync-child-info [location]`

Sets the info at the specified buffer location to the session-level info of the
child mux it is running.
