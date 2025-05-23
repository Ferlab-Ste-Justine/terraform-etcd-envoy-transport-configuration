# About

This Terraform module generates a transport envoy configuration file from the input and stores it in etcd.

The configuration file is in the format expected by this project: https://github.com/Ferlab-Ste-Justine/envoy-transport-control-plane

The configuration version is internally managed on detected file changes and strictly increasing.

# Limitations

## Supported Refresh Rates

The epoch, in seconds, is used to update the value of the configuration version.

This will be good enough as long as your configuration is not updated more than once per second which is a reasonable assumption we feel, but it should be stated.

# Usage

## Input

- **etcd_prefix**: Etcd prefix to store the configuration under.
- **node_id**: Node id of the envoy servers the configuration is for. It will be appended to the etcd prefix.
- **load_balancer**: Configuration of the load balancer. It has the following keys:
  - **services**: Array of services that the load balancer will manage. Each entry has the following keys:
    - **name**: Name of the service
    - **listening_ip**: Ip the load balancer should bind on to forward requests for the service.
    - **listening_port**: Port the load balancer should listen on to forward requests for the service.
    - **cluster_domain**: Domain the load balancer should use to resolve upstream hosts to forward requests to for the service.
    - **cluster_port**: Port the load balancer should forward service requests to on the upstream hosts.
    - **idle_timeout**: Amount of time the load balancer should wait before closing an idle connection on the service. Should be in golang duration format.
    - **idle_timeout**: Maximum number of concurrent connections the load balancer should accept to forward for the service.
    - **access_log_format**: Format of the access logs. See the following reference: https://www.envoyproxy.io/docs/envoy/v1.25.2/configuration/observability/access_log/usage#config-access-log-format-strings. Keep in mind here that this is a transport proxy (tcp), when looking at which arguments are supported.
    - **health_check**: Configuration of the connection health checks for each upstream host. It has the following keys:
      - **timeout**: Timeout of individual health check connections. Should be in golang duration format.
      - **interval**: Interval at which healtch check connections should be attempted. Should be in golang duration format.
      - **healthy_threshold**: How many successful connection requests on a healthy host are required before the host is deemed healthy.
      - **unhealthy_threshold**: How many failed connection requests on an unhealthy host are required before the host is deemed unhealthy.
      - **http**: Parameters to performan an http healthcheck instead of a tcp check
        - **enabled**: If true, the healthcheck will be with http
        - **path**: Path of the healthcheck http requests
        - **status_code_range**: Range of acceptable response status codes
          - **start**: First acceptable response status code in the range
          - **end**: Last acceptable response status code in the range
    - **tls_termination**: Configure service with tls termination using certificate/key files relative to envoy's execution path.
      - **listener_certificate**: Path of the certificate to present to clients
      - **listener_key**: Path of the private key to present to clients
      - **cluster_ca_certificate**: Path to an optional CA certificate validate the backend cluster's server certificate with if the connection on the backend is over tls.
      - **cluster_client_key**: Path to an optional client private key if the connection on the backend is over tls.
      - **cluster_client_certificate**: Path to an optional client certificate if the connection on the backend is over tls. 
      - **http_listener**: Parameters if using an optional http listener. It has the following keys:
        - **enabled**: Boolean value to optionally use a L7 http listener.
        - **server_name**: Server name to return on http requests.
        - **max_concurrent_streams**: Maximum number of streams to allow per peer for clients using http/2.
        - **request_headers_timeout**: The maximum amount of time envoy will wait for all headers to be received once the initial byte is sent.
        - **use_remote_address**: Whether envoy should append to the **x-forwarded-for** header with the client ip. Should be set to true when setting up an edge load balancer.
        - **initial_connection_window_size**: Window size (in bytes) allocated to a new http/2 connection. Should be set to conservatively small amount for edge load balancer.
        - **initial_stream_window_size**: Window size (in bytes) allocated to a new http/2 stream. Should be set to conservatively small amount for edge load balancer.
  - **dns_servers**: Array of dns servers that the load balancer will use to discover upstread hosts based on their domain. Each entry has the following keys:
    - **ip**: Ip address of the dns server
    - **port**: Port the dns server listens on