#!/bin/bash

# Script para agregar permisos a estudiantes en Google Cloud
# Uso: ./agregar_estudiantes.sh YOUR_PROJECT_ID

PROJECT_ID=$1

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Debes proporcionar el PROJECT_ID"
    echo "Uso: ./agregar_estudiantes.sh YOUR_PROJECT_ID"
    exit 1
fi

echo "=========================================="
echo "Agregando estudiantes al proyecto: $PROJECT_ID"
echo "=========================================="
echo ""

# Verificar que el archivo estudiantes.txt existe
if [ ! -f "estudiantes.txt" ]; then
    echo "Error: No se encuentra el archivo estudiantes.txt"
    exit 1
fi

# Contador
count=0

# Leer cada email del archivo
while IFS= read -r email; do
    # Saltar líneas vacías
    if [ -z "$email" ]; then
        continue
    fi
    
    count=$((count + 1))
    echo "[$count] Agregando permisos para: $email"
    
    # Agregar rol Cloud Run Developer
    echo "  → Agregando rol: Cloud Run Developer"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="user:$email" \
        --role="roles/run.developer" \
        --quiet
    
    # Agregar rol Cloud Build Editor
    echo "  → Agregando rol: Cloud Build Editor"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="user:$email" \
        --role="roles/cloudbuild.builds.editor" \
        --quiet
    
    # Agregar rol Viewer de Logs
    echo "  → Agregando rol: Logging Viewer"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="user:$email" \
        --role="roles/logging.viewer" \
        --quiet
    
    # Agregar rol Viewer de Storage (para Container Registry)
    echo "  → Agregando rol: Storage Object Viewer"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="user:$email" \
        --role="roles/storage.objectViewer" \
        --quiet
    
    echo "  ✓ Permisos agregados exitosamente"
    echo ""
    
done < estudiantes.txt

echo "=========================================="
echo "Resumen:"
echo "  Total de estudiantes agregados: $count"
echo "  Proyecto: $PROJECT_ID"
echo ""
echo "Roles asignados a cada estudiante:"
echo "  - roles/run.developer (Deploy Cloud Run)"
echo "  - roles/cloudbuild.builds.editor (Crear builds)"
echo "  - roles/logging.viewer (Ver logs)"
echo "  - roles/storage.objectViewer (Ver imágenes)"
echo "=========================================="
echo ""
echo "Los estudiantes ahora pueden:"
echo "  1. gcloud auth login"
echo "  2. gcloud config set project $PROJECT_ID"
echo "  3. gcloud run deploy su-servicio --source . --region us-central1"
