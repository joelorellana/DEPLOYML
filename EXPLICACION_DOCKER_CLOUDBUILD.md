# 📚 Explicación Detallada: Dockerfile y cloudbuild.yaml

## 🐳 Dockerfile - Línea por Línea

### Código Completo
```dockerfile
# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY api.py .

# Copy model files
COPY modelo_diabetes.pkl .
COPY label_encoder_diabetes.pkl .

# Expose port (Cloud Run will set PORT env variable)
EXPOSE 8080

# Run the application
CMD ["python", "api.py"]
```

---

### Explicación Detallada

#### 1. `FROM python:3.11-slim`

**Qué hace:**
- Define la **imagen base** sobre la cual construiremos nuestro contenedor
- `python:3.11-slim` es una imagen oficial de Python versión 3.11

**¿Por qué "slim"?**
- Versión **ligera** de Python (menos de 150MB vs 900MB de la versión completa)
- Incluye solo lo esencial para ejecutar Python
- Reduce tiempo de build y tamaño final

**Alternativas:**
```dockerfile
FROM python:3.11        # Versión completa (~900MB)
FROM python:3.11-slim   # Versión ligera (~150MB) ✓ Recomendado
FROM python:3.11-alpine # Más ligera (~50MB) pero puede tener problemas con algunas librerías
```

---

#### 2. `WORKDIR /app`

**Qué hace:**
- Crea y establece `/app` como el **directorio de trabajo** dentro del contenedor
- Todos los comandos siguientes se ejecutarán desde este directorio

**Sin WORKDIR:**
```dockerfile
# Tendrías que hacer:
RUN cd /app && pip install ...
COPY api.py /app/api.py
```

**Con WORKDIR:**
```dockerfile
# Mucho más simple:
RUN pip install ...
COPY api.py .
```

**Estructura resultante:**
```
/app/
├── api.py
├── modelo_diabetes.pkl
├── label_encoder_diabetes.pkl
└── requirements.txt
```

---

#### 3. `COPY requirements.txt .`

**Qué hace:**
- Copia el archivo `requirements.txt` desde tu máquina local al contenedor
- El `.` significa "directorio actual" (que es `/app` por el WORKDIR)

**¿Por qué copiar requirements.txt primero?**
- **Docker Layer Caching**: Docker guarda cada paso en capas
- Si `requirements.txt` no cambia, Docker reutiliza la capa cacheada
- Esto hace que builds subsecuentes sean **mucho más rápidos**

**Ejemplo de caching:**
```
Build 1 (primera vez):
├─ FROM python:3.11-slim     [descarga ~150MB]
├─ WORKDIR /app              [crea directorio]
├─ COPY requirements.txt     [copia archivo]
└─ RUN pip install...        [instala ~200MB] ⏱️ 2 minutos

Build 2 (cambias solo api.py):
├─ FROM python:3.11-slim     [usa cache] ⚡
├─ WORKDIR /app              [usa cache] ⚡
├─ COPY requirements.txt     [usa cache] ⚡
└─ RUN pip install...        [usa cache] ⚡ ¡Instantáneo!
```

---

#### 4. `RUN pip install --no-cache-dir -r requirements.txt`

**Qué hace:**
- Ejecuta el comando `pip install` **durante el build**
- Instala todas las dependencias listadas en `requirements.txt`

**Desglose del comando:**
- `RUN` → Ejecuta un comando durante el build
- `pip install` → Instalador de paquetes Python
- `--no-cache-dir` → No guarda archivos de cache de pip
- `-r requirements.txt` → Lee paquetes desde el archivo

**¿Por qué `--no-cache-dir`?**
- Reduce el tamaño de la imagen final
- Cache de pip puede ocupar 100-200MB innecesarios
- En contenedores no necesitamos cache porque cada build es "limpio"

**Ejemplo de requirements.txt:**
```txt
fastapi
uvicorn[standard]
pydantic
xgboost
scikit-learn
joblib
numpy
```

---

#### 5. `COPY api.py .`

**Qué hace:**
- Copia el archivo `api.py` (tu aplicación FastAPI) al contenedor

