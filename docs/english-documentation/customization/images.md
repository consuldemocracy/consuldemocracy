# Images

If you want to overwrite any image, firstly you need to findout the filename, and by defaul it will be located under `app/assets/images`. For example if you want to change the header logo \(`app/assets/images/logo_header.png`\) you must create another file with the exact same file name under `app/assets/images/custom` folder. The images and icons that you will most likely want to change are:

* apple-touch-icon-200.png
* icon\_home.png
* logo\_email.png
* logo\_header.png
* map.jpg
* social\_media\_icon.png
* social\_media\_icon\_twitter.png

## City Map

You'll find the city map at [`/app/assets/images/map.jpg`](https://github.com/consul/consul/blob/master/app/assets/images/map.jpg), just replace it with an image of your cities districts \([example](https://github.com/ayuntamientomadrid/consul/blob/master/app/assets/images/map.jpg)\).

Afterwards we recommend you to use an online tool like [http://imagemap-generator.dariodomi.de/](http://imagemap-generator.dariodomi.de/) or [https://www.image-map.net/](https://www.image-map.net/) to generate the html coordinates to be able to generate a [image-map](https://www.w3schools.com/tags/tag_map.asp) for each of the districts. Those coordinates should be introduced on the respective Geozones at the admin geozones panel \(`/admin/geozones`\)

