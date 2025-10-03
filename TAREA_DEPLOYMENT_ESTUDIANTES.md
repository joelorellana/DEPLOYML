# 🎯 Tarea: Deployment de Modelo ML en PythonAnywhere

## 📋 Información General

**Objetivo:** Desplegar una API de Machine Learning usando Flask en PythonAnywhere

**Duración estimada:** 2-3 horas

**Nivel:** Intermedio

**Requisitos previos:**
- Conocimientos básicos de Python
- Conocimientos básicos de Git
- Cuenta de GitHub (gratuita)
- Cuenta de PythonAnywhere (gratuita)

---

## 🎓 Descripción del Proyecto

Vas a desplegar un modelo de Machine Learning pre-entrenado que predice si un vino es de **alta o baja calidad** basándose en sus características químicas.

**Dataset:** Wine Quality Dataset (UCI Machine Learning Repository)

**Modelo:** Random Forest Classifier (ya entrenado)

**Framework:** Flask (API REST)

**Plataforma:** PythonAnywhere (hosting gratuito)

---

## 📦 Entregables

1. **Repositorio de GitHub** con tu código
2. **URL pública** de tu API funcionando
3. **Screenshot** de una predicción exitosa
4. **Documento README.md** con instrucciones de uso

---

## 🚀 Parte 1: Setup Inicial

### 1.1 Crear Cuenta en PythonAnywhere

1. Ve a: https://www.pythonanywhere.com/
2. Click en "Pricing & signup"
3. Selecciona "Create a Beginner account" (GRATIS)
4. Completa el registro con tu email

**Límites del plan gratuito:**
- 1 aplicación web
- 512 MB de espacio
- Suficiente para esta tarea ✅

### 1.2 Fork del Repositorio Base

1. Ve a: https://github.com/joelorellana/DEPLOYML
2. Click en "Fork" (esquina superior derecha)
3. Esto crea una copia en tu cuenta de GitHub

### 1.3 Clonar tu Fork

```bash
# En tu computadora local
git clone https://github.com/TU-USUARIO/DEPLOYML.git
cd DEPLOYML
```

---

## 📁 Parte 2: Estructura del Proyecto

Vas a crear los siguientes archivos en una nueva carpeta:

```
wine-quality-api/
├── app.py                  # API Flask
├── model.pkl              # Modelo entrenado (proporcionado)
├── scaler.pkl             # Escalador (proporcionado)
├── requirements.txt       # Dependencias
└── README.md             # Documentación
```

### 2.1 Crear Carpeta del Proyecto

```bash
mkdir wine-quality-api
cd wine-quality-api
```

---

## 🤖 Parte 3: Código del Proyecto

### 3.1 Archivo: `app.py`

Crea el archivo `app.py` con el siguiente código:

