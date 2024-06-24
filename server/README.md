# Server

The server is designed to process requests in order, one at a time, from a unix
domain socket.

## Listener

Listens on a socket for requests. The format of a request is:

```
<stdin> <stdout> <stderr> <response-pipe> <client-id>
<command>
```

- `client-id`: the PID of the client (used for logging)
- `response-pipe`: the file to write to when communicating to the client
- `stdin, stdout, stderr`: files to use for standard IO when executing the
  request
- `command`: the actual request to execute

Once the command is completed, the server writes the status code to
the `response-pipe`.

Following the command, the client will send a code indicating how it wants to
detach. The code tells the server what to do with the running request:

- `-1`: background the requests
- `0`: request was completed
- `1`: interrupt and cancel the requests

## Executor loop

Takes commands from standard input and executes them. Requests are separated by
newlines (`'\n'`).

## Call

Calls the server through the socket. Responsible for forwarding file descriptors
through FIFOs or ttys.
