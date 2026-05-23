# AGENTS.md — Guía para agentes de IA

Este fichero describe el proyecto, su estructura, las convenciones de desarrollo y las instrucciones que deben seguir
los agentes de IA (GitHub Copilot, etc.) al trabajar en este repositorio.

## Descripción del proyecto

Aplicación iOS para planificar el menú de la semana.

Está organizada mediante una TabBar de dos pestañas.

La primera muestra una vista de una semana en el iPhone y de 4 semanas en el iPad. Por cada día el usuario puede
almacenar un texto correspondiente a la comida o la cena.

Avanzar y retroceder de semana o grupo de 4 semanas haciendo swipe a izquierda/derecha.

Por defecto la aplicación se abre en la semana actual, empezando el primer día de la semana según la localización del
dispositivo.

Cada comida o cena puede tener asociados componentes que se pueden editar en una vista de detalle. Estos componentes
representan elementos necesario y tienen asociado un campo disponible/no disponible. Con los no disponibles se genera
una lista de la compra semanal.

Todos los datos se almacenarán en iCloud y se sincronizarán automáticamente entre los dispositivos del usuario.

La aplicación soporta iOS 17 o superior, prefiriendo el diseño Liquid Glass de iOS 26.

El proyecto usa TDD estricto, se deben escribir todos los tests antes de desarrollar las funcionalidades y comprobar que
pasan antes de realizar commits.

La aplicación estará localizada en castellano, inglés y euskera. Todo texto que se genere debe tener traducción en los
tres idiomas y si se detecta alguno que no lo esté corregirse.

## Instrucciones para agentes

- **No leer ni exponer el contenido** de ningún fichero del repositorio `private/` (credenciales, certificados,
  keystores, etc.). Tratar todos sus ficheros como de solo lectura y usarlos exclusivamente por su ruta.

## Convenciones de commits

> **Regla fundamental**: cada funcionalidad completada o corrección de bug debe tener su propio commit independiente. No
> agrupar cambios no relacionados en un mismo commit.

### Cuándo hacer commit

- Al completar una funcionalidad nueva (aunque sea parcial pero funcional).
- Al corregir un bug concreto.
- Al añadir o actualizar documentación relevante.
- **No** hacer commit de código roto o que no compila.

### Formato del mensaje de commit

Usar [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>(<scope>): <descripción breve en imperativo>
```

- **El mensaje debe escribirse en español.**
- Ejemplos de tipos: `feat`, `fix`, `docs`, `refactor`, `chore`.

### Trailer obligatorio

Todo commit creado por un agente de IA debe incluir el trailer con su información de co-autoría al final del mensaje.
