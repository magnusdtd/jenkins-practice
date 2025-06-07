import os
import pytest
from fastapi.testclient import TestClient
os.chdir('./app')
from app.main import app
os.chdir('..')

client = TestClient(app)

def test_read_index():
    os.chdir('./app')
    response = client.get("/")
    assert response.status_code == 200
    assert "<html>" in response.text 
    os.chdir('..')


def test_upload_file_success():
    with open("app/sample/sample-1.jpg", "rb") as file:
        response = client.post("/predict", files={"file": file})
    assert response.status_code == 200
    assert response.headers["Content-Type"] == "image/png"

def test_upload_file_no_file():
    response = client.post("/predict", files={})
    assert response.status_code == 400
    assert response.json()["detail"] == "No file uploaded"

