# Detección de PVC mediante el algoritmo de Pan-Tompkins

Este proyecto implementa en MATLAB/Octave un sistema completo para la **detección de complejos QRS** y la **identificación de latidos anómalos**, específicamente **Contracciones Ventriculares Prematuras (PVC)**, utilizando señales ECG reales de la base de datos **MIT-BIH Arrhythmia Database**.  
Forma parte del trabajo final de la asignatura *Procesamiento Digital de Señales* (FICH – UNL), basado en el algoritmo clásico de **Pan-Tompkins (1985)**.

---

## Características principales

- Implementación completa del algoritmo Pan-Tompkins:
  - Filtro pasa banda (paso bajo + paso alto)
  - Filtro derivador
  - Señal cuadrática
  - Integración mediante ventana móvil
- Detección de picos QRS usando técnicas robustas
- Cálculo de intervalos RR y frecuencia cardíaca
- Detección de latidos anómalos tipo PVC mediante:
  - Umbral mínimo de ancho del complejo QRS
  - Intervalo RR < 70% del promedio
- Gráficos del procesamiento paso a paso

## Ejecución

1. Clonar el repositorio
2. Abrir MATLAB/Octave dentro del proyecto.
3. Ejecutar el archivo principal (script.m)
