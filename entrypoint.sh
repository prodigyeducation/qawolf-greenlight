#!/bin/bash
set -e

if [ $(($INPUT_TIMEOUT % 15)) -ne 0 ]; then
  echo "Error: Timeout is not divisible by 15."
  exit 1
fi

timeout=$(($INPUT_TIMEOUT / 15))
numRequestsMade=0

makeRequest() {
    response=$(curl -s -X GET -H "Authorization: Bearer $INPUT_API_KEY" \
     "https://app.qawolf.com/api/v0/ci-greenlight/$INPUT_ROOT_RUN_ID")

    runStage=$(echo $response | jq -r '.runStage')
    if [ $runStage != "completed" ]; then
        totalTimespan=$(($numRequestsMade * 15))
        echo "Run stage is currently '$runStage', waiting for it to be 'completed' ($totalTimespan seconds elapsed)"
        numRequestsMade=$(($numRequestsMade+1))
        if [ "$numRequestsMade" -gt "$timeout" ]; then
            echo "Timeout reached"
            exit 1
        fi
        sleep 15
        makeRequest
        exit 0
    fi

    success=$(echo $response | jq -r '.greenlight')
    blockingBugsCount=$(echo $response | jq -r '.blockingBugsCount')
    nonBlockingBugsCount=$(echo $response | jq -r '.nonBlockingBugsCount')
    numWorkflowRuns=$(echo $response | jq -r '.numWorkflowRuns')
    bugs=$(echo $response | jq -r '.bugs')
    
    echo "success=$success" >> $GITHUB_OUTPUT
    echo "blockingBugsCount=$blockingBugsCount" >> $GITHUB_OUTPUT
    echo "nonBlockingBugsCount=$nonBlockingBugsCount" >> $GITHUB_OUTPUT
    echo "numWorkflowRuns=$numWorkflowRuns" >> $GITHUB_OUTPUT
    echo "bugs=$bugs" >> $GITHUB_OUTPUT
    
    if [ "$success" = "false" ]; then
        echo "Workflow failed, there are $blockingBugsCount blocking bugs and $nonBlockingBugsCount non-blocking bugs"
        exit 1
    fi
}

makeRequest