**¿Por qué después de instalar dependencias?**
- `api.py` cambia frecuentemente durante desarrollo
- Al copiarlo después, los cambios en `api.py` no invalidan el cache de `pip install`

**Flujo optimizado:**
```
Cambias api.py → Solo se re-ejecutan pasos después de COPY api.py
No se reinstalan dependencias (usa cache) ⚡
```

---

#### 6. `COPY modelo_diabetes.pkl .` y `COPY label_encoder_diabetes.pkl .`

**Qué hace:**
- Copia los archivos del modelo ML entrenado al contenedor

**¿Por qué incluir modelos en la imagen?**

**Ventajas:**
- ✅ Imagen auto-contenida (todo incluido)
- ✅ No depende de servicios externos
- ✅ Más rápido al iniciar (no descarga nada)
- ✅ Más simple de desplegar

**Desventajas:**
- ❌ Aumenta tamaño de imagen (~230KB en este caso, aceptable)
- ❌ Para actualizar modelo, hay que rebuild imagen

**Alternativa (para modelos grandes >100MB):**
```dockerfile
# No copiar modelos, descargarlos de Cloud Storage al iniciar
# En api.py:
# from google.cloud import storage
# storage.Client().bucket('modelos').blob('modelo.pkl').download_to_filename('modelo.pkl')
```

---

#### 7. `EXPOSE 8080`

**Qué hace:**
- **Documenta** que el contenedor escucha en el puerto 8080
- Es solo **documentación**, no abre el puerto realmente

**¿Por qué 8080?**
- Cloud Run usa por defecto el puerto 8080
- Puedes usar cualquier puerto, pero 8080 es el estándar

**Importante:**
- `EXPOSE` NO publica el puerto
- Solo indica qué puerto usa la aplicación
- El puerto real se configura en `api.py`:
  ```python
  port = int(os.environ.get("PORT", 8000))
  uvicorn.run("api:app", host="0.0.0.0", port=port)
  ```

---

#### 8. `CMD ["python", "api.py"]`

**Qué hace:**
- Define el **comando por defecto** que se ejecuta cuando el contenedor inicia
- Ejecuta `python api.py` para iniciar la aplicación

**Formato:**
```dockerfile
CMD ["ejecutable", "param1", "param2"]  # Formato exec (recomendado)
CMD python api.py                        # Formato shell
```

**Diferencia entre RUN y CMD:**
```dockerfile
RUN pip install fastapi    # Se ejecuta DURANTE el build
CMD ["python", "api.py"]   # Se ejecuta CUANDO el contenedor inicia
```

**Analogía:**
- `RUN` = Preparar ingredientes en la cocina
- `CMD` = Servir el platillo al cliente

**Puedes sobrescribir CMD:**
```bash
docker run mi-imagen python -c "print('Hola')"  # Sobrescribe CMD
```

---

## ⚙️ cloudbuild.yaml - Línea por Línea

### Código Completo
```yaml
steps:
  # Build the container image
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA', '.']
  
  # Push the container image to Container Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA']
  
  # Deploy container image to Cloud Run
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - 'diabetes-api'
      - '--image'
      - 'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA'
      - '--region'
      - 'us-central1'
      - '--platform'
      - 'managed'
      - '--allow-unauthenticated'
      - '--memory'
      - '1Gi'
      - '--cpu'
      - '1'
      - '--max-instances'
      - '10'
      - '--timeout'
      - '300'

images:
  - 'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA'

options:
  logging: CLOUD_LOGGING_ONLY
```

---

### Explicación Detallada

#### 1. `steps:`

**Qué es:**
- Lista de **pasos secuenciales** que Cloud Build ejecutará
- Cada paso se ejecuta en un contenedor separado
- Los pasos se ejecutan en orden

**Estructura:**
```yaml
steps:
  - name: 'imagen-del-contenedor'
    args: ['comando', 'arg1', 'arg2']
  - name: 'otra-imagen'
    args: ['otro-comando']
```

---

#### 2. Paso 1: Build de la Imagen

```yaml
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA', '.']
```

**Desglose:**

