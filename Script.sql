-- =====================================================
-- SISTEMA DE CONTROL DE ASISTENCIA SENA
-- Scripts SQL Completos - Modelo Actualizado
-- Base de Datos: MySQL 8.0+
-- =====================================================
-- =====================================================
-- 1. CREAR BASE DE DATOS
-- =====================================================
DROP DATABASE IF EXISTS softasistence;

CREATE DATABASE softasistence CHARACTER
SET
    utf8mb4 COLLATE utf8mb4_unicode_ci;

USE softasistence;

-- =====================================================
-- 2. CREAR TABLAS PRINCIPALES
-- =====================================================
-- Tabla: USUARIOS (Instructores, Coordinadores, Administradores)
CREATE TABLE
    USUARIOS (
        cedula INT PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        apellido VARCHAR(100) NOT NULL,
        email VARCHAR(150) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        rol ENUM ('super_admin', 'coordinador', 'instructor') NOT NULL DEFAULT 'instructor',
        activo BOOLEAN NOT NULL DEFAULT TRUE,
        fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_email (email),
        INDEX idx_rol_activo (rol, activo)
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Tabla: FORMACIONES
CREATE TABLE
    FORMACIONES (
        id_formaciones INT AUTO_INCREMENT PRIMARY KEY,
        codigo VARCHAR(50) NOT NULL UNIQUE,
        nombre VARCHAR(200) NOT NULL,
        jornada ENUM ('diurna', 'nocturna', 'mixta', 'fin_de_semana') NOT NULL,
        fecha_inicio DATE NOT NULL,
        fecha_fin DATE NULL,
        activo BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_codigo (codigo),
        INDEX idx_activo_jornada (activo, jornada)
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Tabla: APRENDICES (Estudiantes)
CREATE TABLE
    APRENDICES (
        id_aprendices INT AUTO_INCREMENT PRIMARY KEY,
        documento VARCHAR(50) NOT NULL UNIQUE,
        tipo_documento ENUM ('CC', 'TI', 'CE', 'PAS') NOT NULL DEFAULT 'CC',
        nombres VARCHAR(100) NOT NULL,
        apellidos VARCHAR(100) NOT NULL,
        email VARCHAR(150) NULL,
        telefono VARCHAR(20) NULL,
        activo BOOLEAN NOT NULL DEFAULT TRUE,
        fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_documento (documento),
        INDEX idx_apellidos_nombres (apellidos, nombres),
        INDEX idx_activo (activo)
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Tabla: AMBIENTES (Aulas, Laboratorios)
CREATE TABLE
    AMBIENTES (
        id_ambientes INT AUTO_INCREMENT PRIMARY KEY,
        numero_ambiente VARCHAR(50) NOT NULL UNIQUE,
        nombre VARCHAR(100) NOT NULL,
        capacidad INT NULL,
        ubicacion VARCHAR(150) NULL,
        activo BOOLEAN NOT NULL DEFAULT TRUE,
        INDEX idx_numero_ambiente (numero_ambiente),
        INDEX idx_activo (activo)
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================
-- 3. TABLAS DE RELACIÓN (Muchos a Muchos)
-- =====================================================
-- Tabla: INSTRUCTOR_FORMACION (Asignación de instructores a formaciones)
CREATE TABLE
    INSTRUCTOR_FORMACION (
        id_instructor_formacion INT AUTO_INCREMENT PRIMARY KEY,
        instructor_id INT NOT NULL,
        formacion_id INT NOT NULL,
        fecha_asignacion DATE NOT NULL,
        activo BOOLEAN NOT NULL DEFAULT TRUE,
        UNIQUE KEY uk_instructor_formacion (instructor_id, formacion_id),
        INDEX idx_formacion_id (formacion_id),
        CONSTRAINT fk_instructor_formacion_usuario FOREIGN KEY (instructor_id) REFERENCES USUARIOS (cedula) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_instructor_formacion_formacion FOREIGN KEY (formacion_id) REFERENCES FORMACIONES (id_formaciones) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Tabla: FORMACION_APRENDIZ (Matrícula de aprendices)
CREATE TABLE
    FORMACION_APRENDIZ (
        id_formacion_aprendiz INT AUTO_INCREMENT PRIMARY KEY,
        fk_formacion INT NOT NULL,
        fk_aprendiz INT NOT NULL,
        fecha_matricula DATE NOT NULL,
        estado ENUM ('activo', 'retirado', 'suspendido') NOT NULL DEFAULT 'activo',
        UNIQUE KEY uk_formacion_aprendiz (fk_formacion, fk_aprendiz),
        INDEX idx_aprendiz (fk_aprendiz),
        INDEX idx_estado (estado),
        CONSTRAINT fk_formacion_aprendiz_formacion FOREIGN KEY (fk_formacion) REFERENCES FORMACIONES (id_formaciones) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_formacion_aprendiz_aprendiz FOREIGN KEY (fk_aprendiz) REFERENCES APRENDICES (id_aprendices) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Tabla: FORMACION_AMBIENTE (Asignación de ambientes a formaciones con horarios)
CREATE TABLE
    FORMACION_AMBIENTE (
        id_formacion_ambiente INT AUTO_INCREMENT PRIMARY KEY,
        fk_formacion INT NOT NULL,
        fk_ambiente INT NOT NULL,
        dia_semana ENUM (
            'lunes',
            'martes',
            'miercoles',
            'jueves',
            'viernes',
            'sabado',
            'domingo'
        ) NULL,
        hora_inicio TIME NULL,
        hora_fin TIME NULL,
        INDEX idx_formacion_dia (fk_formacion, dia_semana),
        INDEX idx_ambiente (fk_ambiente),
        CONSTRAINT fk_formacion_ambiente_formacion FOREIGN KEY (fk_formacion) REFERENCES FORMACIONES (id_formaciones) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_formacion_ambiente_ambiente FOREIGN KEY (fk_ambiente) REFERENCES AMBIENTES (id_ambientes) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================
-- 4. TABLA CRÍTICA: ASISTENCIAS
-- =====================================================
CREATE TABLE
    ASISTENCIAS (
        id_asistencias INT AUTO_INCREMENT PRIMARY KEY,
        fk_formacion INT NOT NULL,
        fk_aprendiz INT NOT NULL,
        fk_instructor INT NOT NULL,
        fk_ambiente INT NULL,
        fecha DATE NOT NULL,
        presente BOOLEAN NOT NULL,
        observaciones TEXT NULL,
        hora_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        -- CONSTRAINT CRÍTICO: Evita registros duplicados
        UNIQUE KEY uk_asistencia_diaria (fk_formacion, fk_aprendiz, fecha),
        INDEX idx_fecha (fecha),
        INDEX idx_formacion_fecha (fk_formacion, fecha),
        INDEX idx_aprendiz_fecha (fk_aprendiz, fecha),
        INDEX idx_instructor (fk_instructor),
        INDEX idx_ambiente (fk_ambiente),
        CONSTRAINT fk_asistencias_formacion FOREIGN KEY (fk_formacion) REFERENCES FORMACIONES (id_formaciones) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_asistencias_aprendiz FOREIGN KEY (fk_aprendiz) REFERENCES APRENDICES (id_aprendices) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_asistencias_instructor FOREIGN KEY (fk_instructor) REFERENCES USUARIOS (cedula) ON DELETE RESTRICT ON UPDATE CASCADE,
        CONSTRAINT fk_asistencias_ambiente FOREIGN KEY (fk_ambiente) REFERENCES AMBIENTES (id_ambientes) ON DELETE SET NULL ON UPDATE CASCADE
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- =====================================================
-- 5. TABLAS DE AUDITORÍA Y REPORTES
-- =====================================================
-- Tabla: REPORTES_GOOGLE_SHEETS (Log de exportaciones)
CREATE TABLE
    REPORTES_GOOGLE_SHEETS (
        id_sheets INT AUTO_INCREMENT PRIMARY KEY,
        fk_formacion INT NULL,
        fecha_reporte DATE NOT NULL,
        url_sheet TEXT NULL,
        fk_generado_por INT NOT NULL,
        fecha_generacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        estado ENUM ('exitoso', 'fallido') NOT NULL DEFAULT 'exitoso',
        INDEX idx_fecha_reporte (fecha_reporte),
        INDEX idx_formacion (fk_formacion),
        INDEX idx_generado_por (fk_generado_por),
        CONSTRAINT fk_reportes_formacion FOREIGN KEY (fk_formacion) REFERENCES FORMACIONES (id_formaciones) ON DELETE SET NULL ON UPDATE CASCADE,
        CONSTRAINT fk_reportes_usuario FOREIGN KEY (fk_generado_por) REFERENCES USUARIOS (cedula) ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Tabla: LOGS_AUDITORIA (Trazabilidad de acciones)
CREATE TABLE
    LOGS_AUDITORIA (
        id_log INT AUTO_INCREMENT PRIMARY KEY,
        fk_usuario INT NULL,
        accion VARCHAR(100) NOT NULL,
        tabla_afectada VARCHAR(50) NULL,
        registro_id INT NULL,
        detalles TEXT NULL,
        ip_address VARCHAR(45) NULL,
        fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_usuario_fecha (fk_usuario, fecha_hora),
        INDEX idx_tabla_accion (tabla_afectada, accion),
        INDEX idx_fecha_hora (fecha_hora),
        CONSTRAINT fk_logs_usuario FOREIGN KEY (fk_usuario) REFERENCES USUARIOS (cedula) ON DELETE SET NULL ON UPDATE CASCADE
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Tabla: CONFIGURACIONES (Parámetros del sistema)
CREATE TABLE
    CONFIGURACIONES (
        id INT AUTO_INCREMENT PRIMARY KEY,
        clave VARCHAR(100) NOT NULL UNIQUE,
        valor TEXT NULL,
        descripcion TEXT NULL,
        fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_clave (clave)
    )
    -- =====================================================
    -- 6. TRIGGERS
    -- =====================================================
    -- Trigger: Validar que no se registre asistencia futura
    DELIMITER / / CREATE TRIGGER tr_asistencias_before_insert BEFORE INSERT ON ASISTENCIAS FOR EACH ROW BEGIN IF NEW.fecha > CURDATE () THEN SIGNAL SQLSTATE '45000'
SET
    MESSAGE_TEXT = 'No se puede registrar asistencia para fechas futuras';

END IF;

END / / DELIMITER;

-- Trigger: Registrar en logs cuando se crea un usuario
DELIMITER / / CREATE TRIGGER tr_usuarios_after_insert AFTER INSERT ON USUARIOS FOR EACH ROW BEGIN
INSERT INTO
    LOGS_AUDITORIA (
        fk_usuario,
        accion,
        tabla_afectada,
        registro_id,
        detalles
    )
VALUES
    (
        NEW.cedula,
        'CREATE',
        'USUARIOS',
        NEW.cedula,
        JSON_OBJECT (
            'email',
            NEW.email,
            'rol',
            NEW.rol,
            'nombre',
            NEW.nombre,
            'apellido',
            NEW.apellido
        )
    );

END / / DELIMITER;

-- Trigger: Registrar en logs cuando se actualiza un usuario
DELIMITER / / CREATE TRIGGER tr_usuarios_after_update AFTER
UPDATE ON USUARIOS FOR EACH ROW BEGIN
INSERT INTO
    LOGS_AUDITORIA (
        fk_usuario,
        accion,
        tabla_afectada,
        registro_id,
        detalles
    )
VALUES
    (
        NEW.cedula,
        'UPDATE',
        'USUARIOS',
        NEW.cedula,
        JSON_OBJECT (
            'antes',
            JSON_OBJECT (
                'email',
                OLD.email,
                'rol',
                OLD.rol,
                'activo',
                OLD.activo
            ),
            'despues',
            JSON_OBJECT (
                'email',
                NEW.email,
                'rol',
                NEW.rol,
                'activo',
                NEW.activo
            )
        )
    );

END / / DELIMITER;

-- Trigger: Registrar cuando se crea una asistencia
DELIMITER / / CREATE TRIGGER tr_asistencias_after_insert AFTER INSERT ON ASISTENCIAS FOR EACH ROW BEGIN
INSERT INTO
    LOGS_AUDITORIA (
        fk_usuario,
        accion,
        tabla_afectada,
        registro_id,
        detalles
    )
VALUES
    (
        NEW.fk_instructor,
        'CREATE',
        'ASISTENCIAS',
        NEW.id_asistencias,
        JSON_OBJECT (
            'formacion_id',
            NEW.fk_formacion,
            'aprendiz_id',
            NEW.fk_aprendiz,
            'fecha',
            NEW.fecha,
            'presente',
            NEW.presente
        )
    );

END / / DELIMITER;

-- =====================================================
-- 7. DATOS SEMILLA (SEED DATA)
-- =====================================================
-- Usuarios de prueba (password: 'password123' hasheado con bcrypt)
INSERT INTO
    USUARIOS (
        cedula,
        nombre,
        apellido,
        email,
        password_hash,
        rol,
        activo
    )
VALUES
    (
        1000000001,
        'Admin',
        'Sistema',
        'admin@sena.edu.co',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW5z4rJ7JRzq',
        'super_admin',
        TRUE
    ),
    (
        1000000002,
        'María',
        'López García',
        'maria.lopez@sena.edu.co',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW5z4rJ7JRzq',
        'coordinador',
        TRUE
    ),
    (
        1000000003,
        'Carlos',
        'Ramírez Pérez',
        'carlos.ramirez@sena.edu.co',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW5z4rJ7JRzq',
        'instructor',
        TRUE
    ),
    (
        1000000004,
        'Ana',
        'Martínez Torres',
        'ana.martinez@sena.edu.co',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW5z4rJ7JRzq',
        'instructor',
        TRUE
    ),
    (
        1000000005,
        'Luis',
        'González Ruiz',
        'luis.gonzalez@sena.edu.co',
        '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5lW5z4rJ7JRzq',
        'instructor',
        TRUE
    );

-- Formaciones
INSERT INTO
    FORMACIONES (
        codigo,
        nombre,
        jornada,
        fecha_inicio,
        fecha_fin,
        activo
    )
VALUES
    (
        'ADSI-2025-01',
        'Análisis y Desarrollo de Sistemas de Información',
        'diurna',
        '2025-01-15',
        '2026-07-15',
        TRUE
    ),
    (
        'TEC-WEB-2025-01',
        'Tecnólogo en Desarrollo Web',
        'nocturna',
        '2025-02-01',
        '2026-08-01',
        TRUE
    ),
    (
        'TEC-REDES-2025-01',
        'Tecnólogo en Redes y Telecomunicaciones',
        'mixta',
        '2025-01-20',
        '2026-07-20',
        TRUE
    ),
    (
        'TEC-SOFT-2025-02',
        'Tecnólogo en Desarrollo de Software',
        'diurna',
        '2025-03-01',
        '2026-09-01',
        TRUE
    ),
    (
        'CONT-2025-01',
        'Tecnólogo en Contabilidad y Finanzas',
        'fin_de_semana',
        '2025-02-15',
        '2026-08-15',
        TRUE
    );

-- Ambientes
INSERT INTO
    AMBIENTES (
        numero_ambiente,
        nombre,
        capacidad,
        ubicacion,
        activo
    )
VALUES
    (
        'A-101',
        'Aula de Programación 1',
        30,
        'Edificio A - Piso 1',
        TRUE
    ),
    (
        'A-102',
        'Aula de Programación 2',
        30,
        'Edificio A - Piso 1',
        TRUE
    ),
    (
        'LAB-201',
        'Laboratorio de Redes',
        25,
        'Edificio B - Piso 2',
        TRUE
    ),
    (
        'LAB-202',
        'Laboratorio de Hardware',
        25,
        'Edificio B - Piso 2',
        TRUE
    ),
    (
        'A-301',
        'Aula Multimedia',
        40,
        'Edificio A - Piso 3',
        TRUE
    ),
    (
        'A-302',
        'Aula de Diseño',
        30,
        'Edificio A - Piso 3',
        TRUE
    );

-- Aprendices
INSERT INTO
    APRENDICES (
        documento,
        tipo_documento,
        nombres,
        apellidos,
        email,
        telefono,
        activo
    )
VALUES
    (
        '1005123456',
        'CC',
        'Juan Carlos',
        'Pérez Rodríguez',
        'juan.perez@misena.edu.co',
        '3201234567',
        TRUE
    ),
    (
        '1005234567',
        'CC',
        'Ana María',
        'García López',
        'ana.garcia@misena.edu.co',
        '3209876543',
        TRUE
    ),
    (
        '1005345678',
        'CC',
        'Luis Fernando',
        'Martínez Silva',
        'luis.martinez@misena.edu.co',
        '3207654321',
        TRUE
    ),
    (
        '1005456789',
        'CC',
        'Diana Carolina',
        'Rodríguez Gómez',
        'diana.rodriguez@misena.edu.co',
        '3205432109',
        TRUE
    ),
    (
        '1005567890',
        'CC',
        'Carlos Alberto',
        'López Hernández',
        'carlos.lopez@misena.edu.co',
        '3203210987',
        TRUE
    ),
    (
        '1005678901',
        'CC',
        'María Fernanda',
        'Sánchez Torres',
        'maria.sanchez@misena.edu.co',
        '3201098765',
        TRUE
    ),
    (
        '1005789012',
        'CC',
        'Jorge Andrés',
        'Ramírez Castro',
        'jorge.ramirez@misena.edu.co',
        '3208765432',
        TRUE
    ),
    (
        '1005890123',
        'CC',
        'Laura Sofía',
        'Díaz Moreno',
        'laura.diaz@misena.edu.co',
        '3206543210',
        TRUE
    ),
    (
        '1005901234',
        'CC',
        'David Santiago',
        'Torres Vargas',
        'david.torres@misena.edu.co',
        '3204321098',
        TRUE
    ),
    (
        '1006012345',
        'CC',
        'Valentina',
        'Gómez Jiménez',
        'valentina.gomez@misena.edu.co',
        '3202109876',
        TRUE
    ),
    (
        '1006123456',
        'TI',
        'Camilo Andrés',
        'Herrera Ruiz',
        'camilo.herrera@misena.edu.co',
        '3200987654',
        TRUE
    ),
    (
        '1006234567',
        'CC',
        'Daniela',
        'Castro Mendoza',
        'daniela.castro@misena.edu.co',
        '3208876543',
        TRUE
    ),
    (
        '1006345678',
        'CC',
        'Sebastián',
        'Morales Ortiz',
        'sebastian.morales@misena.edu.co',
        '3206765432',
        TRUE
    ),
    (
        '1006456789',
        'CC',
        'Isabella',
        'Jiménez Cruz',
        'isabella.jimenez@misena.edu.co',
        '3204654321',
        TRUE
    ),
    (
        '1006567890',
        'CC',
        'Mateo',
        'Vargas Reyes',
        'mateo.vargas@misena.edu.co',
        '3202543210',
        TRUE
    );

-- Asignación de instructores a formaciones
INSERT INTO
    INSTRUCTOR_FORMACION (
        instructor_id,
        formacion_id,
        fecha_asignacion,
        activo
    )
VALUES
    (1000000003, 1, '2025-01-15', TRUE), -- Carlos → ADSI
    (1000000004, 2, '2025-02-01', TRUE), -- Ana → Desarrollo Web
    (1000000005, 3, '2025-01-20', TRUE), -- Luis → Redes
    (1000000003, 4, '2025-03-01', TRUE), -- Carlos → Desarrollo Software
    (1000000004, 5, '2025-02-15', TRUE);

-- Ana → Contabilidad
-- Matricular aprendices en formaciones
INSERT INTO
    FORMACION_APRENDIZ (
        fk_formacion,
        fk_aprendiz,
        fecha_matricula,
        estado
    )
VALUES
    -- ADSI (5 aprendices)
    (1, 1, '2025-01-15', 'activo'),
    (1, 2, '2025-01-15', 'activo'),
    (1, 3, '2025-01-15', 'activo'),
    (1, 4, '2025-01-15', 'activo'),
    (1, 5, '2025-01-15', 'activo'),
    -- Desarrollo Web (5 aprendices)
    (2, 6, '2025-02-01', 'activo'),
    (2, 7, '2025-02-01', 'activo'),
    (2, 8, '2025-02-01', 'activo'),
    (2, 9, '2025-02-01', 'activo'),
    (2, 10, '2025-02-01', 'activo'),
    -- Redes (5 aprendices)
    (3, 11, '2025-01-20', 'activo'),
    (3, 12, '2025-01-20', 'activo'),
    (3, 13, '2025-01-20', 'activo'),
    (3, 14, '2025-01-20', 'activo'),
    (3, 15, '2025-01-20', 'activo');

-- Asignar ambientes a formaciones con horarios
INSERT INTO
    FORMACION_AMBIENTE (
        fk_formacion,
        fk_ambiente,
        dia_semana,
        hora_inicio,
        hora_fin
    )
VALUES
    -- ADSI en A-101, Lunes a Viernes
    (1, 1, 'lunes', '08:00:00', '12:00:00'),
    (1, 1, 'martes', '08:00:00', '12:00:00'),
    (1, 1, 'miercoles', '08:00:00', '12:00:00'),
    (1, 1, 'jueves', '08:00:00', '12:00:00'),
    (1, 1, 'viernes', '08:00:00', '12:00:00'),
    -- Desarrollo Web en A-102, Nocturna
    (2, 2, 'lunes', '18:00:00', '22:00:00'),
    (2, 2, 'miercoles', '18:00:00', '22:00:00'),
    (2, 2, 'viernes', '18:00:00', '22:00:00'),
    -- Redes en LAB-201
    (3, 3, 'lunes', '14:00:00', '18:00:00'),
    (3, 3, 'miercoles', '14:00:00', '18:00:00'),
    (3, 3, 'viernes', '14:00:00', '18:00:00');

-- Registros de asistencia de ejemplo
-- Asistencias del 12 de noviembre para ADSI
INSERT INTO
    ASISTENCIAS (
        fk_formacion,
        fk_aprendiz,
        fk_instructor,
        fk_ambiente,
        fecha,
        presente,
        observaciones
    )
VALUES
    (1, 1, 1000000003, 1, '2025-11-12', TRUE, NULL),
    (1, 2, 1000000003, 1, '2025-11-12', TRUE, NULL),
    (
        1,
        3,
        1000000003,
        1,
        '2025-11-12',
        FALSE,
        'Justificó por cita médica'
    ),
    (1, 4, 1000000003, 1, '2025-11-12', TRUE, NULL),
    (1, 5, 1000000003, 1, '2025-11-12', TRUE, NULL);

-- Asistencias del 12 de noviembre para Desarrollo Web
INSERT INTO
    ASISTENCIAS (
        fk_formacion,
        fk_aprendiz,
        fk_instructor,
        fk_ambiente,
        fecha,
        presente,
        observaciones
    )
VALUES
    (2, 6, 1000000004, 2, '2025-11-12', TRUE, NULL),
    (2, 7, 1000000004, 2, '2025-11-12', TRUE, NULL),
    (2, 8, 1000000004, 2, '2025-11-12', TRUE, NULL),
    (
        2,
        9,
        1000000004,
        2,
        '2025-11-12',
        FALSE,
        'Sin justificación'
    ),
    (2, 10, 1000000004, 2, '2025-11-12', TRUE, NULL);

-- Asistencias del 11 de noviembre para ADSI
INSERT INTO
    ASISTENCIAS (
        fk_formacion,
        fk_aprendiz,
        fk_instructor,
        fk_ambiente,
        fecha,
        presente,
        observaciones
    )
VALUES
    (1, 1, 1000000003, 1, '2025-11-11', TRUE, NULL),
    (1, 2, 1000000003, 1, '2025-11-11', TRUE, NULL),
    (1, 3, 1000000003, 1, '2025-11-11', TRUE, NULL),
    (
        1,
        4,
        1000000003,
        1,
        '2025-11-11',
        FALSE,
        'Calamidad familiar'
    ),
    (1, 5, 1000000003, 1, '2025-11-11', TRUE, NULL);

-- Configuraciones del sistema
INSERT INTO
    CONFIGURACIONES (clave, valor, descripcion)
VALUES
    (
        'porcentaje_minimo_asistencia',
        '70',
        'Porcentaje mínimo de asistencia para aprobar'
    ),
    (
        'hora_reporte_automatico',
        '18:00',
        'Hora de generación automática de reportes diarios'
    ),
    (
        'email_notificaciones',
        'notificaciones@sena.edu.co',
        'Email para envío de notificaciones'
    ),
    (
        'periodo_academico_actual',
        '2025-1',
        'Período académico en curso'
    ),
    (
        'max_faltas_consecutivas',
        '3',
        'Máximo de faltas consecutivas antes de alerta'
    ),
    (
        'google_spreadsheet_id',
        '',
        'ID de la hoja de Google Sheets para reportes'
    ),
    (
        'google_drive_folder_id',
        '',
        'ID de la carpeta de Google Drive para reportes'
    );

ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;