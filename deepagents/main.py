from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import json
import time
from typing import Optional, List, Dict, Any
import httpx
import asyncio

app = FastAPI(title="DeepAgents Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://ollama:11434")
LLM_MODEL = os.getenv("LLM_MODEL", "qwen2.5-coder:7b")
WORKSPACES_ROOT = "/workspaces"

class AgentRequest(BaseModel):
    workspace_id: str
    task: str
    context: Optional[Dict[str, Any]] = None

class AgentResponse(BaseModel):
    success: bool
    result: Optional[Dict[str, Any]] = None
    error: Optional[str] = None

class WorkspaceRequest(BaseModel):
    workspace_id: str
    user_id: str

@app.get("/health")
async def health():
    return {"status": "healthy", "timestamp": time.time()}

@app.get("/")
async def root():
    return {"message": "DeepAgents Service", "version": "1.0.0"}

@app.post("/workspaces")
async def create_workspace(request: WorkspaceRequest):
    """Create a new workspace for a user"""
    try:
        workspace_path = os.path.join(WORKSPACES_ROOT, request.workspace_id)
        os.makedirs(workspace_path, exist_ok=True)
        
        # Create a simple README file in the workspace
        readme_content = f"""# Workspace: {request.workspace_id}

This is your personal coding workspace powered by DeepAgents.

## Getting Started
- Create files and folders as needed
- Use the integrated terminal for running commands
- The AI agent can help you with coding tasks

Created for user: {request.user_id}
Created at: {time.strftime('%Y-%m-%d %H:%M:%S')}
"""
        
        with open(os.path.join(workspace_path, "README.md"), "w") as f:
            f.write(readme_content)
        
        return {
            "success": True,
            "workspace_id": request.workspace_id,
            "path": workspace_path,
            "message": "Workspace created successfully"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create workspace: {str(e)}")

@app.post("/agent/execute", response_model=AgentResponse)
async def execute_agent_task(request: AgentRequest):
    """Execute an AI agent task in the workspace"""
    try:
        workspace_path = os.path.join(WORKSPACES_ROOT, request.workspace_id)
        
        if not os.path.exists(workspace_path):
            raise HTTPException(status_code=404, detail="Workspace not found")
        
        # For now, we'll simulate agent execution
        # In a full implementation, this would use DeepAgents/LangChain
        
        # Check if Ollama is available
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(f"{OLLAMA_BASE_URL}/api/tags")
                if response.status_code != 200:
                    raise Exception("Ollama not available")
        except Exception as e:
            return AgentResponse(
                success=False, 
                error=f"LLM service not available: {str(e)}"
            )
        
        # Simulate processing the task
        await asyncio.sleep(1)  # Simulate processing time
        
        result = {
            "task": request.task,
            "workspace": request.workspace_id,
            "status": "completed",
            "message": f"Task '{request.task}' has been processed. This is a placeholder response.",
            "suggestions": [
                "Create a new file",
                "Run tests",
                "Check code quality"
            ],
            "timestamp": time.time()
        }
        
        return AgentResponse(success=True, result=result)
        
    except HTTPException:
        raise
    except Exception as e:
        return AgentResponse(success=False, error=str(e))

@app.get("/workspaces")
async def list_workspaces():
    """List all available workspaces"""
    try:
        if not os.path.exists(WORKSPACES_ROOT):
            return {"workspaces": []}
            
        workspaces = []
        for item in os.listdir(WORKSPACES_ROOT):
            workspace_path = os.path.join(WORKSPACES_ROOT, item)
            if os.path.isdir(workspace_path):
                workspaces.append({
                    "id": item,
                    "path": workspace_path,
                    "created": os.path.getctime(workspace_path)
                })
        
        return {"workspaces": workspaces}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/workspaces/{workspace_id}")
async def get_workspace(workspace_id: str):
    """Get workspace details"""
    try:
        workspace_path = os.path.join(WORKSPACES_ROOT, workspace_id)
        
        if not os.path.exists(workspace_path):
            raise HTTPException(status_code=404, detail="Workspace not found")
        
        # List files in workspace
        files = []
        for root, dirs, filenames in os.walk(workspace_path):
            for filename in filenames:
                file_path = os.path.join(root, filename)
                rel_path = os.path.relpath(file_path, workspace_path)
                files.append({
                    "name": filename,
                    "path": rel_path,
                    "size": os.path.getsize(file_path),
                    "modified": os.path.getmtime(file_path)
                })
        
        return {
            "id": workspace_id,
            "path": workspace_path,
            "files": files,
            "file_count": len(files)
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)