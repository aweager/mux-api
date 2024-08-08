# Unified Mux API

```
WARNING: If you're using this, don't
```

TODO: rework README to simpler API
TODO: rework to JSON output for some commands

Nesting terminal multiplexers gets pretty complicated, especiallly when you
have different multiplexing applications (e.g., wezterm and tmux and neovim) at the
same time. This API allows for a unified scripting setup to manipulate
a graph of muxes.

## Concepts and terminology

### Scopes and locations

Multiplexers support running multiple programs (or editing multiple files) in
their own hierarchical graph structure. In tmux, that structure looks something
like this:
- A _server_ contains one or more _sessions_
- A _session_ contains one or more _windows_
- A _window_ contains one or more _panes_

The terms "server," "session," "window," and "pane" are examples of _scopes_. A
specific server, session, window, or scope would be a _location_.

Neovim similarly has a hierarchical graph structure:
- A _session_ contains one or more _tabpages_
    - n.b.: there isn't an actual term for "the global space" that holds the
      tabpages, but session makes sense
- A _tabpage_ contains one or more _windows_
- A _window_ displays a _buffer_

Note that this hierarchy is not necessarily a tree:
- A tmux window can belong to multiple sessions
- A neovim buffer can belong to multiple windows

### Local variables

At each location, you can attach variables to help with arbitrary scripting.

### Local information

Multiplexers usually have some mechanism for displaying information about a
session, tab, and pane:
- tmux has the status bar, which displays windows and other arbitrary info
- nvim has the tab line, status line, and winbar (and the things vim has)

Most automatically-derived information is attached to the lowest scope, and
based on things like the current directory, actively running program, file name,
etc. Some statically-named information can be specified by the user, e.g.
session name, tab name, icons, styling, and the list goes on.

Info values may not contain newlines.

### Resolution of values

When fetching the value of a variable or piece of information at a location,
you can either query for the value as it was set at that location, or you can
"resolve" the value based on that location's child locations. In tmux, for
instance, the name of a window can be determined by the currently running
process in that window's active pane.

### Connecting mux hierarchies

The main benefit of this unified API is the automatic connection of mux
hierarchies together. For example, a neovim instance running in a tmux pane
should report its session-level info upward to the tmux pane.

This connection is limited to local info; local variables are not published
upward.

## API

`mux [[-I | --instance] <instance>] <command> [<command options and args>]`

- `-I, --instance`: the mux instance to run the command on. If not specified,
  the value of `$MUX_SOCKET` is used

### Mux hierarchy

Each child has pointers to its parents -- the parents, however, are unaware of
their children. Info flows up the tree, but not down it.

### Variables

In the below commands, `<varname>` must consist only of alphanumeric characters,
and is case sensitive.

#### get-var

`get-var <location> <varname>`

Writes the value of `varname` at `location` onto stadard output. Fails if
the value does not exist at that location, or if the location does not exist.

#### resolve-var

`resolve-var <location> <varname>`

Resolves the value of `varname` at `location`, and writes it onto standard
output. Fails of the location does not exist.

#### set-var

`set-var <location> <varname>`

Sets the value of `varname` at `location` to the contents of standard input.
Fails if the location does not exist.

#### delete-var

`delete-var <location> <varname>`

Deletes `varname` at `location`. Fails if the location does not exist.

#### has-var

`has-var <location> <varname>`

Succeeds if `location` has a value associated with `varname`, otherwise fails.
Does not write anything to standard output or error.

#### list-vars

`list-vars <location>`

Lists variable names at `location`, one on each line. Fails if `location` does
not exist.

### Info

When info is changed, the mux should redraw its status indicators.

#### get-info

`get-info <location> [<keys>...]`

Gets the info at `location` with the specified `keys`. Usually, `keys` is
something like `icon icon_color title title_style`.

Writes the values of the keys in the format:

```
key1 value1
key2 value2
```

If a key does not have a value, the key will be output with no following space.
If the key has a value but that value is the empty string, the key will be
followed by a space.

#### resolve-info

`resolve-info <location> [<keys>]...`

Similar to `get-info`, except the values are resolved.

#### set-info

`set-info <location> [<key> <value>]...`

Deletes all existing info at `location`, and sets each `key` to `value`.

#### merge-info

`merge-info <location> [<key> <value>]...`

Sets the info at `location` for each `key` to its `value`, but otherwise leaves
existing info records alone.

#### delete-info

`delete-info <location> [<key>...]`

Deletes the info keys at `location`.

#### has-info

`has-info <location> <key>`

Succeeds if `location` has info at `key`, fails otherwise.

#### list-info

`list-info <location>`

Lists the info keys set at `location`. Fails if location does not exist.
