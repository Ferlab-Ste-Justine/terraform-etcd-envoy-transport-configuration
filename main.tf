resource "time_static" "configuration_update" {
  triggers = {
    zonefile_md5 = md5(yamlencode(var.load_balancer))
  }
}

resource "etcd_key" "lb_configs" {
  key = "${var.etcd_prefix}${var.node_id}"
  value = yamlencode({
    version     = time_static.configuration_update.unix
    services    = var.load_balancer.services
    dns_servers = var.load_balancer.dns_servers
  })
}