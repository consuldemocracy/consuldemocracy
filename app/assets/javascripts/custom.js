// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consul/consul/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consul/consul/blob/master/CUSTOMIZE_ES.md#javascript
//

function SearchFunction(){
    search = document.getElementById("users-search-form");
    console.log(search.value);
    data = document.getElementById("span_tags");
    console.log(data.innerText);
    if (search.value == data.innerText) {
        data.style.setProperty('background-color', 'red');
    } else {
        data.style.setProperty('background-color', 'green');
    }

}