```python
from flask import Flask, request, jsonify
import joblib
import numpy as np

# Inicializar Flask
app = Flask(__name__)

# Cargar modelo y scaler
model = joblib.load('model.pkl')
scaler = joblib.load('scaler.pkl')

# Nombres de las características
FEATURE_NAMES = [
    'fixed_acidity', 'volatile_acidity', 'citric_acid', 
    'residual_sugar', 'chlorides', 'free_sulfur_dioxide',
    'total_sulfur_dioxide', 'density', 'pH', 
    'sulphates', 'alcohol'
]

@app.route('/')
def home():
    """Endpoint principal con información de la API"""
    return jsonify({
        'message': 'Wine Quality Prediction API',
        'version': '1.0',
        'endpoints': {
            '/': 'Información de la API',
            '/health': 'Health check',
            '/predict': 'Predicción de calidad (POST)',
            '/example': 'Ejemplo de datos de entrada'
        },
        'author': 'TU NOMBRE AQUI'  # ⚠️ CAMBIA ESTO
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': model is not None,
        'scaler_loaded': scaler is not None
    })

@app.route('/example')
def example():
    """Retorna un ejemplo de datos de entrada"""
    return jsonify({
        'example_input': {
            'fixed_acidity': 7.4,
            'volatile_acidity': 0.7,
            'citric_acid': 0.0,
            'residual_sugar': 1.9,
            'chlorides': 0.076,
            'free_sulfur_dioxide': 11.0,
            'total_sulfur_dioxide': 34.0,
            'density': 0.9978,
            'pH': 3.51,
            'sulphates': 0.56,
            'alcohol': 9.4
        },
        'expected_output': {
            'quality': 'low',
            'probability_low': 0.85,
            'probability_high': 0.15
        }
    })

@app.route('/predict', methods=['POST'])
def predict():
    """
    Endpoint para hacer predicciones
    
    Request body (JSON):
    {
        "fixed_acidity": 7.4,
        "volatile_acidity": 0.7,
        "citric_acid": 0.0,
        "residual_sugar": 1.9,
        "chlorides": 0.076,
        "free_sulfur_dioxide": 11.0,
        "total_sulfur_dioxide": 34.0,
        "density": 0.9978,
        "pH": 3.51,
        "sulphates": 0.56,
        "alcohol": 9.4
    }
    """
    try:
        # Obtener datos del request
        data = request.get_json()
        
        # Validar que todos los campos estén presentes
        missing_fields = [field for field in FEATURE_NAMES if field not in data]
        if missing_fields:
            return jsonify({
                'error': 'Missing fields',
                'missing': missing_fields
            }), 400
        
        # Extraer features en el orden correcto
        features = [float(data[field]) for field in FEATURE_NAMES]
        features_array = np.array(features).reshape(1, -1)
        
        # Escalar features
        features_scaled = scaler.transform(features_array)
        
        # Hacer predicción
        prediction = model.predict(features_scaled)[0]
        probabilities = model.predict_proba(features_scaled)[0]
        
        # Preparar respuesta
        quality = 'high' if prediction == 1 else 'low'
        
        return jsonify({
            'quality': quality,
            'probability_low': float(probabilities[0]),
            'probability_high': float(probabilities[1]),
            'confidence': float(max(probabilities)),
            'input_features': data
        })
        
    except Exception as e:
        return jsonify({
            'error': str(e)
        }), 500

if __name__ == '__main__':
    # Para desarrollo local
    app.run(debug=True, host='0.0.0.0', port=5000)
```

**⚠️ IMPORTANTE:** Cambia `'TU NOMBRE AQUI'` en la línea 25 por tu nombre real.

---

### 3.2 Archivo: `requirements.txt`

Crea el archivo `requirements.txt`:

```txt
Flask==3.0.0
scikit-learn==1.3.2
joblib==1.3.2
numpy==1.26.2
```

---

### 3.3 Archivo: `README.md`

Crea tu documentación:

```markdown
# Wine Quality Prediction API

API para predecir la calidad de vinos basándose en características químicas.

## Autor
**Tu Nombre Completo**

## Dataset
Wine Quality Dataset - UCI Machine Learning Repository

## Modelo
- Algoritmo: Random Forest Classifier
- Accuracy: ~85%
- Features: 11 características químicas

## Endpoints

### GET /
Información general de la API

### GET /health
Health check del servicio

### GET /example
Ejemplo de datos de entrada

### POST /predict
Realiza una predicción

**Request:**
```json
{
  "fixed_acidity": 7.4,
  "volatile_acidity": 0.7,
  "citric_acid": 0.0,
  "residual_sugar": 1.9,
  "chlorides": 0.076,
  "free_sulfur_dioxide": 11.0,
  "total_sulfur_dioxide": 34.0,
  "density": 0.9978,
  "pH": 3.51,
  "sulphates": 0.56,
  "alcohol": 9.4
}
```

**Response:**
```json
{
  "quality": "low",
  "probability_low": 0.85,
  "probability_high": 0.15,
  "confidence": 0.85
}
```

## Uso Local

```bash
pip install -r requirements.txt
python app.py
```

## URL de Producción
https://TU-USUARIO.pythonanywhere.com

## Fecha de Deployment
[Fecha aquí]
```

---

## 🔧 Parte 4: Obtener los Modelos Pre-entrenados

### Opción A: Entrenar el Modelo (Opcional)

Si quieres entrenar tu propio modelo, crea `train_model.py`:

