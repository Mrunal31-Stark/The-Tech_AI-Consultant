from fastapi import FastAPI
from pydantic import BaseModel

SERVICE_NAME = "task1-knowledge-brain"

app = FastAPI(title="Knowledge Brain API", version="0.1.0")


class Health(BaseModel):
    status: str
    service: str


@app.get("/health")
async def health() -> Health:
    return Health(status="ok", service=SERVICE_NAME)
