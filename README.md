## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/imda-lionelteo/test-models-runs
```

### 2. Configure OpenAI API Key

Replace openai key so litellm can detect this key:
- Go to `.env`, replace your `OPENAI_API_KEY=MyKey1234`

```bash
nano test-models-runs/.env
```

### 3. Initial Docker Compose Run

Run the docker compose file - it will setup the litellm-db and litellm container, and will pull moonshot and run an example:

```bash
cd test-models-runs
docker compose up
```

**Note:** This run will fail for litellm-adapters, because it is trying to read the litellm-api-key which is not existent yet, it just setup. Do not kill the container yet.

### 4. Generate LiteLLM API Key

1. Open your browser and go to http://localhost:4000/sso/key/generate, it will ask you for the login and pw, it is `admin`, `admin123`
2. Click create a new key, place some key name, select all team models for models
3. Click create key. Store this generated litellm key
4. Let's assume this generated litellm key is `sk-UEjATkR-cLSxv5iRbhXrug`

### 5. Restart with LiteLLM Key

Now let's terminate the docker container:
- Press `ctrl-c` and wait for the containers to be shutdown

In your terminal export the litellm-key:

```bash
export LITELLM_API_KEY=sk-UEjATkR-cLSxv5iRbhXrug
```

Remove the results folder if it exists:

```bash
rm -r results
```

Run the docker compose file again:

```bash
docker compose up
```

### 6. Verify Success

You will notice that the results are written:

```
moonshot    |                     INFO     [TaskManager] Results written   task_manager.py:477
moonshot    |                              to data/results/my-run-1.json.                     
moonshot    | [10/02/25 16:24:09] INFO     [ApiAdapter] Test config tests   api_adapter.py:101
moonshot    |                              have been completed.                               
moonshot    |                              Successfully created with                          
moonshot    |                              run_id: my-run-1 
```

## What This Accomplishes

This means that you have successfully:

1. setup litellm with its db --> linking to openai models using openai key
2. generated a virtual key from litellm
3. using litellm key to query the litellm proxy and returning you result from gpt-4o-mini

## Results Location

**So where are the results?**

It is in your folder that you have cloned:
- Results: `yourClonedFolder/test-models-runs/results/my-run-1.json`
- Log: `yourClonedFolder/test-models-run/ms.log`

## Command Configuration

**So where is the command that is run?**

It is in `docker-compose.yml`:

```bash
command: ["sh", "-c", "sleep 15 && wget -q --spider http://litellm:4000/health/liveliness || echo 'Health check failed, continuing anyway' && chmod +x ./moonshot_commands.sh && ./moonshot_commands.sh"]
```

Refer to `moonshot_commands.sh`, it is currently running:

```bash
RUN_IDS="my-run-1 my-run-2 my-run-3 my-run-4"
TEST_NAMES="sample_test"
MODELS="my-gpt-4o my-gpt-4o-mini my-gpt-o1 my-gpt-o1-mini"
```

This creates 4 runs: my-gpt-4o on sample_test, my-gpt-4o-mini on sample_test, etc.

- For my-run-1 and my-run-2 it runs on litellm_adapter
- For my-run-3 and my-run-4 it runs on openai_adapter
- This is defined in `moonshot_config.yaml`

## Adding More Environment Variables

**What if I want to expand beside OPENAI_API_KEY in moonshot?**

You can add more environment variables in `docker-compose.yml`:

```yaml
environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}  # Set via .env file or export
      - LITELLM_API_KEY=${LITELLM_API_KEY}  # Set via .env file or export
```