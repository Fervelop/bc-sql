-- ============================================
-- PROYECTO SEMANAL: Funciones de Agregación
-- Semana 06 — COUNT, SUM, AVG, GROUP BY, HAVING
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

CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    registration_date TEXT NOT NULL DEFAULT (DATE('now'))
);

CREATE TABLE courses (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL,
    price REAL NOT NULL CHECK (price > 0),
    duration_hours INTEGER CHECK (duration_hours > 0)
);

CREATE TABLE enrollments (
    id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id),
    course_id INTEGER NOT NULL REFERENCES courses(id),
    enrollment_date TEXT NOT NULL DEFAULT (DATE('now')),
    progress_percentage INTEGER CHECK (progress_percentage >= 0 AND progress_percentage <= 100)
);

CREATE TABLE lessons (
    id INTEGER PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES courses(id),
    title TEXT NOT NULL,
    duration_minutes INTEGER CHECK (duration_minutes > 0)
);

-- ============================================
-- DATOS DE PRUEBA: 30+ registros por tabla
-- ============================================

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
    ('Roberto Vázquez', 'roberto@email.com');

INSERT INTO courses (title, category, price, duration_hours) VALUES
    ('Python Desde Cero', 'Programación', 99.99, 40),
    ('JavaScript Avanzado', 'Programación', 89.99, 50),
    ('SQL para Analistas', 'Bases de Datos', 79.99, 30),
    ('HTML & CSS Completo', 'Web', 69.99, 25),
    ('Data Science con Python', 'Ciencia de Datos', 149.99, 60),
    ('React Masterclass', 'Web', 119.99, 55),
    ('Machine Learning 101', 'Ciencia de Datos', 189.99, 80),
    ('DevOps Esencial', 'Infraestructura', 129.99, 45);

INSERT INTO enrollments (student_id, course_id, progress_percentage) VALUES
    (1, 1, 100), (1, 3, 75), (1, 4, 50),
    (2, 2, 100), (2, 6, 60), (2, 1, 30),
    (3, 1, 100), (3, 5, 45),
    (4, 3, 100), (4, 7, 20),
    (5, 4, 100), (5, 2, 70), (5, 8, 35),
    (6, 5, 55), (6, 3, 100),
    (7, 2, 100), (7, 6, 40),
    (8, 1, 100), (8, 7, 50),
    (9, 8, 100), (9, 3, 65),
    (10, 4, 100), (10, 5, 75),
    (11, 2, 100), (11, 1, 40),
    (12, 6, 100), (12, 8, 55),
    (13, 3, 100), (13, 4, 85),
    (14, 1, 100), (14, 5, 70),
    (15, 7, 100), (15, 2, 45);

INSERT INTO lessons (course_id, title, duration_minutes) VALUES
    (1, 'Introducción a Python', 45), (1, 'Variables y Tipos', 60), (1, 'Funciones', 75), (1, 'Librerías', 90),
    (2, 'ES6 Basics', 50), (2, 'Async/Await', 65), (2, 'Promises', 55), (2, 'Callbacks', 50),
    (3, 'SELECT Básico', 40), (3, 'JOINs', 75), (3, 'Agregaciones', 60), (3, 'Índices', 50),
    (4, 'HTML5', 45), (4, 'CSS Flexbox', 55), (4, 'CSS Grid', 50), (4, 'Responsive', 60),
    (5, 'Librerías de Datos', 80), (5, 'EDA', 90), (5, 'Visualización', 85),
    (6, 'React Hooks', 70), (6, 'State Management', 80), (6, 'Performance', 75),
    (7, 'Regresión Lineal', 100), (7, 'Clasificación', 95), (7, 'Clustering', 100),
    (8, 'Docker Basics', 60), (8, 'Kubernetes', 90), (8, 'CI/CD', 85);

-- ============================================
-- REPORTE 1: Totales globales
-- ============================================
-- Cuenta todos los estudiantes, promedio de progreso en cursos
SELECT
    COUNT(DISTINCT student_id) AS total_estudiantes,
    COUNT(DISTINCT course_id) AS total_cursos,
    COUNT(*) AS total_inscripciones,
    ROUND(AVG(progress_percentage), 2) AS promedio_progreso
FROM enrollments;

-- ============================================
-- REPORTE 2: Extremos en precios y duración
-- ============================================
SELECT
    MIN(price) AS precio_minimo,
    MAX(price) AS precio_maximo,
    MIN(duration_hours) AS duracion_minima_horas,
    MAX(duration_hours) AS duracion_maxima_horas
FROM courses;

-- ============================================
-- REPORTE 3: Subtotales por categoría
-- ============================================
-- Agrupación por categoría de cursos
SELECT
    category AS categoria,
    COUNT(*) AS total_cursos,
    ROUND(AVG(price), 2) AS precio_promedio,
    ROUND(AVG(duration_hours), 2) AS duracion_promedio_horas,
    SUM(duration_hours) AS duracion_total_horas
FROM courses
GROUP BY category
ORDER BY total_cursos DESC, precio_promedio DESC;

-- ============================================
-- REPORTE 4: Filtro de grupos con HAVING
-- ============================================
-- Mostrar solo las categorías con más de 1 curso
SELECT
    category AS categoria,
    COUNT(*) AS total_cursos,
    ROUND(AVG(price), 2) AS precio_promedio
FROM courses
GROUP BY category
HAVING COUNT(*) > 1
ORDER BY total_cursos DESC;

-- ============================================
-- REPORTE 5: Inscripciones por curso
-- ============================================
-- Estadísticas por curso (inscripciones y progreso)
SELECT
    c.title AS curso,
    COUNT(e.id) AS total_inscritos,
    ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio,
    COUNT(CASE WHEN e.progress_percentage = 100 THEN 1 END) AS completados
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.id
GROUP BY c.id, c.title
ORDER BY total_inscritos DESC;

-- ============================================
-- REPORTE 6: Actividad por estudiante
-- ============================================
-- Cursos inscritos y progreso promedio por estudiante
SELECT
    s.name AS estudiante,
    COUNT(e.id) AS cursos_inscritos,
    ROUND(AVG(e.progress_percentage), 2) AS progreso_promedio,
    COUNT(CASE WHEN e.progress_percentage = 100 THEN 1 END) AS cursos_completados
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id
GROUP BY s.id, s.name
HAVING COUNT(e.id) > 0
ORDER BY cursos_completados DESC, progreso_promedio DESC;

-- ============================================
-- REPORTE 7: Lecciones por curso
-- ============================================
-- Total de lecciones y duración total por curso
SELECT
    c.title AS curso,
    COUNT(l.id) AS total_lecciones,
    ROUND(AVG(l.duration_minutes), 2) AS duracion_promedio_minutos,
    SUM(l.duration_minutes) AS duracion_total_minutos
FROM courses c
LEFT JOIN lessons l ON l.course_id = c.id
GROUP BY c.id, c.title
HAVING COUNT(l.id) > 0
ORDER BY duracion_total_minutos DESC;
