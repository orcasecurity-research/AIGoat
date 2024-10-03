# [AI Goat CTF Challenges](https://github.com/orcasecurity-research/AIGoat) Writeup
### *Machine Learning* | *AI Security* | *AI Red Teaming* | *Walkthrough* |

🐐 **DISCLAIMER** *Hints below!* 🐐

PS: If using mac os, default ports for control center is 5000 and therefore suggest updating the docker build/run to 5010 or other. You need to update the flask python application code (`./app.py`) as well as the `dockerfile` and `docker run..` command. I do recommend building the apps with a `venv` and the source code if using mac to evade `empty response` HTTP calls to the container(s).

**Table of Contents**:
- [AI Goat CTF Challenges Writeup](#ai-goat-ctf-challenges-writeup)
    - [*Machine Learning* | *AI Security* | *AI Red Teaming* | *Walkthrough* |](#machine-learning--ai-security--ai-red-teaming--walkthrough-)
  - [Tips on amending Docker desktop to avoid paying for a license with replacement Colima Container Runtime 🐳](#tips-on-amending-docker-desktop-to-avoid-paying-for-a-license-with-replacementcolimacontainer-runtime-)
  - [Challenges:](#challenges)

## Tips on amending Docker desktop to avoid paying for a license with replacement [Colima](https://github.com/abiosoft/colima) Container Runtime 🐳

- The process should go as following for MAC OS
1. Quit docker desktop
2. Run `docker image ls` → you should get an error like this `Cannot connect to the Docker daemon, ...`
3. Install colima → `brew install colima`
4. Start colima → `colima start --cpu 8 --memory 12` (cpu and memory options only need to be specified on the first run, they persist after that)
5. `docker context use colima`
6. Test the same `docker image ls` command. It shouldn’t error this time around
7. You can now run docker without Docker Desktop! Try building a container or running make dev

Follow up steps

1. Fully uninstall Docker Desktop:
2. Uninstall the docker desktop app from your Mac
3. Install the docker cli `brew install docker`
4. Edit `~/.docker/config.json` and remove the `credsStore` entry
5. `docker context use colima``
6. Install buildx and docker-compose

```
brew install docker-buildx docker-compose
mkdir -p ~/.docker/cli-plugins
ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ln -sfn /opt/homebrew/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
```

## Challenges:

- ML02:2023 Data Poisoning Attack
- ML06:2023 AI Supply Chain Attacks
- ML09:2023 Output Integrity Attack

1. **Challenge 1**:
   1. 
2. **Challenge 2**:
   1. 
3. **Challenge 3**:
