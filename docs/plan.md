# Reclamo Listo — Plan de ejecución (v3)

## 0. Objetivo y contexto

**Objetivo:** construir una pieza de portafolio que demuestre que puedes llevar un sistema de IA a producción de punta a punta, como lo hace un Forward Deployed Engineer: descubrir el problema, acotarlo, construir, evaluar, desplegar, operar y entregar. El medio es aprender CI/CD y el ciclo completo de software; el fin es poder decir en una entrevista "aquí está el link, el repo y las decisiones".

Lo que tiene que quedar demostrado y visible en el repo:

- Que el sistema está en producción y lo puede usar cualquiera.
- Que hubo discovery y un alcance escrito antes de programar.
- Que la calidad del agente se mide con evals y que esas evals bloquean un despliegue malo.
- Que se puede operar: costos, trazas, alertas, vuelta atrás, runbook.
- Que otra persona podría recibirlo y mantenerlo.

**Producto:** una persona describe un problema de consumo y recibe tres cosas:

1. Veredicto: tiene derecho o no, con los artículos citados.
2. El reclamo redactado, listo para pegar en el SERNAC.
3. Un mensaje corto para la tienda.

**Por qué este producto:** el SERNAC recibió unos 655 mil reclamos en 2025 (retail 22%). Ya existe un chat legal generalista gratis (LeyGPT), así que el diferenciador es entregar un documento listo en un tema acotado.

## 1. Decisiones cerradas

- Framework de agentes: Google ADK en Python, no LangGraph.
- Despliegue: Cloud Run, no Agent Engine. Escala a cero, sin instancia mínima, sin balanceador.
- Modelo: Gemini Flash vía Vertex AI, dos llamadas por consulta como máximo.
- Corpus acotado: Ley 19.496 (Ley del Consumidor) y Reglamento de Comercio Electrónico (Decreto 6 de 2021).
- Sin base vectorial: el índice de embeddings se genera en el build y va dentro de la imagen.
- No se guarda el texto del usuario: ni en base de datos, ni en logs, ni en trazas.
- Límite de uso: 3 consultas por persona al día más un tope global diario. Costo objetivo: menos de US$5 al mes.
- Front: Next.js con TypeScript, una sola pantalla.
- Modo aprendizaje: quieres entender cada pieza del CI/CD, no que aparezca hecha.
- Idioma: documentación del repo en inglés; la interfaz en español de Chile.
- Regla de eficiencia: no se agrega ninguna tecnología que el producto no necesite.

## 2. Cómo trabajar en la sesión (modo aprendizaje)

- Explicar antes de escribir. Antes de cada workflow, Dockerfile o módulo de Terraform: 3 a 5 líneas de qué hace y por qué existe.
- Todo entra por Pull Request, incluso trabajando solo. Nada de push directo a main después de la Fase 1.
- Romper cosas a propósito. En cada fase, un ejercicio: un test que falla, un secreto falso, una eval que baja.
- Los pasos de nube los ejecutas tú la primera vez: crear el proyecto, la federación de identidad y el primer terraform apply.
- Verificar versiones al empezar. ADK cambia rápido: confirmar en adk.dev antes de fijar dependencias.
- Cada fase cierra con: criterios cumplidos, un ADR si hubo decisión y 5 líneas de "qué aprendí" en la bitácora.
- Una fase a la vez. No adelantar trabajo de las siguientes.

## 3. Arquitectura

```
Navegador
   │  HTTPS
   ▼
[Cloud Run: web]  Next.js. Sirve la página y expone /api/reclamo del lado servidor.
   │  llamada servidor-a-servidor con token de identidad (IAM)
   ▼
[Cloud Run: api]  FastAPI + ADK. Privado: solo lo invoca la cuenta de servicio de web.
   ├── Firestore        contador de uso (hash de IP + día, y tope global diario)
   ├── Vertex AI        Gemini Flash + embedding de la consulta
   └── índice local     artículos + embeddings, dentro de la imagen
```

**Por qué el backend es privado:** el navegador nunca habla con la API directo. No hay CORS abierto, no hay clave en el front y el límite de uso no se puede saltar.

### El flujo del agente

Un agente secuencial de ADK con cuatro pasos.

