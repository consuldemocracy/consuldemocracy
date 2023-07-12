# Images

If you want to overwrite any image, firstly you need to find out the filename, and by default it will be located under `app/assets/images`. For example if you want to change the header logo (`app/assets/images/logo_header.png`) you must create another file with the exact same file name under `app/assets/images/custom` folder. The images and icons that you will most likely want to change are:

* apple-touch-icon-200.png
* icon_home.png
* logo_email.png
* logo_header.png
* map.jpg
* social_media_icon.png
* social_media_icon_twitter.png

## City Map

You'll find the city map at [`/app/assets/images/map.jpg`](https://github.com/consuldemocracy/consuldemocracy/blob/master/app/assets/images/map.jpg), just replace it with an image of your cities districts ([example](https://github.com/ayuntamientomadrid/consul/blob/master/app/assets/images/map.jpg)).

Afterwards we recommend you to use an online tool like <http://imagemap-generator.dariodomi.de/> or <https://www.image-map.net/> to generate the html coordinates to be able to generate a [image-map](https://www.w3schools.com/tags/tag_map.asp) for each of the districts. Those coordinates should be introduced on the respective Geozones at the admin geozones panel (`/admin/geozones`).
