# ITRockChallenge

Aplicación iOS desarrollada como solución al challenge técnico de ITRock. La app permite autenticación de usuario, selección dinámica de país, visualización de productos desde distintas APIs, escaneo de códigos QR, y un flujo de compra con validación de tarjeta.

---

## Instrucciones para ejecutar la aplicación

1. Clonar el repositorio:

```bash
git clone https://github.com/Nehuen-R/ITRockChallengeEnd.git
```

2. Abrir el proyecto en Xcode (ITRockChallenge.xcodeproj)

3. Ejecutar en un simulador o dispositivo real con iOS 16 o superior.

## Funciones implementaddas

--- Login

. Validación de credenciales.

. Muestra error en caso de datos incorrectos.

--- Selección de País

. Selección entre "País A" (Fake Store API) y "País B" (Platzi Fake Store API).

. Abstracción de la fuente de datos mediante patrón de repositorio.

. Persistencia del país seleccionado con CoreData.

--- Home

. Carrusel horizontal de productos destacados.

. Listado vertical paginado de productos.

. Navegación a detalle de producto.

. Botón para iniciar flujo de compra por QR.

--- Detalle de Producto

. Visualización completa del producto.

. Botón para iniciar compra.

--- Escaneo QR

. Acceso a la cámara para leer códigos QR.

. Validación del QR (producto válido o inválido).

. Navegación automática al detalle del producto.

--- Pago

. Formulario de tarjeta (número, CVV, expiración).

. Validación de tarjeta predefinida.

. Mensajes de éxito o error.

. Redirección al Home tras compra exitosa.

--- Arquitectura y Diseño

. Arquitectura: MVVM (Model-View-ViewModel).

. UIKit como base de la aplicación, con integración puntual de SwiftUI.

. Navegación gestionada con UINavigationController.

. Persistencia de datos con CoreData.

. Abstracción de APIs con ProductRepository.

. Uso de Combine para bindings reactivos.

. Manejo centralizado de errores con ErrorLogger.

--- Mejoras fururas

. Validación mas completa del formulario de tarjeta

. Historial de compras realizadas

. Soporte multilenguaje

. Mejoras de UX/UI (transiciones, loading states, animaciones)

. Test unitarios

. Acceso con Face ID/Touch ID

. Integración con Firebase (Login, Crashlytics)


--- APIs utilizadas

. Fake Store API

. Platzi Fake Store API

