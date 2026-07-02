# AUY1105 - Evaluación Parcial N°3

## Gestión Avanzada del Estado en Terraform

> **Asignatura:** Infraestructura como Código II (AUY1105)\
> **Estudiante:** Carlos Rodrigo Cuevas\
> **Institución:** Duoc UC\
> **Plataforma Cloud:** Amazon Web Services (AWS)\
> **Herramienta IaC:** Terraform

---

# Descripción

Este repositorio contiene la infraestructura desarrollada para la **Evaluación Parcial N°3** de la asignatura **Infraestructura como Código II**.

El objetivo principal consiste en demostrar el manejo avanzado del archivo de estado (`terraform.tfstate`) utilizando comandos de **Terraform CLI**, permitiendo recuperar, sincronizar y administrar correctamente la infraestructura desplegada en AWS sin provocar pérdida de recursos.

---

# Arquitectura Implementada

La infraestructura fue desarrollada utilizando una arquitectura simple compuesta por cuatro recursos principales desplegados directamente en AWS mediante un único archivo de configuración `main.tf`, parametrizado con `variables.tf` y con salidas definidas en `outputs.tf`.

```text
                     AWS CLOUD (us-east-1)
                           │
              ┌────────────┴────────────┐
              │                         │
           VPC (10.0.0.0/16)            │
              │                         │
         Public Subnet                  │
         (10.0.1.0/24)                  │
              │                         │
       Security Group              (sin módulos)
       (SSH port 22)
              │
           EC2 t2.micro
```

---

# Estructura del Proyecto

```text
terraform-evaluacion/
├── main.tf           # Recursos AWS (VPC, Subnet, SG, EC2)
├── variables.tf      # Variables parametrizadas
├── outputs.tf        # Outputs de recursos creados
├── .gitignore        # Excluye .tfstate y .terraform/
└── evidencias/       # Salidas estándar generadas con tee
```

---

# Despliegue Inicial de la Infraestructura

### Configuración de credenciales AWS Academy

Se configuraron las credenciales temporales del Learner Lab mediante `aws configure` para autenticar el acceso a la cuenta:

```bash
aws configure set aws_access_key_id <KEY>
aws configure set aws_secret_access_key <SECRET>
aws configure set aws_session_token <TOKEN>
aws configure set region us-east-1
aws sts get-caller-identity
```

### terraform init — Inicialización del proyecto

```bash
terraform init
```

### terraform apply — Despliegue completo

```bash
terraform apply -auto-approve
```

Se desplegaron los 4 recursos base:

| Recurso | ID |
|---|---|
| VPC | vpc-072be6efd588bd969 |
| Subnet | subnet-009ed7895faeaf876 |
| Security Group | sg-04c4e82be191f3c16 |
| EC2 | i-006f61e755a505b8d |

---

# Recursos Implementados

## Red
- Amazon VPC (`10.0.0.0/16`)
- Public Subnet (`10.0.1.0/24`, `us-east-1a`)
- Security Group (ingress SSH port 22, egress all)

## Cómputo
- Amazon EC2 (`t2.micro`, Amazon Linux)

---

# Escenarios Evaluados

---

## Escenario 1: Recuperación del Estado de Terraform

Durante la gestión de infraestructuras, es posible que el archivo de estado de Terraform se desincronice o se pierda. En este escenario se simuló la pérdida del archivo `terraform.tfstate` y se realizó la recuperación completa mediante `terraform import`.

### Paso 1 — Identificar el problema del estado perdido

Se eliminó el archivo `terraform.tfstate` y se ejecutó `terraform plan`. Sin estado, Terraform desconoce los recursos existentes y planifica crearlos todos nuevamente (**Plan: 4 to add**):

```bash
rm terraform.tfstate
terraform plan
```

<img width="1912" height="260" alt="captura 1" src="https://github.com/user-attachments/assets/99fda7bb-2220-485a-91f5-3c0d286c1302" />

### Paso 2 — Recrear el estado con terraform import

Se importaron los 4 recursos existentes en AWS al archivo de estado utilizando los IDs reales:

```bash
terraform import aws_vpc.main vpc-072be6efd588bd969
terraform import aws_subnet.main subnet-009ed7895faeaf876
terraform import aws_security_group.main sg-04c4e82be191f3c16
terraform import aws_instance.main i-006f61e755a505b8d
```

Cada import finalizó con el mensaje **Import successful!**

<img width="1919" height="773" alt="captura 2" src="https://github.com/user-attachments/assets/e3b6880b-b9b8-40bf-818c-559de6205755" />
<img width="1913" height="935" alt="captura 3" src="https://github.com/user-attachments/assets/c0919e26-32e1-42f3-b831-443166b9363d" />
<img width="1312" height="496" alt="captura 4" src="https://github.com/user-attachments/assets/1482ed2a-fff4-455f-bc8a-d13e1ec7bb61" />
<img width="865" height="466" alt="captura 5" src="https://github.com/user-attachments/assets/71ed8be7-0813-4786-9e3a-83176eb51adf" />

### Paso 3 — Verificar la recreación del estado

