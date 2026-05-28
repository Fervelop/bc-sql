-- ============================================
-- PROYECTO SEMANAL: Subqueries en tu dominio
-- Semana 11 — Subqueries (escalar, IN, EXISTS, FROM)
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
-- DATOS DE PRUEBA: 80+ inscritos, 20+ por tabla secundaria
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
    ('Python Desde Cero', 1, 99.99, 40), ('JavaScript Avanzado', 2, 89.99, 50),
    ('SQL Masterclass', 3, 79.99, 30), ('HTML & CSS', 2, 69.99, 25),
    ('Data Science Python', 4, 149.99, 60), ('React Pro', 2, 119.99, 55),
    ('Machine Learning', 4, 189.99, 80), ('DevOps Esencial', 5, 129.99, 45),
    ('Angular Avanzado', 2, 109.99, 60), ('PostgreSQL Expert', 3, 99.99, 40),
    ('Docker Masterclass', 5, 129.99, 50), ('Python Ciencia', 4, 139.99, 70);

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
-- CONSULTA 1: Subquery escalar en WHERE
-- Cursos cuyo precio supera el promedio de su categoría
-- La subquery calcula el precio promedio de la categoría
-- ============================================

SELECT
    c.title AS curso,
    c.price AS precio,
    c.category_id,
    (SELECT AVG(price) FROM courses c2 WHERE c2.category_id = c.category_id) AS promedio_categoria
FROM courses c
WHERE c.price > (
    SELECT AVG(c2.price)
    FROM courses c2
    WHERE c2.category_id = c.category_id
)
ORDER BY c.category_id, c.price DESC;

-- ============================================
-- CONSULTA 2: Subquery escalar en SELECT
-- Mostrar el promedio global junto a cada curso
-- La subquery se ejecuta para cada fila
-- ============================================

SELECT
    c.title AS curso,
    c.price,
    (SELECT AVG(price) FROM courses) AS promedio_global,
    ROUND(c.price - (SELECT AVG(price) FROM courses), 2) AS diferencia_global
FROM courses c
ORDER BY c.price DESC;

-- ============================================
-- CONSULTA 3: NOT EXISTS
-- Cursos que NO tienen ninguna reseña
-- Alternativa segura a NOT IN
-- ============================================

SELECT
    c.id,
    c.title AS curso,
    c.price,
    COUNT(e.id) AS total_inscritos
FROM courses c
INNER JOIN enrollments e ON c.id = e.course_id
WHERE NOT EXISTS (
    SELECT 1
    FROM course_reviews cr
    WHERE cr.course_id = c.id
)
GROUP BY c.id, c.title, c.price
ORDER BY total_inscritos DESC;

-- ============================================
-- CONSULTA 4: EXISTS
-- Estudiantes que han dejado al menos una reseña
-- ============================================

SELECT
    s.id,
    s.name AS estudiante,
    s.email,
    COUNT(cr.id) AS total_resenas
FROM students s
WHERE EXISTS (
    SELECT 1
    FROM course_reviews cr
    WHERE cr.student_id = s.id
)
GROUP BY s.id, s.name, s.email
ORDER BY total_resenas DESC;

-- ============================================
-- CONSULTA 5: Tabla derivada en FROM
-- Categorías con estadísticas de inscritos y reseñas
-- ============================================

SELECT
    cat_stats.category,
    cat_stats.total_cursos,
    cat_stats.total_inscritos,
    cat_stats.promedio_rating
FROM (
    SELECT
        cat.name AS category,
        COUNT(DISTINCT c.id) AS total_cursos,
        COUNT(DISTINCT e.id) AS total_inscritos,
        ROUND(AVG(COALESCE(cr.rating, 0)), 2) AS promedio_rating
    FROM categories cat
    LEFT JOIN courses c ON cat.id = c.category_id
    LEFT JOIN enrollments e ON c.id = e.course_id
    LEFT JOIN course_reviews cr ON c.id = cr.course_id
    GROUP BY cat.id, cat.name
) AS cat_stats
ORDER BY cat_stats.total_inscritos DESC;

-- ============================================
-- CONSULTA 6: Subquery IN
-- Estudiantes inscritos en cursos de "Programación"
-- ============================================

SELECT
    s.name AS estudiante,
    s.email,
    COUNT(e.id) AS cursos_prog
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
WHERE e.course_id IN (
    SELECT c.id
    FROM courses c
    WHERE c.category_id = (
        SELECT id FROM categories WHERE name = 'Programación'
    )
)
GROUP BY s.id, s.name, s.email
ORDER BY cursos_prog DESC;

-- ============================================
-- CONSULTA 7: NOT IN
-- Cursos de Programación sin reseñas de 5 estrellas
-- ============================================

SELECT
    c.id,
    c.title,
    c.price
FROM courses c
WHERE c.category_id = (SELECT id FROM categories WHERE name = 'Programación')
AND c.id NOT IN (
    SELECT DISTINCT course_id
    FROM course_reviews
    WHERE rating = 5
)
ORDER BY c.title;

-- ============================================
-- CONSULTA 8: Tabla derivada avanzada
-- Reporte de performance por categoría
-- ============================================

SELECT
    perf.categoria,
    perf.cursos_activos,
    perf.estudiantes_totales,
    perf.progreso_promedio,
    perf.rating_promedio,
    CASE
        WHEN perf.rating_promedio >= 4.5 THEN 'Excelente'
        WHEN perf.rating_promedio >= 4 THEN 'Muy Bueno'
        WHEN perf.rating_promedio >= 3.5 THEN 'Bueno'
        ELSE 'Requiere Mejora'
    END AS evaluacion
FROM (
    SELECT
        ca.name AS categoria,
        COUNT(DISTINCT c.id) AS cursos_activos,
        COUNT(DISTINCT e.student_id) AS estudiantes_totales,
        ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio,
        ROUND(AVG(cr.rating), 2) AS rating_promedio
    FROM categories ca
    LEFT JOIN courses c ON ca.id = c.category_id
    LEFT JOIN enrollments e ON c.id = e.course_id
    LEFT JOIN course_reviews cr ON c.id = cr.course_id
    GROUP BY ca.id, ca.name
) AS perf
ORDER BY perf.rating_promedio DESC;

-- ============================================
-- CONSULTA 9: Cursos sin inscripciones
-- ============================================

SELECT
    c.id,
    c.title,
    c.category_id,
    c.price
FROM courses c
WHERE c.id NOT IN (
    SELECT DISTINCT course_id FROM enrollments
)
ORDER BY c.title;
