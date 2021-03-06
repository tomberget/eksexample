resource "kubernetes_namespace" "external_dns" {
  metadata {
    annotations = {
      name = var.namespace
    }

    name = var.namespace
  }
}

resource "helm_release" "external_dns" {
  count = var.external_dns_enabled ? 1 : 0

  name       = var.chart_name
  repository = var.repository
  chart      = var.chart_name
  version    = var.chart_version
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  timeout    = 600

  values = [
    data.template_file.external_dns_config.rendered
  ]
}

data "template_file" "external_dns_config" {
  template = file("${path.root}/modules/external_dns/config.yaml")

  vars = {
    external_dns_region    = var.external_dns_region
    account_id             = var.account_id
    txt_owner_id           = var.txt_owner_id
    external_dns_role_name = var.external_dns_role_name
  }
}
