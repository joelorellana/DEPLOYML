#!/bin/bash

# Script para remover permisos de estudiantes en Google Cloud
# Uso: ./remover_estudiantes.sh YOUR_PROJECT_ID

PROJECT_ID=$1

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Debes proporcionar el PROJECT_ID"
    echo "Uso: ./remover_estudiantes.sh YOUR_PROJECT_ID"
    exit 1
fi

echo "=========================================="
echo "Removiendo estudiantes del proyecto: $PROJECT_ID"
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
    echo "[$count] Removiendo permisos para: $email"
    
    # Remover rol Cloud Run Developer
    gcloud projects remove-iam-policy-binding $PROJECT_ID \
        --member="user:$email" \
        --role="roles/run.developer" \
        --quiet 2>/dev/null
    
    # Remover rol Cloud Build Editor
    gcloud projects remove-iam-policy-binding $PROJECT_ID \
        --member="user:$email" \
        --role="roles/cloudbuild.builds.editor" \
        --quiet 2>/dev/null
    
    # Remover rol Viewer de Logs
    gcloud projects remove-iam-policy-binding $PROJECT_ID \
        --member="user:$email" \
        --role="roles/logging.viewer" \
        --quiet 2>/dev/null
    
    # Remover rol Viewer de Storage
    gcloud projects remove-iam-policy-binding $PROJECT_ID \
        --member="user:$email" \
        --role="roles/storage.objectViewer" \
        --quiet 2>/dev/null
    
    echo "  ✓ Permisos removidos"
    echo ""
    
done < estudiantes.txt

echo "=========================================="
echo "Resumen:"
echo "  Total de estudiantes removidos: $count"
echo "  Proyecto: $PROJECT_ID"
echo "=========================================="
