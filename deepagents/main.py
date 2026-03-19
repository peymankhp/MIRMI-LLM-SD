from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import json
import time
import asyncio
import logging
from typing import Optional, List, Dict, Any, Literal
import httpx
from pathlib import Path

# DeepAgents imports
try:
    from deepagents import create_deep_agent
    from langchain_ollama import ChatOllama
    from langchain_core.messages import HumanMessage, SystemMessage, AIMessage
    DEEPAGENTS_AVAILABLE = True
except ImportError as e:
    logging.warning(f"DeepAgents not available: {e}")
    DEEPAGENTS_AVAILABLE = False

app = FastAPI(title="DeepAgents Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://ollama:11434")
LLM_MODEL = os.getenv("LLM_MODEL", "qwen2.5-coder:7b")
WORKSPACES_ROOT = "/workspaces"

# Global agent instances cache
agent_cache = {}

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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

class CodeAssistRequest(BaseModel):
    workspace_id: str
    file_path: str
    code: str
    task: Literal["complete", "explain", "fix", "optimize", "test"] = "complete"
    cursor_position: Optional[int] = None
class DeepAgent:
    """A DeepAgent wrapper that uses the official DeepAgents library"""
    
    def __init__(self, workspace_path: str, model_name: str = "qwen2.5-coder:7b"):
        self.workspace_path = workspace_path
        self.model_name = model_name
        self.agent = None
        
        if DEEPAGENTS_AVAILABLE:
            try:
                # Initialize the Ollama model
                model = ChatOllama(
                    model=model_name,
                    base_url=OLLAMA_BASE_URL,
                    temperature=0.1,
                )
                
                # Create the DeepAgent with workspace-specific configuration
                self.agent = create_deep_agent(
                    model=model,
                    system_prompt=f"""You are an expert AI coding assistant working in a development workspace.

Workspace: {workspace_path}

You have access to powerful tools for development:
- Planning tools (write_todos) for breaking down complex tasks
- File system tools (read_file, write_file, edit_file, ls, glob, grep) for code management
- Shell access (execute) for running commands and tests
- Sub-agent delegation (task) for complex multi-step work

Guidelines:
- Always understand the project structure before making changes
- Write clean, well-documented, and tested code
- Follow best practices for the programming language
- Use planning tools to break down complex tasks
- Leverage sub-agents for specialized tasks
- Consider security and performance implications
- Provide clear explanations of your actions

Focus on being helpful, accurate, and efficient in your development assistance."""
                )
                
                logger.info(f"DeepAgent initialized for workspace {workspace_path}")
                
            except Exception as e:
                logger.error(f"Failed to initialize DeepAgent: {e}")
                self.agent = None
        else:
            logger.warning("DeepAgents library not available, using fallback")
    
    async def execute_task(self, task: str, context: Optional[Dict] = None) -> Dict[str, Any]:
        """Execute a coding task using DeepAgent"""
        try:
            if not self.agent:
                return {
                    "success": False,
                    "error": "DeepAgent not available",
                    "task": task,
                    "timestamp": time.time()
                }
            
            # Prepare the message with context
            message_content = task
            if context:
                message_content += f"\n\nAdditional context: {json.dumps(context, indent=2)}"
            
            # Execute the task using DeepAgent
            logger.info(f"Executing DeepAgent task: {task}")
            
            # Change to workspace directory for file operations
            original_cwd = os.getcwd()
            try:
                os.chdir(self.workspace_path)
                
                # Invoke the agent
                result = await asyncio.to_thread(
                    self.agent.invoke,
                    {"messages": [{"role": "user", "content": message_content}]}
                )
                
                # Extract the response
                messages = result.get("messages", [])
                if messages:
                    last_message = messages[-1]
                    # Handle both dict and Message objects
                    if isinstance(last_message, dict):
                        response_content = last_message.get("content", "No response generated")
                    else:
                        # It's a Message object (AIMessage, HumanMessage, etc.)
                        response_content = getattr(last_message, "content", "No response generated")
                else:
                    response_content = "No messages in response"
                
                return {
                    "success": True,
                    "response": response_content,
                    "workspace": self.workspace_path,
                    "task": task,
                    "timestamp": time.time(),
                    "agent_type": "deepagent"
                }
                
            finally:
                os.chdir(original_cwd)
            
        except Exception as e:
            logger.error(f"DeepAgent task execution failed: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "task": task,
                "timestamp": time.time()
            }