Se ejecutó `terraform state list` para confirmar que todos los recursos fueron registrados correctamente:

```bash
terraform state list
```

Se usó `terraform state show` sobre cada recurso para validar sus atributos contra la infraestructura real:

```bash
terraform state show aws_vpc.main
terraform state show aws_subnet.main
terraform state show aws_security_group.main
terraform state show aws_instance.main
```

<img width="1908" height="818" alt="captura 6 1" src="https://github.com/user-attachments/assets/a0396aee-98a0-4dd6-b94a-3d0b59df76b1" />
<img width="1906" height="829" alt="captura 6 2" src="https://github.com/user-attachments/assets/e13300a9-9905-4208-8b26-c0decfa06e59" />
<img width="1903" height="823" alt="captura 6 3" src="https://github.com/user-attachments/assets/85e1e8c8-51a5-4f25-8fbb-b94061a78d82" />

### Paso 4 — Validación final

Se ejecutó `terraform plan` para verificar que el estado y la configuración están completamente sincronizados. **No deben aparecer planes de cambios para recursos existentes**:

```bash
terraform plan
```

Resultado: **No changes. Your infrastructure matches the configuration.**

---

## Escenario 2: Actualización y Reforzamiento de Recursos

En este escenario se gestionaron desincronizaciones entre el estado de Terraform y la infraestructura real en AWS, utilizando `terraform refresh` y `terraform taint`.

### Paso 1 — Identificar inconsistencias en los recursos

Se realizó un cambio manual en la consola AWS: se agregó una regla de entrada (puerto 80, `0.0.0.0/0`) al Security Group. Luego se ejecutó `terraform plan` para observar el drift detectado:

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-04c4e82be191f3c16 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

