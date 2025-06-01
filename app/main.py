from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import StreamingResponse, HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from rembg import remove
from PIL import Image
from io import BytesIO
import os

class App:
  def __init__(self):
    self.app = FastAPI()
    self._setup_routes()

    self.app.add_middleware(
      CORSMiddleware,
      allow_origins=["*"],
      allow_credentials=True,
      allow_methods=["*"],
      allow_headers=["*"],
    )

    is_docker_container = os.getenv("IS_DOCKER_CONTAINER", "no")
    if (is_docker_container == "no"):
      self._start_up()
  
  def _start_up(self):
    """Trigger the "rembg" library to download the models"""
    input_image = Image.open('sample/sample-1.jpg')
    output_image = remove(input_image, post_process_mask=True)

    img_io = BytesIO()
    output_image.save(img_io, 'PNG')
    img_io.seek(0)
    print('Start up complete')

  def _setup_routes(self):
    self.app.get("/", response_class=HTMLResponse)(self.read_index)
    self.app.post("/predict")(self.upload_file)

  def read_index(self):
    with open("templates/index.html", "r") as file:
      return file.read()

  def upload_file(self, file: UploadFile = File(...)):
    if not file:
        raise HTTPException(status_code=400, detail="No file uploaded")
    if file.filename == '':
        raise HTTPException(status_code=400, detail="No file selected")
    
    input_image = Image.open(file.file)
    output_image = remove(input_image, post_process_mask=True)

    img_io = BytesIO()
    output_image.save(img_io, 'PNG')
    img_io.seek(0)

    return StreamingResponse(img_io, media_type="image/png", headers={"Content-Disposition": f"attachment; filename={file.filename}_rmng.png"})

app = App().app