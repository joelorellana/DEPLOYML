# Cloud Run Deployment Checklist

## ✅ Archivos Creados

- [x] **Dockerfile** - Configuración del contenedor
- [x] **.dockerignore** - Archivos excluidos del build
- [x] **cloudbuild.yaml** - Configuración de Cloud Build
- [x] **README.md** - Documentación completa
- [x] **api.py** - Modificado para usar PORT env variable
- [x] **requirements.txt** - Dependencias verificadas
- [x] **modelo_diabetes.pkl** - Modelo ML (230KB)
- [x] **label_encoder_diabetes.pkl** - Encoder (509B)

## ✅ Configuración Git

- [x] Branch `deply` creada
- [x] `.gitignore` actualizado (removido *.pkl)
- [x] Modelos incluidos en el repositorio

## 📋 Pasos para Deployment

### 1. Verificar archivos localmente

```bash
# Verificar que el Dockerfile funciona
docker build -t diabetes-api-test .
docker run -p 8080:8080 diabetes-api-test

# Test local
curl http://localhost:8080/health
```

### 2. Commit y Push a GitHub

```bash
# Agregar archivos nuevos
git add Dockerfile .dockerignore cloudbuild.yaml README.md DEPLOYMENT_CHECKLIST.md
git add api.py modelo_diabetes.pkl label_encoder_diabetes.pkl

# Commit
git commit -m "Add Cloud Run deployment configuration"

# Push a branch deply
git push origin deply
```

### 3. Configurar Cloud Run

#### Opción A: Desde la Consola (Recomendado)

1. Ve a Cloud Run en GCP Console
2. Click "Create Service"
3. Selecciona "Continuously deploy from a repository"
4. Click "Set up with Cloud Build"
5. Conecta tu repositorio GitHub: `joelorellana/DEPLOYML`
6. Selecciona branch: `deply`
7. Build type: Dockerfile
8. Configuración:
   - Service name: `diabetes-api`
   - Region: `us-central1`
   - Authentication: Allow unauthenticated
   - Memory: 1 GiB
   - CPU: 1
   - Max instances: 10

#### Opción B: Desde CLI

```bash
# Autenticar
gcloud auth login

# Configurar proyecto
gcloud config set project YOUR_PROJECT_ID

# Habilitar APIs necesarias
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Deploy
gcloud builds submit --config cloudbuild.yaml
```

### 4. Verificar Deployment

Una vez desplegado, obtendrás una URL como:
`https://diabetes-api-XXXXX-uc.a.run.app`

```bash
# Health check
curl https://YOUR-SERVICE-URL/health

# Predicción de prueba
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

### 5. Monitoreo

```bash
# Ver logs
gcloud run services logs read diabetes-api --region=us-central1

# Ver métricas
# Ir a Cloud Console > Cloud Run > diabetes-api > Metrics
```

## 🔧 Configuración Importante

### Variables de Entorno (si necesitas)

```bash
gcloud run services update diabetes-api \
  --update-env-vars KEY=VALUE \
  --region=us-central1
```

### Actualizar Configuración

```bash
# Aumentar memoria
gcloud run services update diabetes-api \
  --memory 2Gi \
  --region=us-central1

# Cambiar max instances
gcloud run services update diabetes-api \
  --max-instances 20 \
  --region=us-central1
```

## 🐛 Troubleshooting

### Error: "Failed to build"
- Verificar Dockerfile localmente
- Revisar logs en Cloud Build

### Error: "Container failed to start"
- Verificar que api.py usa PORT env variable
- Revisar logs: `gcloud run logs read`

### Error: "Model not loaded"
- Verificar que .pkl están en el contenedor
- Verificar rutas en api.py

### Error: "Out of memory"
- Aumentar memoria: `--memory 2Gi`
- Optimizar modelo o usar Cloud Storage

## 📊 Costos Estimados

**Free Tier mensual:**
- 2M requests
- 360,000 GB-segundos
- 180,000 vCPU-segundos

**Estimación para uso bajo-medio:**
- ~1000 requests/día
- Costo: $0-5/mes (dentro de free tier)

## 🔐 Seguridad (Producción)

Para producción, implementar:

```bash
# Requerir autenticación
gcloud run services update diabetes-api \
  --no-allow-unauthenticated \
  --region=us-central1

# Crear service account
gcloud iam service-accounts create diabetes-api-invoker

# Dar permisos
gcloud run services add-iam-policy-binding diabetes-api \
  --member="serviceAccount:diabetes-api-invoker@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.invoker"
```

## ✨ Próximos Pasos

- [ ] Configurar dominio personalizado
- [ ] Implementar rate limiting
- [ ] Agregar API keys
- [ ] Configurar CI/CD automático
- [ ] Implementar logging estructurado
- [ ] Agregar métricas personalizadas
- [ ] Configurar alertas

## 📝 Notas

- El deployment automático se activa con cada push a `deply`
- Cloud Build tarda ~3-5 minutos en completar
- La URL del servicio se mantiene constante
- Los modelos .pkl están incluidos en la imagen (230KB total)
