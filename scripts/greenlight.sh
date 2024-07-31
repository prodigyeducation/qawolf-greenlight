#!/bin/bash
set -e

interval=$INPUT_INTERVAL

if [ $(($INPUT_TIMEOUT % $interval)) -ne 0 ]; then
  echo "Error: Timeout is not divisible by $interval."
  exit 1
fi

timeout=$(($INPUT_TIMEOUT / $interval))
numRequestsMade=0

makeRequest() {
    response=$(curl -s -X GET -H "Authorization: Bearer $INPUT_API_KEY" \
     "https://app.qawolf.com/api/v0/ci-greenlight/$INPUT_ROOT_RUN_ID")

    echo "### QAWolf Greenlight :wolf:" >> $GITHUB_STEP_SUMMARY
    
    runStage=$(echo $response | jq -r '.runStage')
    if [ $runStage != "completed" ]; then
        if [ $runStage = "cancelled" ]; then
            echo "#### Run $INPUT_ROOT_RUN_ID: CANCELLED :heavy_multiplication_x: " >> $GITHUB_STEP_SUMMARY

            echo "status=cancelled" >> $GITHUB_OUTPUT
            echo "Greenlight cancelled for run $INPUT_ROOT_RUN_ID"
            exit 0
        fi
        totalTimespan=$(($numRequestsMade * $interval))
        echo "Run stage is currently '$runStage', waiting for it to be 'completed' ($totalTimespan seconds elapsed)"
        numRequestsMade=$(($numRequestsMade+1))
        if [ "$numRequestsMade" -gt "$timeout" ]; then
            echo "#### Run $INPUT_ROOT_RUN_ID: TIMED OUT :x: " >> $GITHUB_STEP_SUMMARY

            echo "status=timeout" >> $GITHUB_OUTPUT
            echo "Timeout reached"
            exit 1
        fi
        sleep $interval
        makeRequest
        exit 0
    fi

    success=$(echo $response | jq -r '.greenlight')
    blockingBugsCount=$(echo $response | jq -r '.blockingBugsCount')
    nonBlockingBugsCount=$(echo $response | jq -r '.nonBlockingBugsCount')
    numWorkflowRuns=$(echo $response | jq -r '.numWorkflowRuns')
    bugs=$(echo $response | jq -r '.bugs')

    if [ "$success" = "true" ]; then
        echo "#### Run $INPUT_ROOT_RUN_ID: SUCCESS :white_check_mark: " >> $GITHUB_STEP_SUMMARY
        echo "status=success" >> $GITHUB_OUTPUT

        echo "Greenlight passed for run $INPUT_ROOT_RUN_ID"
        exit 0
    else
        echo "#### Run $INPUT_ROOT_RUN_ID: FAILURE :x: " >> $GITHUB_STEP_SUMMARY
        echo "---" >> $GITHUB_STEP_SUMMARY
        echo "- $blockingBugsCount Blocking Bugs" >> $GITHUB_STEP_SUMMARY
        echo "- $nonBlockingBugsCount Non-Blocking Bugs" >> $GITHUB_STEP_SUMMARY
        echo "" >> $GITHUB_STEP_SUMMARY
        echo "\`\`\`json" >> $GITHUB_STEP_SUMMARY
        echo "$bugs" >> $GITHUB_STEP_SUMMARY
        echo "\`\`\`" >> $GITHUB_STEP_SUMMARY

        echo "status=failure" >> $GITHUB_OUTPUT
        echo "blockingBugsCount=$blockingBugsCount" >> $GITHUB_OUTPUT
        echo "nonBlockingBugsCount=$nonBlockingBugsCount" >> $GITHUB_OUTPUT
        echo "numWorkflowRuns=$numWorkflowRuns" >> $GITHUB_OUTPUT
        echo "bugs=$bugs" >> $GITHUB_OUTPUT

        echo "Greenlight failed for run $INPUT_ROOT_RUN_ID"
        exit 1
    fi
}

makeRequest