**`name: 'gcr.io/cloud-builders/docker'`**
- Usa la imagen oficial de Docker de Google Cloud
- Esta imagen tiene Docker instalado y configurado
- Es como decir "usa Docker para este paso"

**`args: ['build', ...]`**
- Argumentos que se pasan al comando docker
- Equivalente a ejecutar: `docker build -t gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA .`

**`'build'`**
- Comando de Docker para construir una imagen

**`'-t'`**
- Flag para "tag" (etiquetar la imagen)
- Le da un nombre a la imagen

**`'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA'`**
- Nombre completo de la imagen con formato: `registry/project/nombre:tag`
- `gcr.io` = Google Container Registry
- `$PROJECT_ID` = Variable automática con tu ID de proyecto
- `diabetes-api` = Nombre de tu aplicación
- `$COMMIT_SHA` = Hash del commit de Git (para versionado)

**Ejemplo real:**
```
gcr.io/mi-proyecto-123/diabetes-api:a1b2c3d4
```

**`'.'`**
- Contexto de build (directorio actual)
- Docker buscará el `Dockerfile` aquí

---

#### 3. Paso 2: Push de la Imagen

```yaml
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA']
```

**Qué hace:**
- Sube la imagen construida a Google Container Registry
- Equivalente a: `docker push gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA`

**¿Por qué push?**
- Cloud Run necesita descargar la imagen desde un registry
- No puede usar imágenes locales
- GCR es el "almacén" de imágenes de Google Cloud

**Flujo:**
```
Build local → Push a GCR → Cloud Run descarga de GCR
```

---

#### 4. Paso 3: Deploy a Cloud Run

```yaml
- name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
  entrypoint: gcloud
  args:
    - 'run'
    - 'deploy'
    - 'diabetes-api'
    - '--image'
    - 'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA'
    - '--region'
    - 'us-central1'
    - '--platform'
    - 'managed'
    - '--allow-unauthenticated'
    - '--memory'
    - '1Gi'
    - '--cpu'
    - '1'
    - '--max-instances'
    - '10'
    - '--timeout'
    - '300'
```

**Desglose de cada argumento:**

**`name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'`**
- Usa la imagen oficial de Google Cloud SDK
- Tiene `gcloud` CLI instalado

**`entrypoint: gcloud`**
- Comando principal a ejecutar
- Sobrescribe el entrypoint por defecto de la imagen

**`'run'`**
- Subcomando de gcloud para Cloud Run

**`'deploy'`**
- Acción: desplegar un servicio

**`'diabetes-api'`**
- Nombre del servicio en Cloud Run
- Este será el nombre que aparece en la consola

**`'--image' 'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA'`**
- Imagen a desplegar (la que acabamos de construir y subir)

**`'--region' 'us-central1'`**
- Región donde se desplegará el servicio
- `us-central1` = Iowa, USA (centro de datos)
- Otras opciones: `us-east1`, `europe-west1`, etc.

**`'--platform' 'managed'`**
- Tipo de plataforma Cloud Run
- `managed` = Completamente administrado por Google (recomendado)
- Alternativa: `gke` (en tu propio cluster Kubernetes)

**`'--allow-unauthenticated'`**
- Permite acceso público sin autenticación
- Cualquiera puede llamar a tu API
- Para APIs privadas, omite este flag

**`'--memory' '1Gi'`**
- Memoria RAM asignada al contenedor
- `1Gi` = 1 Gigabyte
- Opciones: `128Mi`, `256Mi`, `512Mi`, `1Gi`, `2Gi`, `4Gi`, `8Gi`

**`'--cpu' '1'`**
- Número de CPUs virtuales
- `1` = 1 vCPU
- Opciones: `1`, `2`, `4`, `6`, `8`

**`'--max-instances' '10'`**
- Número máximo de instancias simultáneas
- Cloud Run auto-escala según demanda
- Limita a 10 para controlar costos

**`'--timeout' '300'`**
- Timeout máximo para requests en segundos
- `300` = 5 minutos
- Máximo permitido: 3600 segundos (1 hora)