def get_or_create_agent(workspace_id: str, workspace_path: str) -> DeepAgent:
    """Get or create a DeepAgent for the workspace"""
    if workspace_id not in agent_cache:
        agent_cache[workspace_id] = DeepAgent(workspace_path, LLM_MODEL)
        logger.info(f"Created DeepAgent for workspace {workspace_id}")
    
    return agent_cache[workspace_id]

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy", 
        "timestamp": time.time(),
        "deepagents_available": DEEPAGENTS_AVAILABLE,
        "ollama_url": OLLAMA_BASE_URL,
        "model": LLM_MODEL
    }

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "DeepAgents Service", 
        "version": "1.0.0",
        "deepagents_available": DEEPAGENTS_AVAILABLE
    }
@app.post("/workspaces")
async def create_workspace(request: WorkspaceRequest):
    """Create a new workspace for a user"""
    try:
        workspace_path = os.path.join(WORKSPACES_ROOT, request.workspace_id)
        os.makedirs(workspace_path, exist_ok=True)
        
        # Create a comprehensive README file
        readme_content = f"""# Workspace: {request.workspace_id}

Welcome to your AI-powered coding workspace! This environment is equipped with an intelligent 
coding assistant that can help you with various development tasks.

## Features Available

### 🤖 AI Coding Assistant
- **Code Completion**: Get intelligent code suggestions and completions
- **Bug Fixing**: Identify and fix issues in your code
- **Code Explanation**: Understand complex code snippets
- **Optimization**: Improve code performance and readability
- **Test Generation**: Create comprehensive tests for your code

### 🛠️ Development Tools
- **File Management**: Create, read, write, and organize files
- **Project Structure**: Get advice on project architecture
- **Best Practices**: Follow language-specific coding standards
- **Documentation**: Generate and maintain code documentation

## Getting Started

1. **Create Files**: Start by creating your project files
2. **Ask for Help**: Use the AI assistant for coding questions
3. **Iterate**: Refine your code with AI suggestions
4. **Test**: Generate and run tests for your code

## Example Commands

You can ask the AI assistant things like:
- "Create a Python web server using FastAPI"
- "Fix the bug in my JavaScript function"
- "Optimize this SQL query for better performance"
- "Write unit tests for this class"
- "Explain how this algorithm works"

---

**Workspace Details:**
- Created for user: {request.user_id}
- Created at: {time.strftime('%Y-%m-%d %H:%M:%S')}
- Workspace ID: {request.workspace_id}

Happy coding! 🚀
"""
        
        # Create basic project structure
        with open(os.path.join(workspace_path, "README.md"), "w") as f:
            f.write(readme_content)
        
        # Create basic project directories
        os.makedirs(os.path.join(workspace_path, "src"), exist_ok=True)
        os.makedirs(os.path.join(workspace_path, "tests"), exist_ok=True)
        os.makedirs(os.path.join(workspace_path, "docs"), exist_ok=True)
        
        return {
            "success": True,
            "workspace_id": request.workspace_id,
            "path": workspace_path,
            "message": "Workspace created successfully with AI coding assistant"
        }
        
    except Exception as e:
        logger.error(f"Failed to create workspace {request.workspace_id}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to create workspace: {str(e)}")
@app.post("/agent/execute", response_model=AgentResponse)
async def execute_agent_task(request: AgentRequest):
    """Execute an AI agent task in the workspace"""
    try:
        workspace_path = os.path.join(WORKSPACES_ROOT, request.workspace_id)
        
        if not os.path.exists(workspace_path):
            raise HTTPException(status_code=404, detail="Workspace not found")
        
        # Get or create the agent for this workspace
        agent = get_or_create_agent(request.workspace_id, workspace_path)
        
        # Execute the task
        logger.info(f"Executing task for workspace {request.workspace_id}: {request.task}")
        
        result = await agent.execute_task(request.task, request.context)
        
        return AgentResponse(
            success=result["success"],
            result=result if result["success"] else None,
            error=result.get("error") if not result["success"] else None
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Agent execution failed for workspace {request.workspace_id}: {str(e)}")
        return AgentResponse(
            success=False, 
            error=f"Agent execution failed: {str(e)}"
        )

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
                # Get workspace info
                readme_path = os.path.join(workspace_path, "README.md")
                created_time = os.path.getctime(workspace_path)
                
                # Count files
                file_count = sum(len(files) for _, _, files in os.walk(workspace_path))
                
                workspaces.append({
                    "id": item,
                    "path": workspace_path,
                    "created": created_time,
                    "file_count": file_count,
                    "has_readme": os.path.exists(readme_path),
                    "agent_active": item in agent_cache
                })
        
        return {"workspaces": workspaces}
    except Exception as e:
        logger.error(f"Failed to list workspaces: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)