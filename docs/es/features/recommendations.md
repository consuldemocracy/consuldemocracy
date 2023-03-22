# Recomendaciones de Debates y Propuestas

Para Debates y Propuestas los usuarios logueados pueden encontrar elementos recomendados usando el filtro de ordenación "Recomendaciones".

En este listado se muestran, ordenados por votos de forma descendiente, aquellos elementos que:

1. Tengan etiquetas que interesen al usuario. Siendo las etiquetas de su interés aquellas usadas en propuestas que ha seguido.
2. El usuario no sea el autor de los mismos.
3. Sólo en el caso de las propuestas: únicamente se muestran aquellas que aún no hayan llegado al umbral de votos requerido, ocultándose además aquellas que el usuario este siguiendo.

## Cómo probar la funcionalidad

En nuestra instalación en local, si no hemos iniciado sesión, podemos comprobar visitando http://localhost:3000/proposals que no aparece la opción de ordenación "Recomendaciones"

![Recommendations not logged in](../../img/recommendations/recommendations_not_logged_in.jpg)

Una vez iniciada sesión aparece el menú de ordenación, pero al no tener intereses nos muestra un mensaje "Sigue propuestas para que podamos darte recomendaciones" si lo visitamos en http://localhost:3000/proposals?locale=en&order=recommendations&page=1

![Recommendations no follows](../../img/recommendations/recommendations_no_follows.jpg)

Tras seguir una propuesta cualquiera con el botón de "Seguir propuesta ciudadana" que aparece en el menu lateral:

![Recommendations follow button](../../img/recommendations/recommendations_follow_button.jpg)

Podemos comprobar que tenemos recomendaciones:

![Recommendations with follows](../../img/recommendations/recommendations_with_follows.jpg)

La funcionalidad es similar en el menú de debates.