**Comando equivalente en CLI:**
```bash
gcloud run deploy diabetes-api \
  --image gcr.io/mi-proyecto/diabetes-api:abc123 \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --memory 1Gi \
  --cpu 1 \
  --max-instances 10 \
  --timeout 300
```

---

#### 5. `images:`

```yaml
images:
  - 'gcr.io/$PROJECT_ID/diabetes-api:$COMMIT_SHA'
```

**Qué hace:**
- Lista de imágenes que se guardarán en el registro después del build
- Cloud Build las mantiene disponibles para uso futuro

**¿Por qué es importante?**
- Permite rollback a versiones anteriores
- Mantiene historial de imágenes
- Facilita debugging

---

#### 6. `options:`

```yaml
options:
  logging: CLOUD_LOGGING_ONLY
```

**Qué hace:**
- Configuraciones adicionales del build

**`logging: CLOUD_LOGGING_ONLY`**
- Envía logs solo a Cloud Logging
- Alternativas:
  - `LEGACY` = Logs en Cloud Storage (deprecated)
  - `GCS_ONLY` = Solo en Cloud Storage
  - `CLOUD_LOGGING_ONLY` = Solo en Cloud Logging (recomendado)

**Otras opciones disponibles:**
```yaml
options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'N1_HIGHCPU_8'  # Máquina más potente para builds
  timeout: '1200s'              # Timeout del build completo
  substitution_option: 'ALLOW_LOOSE'
```

---

## 🔄 Flujo Completo del Deployment

### 1. Desarrollador hace push
```bash
git push origin deply
```

### 2. Cloud Build se activa
- Detecta cambios en la branch `deply`
- Lee `cloudbuild.yaml`

### 3. Paso 1: Build
```bash
docker build -t gcr.io/PROJECT_ID/diabetes-api:abc123 .
```
- Lee `Dockerfile`
- Instala dependencias
- Copia código y modelos
- Crea imagen

### 4. Paso 2: Push
```bash
docker push gcr.io/PROJECT_ID/diabetes-api:abc123
```
- Sube imagen a Container Registry

### 5. Paso 3: Deploy
```bash
gcloud run deploy diabetes-api --image gcr.io/PROJECT_ID/diabetes-api:abc123 ...
```
- Despliega en Cloud Run
- Asigna URL pública
- Configura auto-scaling

### 6. Resultado
```
✅ API disponible en: https://diabetes-api-xxx.run.app
```

---

## 💡 Variables Automáticas

Cloud Build proporciona variables que puedes usar:

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `$PROJECT_ID` | ID de tu proyecto GCP | `mi-proyecto-123` |
| `$COMMIT_SHA` | Hash del commit Git | `a1b2c3d4e5f6` |
| `$SHORT_SHA` | Hash corto (7 chars) | `a1b2c3d` |
| `$BRANCH_NAME` | Nombre de la branch | `deply` |
| `$TAG_NAME` | Tag de Git (si existe) | `v1.0.0` |
| `$REPO_NAME` | Nombre del repositorio | `DEPLOYML` |

**Uso:**
```yaml
args: ['build', '-t', 'gcr.io/$PROJECT_ID/app:$SHORT_SHA', '.']
```

---

## 🎯 Resumen Ejecutivo

### Dockerfile
- **Propósito**: Empaquetar tu aplicación en un contenedor
- **Resultado**: Imagen Docker ejecutable
- **Se ejecuta**: Durante el build

### cloudbuild.yaml
- **Propósito**: Automatizar build, push y deploy
- **Resultado**: API desplegada en Cloud Run
- **Se ejecuta**: Cuando haces git push

### Relación
```
git push → Cloud Build lee cloudbuild.yaml
         → Ejecuta Dockerfile (build)
         → Sube imagen (push)
         → Despliega (deploy)
         → ✅ API en producción
```

---

## 📚 Recursos Adicionales

- **Dockerfile Reference**: https://docs.docker.com/engine/reference/builder/
- **Cloud Build Docs**: https://cloud.google.com/build/docs
- **Cloud Run Docs**: https://cloud.google.com/run/docs
- **Best Practices**: https://cloud.google.com/architecture/best-practices-for-building-containers
