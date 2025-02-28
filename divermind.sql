-- phpMyAdmin SQL Dump
-- version 5.2.1deb3
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 19-02-2025 a las 20:27:19
-- Versión del servidor: 8.0.41-0ubuntu0.24.04.1
-- Versión de PHP: 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `esquemadivermind`
--

-- --------------------------------------------------------
-- Tablas Geográficas (Jerarquía: Pais -> Region -> Comuna)
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Pais (
    id_pais INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    codigo_iso CHAR(2) DEFAULT NULL,
    prefijo_telefono VARCHAR(10) DEFAULT NULL COMMENT 'Prefijo telefónico del país'
) COMMENT 'Almacena países para ubicaciones geográficas y prefijos telefónicos';

CREATE TABLE IF NOT EXISTS Region (
    id_region INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    id_pais INT NOT NULL,
    FOREIGN KEY (id_pais) REFERENCES Pais(id_pais)
) COMMENT 'Regiones asociadas a un país';

CREATE TABLE IF NOT EXISTS Comuna (
    id_comuna INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    id_region INT NOT NULL,
    FOREIGN KEY (id_region) REFERENCES Region(id_region)
) COMMENT 'Comunas asociadas a una región';

-- --------------------------------------------------------
-- Tabla Direccion (Centralizada)
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Direccion (
    id_direccion INT PRIMARY KEY AUTO_INCREMENT,
    calle VARCHAR(255) NOT NULL COMMENT 'Nombre de la calle',
    numero VARCHAR(20) NOT NULL COMMENT 'Número de la dirección',
    tipo_vivienda ENUM('casa', 'departamento', 'oficina', 'otro') DEFAULT 'casa' COMMENT 'Tipo de vivienda',
    bloque VARCHAR(20) DEFAULT NULL COMMENT 'Bloque (opcional, para departamentos)',
    departamento VARCHAR(20) DEFAULT NULL COMMENT 'Número de departamento (opcional)',
    id_comuna INT NOT NULL COMMENT 'Relación con la comuna',
    FOREIGN KEY (id_comuna) REFERENCES Comuna(id_comuna)
) COMMENT 'Centraliza todas las direcciones del sistema';

-- --------------------------------------------------------
-- Tabla Imagen (Centralizada)
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Imagen (
    id_imagen INT PRIMARY KEY AUTO_INCREMENT,
    ruta_archivo VARCHAR(255) NOT NULL,
    tipo ENUM('logo', 'perfil', 'documento', 'otro') DEFAULT 'otro',
    fecha_subida DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Centraliza todas las imágenes del sistema';

-- --------------------------------------------------------
-- Tabla Usuario (Base para todos los actores del sistema)
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Usuario (
    usuario_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol ENUM('padre', 'educador', 'terapeuta', 'escuela', 'centro_rehabilitacion', 'familia') NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    id_pais INT DEFAULT NULL COMMENT 'Nacionalidad del usuario',
    id_direccion INT DEFAULT NULL COMMENT 'Dirección del usuario',
    FOREIGN KEY (id_pais) REFERENCES Pais(id_pais),
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion)
) COMMENT 'Usuarios del sistema con roles ampliados y nacionalidad';

-- --------------------------------------------------------
-- Tabla Telefono (Relación solo con Usuario)
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Telefono (
    id_telefono INT PRIMARY KEY AUTO_INCREMENT,
    numero VARCHAR(20) NOT NULL,
    id_pais INT NOT NULL COMMENT 'Prefijo del país',
    id_usuario INT NOT NULL COMMENT 'Vínculo con usuario (padre o responsable)',
    FOREIGN KEY (id_pais) REFERENCES Pais(id_pais),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(usuario_id)
) COMMENT 'Almacena números de teléfono con prefijo de país';

-- --------------------------------------------------------
-- Entidades Institucionales (Dependen de Comuna y Usuario)
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Universidad (
    id_universidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(200) NOT NULL,
    id_comuna INT NOT NULL,
    usuario_id INT NOT NULL COMMENT 'Vinculación con usuario de tipo "centro_rehabilitacion"',
    id_imagen_logo INT DEFAULT NULL,
    website VARCHAR(255) DEFAULT NULL,
    id_direccion INT DEFAULT NULL COMMENT 'Dirección de la universidad',
    FOREIGN KEY (id_comuna) REFERENCES Comuna(id_comuna),
    FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    FOREIGN KEY (id_imagen_logo) REFERENCES Imagen(id_imagen),
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion)
) COMMENT 'Universidades vinculadas a un usuario institucional';

