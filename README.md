# Unified Mux API

TODO: rework to simpler API

Nesting terminal multiplexers gets pretty complicated, especiallly when you
have different multiplexing applications (e.g., `wezterm` and `tmux` and `nvim`) at the
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

### Syncing Data

Children are responsible for setting the buffer-level info of their parent to
their resolved session-level info.

## API

`mux [[-I | --instance] <instance>] <command> [<command options and args>]`

- `-I, --instance`: the mux instance to run the command on. At most one of
  `--level` or `--instance` may be specified.

### Mux tree

Each child has a pointer to its parent -- the parent, however, is unaware of
its children. Data flows up the tree, but not down it.

### Common Options

Some options are reused in multiple commands and defined here for brevity.

#### Command Verbs

Some command names begin with a verb that has a consistent meaning across all
commands.

Retrieving data:
- _get_: prints a raw value onto stdout
- _resolve_: for local values, inherits non-existent keys upward from lower
  scopes, and reports the resolved value
- _has_: succeeds if the key exists, fails otherwise
- _list_: prints a list of keys separated by newlines

Modifying data:
- _set_: sets values to arguments passed into the command. For map-like set
  commands, deletes unspecified keys
- _update_: merges map-like values specified in the arguments into the stored
  data
- _delete_: unsets one or more values

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

`set-var [scope/location] <varname>`

#### delete-var

`delete-var [scope/location] <varname>`

#### get-var

`get-var [scope/location] <varname>`

#### resolve-var

`resolve-var [scope/location] <varname>`

### Info

When info is changed, the mux should redraw its status indicators.

#### set-info and update-info

```zsh
{set,update}-info [scope/location] \
    [icon <icon>] \
    [icon_color <iconcolor>] \
    [title <title>] \
    [title_style <titlestyle>]
```

`set-info` clears out the existing info and sets only the specified values.

`update-info` merges the specified values into the existing info.

#### resolve-info

`resolve-info [scope/location] <scope>`

Resolves info at the given scope, inheriting upward from the active child scope
if the value is unset. Info is printed in the form `infoentry value`, each on a
new line.

### Mux Tree

Mux sessions exist in a tree structure -- the buffer of one mux might be
running a mux session of a child. Children keep a pointer to their parent mux.

#### get-parent

`list-parents` (no arguments)

Gets the socket that can be used to interact with the parent mux session.
