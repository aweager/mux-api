# MuxAPI

MuxAPI provides hierarchical variable storage across terminal multiplexer
scopes. It is designed to work for different mux-like programs, mainly tmux and
neovim.

All methods are accessed via JSON-RPC 2.0 through the jrpc-mesh proxy. Method
names are prefixed with the service name when routed (e.g.,
`myservice/MuxAPI.GetMultipleVars`).

## Common Types

### Location

A location reference string in the format `scope:target`. Exact valid scope and
target values depend on the implementation.

## MuxAPI Methods

### MuxAPI.GetMultipleVars

Gets specific variables from a location without scope resolution.

Request parameters:

```json
{
    "location": "s:$0",
    "namespace": "INFO",
    "keys": ["var1", "var2"]
}
```

Result:

```json
{
    "values": {
        "var1": "value1",
        "var2": null
    }
}
```

Values are `null` if not set at the exact location.

### MuxAPI.GetAllVars

Gets all variables in a namespace from a location without scope resolution.

Request parameters:

```json
{
    "location": "s:$0",
    "namespace": "INFO"
}
```

Result:

```json
{
    "values": {
        "var1": "value1",
        "var2": "value2"
    }
}
```

Only includes variables that are set (no null values).

### MuxAPI.ResolveMultipleVars

Gets specific variables with scope resolution (inherits from parent scopes).

Request parameters:

```json
{
    "location": "p:%5",
    "namespace": "INFO",
    "keys": ["var1", "var2"]
}
```

Result:

```json
{
    "values": {
        "var1": "value1",
        "var2": null
    }
}
```

Resolves through the scope hierarchy, starting from the bottom.

### MuxAPI.ResolveAllVars

Gets all variables in a namespace with scope resolution.

Request parameters:

```json
{
    "location": "p:%5",
    "namespace": "INFO"
}
```

Result:

```json
{
    "values": {
        "var1": "value1",
        "var2": "value2"
    }
}
```

### MuxAPI.SetMultipleVars

Sets or unsets multiple variables at a location.

Request parameters:

```json
{
    "location": "s:$0",
    "namespace": "INFO",
    "values": {
        "var1": "newvalue",
        "var2": null
    }
}
```

Set value to `null` to unset a variable.

This method returns an empty result.

### MuxAPI.ClearAndReplaceVars

Clears all variables in a namespace and replaces with new values.

Request parameters:

```json
{
    "location": "s:$0",
    "namespace": "INFO",
    "values": {
        "var1": "value1",
        "var2": "value2"
    }
}
```

This method returns an empty result.

### MuxAPI.GetLocationInfo

Checks if a location reference exists and returns its canonical ID.

Request parameters:

```json
{
    "ref": "s:mysession"
}
```

Result:

```json
{
    "exists": true,
    "id": "$0"
}
```

If the location doesn't exist, `exists` is `false` and `id` is omitted.