CREATE TABLE IF NOT EXISTS Escuela (
    id_escuela INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    id_comuna INT NOT NULL,
    usuario_id INT NOT NULL COMMENT 'Vinculación con usuario de tipo "escuela"',
    id_imagen_logo INT DEFAULT NULL,
    id_direccion INT DEFAULT NULL COMMENT 'Dirección de la escuela',
    FOREIGN KEY (id_comuna) REFERENCES Comuna(id_comuna),
    FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    FOREIGN KEY (id_imagen_logo) REFERENCES Imagen(id_imagen),
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion)
) COMMENT 'Escuelas vinculadas a un usuario institucional';

CREATE TABLE IF NOT EXISTS Centro_Rehabilitacion (
    id_centro INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    id_comuna INT NOT NULL,
    usuario_id INT NOT NULL COMMENT 'Vinculación con usuario de tipo "centro_rehabilitacion"',
    direccion VARCHAR(255) DEFAULT NULL,
    id_imagen_logo INT DEFAULT NULL,
    id_direccion INT DEFAULT NULL COMMENT 'Dirección del centro de rehabilitación',
    FOREIGN KEY (id_comuna) REFERENCES Comuna(id_comuna),
    FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    FOREIGN KEY (id_imagen_logo) REFERENCES Imagen(id_imagen),
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion)
) COMMENT 'Centros de rehabilitación institucionales';

-- --------------------------------------------------------
-- Perfiles Específicos (Dependen de Usuario)
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Familia (
    id_familia INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL COMMENT 'Usuario de tipo "familia"',
    id_imagen_perfil INT DEFAULT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    FOREIGN KEY (id_imagen_perfil) REFERENCES Imagen(id_imagen)
) COMMENT 'Familias vinculadas a un usuario';

CREATE TABLE IF NOT EXISTS Terapeuta (
    id_terapeuta INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL UNIQUE COMMENT 'Usuario de tipo "terapeuta"',
    especialidad VARCHAR(100) DEFAULT NULL,
    fecha_graduacion DATE DEFAULT NULL,
    certificaciones TEXT,
    id_imagen_perfil INT DEFAULT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    FOREIGN KEY (id_imagen_perfil) REFERENCES Imagen(id_imagen)
) COMMENT 'Terapeutas sin redundancia de datos personales';

CREATE TABLE IF NOT EXISTS Profesor (
    id_profesor INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL UNIQUE COMMENT 'Usuario de tipo "educador"',
    id_escuela INT NOT NULL,
    fecha_contratacion DATE DEFAULT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    FOREIGN KEY (id_escuela) REFERENCES Escuela(id_escuela)
) COMMENT 'Profesores vinculados a escuelas';

-- --------------------------------------------------------
-- Perfil del Niño (Integración de Perfil_Personal y Nino)
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Nino (
    id_nino INT PRIMARY KEY AUTO_INCREMENT,
    rut VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    lugar_nacimiento VARCHAR(100) DEFAULT NULL,
    id_imagen_perfil INT DEFAULT NULL,
    necesidades_especiales TEXT,
    id_familia INT NOT NULL,
    id_pais INT DEFAULT NULL COMMENT 'Nacionalidad del niño',
    id_direccion INT DEFAULT NULL COMMENT 'Dirección del niño',
    FOREIGN KEY (id_familia) REFERENCES Familia(id_familia),
    FOREIGN KEY (id_imagen_perfil) REFERENCES Imagen(id_imagen),
    FOREIGN KEY (id_pais) REFERENCES Pais(id_pais),
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion)
) COMMENT 'Información consolidada del niño y su familia';