| Paso | Tipo | Qué hace |
|---|---|---|
| 1. Clasificar | Agente con LLM, salida estructurada | Categoría del caso (garantía legal, retracto, compra cancelada, incumplimiento, cobro indebido, publicidad engañosa) o fuera de alcance. Extrae tienda, fecha, monto y qué pide. |
| 2. Recuperar | Agente sin LLM | Artículos fijos por categoría más los más parecidos por embedding. Si es fuera de alcance, corta el flujo. |
| 3. Redactar | Agente con LLM, salida estructurada | Veredicto, artículos citados, reclamo SERNAC y mensaje a la tienda. Solo puede citar lo recuperado. |
| 4. Verificar | Agente sin LLM | Cada artículo citado tiene que existir en lo recuperado y el texto tiene que calzar. Si falla: un reintento del paso 3; si vuelve a fallar, "no pude responder con certeza". |

**Regla de diseño:** el LLM interpreta y redacta; lo determinista vive en código con tests.

### Contrato de la API

| Método | Ruta | Request | Response |
|---|---|---|---|
| POST | /v1/reclamo | relato (máx. 2.000 caracteres), tienda y fecha_compra opcionales | estado (ok, fuera_de_alcance o sin_certeza), veredicto, resumen, articulos, reclamo_sernac, mensaje_tienda, aviso_legal |
| GET | /health | — | ok, version, commit |

- Errores: 422 validación, 429 límite de uso, 503 tope global alcanzado.
- Contrato primero: FastAPI genera OpenAPI y el front genera sus tipos desde ahí. El CI falla si los tipos están desactualizados.

## 4. Estructura del repo

```
reclamo-listo/
├── CLAUDE.md                 convenciones para Claude Code
├── README.md                 en inglés
├── backend/
│   ├── app/
│   │   ├── main.py           rutas, límite de uso, errores
│   │   ├── agents/           clasificar, recuperar, redactar, verificar
│   │   ├── corpus/           carga del índice y búsqueda
│   │   ├── schemas.py        modelos Pydantic
│   │   ├── limites.py        contador en Firestore
│   │   └── config.py
│   ├── scripts/              descargar_corpus.py, construir_indice.py
│   ├── tests/                unit/ e integration/
│   ├── Dockerfile
│   └── pyproject.toml
├── frontend/                 Next.js + TS, tests con Vitest
├── corpus/                   artículos normalizados en JSON, versionados
├── evals/                    casos/, correr.py, umbrales.yaml
├── infra/                    Terraform
├── .github/workflows/        ci.yml, evals.yml, deploy.yml, seguridad.yml
└── docs/                     todo en inglés
    ├── scoping.md            discovery, problema, usuario, métricas de éxito, riesgos
    ├── adr/                  una decisión por archivo
    ├── arquitectura.md
    ├── seguridad.md          modelo de amenazas
    ├── runbook.md            operar y mantener: desplegar, volver atrás, alertas
    ├── case-study.md         problema, arquitectura, despliegue, impacto
    └── bitacora.md           qué aprendí por fase
```

## 5. CI/CD

Cuatro workflows. Cada uno se construye explicándolo y se ve fallar al menos una vez.

### ci.yml: en cada Pull Request

| Job | Qué corre |
|---|---|
| backend | lint y formato (ruff), tipos (mypy), tests con cobertura mínima de 80% |
| frontend | lint, chequeo de tipos, tests, build y tipos de API al día |
| docker | build de ambas imágenes, sin subirlas |
| terraform | formato, validación y plan publicado como comentario en el PR |

Todos bloquean el merge. Los tests del CI no llaman al modelo real: el LLM va simulado, así el CI es rápido, gratis y determinista.

### evals.yml: calidad del agente

- Corre cuando el PR toca los agentes, el corpus o las evals, y también a mano.
- Usa el modelo real contra los casos dorados y compara con los umbrales.
- Publica una tabla de resultados en el PR; si una métrica baja del umbral, bloquea el merge.
- Se autentica con una cuenta de servicio que solo puede llamar a Vertex AI.

### deploy.yml: al hacer merge a main

