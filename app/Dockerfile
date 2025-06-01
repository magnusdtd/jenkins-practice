# --- Builder Stage ---
FROM python:3.10-slim AS builder

RUN apt-get update && apt-get install -y wget

WORKDIR /app

COPY ./app/requirements.txt requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt

RUN mkdir -p /root/.u2net && wget -O /root/.u2net/u2net.onnx https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2net.onnx

# --- Final Stage ---
FROM python:3.10-slim AS backend

WORKDIR /app

COPY --from=builder /usr/local /usr/local 
COPY --from=builder /root/.u2net /root/.u2net
COPY /app /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]