# Recomendaciones

Para Debates y Propuestas los usuarios logueados pueden encontrar elementos recomendados usando el filtro de ordenación "Recomendaciones".

En este listado se muestran, ordenados por votos de forma descendiente, aquellos elementos que: 1. Tengan etiquetas que interesen al usuario. Siendo las etiquetas de su interés aquellas usadas en propuestas que ha seguido. 2. El usuario no sea el autor de los mismos. 3. Sólo en el caso de las propuestas: únicamente se muestran aquellas que aún no hayan llegado al umbral de votos requerido, ocultándose además aquellas que el usuario este siguiendo.

## Cómo probar la funcionalidad

En nuestra instalación en local, si no hemos iniciado sesión, podemos comprobar visitando [http://localhost:3000/proposals](http://localhost:3000/proposals) que no aparece la opción de ordenación "Recomendaciones"

![Recommendations not logged in](../../.gitbook/assets/recommendations_not_logged_in%20%281%29.jpg)

Una vez iniciada sesión aparece el menú de ordenación, pero al no tener intereses nos muestra un mensaje "Sigue propuestas para que podamos darte recomendaciones" si lo visitamos en [http://localhost:3000/proposals?locale=en&order=recommendations&page=1](http://localhost:3000/proposals?locale=en&order=recommendations&page=1)

![Recommendations no follows](../../.gitbook/assets/recommendations_no_follows%20%281%29.jpg)

Tras seguir una propuesta cualquiera con el botón de "Seguir propuesta ciudadana" que aparece en el menu lateral:

![Recommendations follow button](../../.gitbook/assets/recommendations_follow_button%20%281%29.jpg)

Podemos comprobar que tenemos recomendaciones:

![Recommendations with follows](../../.gitbook/assets/recommendations_with_follows%20%281%29.jpg)

La funcionalidad es similar en el menú de debates.

