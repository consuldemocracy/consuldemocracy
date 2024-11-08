# Customizing images

If you want to overwrite any image, first you need to find out its filename, which will be located under `app/assets/images/`. For example, if you'd like to change the header logo (`app/assets/images/logo_header.png`), create another file with the exact same filename under the `app/assets/images/custom/` folder. Please note that, due to restrictions in the way Ruby on Rails loads images, **you will also have to rename the original file**. In the example, rename `app/assets/images/logo_header.png` to (for example) `app/assets/images/original_logo_header.png` and then create your custom image in `app/assets/images/custom/logo_header.png`.

The images and icons that you will most likely want to change are:

* `apple-touch-icon-200.png`
* `icon_home.png`
* `logo_email.png`
* `logo_header.png`
* `map.jpg`
* `social_media_icon.png`
* `social_media_icon_twitter.png`

Note that, instead of customizing the image using the method explained above, many of these images can be customized in the admin area, under the "Site content custom images" section.

## City Map

You'll find the city map at `/app/assets/images/map.jpg`. You can replace it with an image of your city districts, like this [map image example](https://github.com/consuldemocracy/consuldemocracy/blob/master/app/assets/images/map.jpg).

Afterwards, we recommend you use an online tool like <http://imagemap-generator.dariodomi.de/> or <https://www.image-map.net/> to generate the html coordinates to be able to generate an [image-map](https://www.w3schools.com/tags/tag_map.asp) for each of the districts. Those coordinates should be introduced on the respective geozones at the admin geozones panel (`/admin/geozones`).
