# at_test_proxy

A CLI proxy for debugging and testing TLS/TCP communication.

## Installation

## Usage

### Starting the proxy

TLS socket:

```bash
./attp -c <host-of-service:port-of-service> \
  -s localhost:<local-port> \
  --pub <tls-certficate-chain> \
  --priv <tls-private-key> \
  --cert <tls-trusted-certificates>
```

TCP socket (-r for raw tcp socket):

```bash
./attp -r -c <host-of-service:port-of-service> \
  -s localhost:<local-port>
```

### Using the proxy

Available commands `command (abbreviation)`:

#### Forward (f)

Forward the request / response to the other side.

Example: `forward`

#### Modify (m)

Intercept, modify and forward the message.

Example: `modify my_new_message`

#### Respond (m)

Only allowed when the message is a request from the application.
Respond with a message without sending anything to the server.

Example: `respond my_message`

#### Skip (s)

No-op, ignore the message.

Example: `skip`