- Autenticación con federación de identidad: GitHub no guarda ninguna llave de Google Cloud.
- Build de las dos imágenes, etiquetadas con el SHA del commit, y subida a Artifact Registry.
- Deploy a Cloud Run como revisión nueva sin tráfico.
- Prueba de humo contra esa revisión: /health y una consulta real de punta a punta.
- Si pasa, se mueve el 100% del tráfico. Si falla, el tráfico queda en la revisión anterior.
- Vuelta atrás documentada: un comando para devolver el tráfico.

### seguridad.yml: en cada PR y una vez por semana

- Secretos en el código: gitleaks.
- Dependencias vulnerables: pip-audit y npm audit.
- Imágenes Docker: trivy.
- Actualizaciones: Dependabot.

### Reglas del repo

- main protegida: PR obligatorio, checks en verde, sin force-push.
- Commits con formato convencional (feat:, fix:, ci:).
- pre-commit local con ruff y gitleaks, para fallar antes de llegar al CI.
- Terraform: plan automático en el PR; apply manual con aprobación. El estado vive en un bucket con versionado.

## 6. Tests

| Capa | Qué cubre | Dónde corre |
|---|---|---|
| Unitarios | verificador de citas, corte del corpus, búsqueda, límite de uso, validación | ci.yml |
| Integración | la API de punta a punta con LLM simulado y Firestore en emulador | ci.yml |
| Front | formulario, estados y render del resultado | ci.yml |
| Contrato | tipos TypeScript generados desde OpenAPI al día | ci.yml |
| Evals | calidad del agente con modelo real | evals.yml |
| Humo | la revisión desplegada responde bien | deploy.yml |

## 7. Seguridad

| Amenaza | Mitigación |
|---|---|
| Inyección de instrucciones en el relato | El relato va delimitado como dato. Salida estructurada. El verificador de citas es la última barrera. Casos adversariales en las evals. |
| Artículos inventados | Toda cita debe existir en lo recuperado; sin cita válida no hay respuesta. |
| Abuso y gasto descontrolado | 3 consultas por persona al día, tope global diario, largo máximo de entrada, pocas instancias máximas, alertas en US$10 y US$20. |
| Robots | Cloudflare Turnstile o reCAPTCHA en el formulario (Fase 6). |
| Datos personales | No se guarda el relato. Logs y trazas sin contenido. La IP solo como hash con sal, con vencimiento automático. |
| Llaves filtradas | Cero llaves de cuenta de servicio. Secretos en Secret Manager. gitleaks en CI y pre-commit. |
| Permisos de más | Tres cuentas de servicio con lo mínimo: web, api y deployer. Federación restringida a este repo. |
| Acceso directo al backend | api sin acceso público; exige identidad IAM. |
| Dependencias e imágenes vulnerables | Auditorías automáticas, imágenes mínimas, usuario sin privilegios, versiones fijadas. |
| Web | Cabeceras de seguridad; el texto del modelo se muestra como texto plano. |
| Riesgo legal | Aviso visible de que orienta y no reemplaza asesoría legal. No puede parecer un sitio oficial del SERNAC. |

## 8. Evals

- Casos dorados: partir con 40. Cada uno tiene relato, categoría esperada, artículos que deben citarse y veredicto esperado.
- Casos especiales: 6 a 8 fuera de alcance (laboral, arriendo, saludo) y 4 a 5 adversariales.
- Métricas:
  - categoría correcta
  - artículos esperados citados
  - citas inventadas, que debe ser 0
  - veredicto correcto
  - rechazo correcto de fuera de alcance
- Umbrales: citas inventadas en 0; el resto se fija con la primera corrida real y solo puede subir.
- Los casos dorados los tiene que revisar un abogado antes del lanzamiento. Hasta entonces van marcados como "sin validar".

## 9. Observabilidad y costos

- Logs estructurados: categoría, estado, latencia, tokens, costo estimado. Nunca el relato.
- Trazas de ADK a Cloud Trace, un tramo por paso del agente.
- Panel en Cloud Monitoring con métricas sacadas de los logs: consultas por día, latencia, tasa de "sin certeza", tokens y costo.
- Alertas: presupuesto (US$10 y US$20) y tasa de errores.
- Costo estimado por consulta: cerca de medio centavo de dólar; se verifica con datos reales en la Fase 5.

## 10. Corpus

- Fuente: Biblioteca del Congreso Nacional (LeyChile).
- Descarga: un script baja la versión vigente y la normaliza a un JSON por artículo.
- Versionado: el corpus normalizado vive en el repo. Actualizarlo es un PR, y ese PR dispara las evals.
- Índice: los embeddings se generan en el build de la imagen.

