# test-models-runs

# Clone the repo
git clone https://github.com/imda-lionelteo/test-models-runs

# Replace openai key so litellm can detect this key
Go to .env, replace your OPENAI_API_KEY=MyKey1234

nano test-models-runs/.env

# Run the docker compose file - it will setup the litellm-db and litellm container, and will pull moonshot and run an example.
cd test-models-runs

docker compose up

# Note that this run will fail for litellm-adapters, because it is trying to read the litellm-api-key which is not existent yet, it just setup.
# Do not kill the container yet.
Open your browser and go to http://localhost:4000/sso/key/generate, it will ask you for the login and pw, it is admin, admin123
Click create a new key, place some key name, select all team models for models.
click create key. Store this generated litellm key.
Let's assume this generated litellm key is sk-UEjATkR-cLSxv5iRbhXrug

# Now let's terminate the docker container
Press ctrl-c and wait for the containers to be shutdown.

# in your terminal export the litellm-key
export LITELLM_API_KEY=sk-UEjATkR-cLSxv5iRbhXrug

# Remove the results folder if it exists.
rm -r results

# Run the docker compose file again
docker compose up

# You will notice that the results are written
moonshot    |                     INFO     [TaskManager] Results written   task_manager.py:477
moonshot    |                              to data/results/my-run-1.json.                     
moonshot    | [10/02/25 16:24:09] INFO     [ApiAdapter] Test config tests   api_adapter.py:101
moonshot    |                              have been completed.                               
moonshot    |                              Successfully created with                          
moonshot    |                              run_id: my-run-1 

# This means that you have successfully: 
1. setup litellm with its db --> linking to openai models using openai key,
2. generated a virtual key from litellm
3. using litellm key to query the litellm proxy and returning you result from gpt-4o-mini.

# So where is the results?
it is in your folder that you have cloned.
yourClonedFolder/test-models-runs/results/my-run-1.json
The log is at yourClonedFolder/test-models-run/ms.log

# So where is the command that is run.
It is in docker-compose.yml 
command: ["sh", "-c", "sleep 15 && wget -q --spider http://litellm:4000/health/liveliness || echo 'Health check failed, continuing anyway' && chmod +x ./moonshot_commands.sh && ./moonshot_commands.sh"]

Refer to moonshot_commands.sh, it is currently running 
RUN_IDS="my-run-1 my-run-2 my-run-3 my-run-4"
TEST_NAMES="sample_test"
MODELS="my-gpt-4o my-gpt-4o-mini my-gpt-o1 my-gpt-o1-mini"

4 runs, my-gpt-4o on sample_test, my-gpt-4o-mini on sample_test, ...
for my-run-1 and my-run-2 it runs on litellm_adapter.
for my-run-3 and my-run-4 it runs on openai_adapter.
This is defined in moonshot_config.yaml

# What if i want to expand beside OPENAI_API_KEY in moonshot
you can add more environment variables in docker-compose.yml
environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}  # Set via .env file or export
      - LITELLM_API_KEY=${LITELLM_API_KEY}  # Set via .env file or export


    
