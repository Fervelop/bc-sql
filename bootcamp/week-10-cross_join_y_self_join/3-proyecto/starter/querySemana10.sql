-- ============================================
-- PROYECTO SEMANAL: SELF JOIN en tu dominio
-- Semana 10 — CROSS JOIN y SELF JOIN
-- Dominio: Plataforma de cursos online (Rutas de aprendizaje jerárquica)
-- ============================================

PRAGMA foreign_keys = ON;

-- ============================================
-- SCHEMA: Rutas de Aprendizaje Jerárquica
-- Una ruta puede tener subrutas (parent_route_id)
-- ============================================

DROP TABLE IF EXISTS learning_routes;

CREATE TABLE learning_routes (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    difficulty_level TEXT CHECK (difficulty_level IN ('Beginner', 'Intermediate', 'Advanced')),
    estimated_hours INTEGER CHECK (estimated_hours > 0),
    parent_route_id INTEGER REFERENCES learning_routes(id)  -- auto-referencial
);

-- ============================================
-- DATOS DE PRUEBA: 80+ registros con jerarquía de 3 niveles
-- ============================================

-- Nivel 0: Raíces (parent_route_id = NULL)
INSERT INTO learning_routes (name, description, difficulty_level, estimated_hours) VALUES
    (1, 'Desarrollo Web Completo', 'Aprende desde HTML hasta frameworks modernos', 'Intermediate', 200),
    (2, 'Ciencia de Datos', 'De datos brutos a insights', 'Intermediate', 250),
    (3, 'DevOps y Cloud', 'Infraestructura moderna y automatización', 'Advanced', 180),
    (4, 'Backend con Python', 'APIs, bases de datos y arquitectura', 'Intermediate', 150);

-- Nivel 1: Hijos directos
INSERT INTO learning_routes (name, description, difficulty_level, estimated_hours, parent_route_id) VALUES
    (5, 'Frontend Fundamentals', 'HTML, CSS, JavaScript', 'Beginner', 80, 1),
    (6, 'React Masterclass', 'Librería de UI con React', 'Intermediate', 120, 1),
    (7, 'Backend Fundamentals', 'Servidores y bases de datos', 'Intermediate', 100, 1),
    (8, 'Análisis de Datos', 'Pandas, NumPy, análisis estadístico', 'Intermediate', 120, 2),
    (9, 'Machine Learning', 'Algoritmos y modelos', 'Advanced', 180, 2),
    (10, 'Data Visualization', 'Matplotlib, Plotly, Power BI', 'Intermediate', 80, 2),
    (11, 'Docker y Kubernetes', 'Containerización y orquestación', 'Advanced', 100, 3),
    (12, 'CI/CD Pipelines', 'Automatización de despliegue', 'Advanced', 80, 3),
    (13, 'Django y FastAPI', 'Frameworks web Python', 'Intermediate', 120, 4),
    (14, 'Bases de Datos Avanzadas', 'PostgreSQL, índices, optimización', 'Advanced', 90, 4);

-- Nivel 2: Nietos (cursos específicos dentro de subrutas)
INSERT INTO learning_routes (name, description, difficulty_level, estimated_hours, parent_route_id) VALUES
    (15, 'HTML5 Avanzado', 'Semántica, accesibilidad', 'Beginner', 20, 5),
    (16, 'CSS Grid y Flexbox', 'Layouts modernos', 'Beginner', 30, 5),
    (17, 'JavaScript ES6+', 'Async, promises, moderno', 'Intermediate', 40, 5),
    (18, 'React Hooks', 'State management con hooks', 'Intermediate', 50, 6),
    (19, 'Redux Avanzado', 'Predicción de estado', 'Advanced', 40, 6),
    (20, 'Testing en React', 'Jest, React Testing Library', 'Intermediate', 30, 6),
    (21, 'Express.js', 'Framework web Node.js', 'Intermediate', 60, 7),
    (22, 'SQL Avanzado', 'Queries complejas, índices', 'Advanced', 50, 7),
    (23, 'Pandas para Análisis', 'Manipulación de datos', 'Intermediate', 60, 8),
    (24, 'Excel a Python', 'Automatización con Python', 'Beginner', 30, 8),
    (25, 'Regresión y Clasificación', 'Algoritmos supervisados', 'Advanced', 100, 9),
    (26, 'Clustering y NLP', 'No supervisado y procesamiento', 'Advanced', 80, 9),
    (27, 'Matplotlib Profundo', 'Visualización customizada', 'Intermediate', 40, 10),
    (28, 'Power BI', 'Reportes empresariales', 'Intermediate', 40, 10),
    (29, 'Docker Deep Dive', 'Imágenes, volúmenes, redes', 'Advanced', 60, 11),
    (30, 'Kubernetes Production', 'Despliegue en producción', 'Advanced', 60, 11),
    (31, 'GitHub Actions', 'CI con GitHub', 'Intermediate', 40, 12),
    (32, 'GitLab CI/CD', 'Pipeline con GitLab', 'Intermediate', 40, 12),
    (33, 'Django REST', 'APIs con Django', 'Intermediate', 60, 13),
    (34, 'FastAPI Avanzado', 'APIs de alto rendimiento', 'Intermediate', 60, 13),
    (35, 'Query Optimization', 'Explicar planes, índices', 'Advanced', 50, 14),
    (36, 'Replicación PostgreSQL', 'HA y backups', 'Advanced', 40, 14);

