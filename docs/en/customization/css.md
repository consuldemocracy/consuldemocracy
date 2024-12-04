# Customizing styles with CSS

Consul Democracy uses stylesheets written using [Sass](http://sass-lang.com/guide) with the SCSS syntax and placed under the `app/assets/stylesheets/` folder.

In order to make changes to styles, you can add them directly to a file under `app/assets/stylesheets/custom/`. Alternatively, you can use the `app/assets/stylesheets/custom.scss` file.

For example, to change the margin of the footer, create an `app/assets/stylesheets/custom/layout.scss` file with the following content:

```scss
.footer {
  margin-top: $line-height;
}
```

This will overwrite the `margin-top` property applied to the `.footer` selector.

Note that CSS precedence rules still apply, so if there's a rule defining the `margin-top` property for the `body .footer` selector, the code above will be ignored. So, to effectively overwrite properties for certain elements, use the exact same selector used in the original code.

## Sass variables

Consul Democracy uses variables and functions defined by the [Foundation framework](http://foundation.zurb.com/) and adds a few other variables. In order to overwrite these variables, use the `app/assets/stylesheets/_consul_custom_overrides.scss` file. For example, to change the background color of the footer, add:

```scss
$footer: #fdfdfd;
```

The variables you can override are defined in the `_settings.scss` and `_consul_settings.scss` files.

To define new variables, you can use the `app/assets/stylesheets/_custom_settings.scss` file.

## CSS variables

In multi-tenant applications, Sass variables have a limitation: their value will be the same for every tenant.

So, for the most commonly customized colors, Consul Democracy provides CSS variables, which allow you to define different colors for different tenants.

For example, you can customize the brand, buttons, links and main layout colors for just the main tenant with:

```scss
.tenant-public {
  --anchor-color: #372;
  --anchor-color-hover: #137;
  --brand: #153;
  --brand-secondary: #134a00;
  --button-background-hover: #fa0;
  --button-background-hover-contrast: #{$black};
  --footer: #e6e6e6;
  --main-header: #351;
  --top-links: var(--main-header);
  --subnavigation: #ffd;
}
```

Check the `app/assets/stylesheets/custom/tenants.scss` file for more information.

## Accessibility

To maintain an appropriate accessibility level, if you add new colors, use a [Color contrast checker](http://webaim.org/resources/contrastchecker/) (WCAG AA is mandatory, WCAG AAA is recommended).
