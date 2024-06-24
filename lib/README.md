# Wrapper Library

Instead of re-implementing options parsing and validation for each mux
implementation, you can use this wrapper library. Note that this does not
handle security issues (as that really isn't possible with zsh). It just
helps prevent users from shooting themselves in the foot.

## Usage

Implement all of the below described `mux-impl-<name>` methods, and source
`build-mux.zsh` to create the mux API implementation:

```
source build-mux.zsh <func-name> <impl-def-file>
```

The `<impl-def-file>` may source other files, to spread implementation across
multiple. Any functions defined in these files will be hidden and restored
when the `<func-name>` is invoked.

The `mux-impl` functions will receive no arguments, and are expected to read
the `MuxArgs` associative array, and in special cases a few others, to
perform their actions.

## Required mux-impls

For all mux-impls, these parameters will be set:

```
MuxArgs[cmd] # the command that resulted in this impl being called
```

### Variables

The term "variables" here has a slightly different meaning than the public API:
it refers to any location-specific value, with a namespace:

- _user:_ custom variables defined by the `set-var` command
- _info:_ built-in variables defined by `set-info` and related commands
- _system:_ other built-in variables

The namespace will always be specified, and all actions below occur within that
namespace.

#### mux-impl-set-vars

Sets multiple variable values. Any variable not present in `MuxFifos` should
be deleted from the namespace.

```
MuxArgs[scope]
MuxArgs[location] # may be empty
MuxArgs[location-id] # may be empty
MuxArgs[namespace]
MuxFifos # varname -> fifo to read the value from
```

#### mux-impl-update-vars

Updates multiple variable values. Variables not present in
`MuxFifos` shold be left alone.

```
MuxArgs[scope]
MuxArgs[location] # may be empty
MuxArgs[location-id] # may be empty
MuxArgs[namespace]
MuxFifos # varname -> fifo to read the value from
```

#### mux-impl-delete-vars

Deletes multiple variables.

```
MuxArgs[scope]
MuxArgs[location] # may be empty
MuxArgs[location-id] # may be empty
MuxArgs[namespace]
mux_varnames # variable names to delete
```

#### mux-impl-get-vars

Gets the values of variables and places them into the fifos in `MuxFifos`.

```
MuxArgs[scope]
MuxArgs[location] # may be empty
MuxArgs[location-id] # may be empty
MuxArgs[namespace]
MuxFifos # varname -> fifo to write the value to
```

#### mux-impl-resolve-vars

Resolves the values of variables and places them into the fifos in `MuxFifos`.

```
MuxArgs[scope]
MuxArgs[location] # may be empty
MuxArgs[location-id] # may be empty
MuxArgs[namespace]
MuxFifos # varname -> fifo to write the value to
```

### Registers

#### mux-impl-set-registers

Sets multiple register values, deleting registers which are not present.

```
MuxFifos # regname -> fifo to get the value from
```

#### mux-impl-update-registers

Sets multiple register values, leaving other registers alone.

```
MuxFifos # regname -> fifo to get the value from
```

#### mux-impl-delete-registers

Sets multiple register values, leaving other registers alone.

```
mux_regnames # list of registers to delete
```

#### mux-impl-get-registers

Gets multiple register values.

```
MuxFifos # regname -> fifo to write the value to
```

#### mux-impl-list-registers

Gets the list of currently set regnames.

Output:

```
reply # list of regnames
```

### System

#### mux-impl-get-mux-cmd

No input.

Output:

```
REPLY # the command
```

#### mux-impl-redraw-status

No input or output. Redraws the status indicators.
