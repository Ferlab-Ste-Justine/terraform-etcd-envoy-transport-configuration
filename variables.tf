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
      })
      tls_termination        = object({
        listener_certificate       = string
        listener_key               = string
        cluster_ca_certificate     = string
        cluster_client_key         = string
        cluster_client_certificate = string
        use_http_listener          = optional(bool, false)
        http_parameters            = optional(object({
          server_name            = string
          max_concurrent_streams = number
        }), {
          server_name            = "envoy"
          max_concurrent_streams = 2147483647
        })
      })
    }))
    dns_servers = list(object({
      ip   = string
      port = number
    }))
  })
}
