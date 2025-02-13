# Jenkins Pipeline

This repository contains a simple Jenkins pipeline that runs in a Docker container using Node.js 16 (Alpine version).

## Pipeline Overview

The pipeline is defined using a `Jenkinsfile` and consists of a single stage:

- **Agent**: Runs inside a Docker container using the `node:16-alpine` image.
- **Stage: Test**: Executes a shell command to check the installed Node.js version.

## Pipeline Definition

```groovy
pipeline {
  agent {
    docker { image 'node:16-alpine' }
  }
  stages {
    stage('Test') {
      steps {
        sh 'node --version'
      }
    }
  }
}
```

## Explanation

1. **Agent Configuration**:
   - The pipeline runs within a Docker container using the `node:16-alpine` image.
   - This ensures a consistent environment with Node.js 16 installed.

2. **Stages**:
   - The pipeline consists of a single stage called `Test`.
   - Inside this stage, a shell command (`sh 'node --version'`) is executed to verify the Node.js installation.

## Prerequisites

- Jenkins installed and configured.
- Docker installed on the Jenkins server.
- A Jenkins job set up to use this `Jenkinsfile`.

## Running the Pipeline

1. Add the `Jenkinsfile` to your repository.
2. Configure a Jenkins job to use the repository.
3. Run the pipeline and check the output for the Node.js version.

## Expected Output

When the pipeline runs successfully, you should see an output similar to:

```
+ node --version
v16.x.x
```

This confirms that the Node.js environment inside the Docker container is working correctly.
