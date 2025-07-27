# 🌿 Claude Habitat

A self-contained, persistent, and dedicated development environment for building AI agents, powered by Docker and the Claude CLI.

This repository provides a one-command setup to launch a personal, cloud-based development environment. It comes with the Claude CLI pre-installed and is configured to persist your login session or API key across restarts.

## Features

- **Pre-installed CLI:** The `claude` command is installed and ready to use.
- **Persistent Authentication:** Whether you use OAuth or an API key, your session is saved.
- **Dedicated & Isolated:** Runs in a container, keeping your host machine clean.
- **One-Command Launch:** Uses Docker Compose for a simple `docker compose up -d` startup.
- **Cloud-Ready:** Perfect for deploying on any cloud provider that supports Docker.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Quick Install (Ubuntu/Debian)

For Ubuntu-based systems (including Digital Ocean droplets), use our setup script:

```bash
curl -fsSL https://raw.githubusercontent.com/mrwadams/claude-habitat/main/setup.sh | bash
```

This script will:
- Detect if Docker is already installed
- Install Docker using the most appropriate method (official Docker repo or snap)
- Add your user to the docker group
- Install Docker Compose

**Note:** You'll need to log out and back in after installation for group permissions to take effect.

## Getting Started

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/mrwadams/claude-habitat.git
    cd claude-habitat
    ```

2.  **Launch the Environment:**
    ```bash
    docker compose up -d
    ```
    The first launch builds your custom Docker image. Subsequent launches will be instant.

    Your environment is now running. Access it in your browser at `http://your_server_ip:8080`.

## First-Time Authentication (Choose One Method)

After launching, open the terminal in VS Code (`Ctrl+` or `Cmd+` `` ` ``) and run the `claude` command for the first time. It will prompt you to authenticate.

### Method 1: Interactive Login (OAuth)

1.  When prompted, choose the option to log in through your browser.
2.  The CLI will provide a URL. Open this link in your local browser.
3.  Log in to your Anthropic account and authorize the CLI.
4.  You will be redirected or given a code to complete the process in the terminal.

Your login token is now saved in the `cli-config` volume and will persist automatically.

### Method 2: API Key

1.  When prompted, choose the option to provide an API key.
2.  Paste your Anthropic API key into the terminal.

Your API key is now saved in the `cli-config` volume and will persist automatically.

## Configuration

### Environment Variables

You can customize your Claude Habitat by setting environment variables. Create a `.env` file in the project root:

```bash
# Optional: Set a password for code-server authentication
CODE_SERVER_PASSWORD=your_secure_password

# Note: If CODE_SERVER_PASSWORD is not set, code-server will run without authentication
```

To use the password authentication:
1. Uncomment the `PASSWORD` line in `docker-compose.yml`
2. Set `CODE_SERVER_PASSWORD` in your `.env` file
3. Restart the container: `docker compose down && docker compose up -d`

### Pre-installed Tools

Your habitat comes with a lean development environment:

- **Claude CLI**: Pre-installed and ready to use
- **Python 3**: With pip and venv support
- **Python Essentials**: requests, python-dotenv
- **Version Control**: Git
- **Package Managers**: npm, pip

### Health Monitoring

The container includes a health check that monitors the code-server status. You can check the container health with:

```bash
docker compose ps
```

---

That's it. Your habitat is now fully configured. You can `docker compose down` and `docker compose up` at any time, and your `claude` CLI will remain authenticated and ready to use.