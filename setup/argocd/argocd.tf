resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.29.1"
  namespace        = "argocd"
  create_namespace = true
  values = [
    <<EOT
    server:
        config:
            url: "https://kubernetes.default.svc"
            username: admin
        service:
            type: LoadBalancer
    configs:
        secret:
            argocdServerAdminPassword: $2a$10$CAF82t.Bs.C030HGplOLZebyppdkBGliti03ZAKqmJJTh3Mf95cBq
    EOT
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
