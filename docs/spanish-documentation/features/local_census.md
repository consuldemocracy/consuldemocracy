# Local Census

Proporcionar a los usuarios administradores una forma de gestionar la base de datos del censo local a través del panel de administración **Configuración &gt; Gestionar censo local**. Actualmente la única manera de manipular los registros de esta tabla es a través de la consola de rails.

Permitir a los usuarios de administradores gestionar esta tabla de dos maneras diferentes:

* **Manualmente**: uno por uno a través de una interfaz CRUD.
* **Automáticamente**: a través de un proceso de importación.

## Manualmente

Provide a way to manage local census records to administrator users through administration interface.

* Página de censo local

  ![Manage local census](../../.gitbook/assets/manage-local-census-es.png)

* Añadir un nuevo registro

  ![Create local census record](../../.gitbook/assets/add-local-census-record-es.png)

Funcionalidades:

1. Búsqueda por número\_de\_documento: Como local\_census\_records podría contener muchos registros, hemos añadido una función de búsqueda para permitir a los administradores encontrar los registros existentes por número de documento.
2. Evitar la introducción de registros duplicados: Se ha añadido una validación de modelo al siguiente par de atributos \[:número\_de\_documento, :tipo\_de\_documento\]

## Automáticamente

Permite a los usuarios administradores importar registros del censo local a través de un archivo CSV.

* Página de censo local ![Manage local census csv](../../.gitbook/assets/manage-local-census-csv-en.png)
* Página para importar un CSV ![Create local census records csv](../../.gitbook/assets/add-local-census-records-csv-en%20%281%29.png)

