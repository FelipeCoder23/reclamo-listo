"""FastAPI application entry point."""

from fastapi import FastAPI

from app.config import settings
from app.schemas import Health

app = FastAPI(
    title="Reclamo Listo API",
    version=settings.version,
    docs_url=None,  # private service, no interactive docs exposed
    redoc_url=None,
)


@app.get("/health", response_model=Health)
def health() -> Health:
    """Liveness and version check used by the deploy smoke test."""
    return Health(ok=True, version=settings.version, commit=settings.commit)