```python
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
import joblib

# Cargar dataset
url = "https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv"
df = pd.read_csv(url, sep=';')

# Preparar datos
# Convertir calidad a binario: >=6 = high (1), <6 = low (0)
df['quality_binary'] = (df['quality'] >= 6).astype(int)

X = df.drop(['quality', 'quality_binary'], axis=1)
y = df['quality_binary']

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Escalar
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Entrenar modelo
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train_scaled, y_train)

# Evaluar
accuracy = model.score(X_test_scaled, y_test)
print(f"Accuracy: {accuracy:.2%}")

# Guardar modelo y scaler
joblib.dump(model, 'model.pkl')
joblib.dump(scaler, 'scaler.pkl')
print("Modelo guardado exitosamente!")
```

Ejecutar:
```bash
pip install pandas scikit-learn joblib
python train_model.py
```

### Opción B: Descargar Modelos Pre-entrenados

**Los modelos ya están disponibles en el repositorio base.**

Si no los tienes, contacta al instructor.

---

## 🌐 Parte 5: Deployment en PythonAnywhere

### 5.1 Subir Código a GitHub

```bash
# Agregar archivos
git add .

# Commit
git commit -m "Add wine quality API"

# Push
git push origin main
```

### 5.2 Configurar PythonAnywhere

1. **Login en PythonAnywhere**
   - Ve a: https://www.pythonanywhere.com/
   - Inicia sesión

2. **Abrir Bash Console**
   - Dashboard → "Consoles" → "Bash"

3. **Clonar tu Repositorio**
   ```bash
   git clone https://github.com/TU-USUARIO/DEPLOYML.git
   cd DEPLOYML/wine-quality-api
   ```

4. **Crear Virtual Environment**
   ```bash
   mkvirtualenv --python=/usr/bin/python3.10 wine-env
   pip install -r requirements.txt
   ```

5. **Configurar Web App**
   - Dashboard → "Web" → "Add a new web app"
   - Click "Next"
   - Selecciona "Flask"
   - Python version: 3.10
   - Path: `/home/TU-USUARIO/DEPLOYML/wine-quality-api/app.py`

6. **Configurar Virtual Environment**
   - En la página de configuración de tu web app
   - Sección "Virtualenv"
   - Enter path: `/home/TU-USUARIO/.virtualenvs/wine-env`

7. **Configurar WSGI**
   - Click en el archivo WSGI configuration
   - Reemplaza el contenido con:
   
   ```python
   import sys
   path = '/home/TU-USUARIO/DEPLOYML/wine-quality-api'
   if path not in sys.path:
       sys.path.append(path)
   
   from app import app as application
   ```

8. **Reload Web App**
   - Click en el botón verde "Reload TU-USUARIO.pythonanywhere.com"

### 5.3 Verificar Deployment

Tu API estará disponible en:
```
https://TU-USUARIO.pythonanywhere.com
```

---

## 🧪 Parte 6: Pruebas

### Prueba 1: Health Check

```bash
curl https://TU-USUARIO.pythonanywhere.com/health
```

**Respuesta esperada:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "scaler_loaded": true
}
```

### Prueba 2: Ejemplo de Datos

```bash
curl https://TU-USUARIO.pythonanywhere.com/example
```

### Prueba 3: Predicción - Vino de Baja Calidad

```bash
curl -X POST https://TU-USUARIO.pythonanywhere.com/predict \
  -H "Content-Type: application/json" \
  -d '{
    "fixed_acidity": 7.4,
    "volatile_acidity": 0.7,
    "citric_acid": 0.0,
    "residual_sugar": 1.9,
    "chlorides": 0.076,
    "free_sulfur_dioxide": 11.0,
    "total_sulfur_dioxide": 34.0,
    "density": 0.9978,
    "pH": 3.51,
    "sulphates": 0.56,
    "alcohol": 9.4
  }'
```

### Prueba 4: Predicción - Vino de Alta Calidad

```bash
curl -X POST https://TU-USUARIO.pythonanywhere.com/predict \
  -H "Content-Type: application/json" \
  -d '{
    "fixed_acidity": 8.5,
    "volatile_acidity": 0.28,
    "citric_acid": 0.56,
    "residual_sugar": 1.8,
    "chlorides": 0.092,
    "free_sulfur_dioxide": 35.0,
    "total_sulfur_dioxide": 103.0,
    "density": 0.9969,
    "pH": 3.26,
    "sulphates": 0.75,
    "alcohol": 10.5
  }'
