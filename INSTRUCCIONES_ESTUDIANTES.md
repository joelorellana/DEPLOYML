# 🎓 Instrucciones para Estudiantes - Deployment en Cloud Run

## Requisitos Previos

1. Tener una cuenta de Google (Gmail)
2. Haber recibido acceso al proyecto de Google Cloud
3. Tener Git instalado
4. Tener Google Cloud SDK instalado

## Instalación de Google Cloud SDK

### macOS
```bash
brew install google-cloud-sdk
```

### Windows
Descargar desde: https://cloud.google.com/sdk/docs/install

### Linux
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

## Paso 1: Autenticación

```bash
# Iniciar sesión con tu cuenta de Google
gcloud auth login

# Configurar el proyecto (usa el PROJECT_ID que te proporcionó el instructor)
gcloud config set project PROJECT_ID_AQUI
```

## Paso 2: Clonar el Repositorio

```bash
# Clonar el repositorio del proyecto
git clone https://github.com/joelorellana/DEPLOYML.git

# Entrar al directorio
cd DEPLOYML

# Cambiar a la branch de deployment
git checkout deply
```

## Paso 3: Crear tu Propia Branch

**IMPORTANTE:** Cada estudiante debe trabajar en su propia branch

```bash
# Crear tu branch (usa tu nombre sin espacios)
git checkout -b deploy-tunombre

# Ejemplo:
# git checkout -b deploy-juan
# git checkout -b deploy-maria
```

## Paso 4: Personalizar tu Deployment

### Opción A: Deployment desde Código Local

```bash
# Asegúrate de estar en el directorio del proyecto
cd DEPLOYML

# Deploy directo desde el código
gcloud run deploy api-diabetes-tunombre \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --max-instances 3

# Ejemplo:
# gcloud run deploy api-diabetes-juan --source . --region us-central1 --allow-unauthenticated
```

### Opción B: Deployment desde GitHub (Recomendado)

1. **Fork el repositorio** en tu cuenta de GitHub
2. **Ir a Cloud Run Console**: https://console.cloud.google.com/run
3. **Click en "CREATE SERVICE"**
4. **Seleccionar:** "Continuously deploy from a repository"
5. **Conectar tu repositorio de GitHub**
6. **Configuración:**
   - Service name: `api-diabetes-tunombre`
   - Region: `us-central1`
   - Branch: `deply` o tu branch
   - Build type: Dockerfile
   - Authentication: Allow unauthenticated
   - Memory: 512 MiB
   - CPU: 1
   - Max instances: 3

## Paso 5: Verificar tu Deployment

Una vez desplegado, obtendrás una URL como:
```
https://api-diabetes-tunombre-XXXXX-uc.a.run.app
```

### Probar tu API

```bash
# Health check
curl https://TU-URL-AQUI/health

# Predicción de prueba
curl -X POST https://TU-URL-AQUI/predict \
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

## Paso 6: Ver Logs y Métricas

```bash
# Ver logs de tu servicio
gcloud run services logs read api-diabetes-tunombre --region us-central1

# Ver detalles del servicio
gcloud run services describe api-diabetes-tunombre --region us-central1
```

## Comandos Útiles

### Ver tus servicios
```bash
gcloud run services list --region us-central1
```

### Actualizar configuración
```bash
gcloud run services update api-diabetes-tunombre \
  --memory 1Gi \
  --region us-central1
```

### Eliminar tu servicio
```bash
gcloud run services delete api-diabetes-tunombre --region us-central1
```

### Ver URL de tu servicio
```bash
gcloud run services describe api-diabetes-tunombre \
  --region us-central1 \
  --format='value(status.url)'
```

## Documentación Interactiva

Tu API incluye documentación automática en:
```
https://TU-URL-AQUI/docs
```

## Troubleshooting

### Error: "Permission denied"
- Verifica que estés autenticado: `gcloud auth list`
- Verifica el proyecto: `gcloud config get-value project`

### Error: "Service name already exists"
- Usa un nombre único: `api-diabetes-tunombre-v2`

### Error: "Build failed"
- Verifica que estés en el directorio correcto
- Verifica que exista el archivo `Dockerfile`

### Error: "Out of memory"
- Aumenta la memoria: `--memory 1Gi`

### Ver logs de errores
```bash
gcloud run services logs read api-diabetes-tunombre \
  --region us-central1 \
  --limit 50
```

## Mejores Prácticas

1. **Nombra tu servicio con tu nombre** para evitar conflictos
2. **No uses más de 3 instancias** para controlar costos
3. **Elimina servicios de prueba** que no uses
4. **Revisa los logs** si algo no funciona
5. **Usa memoria de 512Mi** a menos que necesites más

## Recursos Adicionales

- **Documentación Cloud Run**: https://cloud.google.com/run/docs
- **FastAPI Docs**: https://fastapi.tiangolo.com
- **Docker Tutorial**: https://docs.docker.com/get-started/

## Entregables

Para completar la práctica, proporciona:

1. **URL de tu servicio desplegado**
2. **Screenshot del health check funcionando**
3. **Screenshot de una predicción exitosa**
4. **Captura de los logs mostrando requests**

## Soporte

Si tienes problemas:
1. Revisa esta documentación
2. Consulta los logs de tu servicio
3. Pregunta al instructor

---

**¡Buena suerte con tu deployment! 🚀**
