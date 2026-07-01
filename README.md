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

#  Arquitectura Implementada

La infraestructura fue desarrollada utilizando una arquitectura modular compuesta por tres módulos principales.

```text
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
```

---

#  Despliegue Inicial de la Infraestructura

### Configuración de credenciales AWS

Se configuraron las credenciales de AWS Academy para autenticar el acceso a la cuenta:
<img width="1912" height="260" alt="captura 1" src="https://github.com/user-attachments/assets/9220df48-08eb-4d0c-be18-c53350c31fdc" />


### terraform init — Inicialización con módulos remotos

Se ejecutó `terraform init` descargando los tres módulos remotos desde GitHub:
<img width="1919" height="773" alt="captura 2" src="https://github.com/user-attachments/assets/1fb87db0-4b3e-46c8-83b0-b1de56e016fb" />


### terraform apply — Despliegue completo

Se desplegaron todos los recursos. El apply completó exitosamente con los outputs de los IDs de cada recurso:
<img width="1913" height="935" alt="captura 3" src="https://github.com/user-attachments/assets/e29fc008-395d-4777-83fb-3ae94844fe7d" />


### IDs reales de los recursos desplegados

Se extrajeron los IDs de cada recurso desde el estado de Terraform para uso posterior en el import:
<img width="1312" height="496" alt="captura 4" src="https://github.com/user-attachments/assets/7365b44f-936e-4a0c-9019-e3769710db4c" />


---

#  Recursos Implementados

##  Red (`module.red`)

- Amazon VPC
- Public Subnet
- Internet Gateway
- Route Table
- Route Table Association
- Security Group

##  Cómputo (`module.computo`)

- Amazon EC2
- Amazon Linux
- Tipo **t2.micro**

##  Almacenamiento (`module.almacenamiento`)

- Amazon S3 Bucket
- Versionamiento habilitado
- Cifrado AES256
- Bloqueo de acceso público

---

#  Escenarios Evaluados

---

## Escenario 1: Recuperación del Estado de Terraform

Durante la gestión de infraestructuras, es posible que el archivo de estado de Terraform se desincronice o se pierda. En este escenario se simuló la pérdida del archivo `terraform.tfstate` y se realizó la recuperación completa.

### Paso 1 — Identificar el problema del estado perdido

Se eliminó el archivo `terraform.tfstate` y se ejecutó `terraform plan`. Terraform no reconoce los recursos existentes y planifica crearlos todos nuevamente (**Plan: 11 to add**):

<img width="865" height="466" alt="captura 5" src="https://github.com/user-attachments/assets/ceb55e3b-7358-4978-ac9a-ef4d6b4ef74e" />

### Paso 2 — Recrear el estado con terraform import

Se importaron todos los recursos existentes en AWS al archivo de estado utilizando los IDs obtenidos previamente.

**Import de VPC, Subnet e Internet Gateway:**
<img width="1908" height="818" alt="captura 6 1" src="https://github.com/user-attachments/assets/298a4b3f-01c1-4ad7-93cb-825ad35140c7" />

**Import de Route Table, Security Group, Route Table Association y EC2:**
<img width="1906" height="829" alt="captura 6 2" src="https://github.com/user-attachments/assets/73cb7891-4445-4bf8-925f-314ab447f308" />

**Import de S3 Bucket — todos con Import successful!:**
<img width="1903" height="823" alt="captura 6 3" src="https://github.com/user-attachments/assets/764bb61a-2227-4a67-a0a9-8c4204643cd4" />

### Paso 3 — Verificar la recreación del estado

Se ejecutó `terraform state list` para confirmar que todos los recursos fueron registrados correctamente (8 recursos en total):
<img width="906" height="199" alt="captura 16" src="https://github.com/user-attachments/assets/bee91b4c-122d-4bae-8fcf-a0c518465132" />

