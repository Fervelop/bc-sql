-- ============================================
-- PROYECTO SEMANAL: NULL y Constraints
-- Semana 07 — NOT NULL, UNIQUE, CHECK, FK
-- Dominio: Plataforma de cursos online
-- ============================================

PRAGMA foreign_keys = ON;

-- ============================================
-- PARTE 1: ESQUEMA CON CONSTRAINTS
-- ============================================

DROP TABLE IF EXISTS lessons;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT UNIQUE,  -- columna opcional
    registration_date TEXT NOT NULL DEFAULT (DATE('now')),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

CREATE TABLE courses (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL UNIQUE,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    price REAL NOT NULL CHECK (price >= 0),
    duration_hours INTEGER NOT NULL CHECK (duration_hours > 0),
    instructor_name TEXT,  -- columna opcional
    max_students INTEGER CHECK (max_students > 0),
    created_at TEXT NOT NULL DEFAULT (DATE('now'))
);

CREATE TABLE enrollments (
    id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id),
    course_id INTEGER NOT NULL REFERENCES courses(id),
    enrollment_date TEXT NOT NULL DEFAULT (DATE('now')),
    progress_percentage INTEGER NOT NULL DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    completion_date TEXT,  -- columna opcional (NULL si no completado)
    UNIQUE(student_id, course_id)
);

CREATE TABLE lessons (
    id INTEGER PRIMARY KEY,
    course_id INTEGER NOT NULL REFERENCES courses(id),
    title TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    order_number INTEGER NOT NULL,
    optional_notes TEXT  -- columna opcional
);

-- ============================================
-- PARTE 2: DATOS DE PRUEBA
-- ============================================

INSERT INTO categories (name, description) VALUES
    (1, 'Programación', 'Cursos de lenguajes de programación'),
    (2, 'Web', 'Desarrollo web front-end y back-end'),
    (3, 'Bases de Datos', 'SQL y sistemas de gestión de datos'),
    (4, 'Ciencia de Datos', NULL);  -- description = NULL

INSERT INTO students (name, email, phone, is_active) VALUES
    (1, 'Juan Pérez', 'juan@email.com', '123456789', 1),
    (2, 'María García', 'maria@email.com', NULL, 1),  -- sin teléfono
    (3, 'Carlos López', 'carlos@email.com', '987654321', 1),
    (4, 'Ana Martínez', 'ana@email.com', NULL, 1),
    (5, 'Luis Rodríguez', 'luis@email.com', '555666777', 0),
    (6, 'Sofia Fernández', 'sofia@email.com', NULL, 1);

INSERT INTO courses (title, category_id, price, duration_hours, instructor_name, max_students) VALUES
    (1, 'Python Desde Cero', 1, 99.99, 40, 'Dr. Juan', 30),
    (2, 'JavaScript Avanzado', 2, 89.99, 50, NULL, 25),  -- sin instructor
    (3, 'SQL Masterclass', 3, 79.99, 30, 'Ing. María', 20),
    (4, 'React Pro', 2, 119.99, 55, NULL, 15),
    (5, 'Data Science 101', 4, 149.99, 60, 'Dra. Sofia', 40);

INSERT INTO enrollments (student_id, course_id, progress_percentage, completion_date) VALUES
    (1, 1, 100, '2024-01-15'),
    (1, 3, 75, NULL),  -- no completado
    (2, 2, 100, '2024-01-20'),
    (3, 1, 100, '2024-01-10'),
    (3, 4, 50, NULL),
    (4, 3, 100, '2024-01-25'),
    (4, 5, 0, NULL),
    (5, 1, 40, NULL),
    (6, 2, 100, '2024-01-22');

INSERT INTO lessons (course_id, title, duration_minutes, order_number, optional_notes) VALUES
    (1, 'Intro a Python', 45, 1, 'Muy importante'),
    (1, 'Variables y Tipos', 60, 2, NULL),
    (1, 'Funciones', 75, 3, 'Tema difícil'),
    (2, 'ES6 Basics', 50, 1, NULL),
    (2, 'Async/Await', 65, 2, 'Requiere Python knowledge'),
    (3, 'SELECT Básico', 40, 1, NULL),
    (3, 'JOINs', 75, 2, 'Práctica extensa necesaria'),
    (4, 'React Hooks', 70, 1, NULL),
    (5, 'Librerías de Datos', 80, 1, 'Usar Jupyter Notebook');

-- ============================================
-- PARTE 3: CONSULTAS CON NULL Y CONSTRAINTS
-- ============================================

-- Mostrar estudiantes sin teléfono registrado
SELECT id, name, email
FROM students
WHERE phone IS NULL
ORDER BY name;

-- Mostrar cursos sin instructor asignado
SELECT id, title, category_id
FROM courses
WHERE instructor_name IS NULL
ORDER BY title;

-- Mostrar inscripciones no completadas (NULL en completion_date)
SELECT
    e.id,
    s.name AS estudiante,
    c.title AS curso,
    e.progress_percentage,
    e.completion_date
FROM enrollments e
INNER JOIN students s ON e.student_id = s.id
INNER JOIN courses c ON e.course_id = c.id
WHERE e.completion_date IS NULL
ORDER BY s.name, e.progress_percentage DESC;

-- Usar COALESCE para reemplazar NULLs
SELECT
    id,
    title,
    COALESCE(instructor_name, 'Sin asignar') AS instructor,
    COALESCE(max_students, 0) AS capacidad_maxima
FROM courses
ORDER BY title;

-- Mostrar categorías con descripción disponible
SELECT
    id,
    name,
    COALESCE(description, 'Sin descripción') AS descripcion
FROM categories
ORDER BY name;

-- Contar estudiantes activos e inactivos
SELECT
    CASE
        WHEN is_active = 1 THEN 'Activo'
        WHEN is_active = 0 THEN 'Inactivo'
    END AS estado,
    COUNT(*) AS cantidad
FROM students
GROUP BY is_active;

-- Lecciones con y sin notas opcionales
SELECT
    course_id,
    title,
    duration_minutes,
    COALESCE(optional_notes, 'Sin notas') AS notas
FROM lessons
ORDER BY course_id, order_number;

-- Validar constraints: students sin email (debería estar vacío)
SELECT COUNT(*) AS students_sin_email
FROM students
WHERE email IS NULL;

-- Mostrar inscripciones completadas vs pendientes
SELECT
    COUNT(CASE WHEN completion_date IS NOT NULL THEN 1 END) AS completadas,
    COUNT(CASE WHEN completion_date IS NULL THEN 1 END) AS pendientes,
    COUNT(*) AS total_inscripciones
FROM enrollments;
