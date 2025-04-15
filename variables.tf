variable "etcd_prefix" {
  description = "Prefix of the keyspace to work on"
  type = string
}

variable "node_id" {
  description = "Envoy node id the configuration is for"
  type = string
}

variable "load_balancer" {
  description = "Load balancer configs"
  type = object({
    services = list(object({
      name                   = string
      listening_ip           = string
      listening_port         = number
      cluster_domain         = string
      cluster_port           = number
      idle_timeout           = optional(string, "600s")
      max_connections        = optional(number, 200)
      access_log_format      = string
      health_check           = object({
        timeout             = optional(string, "3s")
        interval            = optional(string, "3s")
        healthy_threshold   = optional(number, 1)
        unhealthy_threshold = optional(number, 2)
        http                = optional(object({
          enabled           = optional(bool, false)
          path              = optional(string, "/")
          status_code_range = object({
            start = optional(number, 200)
            end  = optional(number, 200)
          })
        }), {
          enabled           = false
          path              = ""
          status_code_range = []
        })
      })
      tls_termination        = object({
        listener_certificate       = string
        listener_key               = string
        cluster_ca_certificate     = string
        cluster_client_key         = string
        cluster_client_certificate = string
        http_listener            = optional(object({
          enabled                        = optional(bool, false)
          server_name                    = optional(string, "envoy")
          max_concurrent_streams         = optional(number, 128)
          request_headers_timeout        = optional(string, "10s")
          use_remote_address             = optional(bool, true)
          initial_connection_window_size = optional(number, 1048576)
          initial_stream_window_size     = optional(number, 65536) 
        }), {
          enabled                        = false
          server_name                    = "envoy"
          max_concurrent_streams         = 128
          request_headers_timeout        = "10s"
          use_remote_address             = true
          initial_connection_window_size = 1048576
          initial_stream_window_size     = 65536
        })
      })
    }))
    dns_servers = list(object({
      ip   = string
      port = number
    }))
  })
}
