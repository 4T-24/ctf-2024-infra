resource "helm_release" "this" {
  name = "flux2"

  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"

  namespace        = "flux-system"
  create_namespace = true
  wait             = true
}
