package terraform.policies

# =============================================================================
# Politica: Denegar acceso SSH publico
# -----------------------------------------------------------------------------
# Objetivo:
#   Impedir que cualquier Security Group exponga el puerto 22 (SSH) al
#   bloque 0.0.0.0/0 (toda internet), lo que constituye una vulnerabilidad
#   critica de exposicion perimetral.
#
# Criterio de denegacion:
#   Recurso de tipo aws_security_group con una regla de ingress donde:
#     - from_port <= 22 <= to_port
#     - cidr_blocks contenga "0.0.0.0/0"
#
# Indicador evaluado: IL2.1 (Politicas de seguridad)
# Compatibilidad: Rego v1 (OPA >= 1.0)
# =============================================================================
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    ingress := resource.change.after.ingress[_]
    ingress.from_port <= 22
    ingress.to_port >= 22
    ingress.cidr_blocks[_] == "0.0.0.0/0"

    msg := sprintf(
        "Violacion de Seguridad: el Security Group '%s' expone el puerto SSH (22) a 0.0.0.0/0",
        [resource.address],
    )
}
