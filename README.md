
# Diabetes Prediction API - Cloud Run Deployment

API de predicción de diabetes usando Machine Learning (XGBoost) desplegada en Google Cloud Run.

## Descripción

Esta API proporciona endpoints para predecir el riesgo de diabetes en pacientes basándose en mediciones médicas diagnósticas utilizando el dataset Pima Indians Diabetes.

## Tecnologías

- **Framework**: FastAPI
- **ML Model**: XGBoost con Pipeline de scikit-learn
- **Deployment**: Google Cloud Run
- **Container**: Docker

## Estructura del Proyecto

```
DEPLOY/
├── api.py                          # Aplicación FastAPI
├── modelo_diabetes.pkl             # Pipeline ML entrenado
├── label_encoder_diabetes.pkl      # Codificador de etiquetas
├── requirements.txt                # Dependencias Python
├── Dockerfile                      # Configuración Docker
├── .dockerignore                   # Archivos excluidos del build
├── cloudbuild.yaml                 # Configuración Cloud Build
└── README.md                       # Este archivo
```

## Endpoints

### GET /
Información básica de la API

### GET /health
Health check del servicio y modelo

### POST /predict
Predicción individual para un paciente

**Request Body:**
```json
{
  "preg": 6,
  "plas": 148,
  "pres": 72,
  "skin": 35,
  "insu": 0,
  "mass": 33.6,
  "pedi": 0.627,
  "age": 50
}
```

**Response:**
```json
{
  "prediction": "tested_positive",
  "probability_negative": 0.2345,
  "probability_positive": 0.7655,
  "confidence": 0.7655
}
```

### POST /predict/batch
Predicción por lotes (máximo 100 pacientes)

## Features del Modelo

| Feature | Descripción | Rango |
|---------|-------------|-------|
| preg | Número de embarazos | 0-20 |
| plas | Glucosa en plasma (mg/dL) | 0-300 |
| pres | Presión arterial diastólica (mm Hg) | 0-200 |
| skin | Grosor pliegue cutáneo (mm) | 0-100 |
| insu | Insulina sérica (mu U/ml) | 0-900 |
| mass | Índice de masa corporal (kg/m²) | 0-70 |
| pedi | Función de pedigrí de diabetes | 0-3 |
| age | Edad (años) | 21-120 |

## Deployment en Cloud Run

### Requisitos Previos

1. Cuenta de Google Cloud activa
2. Proyecto de GCP creado
3. Facturación habilitada
4. Google Cloud SDK instalado

### Opción 1: Deployment desde GitHub (Recomendado)

1. Conecta tu repositorio de GitHub en Cloud Run
2. Selecciona la branch `deply`
3. Cloud Build detectará automáticamente el `Dockerfile`
4. Configuración automática con `cloudbuild.yaml`

### Opción 2: Deployment Manual

```bash
# 1. Autenticarse
gcloud auth login

# 2. Configurar proyecto
gcloud config set project YOUR_PROJECT_ID

# 3. Build de la imagen
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/diabetes-api

# 4. Deploy a Cloud Run
gcloud run deploy diabetes-api \
  --image gcr.io/YOUR_PROJECT_ID/diabetes-api \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 1Gi \
  --cpu 1
```

## Configuración de Cloud Run

- **Región**: us-central1
- **Memoria**: 1 GB
- **CPU**: 1 vCPU
- **Timeout**: 300 segundos
- **Max Instances**: 10
- **Authentication**: Allow unauthenticated (público)

## Pruebas Locales

### Con Docker

```bash
# Build
docker build -t diabetes-api .

# Run
docker run -p 8080:8080 diabetes-api

# Test
curl http://localhost:8080/health
```

### Sin Docker

```bash
# Instalar dependencias
pip install -r requirements.txt

# Ejecutar
python api.py

# Test
curl http://localhost:8000/health
```

## Ejemplo de Uso

```bash
# Predicción individual
curl -X POST https://YOUR-SERVICE-URL/predict \
  -H "Content-Type: application/json" \
  -d '{
    "preg": 6,
    "plas": 148,
    "pres": 72,
    "skin": 35,
    "insu": 0,
    "mass": 33.6,
    "pedi": 0.627,
    "age": 50
  }'
```

## Monitoreo

- **Logs**: Cloud Logging
- **Métricas**: Cloud Monitoring
- **Traces**: Cloud Trace

Accede a través de la consola de GCP en la sección de Cloud Run.

## Costos Estimados

Cloud Run cobra por:
- Tiempo de CPU (vCPU-segundos)
- Memoria (GB-segundos)
- Requests

**Free Tier incluye:**
- 2 millones de requests/mes
- 360,000 GB-segundos de memoria
- 180,000 vCPU-segundos

## Troubleshooting

### Error: Model not loaded
- Verificar que los archivos .pkl estén en el contenedor
- Revisar logs: `gcloud run logs read diabetes-api`

### Error: Port binding
- Cloud Run usa variable PORT automáticamente
- El código ya está configurado para leerla

### Error: Memory exceeded
- Aumentar memoria en Cloud Run: `--memory 2Gi`

## Seguridad

Para producción, considera:
- Habilitar autenticación (remover `--allow-unauthenticated`)
- Implementar API keys
- Rate limiting
- HTTPS (habilitado por defecto en Cloud Run)

## Licencia

Proyecto de uso educativo/interno.