Se usó `terraform state show` sobre la EC2 para validar sus atributos:
<img width="1884" height="816" alt="captura 17 1" src="https://github.com/user-attachments/assets/13c20e3e-0dfe-4e5a-8d20-d1ce4d79f612" />

<img width="1434" height="821" alt="captura 17 2" src="https://github.com/user-attachments/assets/c934010a-ed2f-4fbd-b505-7da809f2a4f6" />

### Paso 4 — Validación final

Se ejecutó `terraform plan` para verificar el estado de sincronización tras el import:
<img width="1342" height="807" alt="captura 18" src="https://github.com/user-attachments/assets/9413a0e8-cd9c-44b0-9d23-17c449458ba4" />

<img width="1323" height="575" alt="captura 19" src="https://github.com/user-attachments/assets/2e83d3a8-bda1-4682-be0c-7b317848fabd" />

<img width="855" height="792" alt="captura 20" src="https://github.com/user-attachments/assets/77215ce5-bd2f-427e-a640-63d07dee8c65" />

---

## Escenario 2: Actualización y Reforzamiento de Recursos

En este escenario se gestionaron desincronizaciones entre el estado de Terraform y la infraestructura real en AWS.

### Paso 2 — Sincronizar el estado con la infraestructura real

Se ejecutó `terraform apply -refresh-only` para actualizar el archivo de estado con los valores reales de los recursos desplegados:
<img width="997" height="458" alt="captura 21" src="https://github.com/user-attachments/assets/036bbf7c-432b-4104-9d2f-191b78907507" />

### Paso 3 — Aplicación de cambios y recreación de recursos

Se aplicaron los cambios finales. El apply completó con nueva EC2 creada y todos los recursos sincronizados:
<img width="964" height="590" alt="captura 22" src="https://github.com/user-attachments/assets/40a45eda-85ba-4c90-92e2-4aa7712fdb59" />

---

## Escenario 3: Eliminación de Recursos del Estado de Terraform

En este escenario se eliminó el Security Group del archivo de estado de Terraform sin eliminarlo físicamente de AWS, utilizando `terraform state rm`.

>  Este escenario fue ejecutado en el laboratorio TAITE 09 durante la evaluación presencial.

**Comandos ejecutados:**
```bash
# Identificar recursos
terraform state list

# Eliminar Security Group del estado
terraform state rm module.red.aws_security_group.this

# Verificar que fue eliminado
terraform state list

# Confirmar que sigue en AWS
aws ec2 describe-security-groups --group-ids <sg-id>

# Validar que terraform no intenta recrearlo
terraform plan
# Resultado esperado: No changes. Your infrastructure matches the configuration.
```

---

#  Evidencias

Las salidas de consola fueron almacenadas utilizando `tee` en:

```text
evidencias/
└── ep3/
    ├── captura_1.png
    ├── captura_2.png
    ├── captura_3.png
    ├── captura_4.png
    ├── captura_5.png
    ├── captura_6_1.png
    ├── captura_6_2.png
    ├── captura_6_3.png
    ├── captura_16.png
    ├── captura_17_1.png
    ├── captura_17_2.png
    ├── captura_18.png
    ├── captura_19.png
    ├── captura_20.png
    ├── captura_21.png
    └── captura_22.png
```

---

#  Comandos Utilizados

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
```

---

# ✅ Resultado

La infraestructura fue administrada correctamente utilizando Terraform CLI, recuperando el estado, corrigiendo desincronizaciones y manteniendo la integridad de los recursos desplegados en AWS.

| Escenario | Comando Principal | Resultado |
|---|---|---|
| 1 — Recuperación del estado | `terraform import` | 8 recursos importados exitosamente |
| 2 — Actualización y reforzamiento | `terraform apply -refresh-only` + `terraform taint` | Estado sincronizado, EC2 recreada |
| 3 — Eliminación del estado | `terraform state rm` | SG eliminado del estado, intacto en AWS |

---

##  Autor

**Carlos Rodrigo Cuevas**\
Infraestructura como Código II (AUY1105)\
Duoc UC
