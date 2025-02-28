# Base de Datos de DIVERMIND

La base de datos de **DIVERMIND** está diseñada para centralizar información sobre niños con necesidades especiales, sus familias, terapeutas, escuelas, centros de rehabilitación y otros actores clave. Utiliza una estructura jerárquica geográfica y una serie de tablas que permiten almacenar y gestionar la información de manera eficiente. A continuación, se describe la estructura y las relaciones de las tablas.

## Estructura General

### Tablas Geográficas
Estas tablas permiten almacenar información geográfica, jerarquizada en tres niveles:

- **Pais**: Almacena países, sus códigos ISO y prefijos telefónicos.
- **Region**: Relaciona las regiones con un país específico.
- **Comuna**: Relaciona las comunas con una región.

### Tablas de Direcciones e Imágenes
- **Direccion**: Almacena direcciones con detalles como calle, número, tipo de vivienda y relación con la comuna.
- **Imagen**: Centraliza las imágenes utilizadas en el sistema, como fotos de perfil, logos y documentos.

### Tabla de Usuarios
La tabla **Usuario** almacena información sobre los actores del sistema (padres, educadores, terapeutas, escuelas, centros de rehabilitación y familias) y sus roles. También contiene vínculos a la nacionalidad y la dirección del usuario.

### Tabla de Teléfonos
La tabla **Telefono** almacena números telefónicos, asociados a usuarios y/o niños, junto con el prefijo de país correspondiente.

### Entidades Institucionales
Estas tablas almacenan información sobre instituciones educativas y de rehabilitación, incluyendo universidades, escuelas y centros de rehabilitación. Cada entidad está asociada con un usuario institucional y tiene una dirección y un logo.

- **Universidad**
- **Escuela**
- **Centro_Rehabilitacion**

### Perfiles Específicos
Estas tablas permiten gestionar perfiles específicos para las familias, terapeutas y profesores asociados a los usuarios.

- **Familia**: Información sobre las familias vinculadas a los usuarios.
- **Terapeuta**: Información sobre los terapeutas, incluyendo especialidad y certificaciones.
- **Profesor**: Información sobre los profesores asociados a las escuelas.

### Perfil del Niño
La tabla **Nino** almacena información detallada sobre los niños, como su nombre, fecha de nacimiento, necesidades especiales, vínculo con la familia, nacionalidad y dirección.

## Relaciones Entre Tablas

- **Usuarios** tienen una relación con las tablas **Direccion**, **Pais**, y **Telefono**.
- **Niños** están vinculados con la **Familia**, **Pais**, **Direccion**, e **Imagen**.
- **Instituciones** como universidades, escuelas y centros de rehabilitación están asociadas con las **Comuna** y **Usuario** correspondiente.
- **Terapeutas**, **Familias**, y **Profesores** están relacionados con los **Usuarios** correspondientes.

## Propósito
La base de datos de **DIVERMIND** busca centralizar toda la información relevante sobre los niños con necesidades especiales, facilitando la comunicación entre familias, terapeutas, educadores y otras instituciones para mejorar el seguimiento, la educación y la rehabilitación de los niños.

## colores asociados
https://paletton.com/#uid=13u0u0kbdWv00++5AZTg1QTkdHY
