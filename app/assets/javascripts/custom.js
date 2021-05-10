// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consul/consul/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consul/consul/blob/master/CUSTOMIZE_ES.md#javascript
//

function SearchFunction(){
    search = document.getElementById("users-search-form");
    var searchValue = search.value;
    var searchLower = searchValue.toLowerCase();

    spanTags = document.querySelectorAll('#span_tags');
    var i;
    for (i = 0; i < spanTags.length; ++i) {
      var dataValue = spanTags[i].innerText;
      dataLower = dataValue.toLowerCase();
      if (dataLower.includes(searchLower)) {
        spanTags[i].style.display = '';
      } else {
        spanTags[i].style.display = 'none';
      }
    }
}

function toggleSelect() {
  var x = document.getElementById("hidden-select");
  if (x.style.display === "none") {
    x.style.display = "block";
  } else {
    x.style.display = "none";
  }
}