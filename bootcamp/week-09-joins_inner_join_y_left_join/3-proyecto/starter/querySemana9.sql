-- ============================================
-- PROYECTO SEMANAL: JOINs aplicados a tu dominio
-- Semana 09 — INNER JOIN y LEFT JOIN
-- Dominio: Plataforma de cursos online
-- ============================================

PRAGMA foreign_keys = ON;

-- ============================================
-- SCHEMA: Plataforma de Cursos Online
-- ============================================

DROP TABLE IF EXISTS lessons;
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

-- ============================================
-- DATOS DE PRUEBA (85+ registros en tabla principal)
-- ============================================

INSERT INTO categories (name) VALUES
    ('Programación'),
    ('Web'),
    ('Bases de Datos'),
    ('Ciencia de Datos'),
    ('DevOps');

INSERT INTO students (name, email) VALUES
    ('Juan Pérez', 'juan@email.com'),
    ('María García', 'maria@email.com'),
    ('Carlos López', 'carlos@email.com'),
    ('Ana Martínez', 'ana@email.com'),
    ('Luis Rodríguez', 'luis@email.com'),
    ('Sofia Fernández', 'sofia@email.com'),
    ('Pablo Sánchez', 'pablo@email.com'),
    ('Elena Ruiz', 'elena@email.com'),
    ('Miguel Torres', 'miguel@email.com'),
    ('Laura Moreno', 'laura@email.com'),
    ('David Álvarez', 'david@email.com'),
    ('Carmen Gil', 'carmen@email.com'),
    ('Andrés Jiménez', 'andres@email.com'),
    ('Patricia Domínguez', 'patricia@email.com'),
    ('Roberto Vázquez', 'roberto@email.com'),
    ('Beatriz Romero', 'beatriz@email.com'),
    ('Fernando Díaz', 'fernando@email.com'),
    ('Gloria Herrera', 'gloria@email.com'),
    ('Héctor Mendoza', 'hector@email.com'),
    ('Irene Núñez', 'irene@email.com');

INSERT INTO courses (title, category_id, price, duration_hours) VALUES
    ('Python Desde Cero', 1, 99.99, 40),
    ('JavaScript Avanzado', 2, 89.99, 50),
    ('SQL Masterclass', 3, 79.99, 30),
    ('HTML & CSS Completo', 2, 69.99, 25),
    ('Data Science con Python', 4, 149.99, 60),
    ('React Pro', 2, 119.99, 55),
    ('Machine Learning 101', 4, 189.99, 80),
    ('DevOps Esencial', 5, 129.99, 45),
    ('Angular Avanzado', 2, 109.99, 60),
    ('PostgreSQL Expert', 3, 99.99, 40),
    ('Docker Masterclass', 5, 129.99, 50),
    ('Python para Ciencia', 4, 139.99, 70);

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

-- ============================================
-- CONSULTA 1: INNER JOIN principal
-- Estudiantes y sus inscripciones (solo registros con relación)
-- ============================================

SELECT
    s.name AS estudiante,
    c.title AS curso,
    ca.name AS categoria,
    e.progress_percentage AS progreso,
    e.enrollment_date AS fecha_inscripcion
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
INNER JOIN courses c ON e.course_id = c.id
INNER JOIN categories ca ON c.category_id = ca.id
ORDER BY s.name, c.title;

-- ============================================
-- CONSULTA 2: JOIN con tres tablas
-- Estudiantes, cursos, categorías e inscripciones detalladas
-- ============================================

SELECT
    s.name AS estudiante,
    c.title AS curso,
    ca.name AS categoria,
    c.price AS precio,
    c.duration_hours AS horas,
    e.progress_percentage AS progreso,
    CASE
        WHEN e.progress_percentage = 100 THEN 'Completado'
        WHEN e.progress_percentage >= 50 THEN 'En progreso'
        ELSE 'Iniciado'
    END AS estado
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
INNER JOIN courses c ON e.course_id = c.id
INNER JOIN categories ca ON c.category_id = ca.id
WHERE e.progress_percentage > 0
ORDER BY s.name, e.progress_percentage DESC;

-- ============================================
-- CONSULTA 3: LEFT JOIN — todos los registros
-- Todos los estudiantes aunque no tengan inscripciones
-- ============================================

SELECT
    s.name AS estudiante,
    s.email,
    s.registration_date AS fecha_registro,
    c.title AS curso,
    ca.name AS categoria,
    COALESCE(e.progress_percentage, 0) AS progreso
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
LEFT JOIN courses c ON e.course_id = c.id
LEFT JOIN categories ca ON c.category_id = ca.id
ORDER BY s.name, c.title;

-- ============================================
-- CONSULTA 4: Detectar huérfanos (estudiantes sin inscripciones)
-- ============================================

SELECT
    s.id,
    s.name AS estudiante,
    s.email,
    s.registration_date AS fecha_registro
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
WHERE e.id IS NULL
ORDER BY s.name;

-- ============================================
-- CONSULTA 5: Reporte agregado con LEFT JOIN + COUNT
-- Cantidad de inscripciones por curso (incluye 0)
-- ============================================

SELECT
    c.title AS curso,
    ca.name AS categoria,
    c.price,
    c.duration_hours,
    COUNT(e.id) AS total_inscritos,
    ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio,
    COUNT(CASE WHEN e.progress_percentage = 100 THEN 1 END) AS completados
FROM courses c
LEFT JOIN categories ca ON c.category_id = ca.id
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.title, ca.name, c.price, c.duration_hours
ORDER BY total_inscritos DESC, curso;

-- ============================================
-- CONSULTA 6: Estudiantes con más de 2 cursos inscritos
-- ============================================

SELECT
    s.name AS estudiante,
    COUNT(e.id) AS total_cursos,
    COUNT(CASE WHEN e.progress_percentage = 100 THEN 1 END) AS completados,
    ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name
HAVING COUNT(e.id) > 2
ORDER BY total_cursos DESC;

-- ============================================
-- CONSULTA 7: Categorías y cantidad de cursos disponibles
-- ============================================

SELECT
    ca.name AS categoria,
    COUNT(c.id) AS total_cursos,
    COUNT(e.id) AS total_inscripciones,
    ROUND(AVG(c.price), 2) AS precio_promedio
FROM categories ca
LEFT JOIN courses c ON ca.id = c.category_id
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY ca.id, ca.name
ORDER BY total_cursos DESC;