terraform plan
```
### Paso 2 — Sincronizar el estado con la infraestructura real

Se ejecutó `terraform refresh` para actualizar el archivo de estado con los valores reales de los recursos desplegados. Luego se volvió a ejecutar `terraform plan` para verificar que las inconsistencias fueron resueltas:

```bash
terraform refresh
terraform plan
```
<img width="906" height="199" alt="captura 16" src="https://github.com/user-attachments/assets/78eb81c1-10c4-4bce-9b5d-3e669b13d4eb" />

### Paso 3 — Reforzamiento de recursos con terraform taint

Se marcó la EC2 para recreación utilizando `terraform taint`, se observó el impacto en el plan y se aplicaron los cambios:

```bash
terraform taint aws_instance.main
terraform plan
terraform apply -auto-approve
```

El plan mostró la EC2 con símbolo **-/+** (destroy and then create replacement). La nueva EC2 fue creada con ID `i-006f61e755a505b8d`.

<img width="1884" height="816" alt="captura 17 1" src="https://github.com/user-attachments/assets/da8e55c0-2053-4548-8903-69b673938b74" />
<img width="1434" height="821" alt="captura 17 2" src="https://github.com/user-attachments/assets/74c9d06d-45ce-41d9-b1ed-b35200781348" />
<img width="1342" height="807" alt="captura 18" src="https://github.com/user-attachments/assets/496e1563-87f5-4605-8b05-fd3e33057463" />
<img width="1323" height="575" alt="captura 19" src="https://github.com/user-attachments/assets/2bd326b1-3fd9-4d71-b39d-8f112be4f2c5" />
<img width="855" height="792" alt="captura 20" src="https://github.com/user-attachments/assets/04a0450b-de44-4e55-80aa-e41dfc3915ca" />

### Paso 4 — Validación final y limpieza

Se intentó ejecutar `terraform untaint` (que reportó que el recurso ya no está tainted porque fue recreado en el apply) y se confirmó que no hay más cambios pendientes:

```bash
terraform untaint aws_instance.main
terraform plan
```

Resultado: **No changes. Your infrastructure matches the configuration.**

<img width="997" height="458" alt="captura 21" src="https://github.com/user-attachments/assets/fce67a94-933b-47ce-a2f4-ef432d3f28fc" />
<img width="964" height="590" alt="captura 22" src="https://github.com/user-attachments/assets/9ad73106-26f1-4914-ab9c-f6a12c3bdff4" />

---

## Escenario 3: Eliminación del Security Group del Estado de Terraform

En ocasiones es necesario eliminar un recurso del archivo de estado de Terraform sin eliminarlo físicamente de la infraestructura. En este escenario se dejó el Security Group fuera de la administración de Terraform utilizando `terraform state rm`.

### Paso 1 — Identificar recursos gestionados por Terraform

Se ejecutó `terraform state list` para obtener la lista de recursos gestionados actualmente:

```bash
terraform state list
```

Los 4 recursos aparecen en el estado: `aws_instance.main`, `aws_security_group.main`, `aws_subnet.main`, `aws_vpc.main`.

<img width="1126" height="120" alt="captura 23" src="https://github.com/user-attachments/assets/9aeeb75d-5f77-4d8c-bd9a-96c665024253" />

### Paso 2 — Eliminar el Security Group del estado

Se usó `terraform state rm` para eliminar el Security Group del archivo de estado sin destruirlo en AWS:

```bash
terraform state rm aws_security_group.main | tee evidencias/e3_02_state_rm.txt
```

Resultado: **Removed aws_security_group.main**

<img width="1243" height="251" alt="captura 24" src="https://github.com/user-attachments/assets/c14a4e03-ce12-4e66-9f85-7eeca692701c" />

### Paso 3 — Verificar que fue eliminado del estado

Se ejecutó nuevamente `terraform state list` para confirmar que el Security Group ya no aparece como recurso gestionado:

```bash
terraform state list | tee evidencias/e3_03_state_list_despues.txt
```

Ahora solo aparecen 3 recursos: `aws_instance.main`, `aws_subnet.main`, `aws_vpc.main`.

<img width="1391" height="166" alt="captura 25" src="https://github.com/user-attachments/assets/728ef57e-e639-4029-8821-46505d24d944" />

### Paso 4 — Editar el código (eliminar bloque del SG y actualizar EC2)

Se editó `main.tf` para eliminar el bloque completo del recurso `aws_security_group.main` y se reemplazó la referencia dinámica en la EC2 por el ID fijo del Security Group. También se eliminó el output correspondiente en `outputs.tf`.

```bash
nano main.tf
```

La EC2 quedó con el ID fijo del SG en lugar de la referencia al recurso:

```hcl
vpc_security_group_ids = ["sg-04c4e82be191f3c16"]
```

<img width="941" height="692" alt="captura 26 1" src="https://github.com/user-attachments/assets/10cf5551-f948-42d6-96ae-ba78aa1fb593" />
<img width="926" height="180" alt="captura 26 2" src="https://github.com/user-attachments/assets/145879f0-2b34-4c58-a4b6-c320d9bb1b21" />

### Paso 5 — Confirmar que el Security Group sigue existiendo en AWS

Se verificó mediante AWS CLI que el Security Group sigue existiendo físicamente en la infraestructura, aunque Terraform ya no lo administre:

```bash
aws ec2 describe-security-groups --group-ids sg-04c4e82be191f3c16 | tee evidencias/e3_04_sg_sigue_existiendo.txt
```

El JSON retornado confirma que el recurso sigue activo en AWS.

<img width="1298" height="745" alt="captura 27" src="https://github.com/user-attachments/assets/c5d59c40-56e0-4121-a5de-4865ed39cd3a" />

### Paso 6 — Validación final

Se ejecutó `terraform plan` para verificar que Terraform no intenta recrear el Security Group eliminado del estado:

```bash
terraform plan | tee evidencias/e3_05_plan_final.txt
```

Resultado: **No changes. Your infrastructure matches the configuration.**

<img width="1146" height="300" alt="captura 28" src="https://github.com/user-attachments/assets/ca1dbe95-d75f-4ee2-98b0-53256f565b3c" />

---

# Optimización del Código (IL4.2)

Como parte de las buenas prácticas de Infrastructure as Code, el código fue refactorizado separando la configuración en tres archivos:

- `variables.tf` — parametriza región, CIDRs, tipo de instancia, AMI y nombre del proyecto.
- `outputs.tf` — expone los IDs de los recursos creados para referencia externa.
- `main.tf` — contiene únicamente la definición de recursos, usando variables en lugar de valores hardcodeados.

Esta separación mejora la legibilidad, facilita el mantenimiento y permite reutilizar la configuración en distintos entornos cambiando solo los valores de las variables.

---

# Evidencias

Las salidas de consola fueron almacenadas utilizando `tee` en:

```text
evidencias/
├── 00_plan_post_refactor.txt
├── 01_state_list.txt
├── 02_state_show_vpc.txt
├── 03_state_show_subnet.txt
├── 04_state_show_sg.txt
├── 05_state_show_ec2.txt
├── 06_outputs.txt
├── 07_plan_final.txt
├── e3_00_sg_id.txt
├── e3_01_state_list_antes.txt
├── e3_02_state_rm.txt
├── e3_03_state_list_despues.txt
├── e3_04_sg_sigue_existiendo.txt
└── e3_05_plan_final.txt
```

---

# Comandos Utilizados

```bash
terraform init
terraform plan
terraform apply
terraform apply -refresh-only
terraform state list
terraform state show
terraform import
terraform state rm
terraform refresh
terraform taint
terraform untaint
terraform output
```

---

# Resultado

La infraestructura fue administrada correctamente utilizando Terraform CLI, recuperando el estado, corrigiendo desincronizaciones y manteniendo la integridad de los recursos desplegados en AWS.

| Escenario | Comando Principal | Resultado |
|---|---|---|
| 1 — Recuperación del estado | `terraform import` | 4 recursos importados exitosamente |
| 2 — Actualización y reforzamiento | `terraform refresh` + `terraform taint` | Estado sincronizado, EC2 recreada |
| 3 — Eliminación del estado | `terraform state rm` | SG eliminado del estado, intacto en AWS |

---

## Autor

**Carlos Rodrigo Cuevas**
Duoc UC — Escuela de Informática y Telecomunicaciones
Infraestructura como Código II (AUY1105)
