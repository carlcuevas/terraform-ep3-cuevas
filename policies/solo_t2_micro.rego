package terraform.policies

# =============================================================================
# Politica: Restringir tipo de instancia EC2 a t2.micro
# -----------------------------------------------------------------------------
# Objetivo:
#   Controlar costos y cumplir con los requerimientos del proyecto limitando
#   la creacion de instancias EC2 exclusivamente al tipo t2.micro.
#
# Criterio de denegacion:
#   Recurso de tipo aws_instance cuyo instance_type sea distinto de "t2.micro".
#
# Indicador evaluado: IL2.1 (Politicas de seguridad)
# Compatibilidad: Rego v1 (OPA >= 1.0)
# =============================================================================
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_instance"
    resource.change.after.instance_type != "t2.micro"

    msg := sprintf(
        "Violacion de Politica: la instancia '%s' usa tipo '%s'. Solo se permite t2.micro",
        [resource.address, resource.change.after.instance_type],
    )
}
