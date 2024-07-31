const qaWolf = require("@qawolf/ci-sdk");
const core = require("@actions/core");

const qaWolfApiKey = process.env.INPUT_API_KEY;
const qaWolfTimeout = parseInt(process.env.INPUT_TIMEOUT || "600", 10);
const qaWolfInterval = parseInt(process.env.INPUT_INTERVAL || "30", 10);

let qaWolfConfig = {};
try {
  qaWolfConfig = JSON.parse(process.env.INPUT_CONFIG);
} catch (error) {
  core.setFailed("QAWolf CI Notify Deploy failed: invalid config");
  process.exit(1);
  return;
}

const { attemptNotifyDeploy, pollCiGreenlightStatus } = qaWolf.makeQaWolfSdk({
  apiKey: qaWolfApiKey,
});

async function notifyDeploy() {
  const result = await attemptNotifyDeploy(qaWolfConfig);
  if ((result.outcome != "success")) {
    core.setFailed("QAWolf CI Notify Deploy failed");
    process.exit(1);
  }
  core.setOutput("runId", result.runId);
  return result.runId;
}

async function pollGreenlight(runId) {
  const result = await pollCiGreenlightStatus({
    runId,
    pollTimeout: qaWolfTimeout * 1000,
    retryInterval: qaWolfInterval * 1000,
  });
  switch (result.outcome) {
    case "failed":
      core.setOutput("status", "failed");
      core.setOutput(
        "blockingBugsCount",
        result.greenlightStatus.blockingBugsCount
      );
      core.setOutput(
        "blockingBugUrls",
        JSON.stringify(result.greenlightStatus.blockingBugUrls)
      );
      core.setOutput(
        "nonBlockingBugsCount",
        result.greenlightStatus.nonBlockingBugsCount
      );
      core.setOutput(
        "nonBlockingBugUrls",
        JSON.stringify(result.greenlightStatus.nonBlockingBugUrls)
      );
      core.setOutput(
        "reproducedBugs",
        JSON.stringify(result.greenlightStatus.reproducedBugs)
      );

      await core.summary
        .addHeading("QAWolf Greenlight :wolf:")
        .addHeading(`Run ${runId}: FAILED :x: `, 3)
        .addHeading(
          `${result.greenlightStatus.blockingBugsCount} Blocking Bugs`,
          4
        )
        .addList(
          result.greenlightStatus.blockingBugUrls.map(
            (item) => `[${item}](${item})`
          )
        )
        .addHeading(
          `${result.greenlightStatus.nonBlockingBugsCount} Non-blocking Bugs`,
          4
        )
        .addBreak()
        .addCodeBlock(
          JSON.stringify(result.greenlightStatus.reproducedBugs, null, 2),
          "json"
        )
        .write();

      core.setFailed("QAWolf CI Greenlight failed");
      break;
    case "success":
      core.setOutput("status", "success");
      core.setOutput("blockingBugsCount", 0);
      core.setOutput("nonBlockingBugsCount", 0);
      await core.summary
        .addHeading("QAWolf Greenlight :wolf:")
        .addHeading(`Run ${runId}: SUCCESS :white_check_mark:`, 3)
        .write();
      core.info("QAWolf CI Greenlight succeeded");
      process.exit(0);
      break;
    case "aborted":
      if (result.abortReason === "poll-timed-out") {
        core.setOutput("status", "timeout");
        await core.summary
          .addHeading("QAWolf Greenlight :wolf:")
          .addHeading(`Run ${runId}: TIMEOUT :x:`, 3)
          .write();

        core.setFailed("QAWolf CI Greenlight timeout");
      } else {
        core.setOutput("status", "cancelled");
        await core.summary
          .addHeading("QAWolf Greenlight :wolf:")
          .addHeading(`Run ${runId}: CANCELLED :heavy_multiplication_x: `, 3)
          .write();

        core.setFailed("QAWolf CI Greenlight cancelled");
      }
      break;
  }
}
(async () => {
  const runId = await notifyDeploy();
  await pollGreenlight(runId);
})();
