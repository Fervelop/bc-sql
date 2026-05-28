-- ============================================
-- PROYECTO SEMANAL: CTEs y CASE WHEN en tu dominio
-- Semana 12 — Common Table Expressions + Condicionales
-- Dominio: Plataforma de cursos online
-- ============================================

PRAGMA foreign_keys = ON;

-- ============================================
-- SCHEMA: Plataforma de Cursos Online
-- ============================================

DROP TABLE IF EXISTS course_reviews;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    registration_date TEXT NOT NULL DEFAULT (DATE('now'))
);

CREATE TABLE courses (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL UNIQUE,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    price REAL NOT NULL CHECK (price > 0),
    duration_hours INTEGER CHECK (duration_hours > 0)
);

CREATE TABLE enrollments (
    id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id),
    course_id INTEGER NOT NULL REFERENCES courses(id),
    enrollment_date TEXT NOT NULL DEFAULT (DATE('now')),
    progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100)
);

CREATE TABLE course_reviews (
    id INTEGER PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES courses(id),
    student_id INTEGER NOT NULL REFERENCES students(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_date TEXT NOT NULL DEFAULT (DATE('now'))
);

-- ============================================
-- DATOS DE PRUEBA: 80+ registros, distribución variada
-- ============================================

INSERT INTO categories (name) VALUES
    ('Programación'), ('Web'), ('Bases de Datos'), ('Ciencia de Datos'), ('DevOps');

INSERT INTO students (name, email) VALUES
    ('Juan Pérez', 'juan@email.com'), ('María García', 'maria@email.com'),
    ('Carlos López', 'carlos@email.com'), ('Ana Martínez', 'ana@email.com'),
    ('Luis Rodríguez', 'luis@email.com'), ('Sofia Fernández', 'sofia@email.com'),
    ('Pablo Sánchez', 'pablo@email.com'), ('Elena Ruiz', 'elena@email.com'),
    ('Miguel Torres', 'miguel@email.com'), ('Laura Moreno', 'laura@email.com'),
    ('David Álvarez', 'david@email.com'), ('Carmen Gil', 'carmen@email.com'),
    ('Andrés Jiménez', 'andres@email.com'), ('Patricia Domínguez', 'patricia@email.com'),
    ('Roberto Vázquez', 'roberto@email.com'), ('Beatriz Romero', 'beatriz@email.com'),
    ('Fernando Díaz', 'fernando@email.com'), ('Gloria Herrera', 'gloria@email.com'),
    ('Héctor Mendoza', 'hector@email.com'), ('Irene Núñez', 'irene@email.com');

INSERT INTO courses (title, category_id, price, duration_hours) VALUES
    ('Python Desde Cero', 1, 99.99, 40),
    ('JavaScript Avanzado', 2, 89.99, 50),
    ('SQL Masterclass', 3, 79.99, 30),
    ('HTML & CSS', 2, 69.99, 25),
    ('Data Science Python', 4, 149.99, 60),
    ('React Pro', 2, 119.99, 55),
    ('Machine Learning', 4, 189.99, 80),
    ('DevOps Esencial', 5, 129.99, 45),
    ('Angular Avanzado', 2, 109.99, 60),
    ('PostgreSQL Expert', 3, 99.99, 40),
    ('Docker Masterclass', 5, 129.99, 50),
    ('Python Ciencia', 4, 139.99, 70);

INSERT INTO enrollments (student_id, course_id, progress_percentage) VALUES
    (1, 1, 100), (1, 3, 75), (1, 4, 50),
    (2, 2, 100), (2, 6, 60), (2, 1, 30),
    (3, 1, 100), (3, 5, 45), (3, 3, 80),
    (4, 3, 100), (4, 7, 20),
    (5, 4, 100), (5, 2, 70), (5, 8, 35),
    (6, 5, 55), (6, 3, 100), (6, 11, 40),
    (7, 2, 100), (7, 6, 40), (7, 9, 65),
    (8, 1, 100), (8, 7, 50), (8, 10, 85),
    (9, 8, 100), (9, 3, 65), (9, 12, 30),
    (10, 4, 100), (10, 5, 75), (10, 2, 90),
    (11, 2, 100), (11, 1, 40), (11, 11, 55),
    (12, 6, 100), (12, 8, 55), (12, 3, 70),
    (13, 3, 100), (13, 4, 85), (13, 9, 20),
    (14, 1, 100), (14, 5, 70), (14, 10, 60),
    (15, 7, 100), (15, 2, 45), (15, 12, 75),
    (16, 4, 100), (16, 6, 80),
    (17, 1, 100), (17, 3, 55),
    (18, 5, 45), (18, 8, 90),
    (19, 2, 100), (19, 9, 35),
    (20, 10, 100), (20, 7, 65);

INSERT INTO course_reviews (course_id, student_id, rating) VALUES
    (1, 1, 5), (1, 3, 5), (1, 8, 4),
    (2, 2, 5), (2, 7, 4), (2, 11, 5),
    (3, 1, 4), (3, 4, 5), (3, 6, 5),
    (4, 1, 3), (4, 5, 4), (4, 10, 4),
    (5, 3, 4), (5, 6, 4), (5, 18, 3),
    (6, 2, 5), (6, 7, 5), (6, 12, 4),
    (7, 4, 3), (7, 8, 2), (7, 15, 4),
    (8, 5, 5), (8, 9, 4), (8, 18, 5),
    (10, 8, 5), (10, 14, 4), (10, 20, 5),
    (12, 9, 3), (12, 15, 4);

-- ============================================
-- CONSULTA 1: CTE simple + CASE WHEN clasificación
-- Clasifica cursos en bandas de precio
-- ============================================

WITH cursos_con_actividad AS (
    SELECT
        c.id,
        c.title,
        c.price,
        c.category_id,
        ca.name AS categoria,
        COUNT(e.id) AS total_inscritos,
        ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio
    FROM courses c
    LEFT JOIN categories ca ON c.category_id = ca.id
    LEFT JOIN enrollments e ON c.id = e.course_id
    GROUP BY c.id, c.title, c.price, c.category_id, ca.name
)
SELECT
    title AS curso,
    categoria,
    price AS precio,
    total_inscritos,
    progreso_promedio,
    CASE
        WHEN price >= 150 THEN 'Premium'
        WHEN price >= 100 THEN 'Estándar'
        ELSE 'Económico'
    END AS banda_precio,
    CASE
        WHEN progreso_promedio >= 75 THEN 'Muy Popular'
        WHEN progreso_promedio >= 50 THEN 'Popular'
        ELSE 'En Desarrollo'
    END AS popularidad
FROM cursos_con_actividad
ORDER BY price DESC;

-- ============================================
-- CONSULTA 2: Dos CTEs encadenados
-- Primer CTE: total de inscritos por categoría
-- Segundo CTE: categorías por encima del promedio
-- Mostrar nombre y total de las categorías TOP
-- ============================================

WITH inscritos_por_categoria AS (
    SELECT
        ca.id,
        ca.name,
        COUNT(DISTINCT e.student_id) AS total_inscritos
    FROM categories ca
    LEFT JOIN courses c ON ca.id = c.category_id
    LEFT JOIN enrollments e ON c.id = e.course_id
    GROUP BY ca.id, ca.name
),
categorias_top AS (
    SELECT
        id,
        name,
        total_inscritos
    FROM inscritos_por_categoria
    WHERE total_inscritos > (
        SELECT AVG(total_inscritos)
        FROM inscritos_por_categoria
    )
)
SELECT
    cat.name AS categoria,
    cat.total_inscritos,
    CASE
        WHEN cat.total_inscritos >= 15 THEN 'Top Tier'
        WHEN cat.total_inscritos >= 10 THEN 'Mid Tier'
        ELSE 'Emergente'
    END AS clasificacion
FROM categorias_top cat
ORDER BY cat.total_inscritos DESC;

-- ============================================
-- CONSULTA 3: CTE + COUNT condicional por banda de precio
-- Por categoría, contar cuántos cursos en cada banda
-- ============================================

WITH clasificados AS (
    SELECT
        c.id,
        c.title,
        ca.name AS categoria,
        c.price,
        CASE
            WHEN c.price >= 150 THEN 'Premium'
            WHEN c.price >= 100 THEN 'Estándar'
            ELSE 'Económico'
        END AS banda_precio
    FROM courses c
    INNER JOIN categories ca ON c.category_id = ca.id
)
SELECT
    categoria,
    COUNT(CASE WHEN banda_precio = 'Premium' THEN 1 END) AS premium_count,
    COUNT(CASE WHEN banda_precio = 'Estándar' THEN 1 END) AS estandar_count,
    COUNT(CASE WHEN banda_precio = 'Económico' THEN 1 END) AS economico_count,
    COUNT(*) AS total_cursos
FROM clasificados
GROUP BY categoria
ORDER BY categoria;

-- ============================================
-- CONSULTA 4: Reporte combinado de estudiantes
-- Clasificación por actividad y desempeño
-- ============================================

WITH actividad_estudiantes AS (
    SELECT
        s.id,
        s.name,
        s.email,
        COUNT(DISTINCT e.course_id) AS cursos_inscritos,
        ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio,
        COUNT(CASE WHEN e.progress_percentage = 100 THEN 1 END) AS cursos_completados
    FROM students s
    LEFT JOIN enrollments e ON s.id = e.student_id
    GROUP BY s.id, s.name, s.email
)
SELECT
    name AS estudiante,
    email,
    cursos_inscritos,
    progreso_promedio,
    cursos_completados,
    CASE
        WHEN cursos_inscritos = 0 THEN 'Sin Actividad'
        WHEN progreso_promedio >= 80 THEN 'Alto Rendimiento'
        WHEN progreso_promedio >= 50 THEN 'Rendimiento Medio'
        ELSE 'Bajo Rendimiento'
    END AS rendimiento,
    CASE
        WHEN cursos_completados >= 2 THEN 'Completador'
        WHEN cursos_inscritos >= 3 THEN 'Activo'
        WHEN cursos_inscritos > 0 THEN 'Iniciador'
        ELSE 'Inactivo'
    END AS tipo_estudiante
FROM actividad_estudiantes
ORDER BY progreso_promedio DESC;

-- ============================================
-- CONSULTA 5: Análisis detallado por curso
-- Múltiples CTEs y CASE WHEN
-- ============================================

WITH estadisticas_curso AS (
    SELECT
        c.id,
        c.title,
        c.price,
        ca.name AS categoria,
        COUNT(DISTINCT e.student_id) AS total_inscritos,
        COUNT(DISTINCT CASE WHEN e.progress_percentage = 100 THEN e.student_id END) AS completados,
        ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio,
        ROUND(AVG(COALESCE(cr.rating, 0)), 2) AS rating_promedio
    FROM courses c
    INNER JOIN categories ca ON c.category_id = ca.id
    LEFT JOIN enrollments e ON c.id = e.course_id
    LEFT JOIN course_reviews cr ON c.id = cr.course_id
    GROUP BY c.id, c.title, c.price, ca.name
),
calificacion_desempenio AS (
    SELECT
        id,
        title,
        categoria,
        price,
        total_inscritos,
        completados,
        progreso_promedio,
        rating_promedio,
        CASE
            WHEN completados = 0 THEN 'Sin Completados'
            WHEN (CAST(completados AS FLOAT) / total_inscritos) >= 0.75 THEN 'Excelente'
            WHEN (CAST(completados AS FLOAT) / total_inscritos) >= 0.50 THEN 'Bueno'
            ELSE 'Regular'
        END AS tasa_completacion
    FROM estadisticas_curso
)
SELECT
    title AS curso,
    categoria,
    price,
    total_inscritos,
    completados,
    ROUND((CAST(completados AS FLOAT) / NULLIF(total_inscritos, 0)) * 100, 2) AS pct_completacion,
    progreso_promedio,
    rating_promedio,
    tasa_completacion,
    CASE
        WHEN rating_promedio >= 4.5 AND total_inscritos >= 3 THEN 'Top Course'
        WHEN rating_promedio >= 4 AND progreso_promedio >= 60 THEN 'Recomendado'
        WHEN rating_promedio < 3 THEN 'Necesita Mejoras'
        ELSE 'Estándar'
    END AS recomendacion
FROM calificacion_desempenio
ORDER BY rating_promedio DESC, total_inscritos DESC;

-- ============================================
-- CONSULTA 6: CTE recursivo simulado
-- Jerarquía de rendimiento por categoría
-- ============================================

WITH categoria_stats AS (
    SELECT
        ca.name AS categoria,
        COUNT(DISTINCT c.id) AS total_cursos,
        COUNT(DISTINCT e.student_id) AS total_estudiantes,
        ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio,
        ROUND(AVG(COALESCE(cr.rating, 0)), 2) AS rating_promedio,
        COUNT(DISTINCT CASE WHEN e.progress_percentage = 100 THEN e.student_id END) AS estudiantes_completados
    FROM categories ca
    LEFT JOIN courses c ON ca.id = c.category_id
    LEFT JOIN enrollments e ON c.id = e.course_id
    LEFT JOIN course_reviews cr ON c.id = cr.course_id
    GROUP BY ca.id, ca.name
)
SELECT
    categoria,
    total_cursos,
    total_estudiantes,
    estudiantes_completados,
    progreso_promedio,
    rating_promedio,
    CASE
        WHEN ROW_NUMBER() OVER (ORDER BY rating_promedio DESC) = 1 THEN '🥇 Líder'
        WHEN ROW_NUMBER() OVER (ORDER BY rating_promedio DESC) = 2 THEN '🥈 Segunda'
        WHEN ROW_NUMBER() OVER (ORDER BY rating_promedio DESC) = 3 THEN '🥉 Tercera'
        ELSE '   Regular'
    END AS posicion
FROM categoria_stats
ORDER BY rating_promedio DESC;
