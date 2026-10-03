"""Runtime configuration, read once from environment variables."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="APP_")

    version: str = "0.1.0"
    # Injected by deploy.yml at build time; "local" when running on a laptop.
    commit: str = "local"
    google_cloud_project: str = ""


settings = Settings()
