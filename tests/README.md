# Planes de prueba para políticas OPA

Esta carpeta contiene planes de Terraform en formato JSON que sirven como **fixtures de prueba** para validar el comportamiento de las políticas OPA de forma independiente (sin necesidad de ejecutar `terraform plan` real contra AWS).

## Escenarios disponibles

| Archivo | Descripción | Resultado esperado |
|---|---|---|
| `plan-conforme.json` | Infra con SSH restringido a VPC + `t2.micro` | ALLOW `[]` |
| `plan-ssh-publico.json` | SG con SSH abierto a `0.0.0.0/0` | DENY por política SSH |
| `plan-tipo-invalido.json` | EC2 con `instance_type = t3.medium` | DENY por política tipo |

## Cómo ejecutar los tests

Desde la raíz del repo, con OPA instalado:

```bash
# Escenario A - debe devolver []
opa eval -d policies/ -i tests/plan-conforme.json "data.terraform.policies.deny" --format=pretty

# Escenario B - debe devolver mensaje de violación SSH
opa eval -d policies/ -i tests/plan-ssh-publico.json "data.terraform.policies.deny" --format=pretty

# Escenario C - debe devolver mensaje de violación tipo
opa eval -d policies/ -i tests/plan-tipo-invalido.json "data.terraform.policies.deny" --format=pretty
```

## Cómo se generaron

Los planes `plan-ssh-publico.json` y `plan-tipo-invalido.json` son versiones simplificadas de la salida de `terraform show -json` con modificaciones intencionales que violan cada política, para probar aislada y rápidamente el comportamiento de las reglas Rego.

Esto permite validar IE2.3.1 (pruebas de efectividad de políticas) sin depender de credenciales AWS activas.
