from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_returns_ok_and_version() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    body = response.json()
    assert body["ok"] is True
    assert body["version"] == "0.1.0"
    assert body["commit"] == "local"


def test_docs_are_not_exposed() -> None:
    assert client.get("/docs").status_code == 404
