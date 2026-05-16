resource "kubernetes_job_v1" "mission" {
  metadata {
    name = "mission-deploy-job"
  }

  spec {
    template {
      metadata {}
      spec {
        # Pod-level security: reject if container tries to run as root
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
        }

        container {
          name              = "mission"
          image             = "mission-deploy:1.0"
          image_pull_policy = "Never"

          # Container-level security: read-only filesystem, no privilege escalation
          security_context {
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
            capabilities {
              drop = ["ALL"]
            }
          }

          # Resource limits prevent the container from consuming excessive resources
          resources {
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 2
  }

  wait_for_completion = true

  timeouts {
    create = "2m"
  }
}