```

---

## 📸 Parte 7: Documentación de Entrega

### 7.1 Screenshots Requeridos

Toma capturas de pantalla de:

1. **Dashboard de PythonAnywhere** mostrando tu web app activa
2. **Respuesta del endpoint `/health`** en el navegador
3. **Respuesta de una predicción exitosa** usando Postman o curl
4. **Tu repositorio de GitHub** con todos los archivos

### 7.2 Actualizar README.md

Completa tu README con:
- Tu nombre completo
- URL de tu API en producción
- Fecha de deployment
- Instrucciones de uso

---

## 📝 Criterios de Evaluación

| Criterio | Puntos | Descripción |
|----------|--------|-------------|
| **Código funcional** | 30 | API funciona correctamente |
| **Deployment exitoso** | 25 | API accesible públicamente |
| **Documentación** | 20 | README completo y claro |
| **Pruebas** | 15 | Screenshots de pruebas |
| **Código limpio** | 10 | Código bien organizado |

**Total: 100 puntos**

---

## 🎁 Puntos Extra (Opcional)

### +10 puntos: Agregar Endpoint de Estadísticas

```python
@app.route('/stats')
def stats():
    """Retorna estadísticas del modelo"""
    return jsonify({
        'model_type': 'Random Forest Classifier',
        'n_features': 11,
        'accuracy': 0.85,
        'training_samples': 1279,
        'test_samples': 320
    })
```

### +10 puntos: Validación de Rangos

Agrega validación para asegurar que los valores estén en rangos válidos:

```python
VALID_RANGES = {
    'fixed_acidity': (4.6, 15.9),
    'volatile_acidity': (0.12, 1.58),
    'citric_acid': (0.0, 1.0),
    # ... etc
}
```

### +15 puntos: Frontend Simple

Crea un archivo `templates/index.html` con un formulario HTML para hacer predicciones desde el navegador.

---

## 🆘 Troubleshooting

### Error: "Module not found"
```bash
# En PythonAnywhere Bash console
workon wine-env
pip install -r requirements.txt
```

### Error: "File not found: model.pkl"
- Verifica que los archivos .pkl estén en el mismo directorio que app.py
- Verifica la ruta en PythonAnywhere

### Error: "502 Bad Gateway"
- Verifica el archivo WSGI configuration
- Verifica que el virtual environment esté configurado correctamente
- Revisa los error logs en PythonAnywhere

### La API no responde
- Click en "Reload" en la página de Web de PythonAnywhere
- Revisa los logs de error
- Verifica que el código no tenga errores de sintaxis

---

## 📚 Recursos Adicionales

- **PythonAnywhere Help**: https://help.pythonanywhere.com/
- **Flask Documentation**: https://flask.palletsprojects.com/
- **Wine Quality Dataset**: https://archive.ics.uci.edu/ml/datasets/wine+quality
- **Tutorial Flask**: https://flask.palletsprojects.com/en/3.0.x/quickstart/

---

## 📅 Fecha de Entrega

**Fecha límite:** [INSTRUCTOR: Especificar fecha]

**Formato de entrega:**
1. Link al repositorio de GitHub
2. URL de la API en producción
3. Documento PDF con screenshots

---

## ✅ Checklist Final

Antes de entregar, verifica:

- [ ] Código subido a GitHub
- [ ] API desplegada en PythonAnywhere
- [ ] Endpoint `/health` funciona
- [ ] Endpoint `/predict` funciona
- [ ] README.md completo con tu nombre
- [ ] Screenshots tomados
- [ ] URL de producción funcional
- [ ] Código comentado y limpio

---

## 🎓 Aprendizajes Esperados

Al completar esta tarea habrás aprendido:

1. ✅ Crear una API REST con Flask
2. ✅ Cargar y usar modelos de ML en producción
3. ✅ Desplegar aplicaciones en la nube
4. ✅ Documentar APIs profesionalmente
5. ✅ Probar endpoints con curl/Postman
6. ✅ Manejar errores y validaciones
7. ✅ Trabajar con Git y GitHub

---

**¡Buena suerte con tu deployment! 🚀**

Si tienes dudas, consulta con el instructor o revisa la documentación de PythonAnywhere.
