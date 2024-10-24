# Customizing views and HTML

Just like most Ruby on Rails application, Consul Democracy uses ERB templates to render HTML. These templates are traditionally placed in the `app/views/` folder.

Unlike [Ruby code](models.md), [CSS code](css.md) or [JavaScript code](javascript.md), it isn't possible to overwrite only certain parts of an ERB template. So, in order to customize a view, find the correct file under the `app/views/` folder and copy it to `app/views/custom/`, keeping as well any sub-folder structure, and then apply your customizations. For example, to customize `app/views/welcome/index.html.erb`, copy it to `app/views/custom/welcome/index.html.erb`.

In order to keep track of your custom changes, when using git, we recommend copying the original file to the custom folder in one commit (without any modifications) and then modifying the custom file in a different commit. When upgrading to a new version of Consul Democracy, this will make it easier to check the differences between the view in the old version of Consul Democracy, the view in the new version of Consul Democracy, and your custom changes.

As mentioned earlier, the custom file will completely overwrite the original one. This means that, when upgrading to a new version of Consul Democracy, the changes in the original file will be ignored. You'll have to check the changes in the original file and apply them to your custom file if appropriate.

**Note**: Consul Democracy only uses the `app/views/` folder for code written before 2021. Code written since then is placed under the `app/components/` folder. The main reason is that components allow extracting some of the logic to a Ruby file, and maintaining custom Ruby code is easier than maintaining custom ERB code.
