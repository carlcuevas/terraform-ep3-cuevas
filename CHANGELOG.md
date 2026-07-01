# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).
Versionado según [Semantic Versioning](https://semver.org/lang/es/).

## [2.0.0] - 2025-XX-XX

### Changed
- Refactorización completa del `main.tf` monolítico a arquitectura modular.
- Recursos de VPC, Subnet y SG consumidos desde el módulo de Redes.
- Recursos de EC2 consumidos desde el módulo de Cómputo.

### Added
- Módulo de Almacenamiento (S3) integrado.
- Archivo `variables.tf` con variables de alto nivel.
- Archivo `outputs.tf` consolidando outputs de los tres módulos.

### Removed
- Definición directa de recursos AWS en `main.tf` (delegados a módulos).

## [1.0.0] - 2025-XX-XX

### Added
- Infraestructura base: VPC, Subnet, Security Group, EC2.
- Pipeline CI/CD con TFLint, Checkov, terraform validate y OPA.
- Políticas OPA para restricción SSH y tipos de instancia.
