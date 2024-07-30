const qaWolf = require("@qawolf/ci-sdk");
const core = require("@actions/core");

const qaWolfApiKey = process.env.INPUT_API_KEY;
let qaWolfConfig = {};
try {
  qaWolfConfig = JSON.parse(process.env.INPUT_CONFIG);
} catch (error) {
  core.setFailed("QAWolf CI Notify Deploy failed: invalid config");
  process.exit(1);
  return;
}

const { attemptNotifyDeploy } = qaWolf.makeQaWolfSdk({
  apiKey: qaWolfApiKey,
});

(async () => {
  const result = await attemptNotifyDeploy(qaWolfConfig);
  if (result.outcome !== "success") {
    core.setFailed("QAWolf CI Notify Deploy failed");
    process.exit(1);
  }
  core.setOutput("runId", result.runId);
})();
