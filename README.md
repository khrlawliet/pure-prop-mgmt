# Service Pre-Deployment Check

A bash script that validates service deployments by checking artifact availability in artifactory before deployment.

## 📋 Overview

This script reads a manifest file containing service paths, extracts version information from each service directory, and verifies artifact availability via API calls to prevent deployment failures.

## 🚀 Features

- **Automated Version Detection**: Supports multiple version sources
- **Artifact Validation**: Checks artifactory availability before deployment
- **Comprehensive Reporting**: Generates detailed deployment readiness reports
- **Error Handling**: Robust error handling with clear status messages
- **Cross-platform**: Works on Unix/Linux/macOS environments

## 📁 Project Structure

```
pure/
├── pre-deployment-script.sh    # Main deployment check script
├── services.txt                # Service manifest file
├── app/
│   ├── product-service/
│   │   └── package.json
│   ├── scheduler-service/
│   └── user-service/
│       └── version.txt
└── lib/
    └── common-utils/
        └── version.txt
```

## 🛠️ Prerequisites

- **Bash**: Version 4.0 or higher
- **curl**: For API calls to artifactory
- **jq**: For JSON parsing
- **Git**: For version control

### Installing Dependencies

**For Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install curl jq
```

**For macOS:**
```bash
brew install curl jq
```

**For Windows (Git Bash):**
```bash
# Download jq manually
curl -L https://github.com/jqlang/jq/releases/latest/download/jq-win64.exe -o /usr/local/bin/jq.exe
```

## 📖 Usage

### Basic Usage

```bash
./pre-deployment-script.sh services.txt
```

### Example Output

```
Service Pre-Deployment Check Report:
====================================
Service: user-service
Version: 1.2.3
Artifact: available
------------------------------------
Service: product-service
Version: 2.1.0
Artifact: unavailable
------------------------------------
Service: common-utils
Version: 1.0.5
Artifact: available
------------------------------------
====================================
```

## 📝 Manifest File Format

The `services.txt` file should contain one service directory path per line:

```
app/user-service
app/product-service
lib/common-utils
app/scheduler-service
```

### Service Directory Requirements

Each service directory should contain version information in one of these formats:

1. **version.txt** (highest priority)
   ```
   1.2.3
   ```

2. **package.json** with version field
   ```json
   {
     "name": "my-service",
     "version": "1.2.3"
   }
   ```

## 🔧 Configuration

### Artifactory URL

The script uses a configurable artifactory URL:

```bash
ARTIFACTORY_URL="https://mock-check-artifact.vercel.app/check-artifact"
```

To use your own artifactory, modify this variable in the script.

### Expected API Response Format

The artifactory API should return JSON in this format:

```json
{
  "status": "available|unavailable"
}
```

## 📊 Status Codes

| Status | Description |
|--------|-------------|
| `available` | Artifact is ready for deployment |
| `unavailable` | Artifact is missing from artifactory |
| `n/a` | Version is unknown, skipping check |
| `error_checking_artifact` | API call failed or invalid response |

## 🚨 Error Handling

The script includes comprehensive error handling:

- **Missing directories**: Validates service paths exist
- **API failures**: Handles network and response errors gracefully
- **Invalid JSON**: Safely parses responses with fallback values
- **Missing dependencies**: Clear error messages for missing tools

## 🔍 Troubleshooting

### Common Issues

1. **"jq: command not found"**
   ```bash
   # Install jq (see Prerequisites section)
   ```

2. **"Directory does not exist"**
   ```bash
   # Verify paths in services.txt are correct
   ls -la app/user-service
   ```

3. **"error_checking_artifact"**
   ```bash
   # Check network connectivity and API endpoint
   curl -s "https://mock-check-artifact.vercel.app/check-artifact/test/1.0.0"
   ```


**Repository**: [pure-prop-mgmt](https://github.com/khrlawliet/pure-prop-mgmt)  
**Author**: khrlawliet  
**Branch**: main
