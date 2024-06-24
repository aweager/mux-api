# Setup

The server is designed to only process one request at a time.

## Wrapper

Listens on a socket for requests, and passes them along to the executor on its
standard input.

## Executor

Listens for commands on standard input, and executes them.

## Call

Calls the server through the socket. Responsible for forwarding file descriptors
using socat.
