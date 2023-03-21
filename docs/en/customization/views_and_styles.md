# Views & Styles

## Views (HTML)

If you want to change any page HTML  you can just find the correct file under the `app/views` folder and put a copy at `app/views/custom` keeping as well any sub-folder structure, and then apply your customizations. For example if you want to customize `app/views/pages/conditions.html` you'll have to make a copy at `app/views/custom/pages/conditions.html.erb` (note the `pages` subdirectory).

## CSS Styles with SASS

In order to make changes to any CSS selector (custom style sheets), you can add them directly at `app/assets/stylesheets/custom.scss`. For example to change the header color (`.top-links`) you can just add:

```css
.top-links {
  background: red;
}
```

If you want to change any [foundation](http://foundation.zurb.com/) variable, you can do it at the `app/assets/stylesheets/_custom_settings.scss` file. For example to change the main application color just add:

```css
$brand:             #446336;
```

We use [SASS, with SCSS syntax](http://sass-lang.com/guide) as CSS preprocessor.

Also you can check your scss files syntax with

```bash
scss-lint
```

## Accessibility

To maintain accessibility level, if you add new colors use a [Color contrast checker](http://webaim.org/resources/contrastchecker/) (WCAG AA is mandatory, WCAG AAA is recommended).
