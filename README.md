# AUY1105 — Infraestructura como Código II

## Evaluación Parcial 2: Implementación de Módulos Terraform

**Grupo 3** — Integrantes:
- Daniel Tapia Sobarzo — [@recouma](https://github.com/recouma)
- Carlos Rodrigo Cuevas Núñez — [@carlcuevas](https://github.com/carlcuevas)

---

## Propósito del Proyecto

Este repositorio principal orquesta la infraestructura en AWS mediante módulos de Terraform desacoplados, siguiendo buenas prácticas de documentación, versionado semántico y reutilización de código.

## Arquitectura Modular

| Módulo | Repositorio | Recursos |
|---|---|---|
| **Redes** | [terraform-aws-vpc-auy1105-grupo-3](https://github.com/recouma/terraform-aws-vpc-auy1105-grupo-3) | VPC, Subnets, IGW, SG |
| **Cómputo** | [terraform-aws-ec2-auy1105-grupo-3](https://github.com/recouma/terraform-aws-ec2-auy1105-grupo-3) | EC2 Instance |
| **Almacenamiento** | [terraform-aws-s3-auy1105-grupo-3](https://github.com/recouma/terraform-aws-s3-auy1105-grupo-3) | S3 Bucket |

## Instrucciones de Uso

```bash
git clone https://github.com/carlcuevas/AUY1105-grupo-3.git
cd AUY1105-grupo-3
terraform init
terraform plan
terraform apply
```

## Versionado

Cada módulo sigue versionado semántico (MAJOR.MINOR.PATCH):
- `v0.1.0` — Estructura inicial del módulo.
- `v1.0.0` — Primera versión estable y funcional.

## Pipeline CI/CD

Se mantienen los pasos de validación de la Evaluación Parcial 1:
- TFLint — Análisis estático.
- Checkov — Escaneo de seguridad.
- terraform validate — Validación sintáctica.
- OPA — Evaluación de políticas.
