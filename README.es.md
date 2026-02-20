# Método IRIS
## Sistema de Mejora Iterativa de Repositorios

> **Metodología universal de 5 fases para la mejora continua de cualquier base de código. Compatible con los principales agentes de codificación con IA.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Multi-Agent](https://img.shields.io/badge/agentes-5%20plataformas-purple)](agents/)

**Versión:** 2.1.0 | **Licencia:** MIT | **Idioma:** [EN](README.md) / [ES](README.es.md)

**Autor:** Francisco J Bernades  
**GitHub:** [@exchanet](https://github.com/exchanet)  
**Repositorio:** [method_IRIS](https://github.com/exchanet/method_IRIS)

---

## Por qué usar IRIS

### Para equipos que necesitan:
- **Mejora sistemática de calidad** — ciclos medibles en lugar de refactors puntuales
- **Código legacy y multilingüe** — Python, JavaScript, Go, Java, Rust, Ruby, PHP, C# y otros
- **Integración con otros métodos** — handoffs desde Enterprise Builder, Modular Design o PDCA-T
- **Proceso consistente entre agentes de IA** — mismo protocolo de 5 fases en Cursor, Claude Code, Kimi, Windsurf o Antigravity

### Qué obtienes:
- **Ciclos de mejora medibles** — 5 métricas universales (densidad de defectos, cobertura, complejidad, deuda técnica, salud arquitectónica)
- **Tamaño de iteración seguro** — ≤400 LOC por iteración con planes de rollback y Definition of Done
- **Memoria semántica** — `IRIS_MEMORY.json` guarda cambios rechazados, patrones intencionales y restricciones arquitectónicas para que IRIS no vuelva a proponer lo que el equipo rechazó
- **Monitor de build delta** — comprobaciones ligeras (diff + tests afectados) sin re-analizar todo el código
- **Handoffs en JSON** — `IRIS_INPUT.json` / `IRIS_OUTPUT.json` validados por schema para integración con otros métodos Exchanet
- **Mismo protocolo en 5 plataformas** — instala una vez y usa con Cursor AI, Claude Code, Kimi Code, Windsurf o Google Antigravity

---

## Métodos compañeros recomendados

- [Method Enterprise Builder Planning](https://github.com/exchanet/method_enterprise_builder_planning) — Planificación y entrega de sistemas enterprise
- [Method Modular Design](https://github.com/exchanet/method_modular_design) — Patrón de arquitectura Core + Packs
- [Método PDCA-T](https://github.com/exchanet/method_pdca-t_coding) — Ciclo de aseguramiento de calidad (≥99% cobertura de tests)

---

## Qué es IRIS

**Método IRIS** es una **metodología universal de 5 fases** para la mejora continua de cualquier repositorio. Es agnóstico al lenguaje, al framework y al IDE: descubre el código, cuantifica la calidad con métricas definidas y produce una hoja de ruta de mejoras priorizada y con riesgo evaluado. Cada ciclo termina preparando el siguiente; no hay "terminado", solo "mejor".

Principios: **adaptarse al código existente** (sin imponer estilo), **métricas primero** (números sobre opiniones), **lotes seguros** (≤400 LOC por iteración) e **integración por contrato** (handoffs con JSON Schema).

### Soporte multi-agente

| Plataforma      | Adaptador                   | Instalación                     |
|-----------------|-----------------------------|----------------------------------|
| **Cursor AI**   | Reglas y skills en `.cursor/` | Copiar `agents/cursor/.cursor/` |
| **Claude Code** | `CLAUDE.md`                 | Copiar a la raíz del proyecto   |
| **Kimi Code**   | `KIMI.md`                   | Copiar a la raíz del proyecto   |
| **Windsurf**    | `WINDSURF.md`               | Copiar a la raíz del proyecto   |
| **Google Antigravity** | `ANTIGRAVITY.md`     | Copiar a la raíz del proyecto   |

Todos los adaptadores siguen el **mismo protocolo de 5 fases**.

### El ciclo IRIS de 5 fases

```
INGERIR  → Modelo mental completo (estructura, stack, puntos de entrada, memoria)
    ↓
REVISAR  → Cuantificar calidad: 5 dimensiones en paralelo, 5 métricas principales
    ↓
IDEAR    → Hoja de ruta priorizada, análisis cascade, iteraciones ≤400 LOC
    ↓
IMPLEMENTAR → Una iteración cada vez, tests tras cada archivo
    ↓
VERIFICAR → Verificar, actualizar IRIS_LOG.md e IRIS_MEMORY.json, preparar siguiente ciclo
    ↓
→ INGERIR (siguiente ciclo)
```

---

## Métricas principales

| Métrica                    | Objetivo       | Fórmula |
|----------------------------|----------------|---------|
| Densidad de defectos       | <1.0 por 1K LOC | `(hallazgos / LOC) × 1000` |
| Cobertura de tests         | ≥99%           | `(cubiertas / total) × 100` |
| Puntuación de complejidad  | <12            | `(ciclomática × 0.6) + (cognitiva × 0.4)` |
| Ratio de deuda técnica     | <5%            | `(horas_corrección / horas_desarrollo) × 100` |
| Índice de salud arquitectónica | ≥90/100   | `promedio(acoplamiento, cohesión, SOLID, duplicación)` |

---

## Inicio rápido

### Cursor AI

1. Copia la carpeta `.cursor/` a tu proyecto:
   ```bash
   cp -r agents/cursor/.cursor /ruta/a/tu/proyecto/
   ```
2. Abre Cursor en tu proyecto y ejecuta: `/iris:full`

### Claude Code

1. Copia `CLAUDE.md` a tu proyecto:
   ```bash
   cp agents/claude-code/CLAUDE.md /ruta/a/tu/proyecto/
   ```
2. Usa: `IRIS: full`

### Kimi Code

1. Copia `KIMI.md` a tu proyecto:
   ```bash
   cp agents/kimi-code/KIMI.md /ruta/a/tu/proyecto/
   ```
2. Usa: `@iris full`

### Windsurf

1. Copia `WINDSURF.md` a tu proyecto:
   ```bash
   cp agents/windsurf/WINDSURF.md /ruta/a/tu/proyecto/
   ```
2. Usa: `IRIS: full`

### Google Antigravity

1. Copia `ANTIGRAVITY.md` a tu proyecto:
   ```bash
   cp agents/antigravity/ANTIGRAVITY.md /ruta/a/tu/proyecto/
   ```
2. Usa: `IRIS: full [ruta]`

**Instalación automatizada:** Usa `scripts/install.sh` (macOS/Linux) o `scripts/install.ps1` (Windows).

---

## Activación

Una vez instalado, activa IRIS con:

```
/iris:full
/iris:analyze [ruta]
"Usa IRIS para mejorar esta base de código"
"Ejecuta la evaluación de calidad IRIS en este repo"
```

---

## Comandos

| Comando | Descripción |
|---------|-------------|
| `/iris:analyze [ruta]` | Fase 1 + 2: Contexto + evaluación de calidad (5 dimensiones en paralelo) |
| `/iris:plan` | Fase 3: Hoja de ruta de mejoras con análisis cascade |
| `/iris:execute iter-N` | Fase 4: Implementar iteración N |
| `/iris:verify` | Fase 5: Verificar ciclo, actualizar IRIS_MEMORY.json |
| `/iris:full [ruta]` | Ciclo completo de 5 fases |
| `/iris:monitor` | Monitor de build completo (diff + tests afectados + delta métricas) |
| `/iris:monitor:delta` | Delta ligero (solo diff + tests afectados) |
| `/iris:memory` | Ver y editar IRIS_MEMORY.json |
| `/iris:cascade` | Mostrar mapa de eliminación cascade del último `/iris:plan` |
| `/iris:analyze --security` | Con análisis STRIDE + OWASP |
| `/iris:analyze --performance` | Con análisis de rendimiento algorítmico y BD |
| `/iris:analyze --architecture` | Con análisis profundo SOLID y acoplamiento |

---

## Packs de especialización

Packs opcionales para profundizar en Fase 2:

| Pack | Cubre | Se activa con |
|------|--------|----------------|
| Security Pack | STRIDE, OWASP Top 10, escaneo de secretos | `--security` |
| Performance Pack | Big O, N+1, patrones async, caché | `--performance` |
| Architecture Pack | SOLID, acoplamiento/cohesión, violaciones de capas | `--architecture` |

---

## Estructura del repositorio

```
method_IRIS/
├── agents/
│   ├── cursor/.cursor/rules/           ← Regla Cursor
│   │   .cursor/skills/method-iris/    ← Skills por fase + build monitor
│   ├── claude-code/CLAUDE.md
│   ├── kimi-code/KIMI.md
│   ├── windsurf/WINDSURF.md
│   └── antigravity/ANTIGRAVITY.md
├── core/
│   ├── iris-methodology.md            ← Definición formal de 5 fases
│   ├── iris-memory-spec.md            ← Especificación de memoria semántica
│   ├── iris-build-monitor.md          ← Especificación del pipeline delta
│   └── schemas/                        ← JSON Schema Draft-7
│       ├── handoff-input.json
│       ├── handoff-output.json
│       ├── metrics.json
│       └── memory.json
├── packs/
│   ├── security-pack/
│   ├── performance-pack/
│   └── architecture-pack/
├── docs/
│   ├── INTEGRATION-GUIDE.md
│   ├── IDE-SETUP.md
│   └── METRICS-REFERENCE.md
├── examples/
│   ├── standalone-usage.md
│   ├── with-pdca-t.md
│   ├── with-enterprise-builder.md
│   └── full-ecosystem-demo.md
└── scripts/
    ├── install.ps1                     ← Windows
    └── install.sh                      ← macOS/Linux
```

---

## Memoria semántica

`IRIS_MEMORY.json` (raíz del proyecto) persiste en todos los ciclos IRIS:

| Componente | Propósito |
|------------|-----------|
| `intentional_patterns` | Patrones que parecen problemáticos pero son deliberados; IRIS los etiqueta NOTED, no IMPROVABLE. |
| `rejected_changes` | Propuestas que el equipo rechazó; IRIS no las vuelve a proponer salvo que expiren. |
| `architectural_constraints` | Reglas que IRIS no debe violar nunca. |

Usa `/iris:memory` para ver y editar. IRIS crea el archivo cuando se toman decisiones en IDEATE.

**Archivos de handoff:** `IRIS_INPUT.json`, `IRIS_OUTPUT.json` (validados por schema), `IRIS_LOG.md` (historial de ciclos).

---

## Integración con el ecosistema

IRIS funciona en solitario o con otros métodos Exchanet:

```
Enterprise Builder → entrega el sistema
      ↓
Modular Design → arquitectura Core/Pack
      ↓
PDCA-T → tareas con ≥99% cobertura
      ↓ (escalado cuando hay bloqueo)
IRIS ← → resuelve bloqueos, monitorea calidad
      ↓
Enterprise Builder (siguiente ciclo)
```

---

## Compatibilidad

| IDE / Agente | Estado |
|--------------|--------|
| Cursor AI (0.40+) | Soporte completo |
| Claude Code | Soporte completo |
| Kimi Code (Moonshot AI) | Soporte completo |
| Windsurf (Codeium) | Soporte completo |
| Google Antigravity | Soporte completo |
| Cualquier LLM con acceso a archivos | Usar `core/iris-methodology.md` |

---

## Licencia

MIT — ver [LICENSE](LICENSE).

---

## Autor

**Francisco J Bernades**  
GitHub: [@exchanet](https://github.com/exchanet)

---

**Read in English / Leer en inglés:** [README.md](README.md)
