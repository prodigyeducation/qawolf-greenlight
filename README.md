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
    root_run_id: ${{ secrets.ROOT_RUN_ID }}
    api_key: ${{ secrets.QAWOLF_API_KEY }}
    timeout: 600 # Optional, default is 600 seconds
```

## Inputs
- `root_run_id` (required): The root run ID.
- `api_key` (required): The QAWolf API key.
- `timeout` (optional): The timeout for the test run in seconds (must be divisible by 15). Default is 600 seconds.

## Outputs
- `success`: The status of the test run.
- `blockingBugsCount`: The number of blocking bugs.
- `nonBlockingBugsCount`: The number of non-blocking bugs.
- `numWorkflowsRun`: The number of workflows run.
- `bugs`: The number of reproduced bugs in JSON format.

## Contributing
Contributions are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.
