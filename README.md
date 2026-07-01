#  AUY1105 - Evaluación Parcial N°3

## Gestión Avanzada del Estado en Terraform

> **Asignatura:** Infraestructura como Código II (AUY1105)\
> **Estudiante:** Carlos Rodrigo Cuevas\
> **Institución:** Duoc UC\
> **Plataforma Cloud:** Amazon Web Services (AWS)\
> **Herramienta IaC:** Terraform

------------------------------------------------------------------------

#  Descripción

Este repositorio contiene la infraestructura desarrollada para la
**Evaluación Parcial N°3** de la asignatura **Infraestructura como
Código II**.

El objetivo principal consiste en demostrar el manejo avanzado del
archivo de estado (`terraform.tfstate`) utilizando comandos de
**Terraform CLI**, permitiendo recuperar, sincronizar y administrar
correctamente la infraestructura desplegada en AWS sin provocar pérdida
de recursos.

------------------------------------------------------------------------

#  Arquitectura Implementada

La infraestructura fue desarrollada utilizando una arquitectura modular
compuesta por tres módulos principales.

``` text
                     AWS CLOUD
                         │
        ┌────────────────┴────────────────┐
        │                                 │
    module.red                     module.almacenamiento
        │                                 │
        │                                 └── Bucket S3
        │                                      • Versionamiento
        │                                      • Cifrado AES256
        │                                      • Public Access Block
        │
        ├── VPC
        ├── Public Subnet
        ├── Internet Gateway
        ├── Route Table
        ├── Route Table Association
        └── Security Group
                     │
                     │
             module.computo
                     │
                     └── EC2 t2.micro
 Recursos Implementados
 Red (module.red)
Amazon VPC

Public Subnet

Internet Gateway

Route Table

Route Table Association

Security Group

 Cómputo (module.computo)
Amazon EC2

Amazon Linux

Tipo t2.micro

 Almacenamiento (module.almacenamiento)
Amazon S3 Bucket

Versionamiento habilitado

Cifrado AES256

Bloqueo de acceso público

 Escenarios Evaluados
1. Recuperación del Estado
Simulación de pérdida de terraform.tfstate.

Ejecución de terraform plan.

Recuperación mediante terraform import.

Validación con terraform state list, terraform state show y
terraform plan.

Resultado esperado: No changes. Your infrastructure matches the
configuration.

2. Actualización y Reforzamiento
Detección de cambios manuales (drift).

Sincronización con terraform refresh o
terraform apply -refresh-only.

Reforzamiento mediante terraform taint o
terraform apply -replace.

Aplicación de cambios y validación final.

3. Eliminación de Recursos del Estado
Identificación con terraform state list.

Eliminación mediante terraform state rm.

Validación en AWS.

Verificación final con terraform plan.

 Evidencias
Las salidas de consola fueron almacenadas utilizando tee en:

evidencias/
└── ep3/
Incluyen logs de los tres escenarios y de la recuperación del estado.

 Comandos Utilizados
terraform init
terraform plan
terraform apply
terraform state list
terraform state show
terraform import
terraform state rm
terraform refresh
terraform taint
terraform untaint
terraform apply -refresh-only
terraform apply -replace

✅ Resultado
La infraestructura fue administrada correctamente utilizando Terraform
CLI, recuperando el estado, corrigiendo desincronizaciones y manteniendo
la integridad de los recursos desplegados en AWS.

 Autor
Carlos Rodrigo Cuevas

Infraestructura como Código II (AUY1105)

Duoc UC
