# MIRMI-LLM 🤖🎨

**MIRMI-LLM** is a self-hosted AI platform for the [Munich Institute of Robotics and Machine Intelligence (MIRMI)](https://www.mirmi.tum.de) at TUM.

It combines a full-featured LLM chat interface with an integrated **Image Generator** powered by Stable Diffusion — all running locally, offline-capable, with enterprise authentication.

---

## Features

- 💬 **LLM Chat** — multi-model conversations via Ollama or OpenAI-compatible APIs
- 🎨 **Image Generator** — sidebar shortcut, prompt-to-image via Stable Diffusion (AUTOMATIC1111)
- 🤖 **DeepAgents** — agentic AI service with tool use
- 💻 **IDE** — in-browser code environment
- 📚 **RAG** — document upload and retrieval-augmented generation
- 🔍 **Web Search** — 15+ search providers
- 🔐 **Enterprise Auth** — LDAP, SSO, RBAC, SCIM 2.0
- 🌐 **Multilingual** — i18n support
- 📱 **PWA** — installable, offline-capable

---

## Stack

| Service   | Technology                       |
| --------- | -------------------------------- |
| Frontend  | SvelteKit 5 + TailwindCSS 4      |
| Backend   | FastAPI (Python)                 |
| LLM       | Ollama + OpenAI-compatible       |
| Image Gen | Stable Diffusion (AUTOMATIC1111) |
| Database  | SQLite (default) / PostgreSQL    |
| Sessions  | Redis                            |
| Proxy     | Nginx + Let's Encrypt SSL        |

---

## Quick Setup

> For full details see [SETUP.md](./SETUP.md)

### Requirements

- Linux server (Ubuntu 22.04+ recommended)
- Docker + Docker Compose v2
- NVIDIA GPU with 8GB+ VRAM (for Stable Diffusion)
- NVIDIA Container Toolkit
- Domain name (optional, for HTTPS)

### 1. Clone

```bash
git clone https://github.com/peymankhp/MIRMI-LLM-SD.git
cd MIRMI-LLM-SD
```

### 2. Configure

```bash
cp .env.example .env
# Edit .env — set WEBUI_SECRET_KEY at minimum
nano .env
```

### 3. Start

```bash
# Start everything (LLM + Image Generation)
docker compose -f docker-compose.yaml -f docker-compose-stable-diffusion.yaml up -d
```

### 4. Open

```
http://localhost:8080
```

First user to register becomes admin.

---

## Image Generator

After setup, every user sees **Image Generator** in the left sidebar between Search and IDE.

Configure it in Admin Panel → Settings → Images:

- Engine: `AUTOMATIC1111`
- Base URL: `http://automatic1111:7860`
- Enable Image Generation: ON

See [SETUP.md](./SETUP.md#stable-diffusion) for the full walkthrough.

---

## License

See [LICENSE](./LICENSE) and [LICENSE_HISTORY](./LICENSE_HISTORY).
