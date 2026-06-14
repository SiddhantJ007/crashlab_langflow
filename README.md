# Langflow Feedback Service

Standalone Langflow deployment scaffold for CrashLab.

This service is intentionally separate from the main CrashLab repo so CrashLab remains a lightweight evaluator and Langflow remains an external target system.

## What This Folder Is For
- deploy a public Langflow instance on Render
- import your feedback-analysis flow into that instance
- expose a stable public API URL for CrashLab
- keep Langflow-specific runtime files out of the CrashLab repo

## Recommended Deployment Model
- CrashLab = one Render web service
- Langflow Feedback Service = separate Render web service

Do not deploy Langflow inside the CrashLab app process.

## Files Included
- `requirements.txt`: pins `langflow==1.8.4` plus the known-good transitive versions that Render kept resolving incorrectly
- `constraints.txt`: exact lock-style package constraints exported from the locally working `lf-venv` to stop Render dependency backtracking
- `.python-version`: pins Python 3.12.9
- `.env.sample`: example service env vars
- `render.yaml`: optional Render scaffold
- `scripts/start.sh`: Render start command wrapper
- `flows/`: place exported flow JSON here before publishing if you want to keep deployment assets together

## Render Setup
Build command:
```bash
pip install -r requirements.txt -c constraints.txt
```

If Render continues to ignore `render.yaml`, set the same build command manually in the Render dashboard and use **Clear build cache & deploy** before retrying.

Start command:
```bash
bash scripts/start.sh
```

Recommended env vars:
```bash
LANGFLOW_HOST=0.0.0.0
LANGFLOW_AUTO_LOGIN=false
OPENAI_API_KEY=your_model_provider_key_here
LANGFLOW_DATABASE_URL=sqlite:////opt/render/project/src/langflow-data/langflow.db
LANGFLOW_CONFIG_DIR=/opt/render/project/src/langflow-data
```

If you want the Langflow project and credentials to persist across restarts, attach a Render disk and point `LANGFLOW_CONFIG_DIR` and `LANGFLOW_DATABASE_URL` at that mounted path.

## Cold Start Note
On free-tier style infrastructure, Langflow may sleep after inactivity. The first request can take noticeable time to wake the service. CrashLab should document this as an external target limitation and not hide the resulting startup delays.

## How To Use With CrashLab
After Langflow is deployed and your flow is imported:
1. note the public base URL of the Langflow service
2. copy the deployed flow ID
3. set these env vars on CrashLab:

```bash
LANGFLOW_BASE_URL=https://your-langflow-service.onrender.com
LANGFLOW_FLOW_ID=your-deployed-flow-id
LANGFLOW_API_KEY=your-langflow-api-key-if-used
```

4. redeploy CrashLab
5. verify the Langflow card becomes `Ready`
6. click `Probe Target` before running the full demo suite

## Importing The Flow
This scaffold does not bundle your private or evolving flow automatically.

Recommended process:
1. export the tested flow JSON from your local Langflow UI
2. place it in `flows/` for your separate Langflow repo if desired
3. deploy the Langflow service
4. import the flow in the deployed Langflow UI
5. confirm the API works with a direct curl call
6. then wire CrashLab to that deployed URL and flow ID

## Suggested Separate Repo Name
- `crashlab-langflow-target`
- `langflow-feedback-service`

## Suggested First Validation
After deployment, test locally from any shell:
```bash
curl -sS -X POST "https://your-langflow-service.onrender.com/api/v1/run/YOUR_FLOW_ID" \
  -H 'Content-Type: application/json' \
  -H 'accept: application/json' \
  -H "x-api-key: $LANGFLOW_API_KEY" \
  -d '{
    "input_value": "Source feedback: \"The dashboard is cleaner, but exports still fail twice a week.\" Analyze this feedback and return structured sentiment, summary, and recommendation.",
    "input_type": "chat",
    "output_type": "chat",
    "session_id": "crashlab-langflow-smoke"
  }'
```

Only after that should you reconnect CrashLab.

## Why `constraints.txt` Exists
Render was spending 90+ minutes backtracking through Langflow's optional dependency graph instead of building the service. This scaffold now installs Langflow with an exact constraints set exported from the working local environment so Render can install a known-good package graph directly.

## Known-Good Core Pins
These are duplicated in `requirements.txt` even though `constraints.txt` exists, because Render previously ignored or bypassed the constraints path during troubleshooting.

- `langflow==1.8.4`
- `cuga==0.2.6`
- `google-api-python-client==2.154.0`
- `langchain-google-community==2.0.4`
- `langchain-google-vertexai==2.0.20`