-- --------------------------------------------------------
-- Tablas de Seguimiento del Niño
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Hitos_Desarrollo (
    id_hito INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    fecha DATE NOT NULL,
    categoria ENUM('comunicacion', 'social', 'academico', 'terapeutico') NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Registra hitos importantes en el desarrollo del niño';

CREATE TABLE IF NOT EXISTS Progreso_Comunicacion (
    id_progreso INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    fecha DATE NOT NULL,
    tipo ENUM('palabra_nueva', 'frase', 'conversacion') NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Seguimiento de habilidades de comunicación del niño';

CREATE TABLE IF NOT EXISTS Habilidades_Sociales (
    id_habilidad INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    fecha DATE NOT NULL,
    nivel ENUM('inicial', 'intermedio', 'avanzado') NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Registra avances en habilidades sociales del niño';

CREATE TABLE IF NOT EXISTS Autismo (
    id_autismo INT PRIMARY KEY AUTO_INCREMENT,
    nivel ENUM('leve', 'moderado', 'severo') NOT NULL,
    descripcion TEXT,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Niveles de autismo asociados a niños';

CREATE TABLE IF NOT EXISTS Contacto_Emergencia (
    id_contacto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    relacion VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Contactos de emergencia para niños';

CREATE TABLE IF NOT EXISTS Debilidades (
    id_debilidad INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    categoria ENUM('sensorial', 'comunicacion', 'emocional', 'otros') DEFAULT NULL,
    nivel ENUM('leve', 'moderado', 'severo') DEFAULT NULL,
    observaciones TEXT,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Áreas de dificultad del niño';

CREATE TABLE IF NOT EXISTS Detonantes_Crisis (
    id_detonante INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Factores desencadenantes de crisis';

CREATE TABLE IF NOT EXISTS Diagnostico (
    id_diagnostico INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    fecha_diagnostico DATE NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Diagnósticos médicos asociados a niños';

CREATE TABLE IF NOT EXISTS Documento (
    id_documento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    archivo VARCHAR(255) NOT NULL,
    tipo ENUM('informe', 'imagen', 'video', 'pdf') DEFAULT NULL,
    fecha_subida DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Documentos relacionados con niños';

CREATE TABLE IF NOT EXISTS Estado_Posterior_Crisis (
    id_estado_posterior INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Estado del niño después de una crisis';

CREATE TABLE IF NOT EXISTS Evaluacion_TEA (
    id_evaluacion INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    id_nino INT NOT NULL,
    id_terapeuta INT NOT NULL,
    id_profesor INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino),
    FOREIGN KEY (id_terapeuta) REFERENCES Terapeuta(id_terapeuta),
    FOREIGN KEY (id_profesor) REFERENCES Profesor(id_profesor)
) COMMENT 'Evaluaciones periódicas del niño';

CREATE TABLE IF NOT EXISTS Gustos_Intereses (
    id_gusto_interes INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Gustos e intereses de los niños';

CREATE TABLE IF NOT EXISTS Historial_Medico (
    id_historial INT PRIMARY KEY AUTO_INCREMENT,
    descripcion TEXT NOT NULL,
    fecha DATE NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Historial médico de los niños';

-- --------------------------------------------------------
-- Tablas de Planificaciones
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Planificacion_Terapeutica (
    id_planificacion INT PRIMARY KEY AUTO_INCREMENT,
    objetivo TEXT NOT NULL,
    actividad TEXT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE DEFAULT NULL,
    estado ENUM('pendiente', 'en_progreso', 'completado') DEFAULT 'pendiente',
    id_nino INT NOT NULL,
    id_terapeuta INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino),
    FOREIGN KEY (id_terapeuta) REFERENCES Terapeuta(id_terapeuta)
) COMMENT 'Planificaciones terapéuticas para el niño';

CREATE TABLE IF NOT EXISTS Planificacion_Academica (
    id_planificacion INT PRIMARY KEY AUTO_INCREMENT,
    objetivo TEXT NOT NULL,
    actividad TEXT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE DEFAULT NULL,
    estado ENUM('pendiente', 'en_progreso', 'completado') DEFAULT 'pendiente',
    id_nino INT NOT NULL,
    id_profesor INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino),
    FOREIGN KEY (id_profesor) REFERENCES Profesor(id_profesor)
) COMMENT 'Planificaciones académicas para el niño';

-- --------------------------------------------------------
-- Tablas de Comentarios y Notificaciones
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Comentarios (
    id_comentario INT PRIMARY KEY AUTO_INCREMENT,
    contenido TEXT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL,
    id_nino INT NOT NULL,
    id_comentario_padre INT DEFAULT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(usuario_id),
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino),
    FOREIGN KEY (id_comentario_padre) REFERENCES Comentarios(id_comentario)
) COMMENT 'Almacena comentarios y respuestas en hilos';

CREATE TABLE IF NOT EXISTS Permisos_Comentarios (
    id_permiso INT PRIMARY KEY AUTO_INCREMENT,
    id_familia INT NOT NULL,
    id_nino INT NOT NULL,
    fecha_autorizacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_familia) REFERENCES Familia(id_familia),
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Controla qué familiares pueden comentar';

CREATE TABLE IF NOT EXISTS Notificaciones (
    id_notificacion INT PRIMARY KEY AUTO_INCREMENT,
    mensaje TEXT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    leida BOOLEAN DEFAULT FALSE,
    id_usuario INT NOT NULL,
    id_comentario INT DEFAULT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(usuario_id),
    FOREIGN KEY (id_comentario) REFERENCES Comentarios(id_comentario)
) COMMENT 'Registra notificaciones para usuarios';

-- --------------------------------------------------------
-- Tablas de Logs y Auditoría
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS logs_ip (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ip_publica VARCHAR(45) DEFAULT NULL UNIQUE,
    ip_privada VARCHAR(45) DEFAULT NULL,
    geo_localizacion VARCHAR(100) DEFAULT NULL
) COMMENT 'Registro de direcciones IP';

CREATE TABLE IF NOT EXISTS logs_peticion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id INT DEFAULT NULL,
    ip_id INT DEFAULT NULL,
    endpoint VARCHAR(255) DEFAULT NULL,
    metodo_http VARCHAR(10) DEFAULT NULL,
    FOREIGN KEY (usuario_id) REFERENCES Usuario(usuario_id),
    FOREIGN KEY (ip_id) REFERENCES logs_ip(id)
) COMMENT 'Registro de peticiones realizadas por los usuarios';

CREATE TABLE IF NOT EXISTS logs_detalles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    log_id INT DEFAULT NULL,
    navegador VARCHAR(255) DEFAULT NULL,
    sistema_operativo VARCHAR(100) DEFAULT NULL,
    dispositivo VARCHAR(50) DEFAULT NULL,
    FOREIGN KEY (log_id) REFERENCES logs_peticion(id) ON DELETE CASCADE
) COMMENT 'Detalles adicionales de las peticiones (navegador, SO, dispositivo)';

CREATE TABLE IF NOT EXISTS logs_errores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    log_id INT DEFAULT NULL,
    mensaje_error TEXT,
    codigo_respuesta INT DEFAULT NULL,
    FOREIGN KEY (log_id) REFERENCES logs_peticion(id) ON DELETE CASCADE
) COMMENT 'Registro de errores ocurridos durante las peticiones';

CREATE TABLE IF NOT EXISTS logs_sql (
    id INT PRIMARY KEY AUTO_INCREMENT,
    log_id INT DEFAULT NULL,
    query_sql TEXT,
    parametros TEXT,
    tabla_afectada VARCHAR(100) DEFAULT NULL,
    fila_afectada INT DEFAULT NULL,
    FOREIGN KEY (log_id) REFERENCES logs_peticion(id) ON DELETE CASCADE
) COMMENT 'Registro de consultas SQL ejecutadas en el sistema';

-- --------------------------------------------------------
-- Tablas de Acceso Compartido
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Acceso_Compartido (
    id_acceso INT PRIMARY KEY AUTO_INCREMENT,
    codigo_qr VARCHAR(255) DEFAULT NULL,
    enlace_unico VARCHAR(255) DEFAULT NULL,
    fecha_creacion DATETIME NOT NULL,
    fecha_expiracion DATETIME DEFAULT NULL,
    id_nino INT DEFAULT NULL,
    id_familia INT DEFAULT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino),
    FOREIGN KEY (id_familia) REFERENCES Familia(id_familia)
) COMMENT 'Gestiona el acceso compartido a la información de un niño';

CREATE TABLE IF NOT EXISTS Permiso_Acceso (
    id_permiso INT PRIMARY KEY AUTO_INCREMENT,
    id_acceso INT DEFAULT NULL,
    tipo_permiso ENUM('lectura', 'edicion') DEFAULT NULL,
    FOREIGN KEY (id_acceso) REFERENCES Acceso_Compartido(id_acceso)
) COMMENT 'Define los permisos de acceso (lectura/edición)';

-- --------------------------------------------------------
-- Tablas de Medicamentos
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Medicamento (
    id_medicamento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    dosis VARCHAR(50) NOT NULL,
    id_nino INT NOT NULL,
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Medicamentos recetados a niños';

CREATE TABLE IF NOT EXISTS Horario_Medicamento (
    id_horario INT PRIMARY KEY AUTO_INCREMENT,
    id_medicamento INT NOT NULL,
    hora TIME NOT NULL,
    frecuencia ENUM('diario', 'semanal', 'mensual') DEFAULT NULL,
    FOREIGN KEY (id_medicamento) REFERENCES Medicamento(id_medicamento)
) COMMENT 'Horarios de administración de medicamentos';

-- --------------------------------------------------------
-- Tablas de Preguntas y Respuestas
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Pregunta (
    id_pregunta INT PRIMARY KEY AUTO_INCREMENT,
    texto_pregunta TEXT NOT NULL,
    tipo ENUM('OPCION', 'RESPUESTA', 'AUDIO') NOT NULL,
    audio VARCHAR(255) DEFAULT NULL,
    id_terapeuta INT DEFAULT NULL,
    FOREIGN KEY (id_terapeuta) REFERENCES Terapeuta(id_terapeuta)
) COMMENT 'Preguntas utilizadas en evaluaciones';

CREATE TABLE IF NOT EXISTS Opcion_Pregunta (
    id_opcion INT PRIMARY KEY AUTO_INCREMENT,
    texto_opcion TEXT NOT NULL,
    id_pregunta INT DEFAULT NULL,
    FOREIGN KEY (id_pregunta) REFERENCES Pregunta(id_pregunta)
) COMMENT 'Opciones para preguntas de tipo OPCION';

CREATE TABLE IF NOT EXISTS Respuesta (
    id_respuesta INT PRIMARY KEY AUTO_INCREMENT,
    texto_respuesta TEXT,
    id_pregunta INT DEFAULT NULL,
    id_nino INT DEFAULT NULL,
    FOREIGN KEY (id_pregunta) REFERENCES Pregunta(id_pregunta),
    FOREIGN KEY (id_nino) REFERENCES Nino(id_nino)
) COMMENT 'Respuestas a preguntas de evaluaciones';

-- --------------------------------------------------------
-- Tablas de Entrevistas (Modelo EAV para respuestas)
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS Entrevistas (
    id_entrevista BIGINT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    nino_id BIGINT NOT NULL,
    terapeuta_id BIGINT NOT NULL,
    tipo ENUM('inicial', 'seguimiento', 'crisis') NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (nino_id) REFERENCES Nino(id_nino),
    FOREIGN KEY (terapeuta_id) REFERENCES Terapeuta(id_terapeuta)
) COMMENT 'Entrevistas realizadas a los niños';

CREATE TABLE IF NOT EXISTS Preguntas_Entrevista (
    id_pregunta BIGINT PRIMARY KEY AUTO_INCREMENT,
    texto TEXT NOT NULL,
    tipo_respuesta ENUM(
        'texto', 
        'escala_numerica', 
        'escala_visual', 
        'opcion_unica', 
        'opcion_multiple', 
        'verdadero_falso', 
        'imagen', 
        'multimedia', 
        'tiempo', 
        'frecuencia'
    ) NOT NULL,
    opciones JSON COMMENT 'Opciones para escalas/opciones'
) COMMENT 'Preguntas para entrevistas';

CREATE TABLE IF NOT EXISTS Opciones_Pregunta_Entrevista (
    id_opcion BIGINT PRIMARY KEY AUTO_INCREMENT,
    pregunta_id BIGINT NOT NULL,
    valor VARCHAR(100) NOT NULL,
    icono VARCHAR(100) COMMENT 'Ruta de imagen para escalas visuales',
    FOREIGN KEY (pregunta_id) REFERENCES Preguntas_Entrevista(id_pregunta)
) COMMENT 'Opciones predefinidas para preguntas';

CREATE TABLE IF NOT EXISTS Respuestas_Entrevista (
    id_respuesta BIGINT PRIMARY KEY AUTO_INCREMENT,
    entrevista_id BIGINT NOT NULL,
    pregunta_id BIGINT NOT NULL,
    FOREIGN KEY (entrevista_id) REFERENCES Entrevistas(id_entrevista),
    FOREIGN KEY (pregunta_id) REFERENCES Preguntas_Entrevista(id_pregunta)
) COMMENT 'Respuestas genéricas de entrevistas';

-- Subtipos de Respuestas (Modelo EAV)
CREATE TABLE IF NOT EXISTS Respuestas_Texto_Entrevista (
    respuesta_id BIGINT PRIMARY KEY,
    contenido TEXT NOT NULL,
    FOREIGN KEY (respuesta_id) REFERENCES Respuestas_Entrevista(id_respuesta)
) COMMENT 'Respuestas de texto libre';

CREATE TABLE IF NOT EXISTS Respuestas_Escala_Numerica_Entrevista (
    respuesta_id BIGINT PRIMARY KEY,
    valor INT NOT NULL CHECK (valor BETWEEN 1 AND 10),
    FOREIGN KEY (respuesta_id) REFERENCES Respuestas_Entrevista(id_respuesta)
) COMMENT 'Respuestas de escala numérica';

CREATE TABLE IF NOT EXISTS Respuestas_Escala_Visual_Entrevista (
    respuesta_id BIGINT PRIMARY KEY,
    opcion_id BIGINT NOT NULL,
    FOREIGN KEY (respuesta_id) REFERENCES Respuestas_Entrevista(id_respuesta),
    FOREIGN KEY (opcion_id) REFERENCES Opciones_Pregunta_Entrevista(id_opcion)
) COMMENT 'Respuestas de escala visual';

CREATE TABLE IF NOT EXISTS Respuestas_Opcion_Unica_Entrevista (
    respuesta_id BIGINT PRIMARY KEY,
    opcion_id BIGINT NOT NULL,
    FOREIGN KEY (respuesta_id) REFERENCES Respuestas_Entrevista(id_respuesta),
    FOREIGN KEY (opcion_id) REFERENCES Opciones_Pregunta_Entrevista(id_opcion)
) COMMENT 'Respuestas de opción única';

CREATE TABLE IF NOT EXISTS Respuestas_Opcion_Multiple_Entrevista (
    respuesta_id BIGINT,
    opcion_id BIGINT NOT NULL,
    PRIMARY KEY (respuesta_id, opcion_id),
    FOREIGN KEY (respuesta_id) REFERENCES Respuestas_Entrevista(id_respuesta),
    FOREIGN KEY (opcion_id) REFERENCES Opciones_Pregunta_Entrevista(id_opcion)
) COMMENT 'Respuestas de opción múltiple';

CREATE TABLE IF NOT EXISTS Respuestas_Booleana_Entrevista (
    respuesta_id BIGINT PRIMARY KEY,
    valor BOOLEAN NOT NULL,
    FOREIGN KEY (respuesta_id) REFERENCES Respuestas_Entrevista(id_respuesta)
) COMMENT 'Respuestas verdadero/falso';

CREATE TABLE IF NOT EXISTS Respuestas_Multimedia_Entrevista (
    respuesta_id BIGINT PRIMARY KEY,
    ruta_archivo VARCHAR(255) NOT NULL,
    tipo ENUM('audio', 'video') NOT NULL,
    FOREIGN KEY (respuesta_id) REFERENCES Respuestas_Entrevista(id_respuesta)
) COMMENT 'Respuestas multimedia';

CREATE TABLE IF NOT EXISTS Respuestas_Tiempo_Entrevista (
    respuesta_id BIGINT PRIMARY KEY,
    segundos INT NOT NULL,
    FOREIGN KEY (respuesta_id) REFERENCES Respuestas_Entrevista(id_respuesta)
) COMMENT 'Respuestas de tiempo/duración';

CREATE TABLE IF NOT EXISTS Respuestas_Frecuencia_Entrevista (
    respuesta_id BIGINT PRIMARY KEY,
    conteo INT NOT NULL,
    FOREIGN KEY (respuesta_id) REFERENCES Respuestas_Entrevista(id_respuesta)
) COMMENT 'Respuestas de frecuencia';

-- --------------------------------------------------------
-- Fin del esquema
-- --------------------------------------------------------

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;