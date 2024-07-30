# QAWolf Greenlight

This GitHub Action integrates with QAWolf, an end-to-end testing platform, to validate QAWolf test suites and retrieve the status of a workflow run.

## Installation

To use this GitHub Action, follow these steps:

1. Clone the repository: `git clone https://github.com/SMARTeacher/qawolf-greenlight.git`

## Usage

To use this action in your workflow, add the following step to your GitHub Actions workflow file:

```yaml
- name: QAWolf Greenlight
  uses: SMARTeacher/qawolf-greenlight@v1
  with:
    qawolf-api-key: ${{ secrets.QAWOLF_API_KEY }}
    qawolf-notification-config: '{ "branch": "main", "deploymentType": "staging" }'
    timeout: 600 # Optional, default is 600 seconds
    interval: 30 # Optional, default is 30 seconds
```

## Inputs
- `qawolf-api-key` (required): The QAWolf API key.
- `qawolf-notification-config` (required): The QAWolf Notification Config, see typing for[DeployConfig](https://www.npmjs.com/package/@qawolf/ci-sdk).
- `timeout` (optional): The timeout for the test run in seconds (must be divisible by `inputs.interval`). Default is 600 seconds.
- `interval` (optional): The interval to retry. Default is 30 seconds.

## Outputs
- `status`: The status of the test run. 'success' or 'failure' or 'timeout' or 'cancelled'
- `blockingBugsCount`: The number of blocking bugs.
- `nonBlockingBugsCount`: The number of non-blocking bugs.
- `numWorkflowsRun`: The number of workflows run.
- `bugs`: The number of reproduced bugs in JSON format.

## Contributing
Contributions are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.