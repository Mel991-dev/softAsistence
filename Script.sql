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
    ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;