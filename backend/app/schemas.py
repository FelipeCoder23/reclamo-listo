"""Pydantic models shared by routes and tests. Field names in the domain stay in Spanish."""

from pydantic import BaseModel


class Health(BaseModel):
    ok: bool
    version: str
    commit: str
