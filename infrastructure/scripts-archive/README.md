# Scripts Archive

This directory contains test, validation, and installation scripts from the project development lifecycle.

## Script Categories

### Test Scripts
- **`test-cheetah-integration.sh`** - Integration testing for Cheetah platform
- **`test-scripts-move.sh`** - Script migration validation

### Validation Scripts  
- **`validate-cheetah-improvements.sh`** - Platform improvement validation
- Tests deployment automation
- Validates security integrations
- Checks cost optimization features

### Installation Scripts
- **`install-prerequisites.sh`** - System prerequisites installer
- AWS CLI, kubectl, terraform installation
- Development environment setup

### Legacy Scripts (from root/scripts/)
- **`setup-secrets.sh`** - Cloud secrets setup (moved from root)
- **`secure-deploy.sh`** - Secure deployment script (moved from root)

## Historical Context

These scripts represent different phases of development:

1. **Phase 1**: Basic installation and setup scripts
2. **Phase 3**: Cheetah integration and testing scripts  
3. **Phase 4**: Security and validation enhancements
4. **Phase 5**: Platform improvement validations

## Current Active Scripts

For current operations, use:
- **`../deploy.sh`** - Main deployment script (Cheetah-based)
- **`../scripts/`** - Current active deployment scripts
- **`../cheetah/scripts/`** - Cheetah platform scripts

## Usage

These archived scripts are primarily for:
- **Historical reference**
- **Debugging legacy issues** 
- **Understanding evolution**
- **Migration documentation**

Most functionality has been integrated into the Cheetah platform deployment workflow.

## Migration Status

✅ **MIGRATED**: Core functionality moved to Cheetah platform  
📁 **ARCHIVED**: Scripts preserved for historical reference  
🔄 **SUPERSEDED**: Replaced by `../deploy.sh` unified deployment

For the complete project evolution, see: [`../../PROJECT_DEVELOPMENT_JOURNEY.md`](../../PROJECT_DEVELOPMENT_JOURNEY.md)
