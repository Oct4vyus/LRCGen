# Dockerfile para LRCGen - Optimizado para CPU y construcción desde Portainer
FROM python:3.10-slim

# Evitar prompts interactivos y archivos .pyc
ENV PYTHONUNBUFFERED=1     PYTHONDONTWRITEBYTECODE=1     DEBIAN_FRONTEND=noninteractive

# Instalar dependencias esenciales del sistema (FFmpeg para procesamiento de audio)
RUN apt-get update && apt-get install -y --no-install-recommends     ffmpeg     git     build-essential     curl     && apt-get clean     && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Actualizar gestor de paquetes de Python
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Instalar PyTorch y Torchaudio optimizados exclusivamente para CPU (sin CUDA / GPU)
RUN pip install --no-cache-dir     torch torchvision torchaudio     --index-url https://download.pytorch.org/whl/cpu

# Copiar e instalar requerimientos del proyecto
COPY requirements.txt .
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Instalar motor de aislamiento vocal UVR5 específico para CPU
RUN pip install --no-cache-dir "audio-separator[cpu]"

# Copiar el código fuente de la aplicación
COPY . /app

# Pre-crear directorios de caché de modelos y uploads
RUN mkdir -p /root/.cache/whisper /root/.cache/audio-separator /app/uploads

EXPOSE 8000

# Variables de entorno predeterminadas
ENV WHISPER_MODEL=medium     DEFAULT_LANGUAGE=es     UVR_ENABLED=true

# Comando por defecto para iniciar el servidor FastAPI / Uvicorn
CMD ["python", "-m", "uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
