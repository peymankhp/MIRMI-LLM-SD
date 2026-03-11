from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
import httpx
import os
import time
from typing import Optional
from mirmi_llm.utils.auth import get_current_user

router = APIRouter()

CODE_SERVER_URL = os.getenv("CODE_SERVER_URL", "http://code-server:8080")
DEEPAGENTS_URL = os.getenv("DEEPAGENTS_URL", "http://deepagents:8000")

class IDESessionResponse(BaseModel):
    url: str
    workspace_id: str
    message: str

class AgentTaskRequest(BaseModel):
    workspace_id: str
    task: str

class AgentTaskResponse(BaseModel):
    success: bool
    result: Optional[dict] = None
    error: Optional[str] = None

@router.post("/session", response_model=IDESessionResponse)
async def create_ide_session(user=Depends(get_current_user)):
    """Create a new IDE session for the user"""
    try:
        # Generate unique workspace ID
        workspace_id = f"user_{user.id}_{int(time.time())}"
        
        # Create workspace via DeepAgents
        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                response = await client.post(
                    f"{DEEPAGENTS_URL}/workspaces",
                    json={"workspace_id": workspace_id, "user_id": str(user.id)}
                )
                
                if response.status_code != 200:
                    raise Exception(f"DeepAgents returned status {response.status_code}")
                    
            except httpx.RequestError as e:
                raise Exception(f"Could not connect to DeepAgents service: {str(e)}")
        
        # Return code-server URL with workspace
        ide_url = f"{CODE_SERVER_URL}/?folder=/home/coder/workspaces/{workspace_id}"
        
        return IDESessionResponse(
            url=ide_url, 
            workspace_id=workspace_id,
            message="IDE session created successfully"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/agent/task", response_model=AgentTaskResponse)
async def execute_agent_task(
    request: AgentTaskRequest,
    user=Depends(get_current_user)
):
    """Execute an agent task in the workspace"""
    try:
        async with httpx.AsyncClient(timeout=120.0) as client:
            response = await client.post(
                f"{DEEPAGENTS_URL}/agent/execute",
                json={
                    "workspace_id": request.workspace_id, 
                    "task": request.task,
                    "context": {"user_id": str(user.id)}
                }
            )
            
            if response.status_code != 200:
                raise Exception(f"DeepAgents returned status {response.status_code}")
                
            result = response.json()
            return AgentTaskResponse(**result)
            
    except httpx.RequestError as e:
        raise HTTPException(status_code=500, detail=f"Could not connect to DeepAgents: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/workspaces")
async def list_user_workspaces(user=Depends(get_current_user)):
    """List workspaces for the current user"""
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(f"{DEEPAGENTS_URL}/workspaces")
            
            if response.status_code != 200:
                raise Exception(f"DeepAgents returned status {response.status_code}")
                
            data = response.json()
            
            # Filter workspaces for current user
            user_workspaces = [
                ws for ws in data.get("workspaces", [])
                if ws["id"].startswith(f"user_{user.id}_")
            ]
            
            return {"workspaces": user_workspaces}
            
    except httpx.RequestError as e:
        raise HTTPException(status_code=500, detail=f"Could not connect to DeepAgents: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/health")
async def ide_health():
    """Check health of IDE services"""
    health_status = {
        "code_server": False,
        "deepagents": False,
        "timestamp": time.time()
    }
    
    # Check Code Server
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(f"{CODE_SERVER_URL}/healthz")
            health_status["code_server"] = response.status_code == 200
    except:
        pass
    
    # Check DeepAgents
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            response = await client.get(f"{DEEPAGENTS_URL}/health")
            health_status["deepagents"] = response.status_code == 200
    except:
        pass
    
    return health_status