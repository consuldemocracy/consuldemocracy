// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consul/consul/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consul/consul/blob/master/CUSTOMIZE_ES.md#javascript
//
//

// figura = document.querySelector('.figura_uno');

// figura.addEventListener('click', (event) => { 
//     alert('pulsado');
// });

document.addEventListener("DOMContentLoaded", function(event) {

    //CAROUSEL
    console.log("DOM fully loaded and parsed");
    const carouselImages = document.querySelector('.carousel__images');
    const carouselButtons = document.querySelectorAll('.carousel__button');
    const numberOfImages = document.querySelectorAll('#figura').length;
    //console.log(numberOfImages);
    let imageIndex = 1;
    let translateX = 0;
    
    carouselButtons.forEach(button => {
      button.addEventListener('click', (event) => {
        if (event.target.id === 'previous') {
          if (imageIndex !== 1) {
            imageIndex--;
            translateX += 400;
          }
        } else {
          if (imageIndex !== numberOfImages) {
            imageIndex++;
            translateX -= 400;
          }
        }
        
        carouselImages.style.transform = `translateX(${translateX}px)`;
      });
    });

    //FAQ
    $('.answer').hide();
    $('#preguntas h2').click(function () {
        if ($(this).next('.answer').is(':hidden')){
            $(this).next('.answer').show();
        }else{
            $(this).next('.answer').hide();
        }

    });
  });