## 11. Fases

Cada fase termina desplegada. Primero el pipeline, después la inteligencia.

### Fase 0: Discovery, alcance y preparación (a mano)

- Discovery: conversar con 3 a 5 personas que hayan tenido un problema con una compra. Qué pasó, qué hicieron, dónde se trabaron, qué les habría servido.
- Alcance: hallazgos del discovery, problema, usuario, qué entra y qué no, riesgos, y métricas de éxito definidas antes de construir.
- Proyecto de Google Cloud nuevo, con facturación y alertas de presupuesto.
- Repo público en GitHub, con main protegida.
- Herramientas locales: gcloud, terraform, uv, node, docker, gh, pre-commit.
- CLAUDE.md con las convenciones del plan.
- **Listo cuando:** discovery y alcance están escritos, gcloud y gh autenticados, y el repo tiene README y licencia.

### Fase 1: Esqueleto desplegado con CI/CD completo

- api con /health y web con una página "hola" que llama a la API.
- Dockerfiles y Terraform: Artifact Registry, dos servicios Cloud Run, cuentas de servicio, federación de identidad, Firestore, bucket de estado.
- ci.yml, deploy.yml y seguridad.yml funcionando.
- Ejercicio: un PR con un test roto y otro con un secreto falso.
- **Listo cuando:** un merge a main despliega solo, con prueba de humo y vuelta atrás probada una vez.

### Fase 2: Corpus y búsqueda

- Descarga y normalización por artículo; índice de embeddings en el build.
- Búsqueda por categoría más similitud, con tests.
- **Listo cuando:** la búsqueda devuelve los artículos correctos en 10 casos escritos a mano.

### Fase 3: Agente ADK y API

- Los cuatro pasos, con esquemas Pydantic y tests exhaustivos del verificador de citas.
- POST /v1/reclamo, límite de uso, tope global y errores.
- Probar el flujo con la interfaz local de ADK.
- **Listo cuando:** la API desplegada responde bien 5 casos reales y rechaza 2 fuera de alcance.

### Fase 4: Front

- Formulario, estados, resultado con botones de copiar, aviso legal y consultas restantes.
- Tipos generados desde OpenAPI; diseño propio y usable en celular.
- **Listo cuando:** alguien que no eres tú lo usa desde el celular sin explicación.

### Fase 5: Evals y observabilidad

- 40 casos dorados, umbrales y evals.yml bloqueando merges.
- Logs estructurados, trazas, panel y alertas.
- Ejercicio: empeorar un prompt a propósito y ver la eval bloquear el PR.
- **Listo cuando:** las evals corren en cada PR y hay un panel con el costo real por consulta.

### Fase 6: Endurecer, entregar y lanzar

- Protección contra robots, cabeceras de seguridad y seguridad.md completo.
- Casos dorados revisados por un abogado.
- runbook.md: cómo desplegar, volver atrás, qué hacer ante cada alerta y qué necesita otra persona para mantenerlo. Probado con un incidente simulado.
- case-study.md con la estructura problema, arquitectura, despliegue e impacto, con números reales.
- README en inglés con diagrama, demo y decisiones; dominio opcional.
- Demo de 3 minutos en inglés y post de LinkedIn.
- **Listo cuando:** está el link público, el README se entiende sin ti al lado y el caso se puede contar en 2 minutos.

## 12. Fuera del MVP

Otras leyes (finiquito, Dicom), foto de la boleta, bot de WhatsApp, cuentas de usuario, historial, ambiente de staging separado, envío automático al SERNAC, voto de "¿te sirvió?", BigQuery, servidor MCP, comparación entre modelos y Kubernetes. Se agregan solo si aparece una necesidad real.

## 13. Preguntas abiertas

- Región: us-central1 (más barata, con todos los modelos) o Santiago (menos latencia). Propuesta: us-central1.
- Nombre y dominio: "Reclamo Listo" es nombre de trabajo; revisar que no exista y que no se confunda con el SERNAC.
- Abogado: quién revisa los casos dorados.
- Modelo: nombre exacto del Flash vigente al empezar.
- Discovery: a quiénes entrevistar en la Fase 0.
