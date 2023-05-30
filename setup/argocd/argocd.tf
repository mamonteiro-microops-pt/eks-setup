resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.34.6"
  namespace        = "argocd"
  create_namespace = true
  values = [
    "${file("./argocd/values.yaml")}"
  ]
}

resource "helm_release" "argocd_setup" {
  name = "argocd-setup"
  chart = "./argocd/argo_applications"
  # repository = ""
  version   = "1.0.5"
  values    = []
  namespace = "argocd"
  depends_on = [
    helm_release.argocd
  ]
}

# resource "kubernetes_manifest" "guestbook" {
#   manifest = yamldecode(file("./argocd/argo_applications/argo_example.yaml"))
# }