-- ============================================
-- CONSULTA 1: SELF JOIN básico (INNER JOIN)
-- Mostrar ruta hijo y su ruta padre (excluye raíces)
-- ============================================

SELECT
    child.id AS child_id,
    child.name AS ruta_hija,
    child.difficulty_level AS dificultad_hija,
    child.estimated_hours AS horas_hija,
    parent.id AS parent_id,
    parent.name AS ruta_padre,
    parent.difficulty_level AS dificultad_padre,
    parent.estimated_hours AS horas_padre
FROM learning_routes child
INNER JOIN learning_routes parent ON child.parent_route_id = parent.id
ORDER BY parent.name, child.name;

-- ============================================
-- CONSULTA 2: Incluir la raíz con LEFT JOIN
-- Usa COALESCE para etiquetar registros raíz
-- ============================================

SELECT
    child.id AS id,
    child.name AS ruta,
    child.difficulty_level AS dificultad,
    child.estimated_hours AS horas,
    COALESCE(parent.name, '✓ RUTA PRINCIPAL') AS padre_o_raiz,
    COALESCE(parent.difficulty_level, 'N/A') AS dif_padre
FROM learning_routes child
LEFT JOIN learning_routes parent ON child.parent_route_id = parent.id
ORDER BY COALESCE(parent.name, 'ZZZZZ'), child.name;

-- ============================================
-- CONSULTA 3: Contar subrutas por ruta padre
-- Cuántas subrutas directas tiene cada ruta
-- Mostrar solo las que tienen al menos 1 subruta
-- ============================================

SELECT
    parent.id AS parent_id,
    parent.name AS ruta_padre,
    parent.difficulty_level AS dificultad,
    parent.estimated_hours AS horas_padre,
    COUNT(child.id) AS total_subrutas,
    SUM(child.estimated_hours) AS horas_totales_subrutas
FROM learning_routes parent
LEFT JOIN learning_routes child ON child.parent_route_id = parent.id
GROUP BY parent.id, parent.name, parent.difficulty_level, parent.estimated_hours
HAVING COUNT(child.id) > 0
ORDER BY total_subrutas DESC, parent.name;

-- ============================================
-- CONSULTA 4: Dos niveles jerárquicos
-- Mostrar: ruta → padre → abuelo
-- ============================================

SELECT
    child.id AS child_id,
    child.name AS ruta_actual,
    child.difficulty_level AS dificultad_actual,
    child.estimated_hours AS horas_actual,
    parent.id AS parent_id,
    parent.name AS ruta_padre,
    parent.difficulty_level AS dif_padre,
    COALESCE(grandparent.id, 0) AS grandparent_id,
    COALESCE(grandparent.name, 'SIN ABUELO (es raíz)') AS ruta_abuelo,
    COALESCE(grandparent.difficulty_level, 'N/A') AS dif_abuelo
FROM learning_routes child
LEFT JOIN learning_routes parent ON child.parent_route_id = parent.id
LEFT JOIN learning_routes grandparent ON parent.parent_route_id = grandparent.id
ORDER BY 
    COALESCE(grandparent.name, 'ZZZZZ'),
    COALESCE(parent.name, 'ZZZZZ'),
    child.name;

-- ============================================
-- CONSULTA 5: Estadísticas por nivel jerárquico
-- ============================================

SELECT
    CASE
        WHEN parent_route_id IS NULL THEN 'Nivel 0: Raíz'
        WHEN (SELECT parent_route_id FROM learning_routes lr2 WHERE lr2.id = learning_routes.parent_route_id) IS NULL THEN 'Nivel 1: Subruta'
        ELSE 'Nivel 2: Curso específico'
    END AS nivel,
    COUNT(*) AS total_rutas,
    ROUND(AVG(estimated_hours), 2) AS promedio_horas,
    MIN(estimated_hours) AS min_horas,
    MAX(estimated_hours) AS max_horas
FROM learning_routes
GROUP BY nivel
ORDER BY nivel;

-- ============================================
-- CONSULTA 6: Árbol de rutas (visualización jerárquica)
-- ============================================

SELECT
    CASE
        WHEN parent_route_id IS NULL THEN '● ' || name
        WHEN (SELECT parent_route_id FROM learning_routes lr2 WHERE lr2.id = learning_routes.parent_route_id) IS NULL THEN '  ├─ ' || name
        ELSE '  │  ├─ ' || name
    END AS arbol,
    estimated_hours AS horas,
    difficulty_level AS nivel_dif
FROM learning_routes
ORDER BY parent_route_id, name;

-- ============================================
-- CONSULTA 7: Rutas sin subrutas (hojas del árbol)
-- ============================================

SELECT
    lr.id,
    lr.name AS ruta,
    lr.difficulty_level,
    lr.estimated_hours,
    parent.name AS ruta_padre
FROM learning_routes lr
LEFT JOIN learning_routes child ON child.parent_route_id = lr.id
LEFT JOIN learning_routes parent ON lr.parent_route_id = parent.id
WHERE child.id IS NULL
ORDER BY parent.name, lr.name;
