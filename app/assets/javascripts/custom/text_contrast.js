function getContrastYIQ(hexcolor) {
        hexcolor = hexcolor.replace("#", "");
        var r = parseInt(hexcolor.substr(0, 2), 16);
        var g = parseInt(hexcolor.substr(2, 2), 16);
        var b = parseInt(hexcolor.substr(4, 2), 16);
        var yiq = ((r*299)+(g*587)+(b*114))/1000;
        return (yiq >= 128) ? 'black' : 'white';
    }

    document.addEventListener("DOMContentLoaded", function() {
        var root = document.documentElement;
        var bgColor = getComputedStyle(root).getPropertyValue('--background-color').trim();
        var textColor = getContrastYIQ(bgColor);
        root.style.setProperty('--text-color', textColor);
    });
