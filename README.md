<p align="center">
  <img src="http://www.ment.com.mx/prism/logo.png" style="width: 100%; max-width:800px;" />
</p>

|  [Download][] | [Features][] | [Usage][] | [Customization][] | [Changelog][] | [Next][] | [Contribute][] | [Credits][] |

<p align="center">
  <img src="http://www.ment.com.mx/prism/ClassicSample.png" style="width: 100%; max-width:800px;" />
</p>

_(Formerly **ShareableColorPalette**)_

Creates a beautiful artboard with all the colors in your 'Document Colors' with its respective color label in a variety of formats.  _(Sketch **41**)_

**Important: Make sure to download version 1.0.3 to use Sketch 45 plugin auto updates.** 😎





******


<h2>Features</h2>

* Beautiful color palette generation.
* Automatic color naming.
* Fully customizable.
* Export as code in a variety of formats (CSS, SASS variables, Swift, etc).
* Color renaming (Alias).
* Rebuilt from the ground up using `Coffeescript` and love.



<h2>Usage</h2>

1. Install plugin.
2. Add your colors to your *Document Colors*.
3. Run command **[ctrl cmd c]**.
4. Voilà!

<p align="center">
  <img src="http://www.ment.com.mx/prism/CreatePalette.gif" style="width: 100%; max-width:800px;" />
</p>

<h4>Changing a Color Alias</h4>

To change the color alias, just change the text on the *Name* layer. If you want the default color name, just delete the text on that same layer.

<p align="center">
  <img src="http://www.ment.com.mx/prism/changealias.gif" style="width: 100%; max-width:800px;" />
</p>

<h4>Exporting Colors as Code</h4>

1. Select the colors you want to export *(optional)*
2. Click Export Selected Colors **[ctrl cmd s]** or Export All Colors **[ctrl cmd e]**
3. Select the format to export.
4. Save your color code file or copy the colors to clipboard.

<p align="center">
  <img src="http://www.ment.com.mx/prism/ExportColorCode.gif" style="width: 100%; max-width:800px;" />
</p>

<h2>Customization</h2>
Under the Prism menu, there's an option called **Show Template File...** that opens the Template.sketch file located under the Prism.sketchplugin package, this file contains the all the layers that are used as templates and are later copied over to your palette.

<h4>Changing Palette Template</h4>
The template file is a normal sketch file that has multiple pages, each page with its own cell Template, you can add or remove all the pages you want to manage your own templates, to select the style you want just open the file and save it on the page your desired template is. Now just generate your palette to see the changes.

<p align="center">
  <img src="http://www.ment.com.mx/prism/ChangeTemplate.gif" style="width: 100%; max-width:800px;" />
</p>

<h4>Editing Template</h4>

Prism offers a lot of freedom to let you customize your own templates, however, in order for your template to play nicely with Prism you just have a few restrictions:
* Your template page must have only one artboard layer that is exactly named "Prism Palette", users can then change the name of the artboard once the palatte is generated in their sketch files. Your cell doesn't have to be inside this artboard, but it would be good practice, as future releases may use this cell-inside-artboard to specify the spacing between cells.
* Your template **must** have a layer group named exactly "Cell", everything that your cell includes must be inside this group, you can then go ahead and add as many groups as you like inside of it ;)
* Inside the "Cell" group there must be a layer named exactly "Color", it must have at least one solid Fill and this fill must be on the bottom of all the other fills, this layer is the one that Prism uses to display the real color.
* Inside the "Cell" group there must be a **text** layer named exactly "Name" (lol), this is the layer that Prism uses to display the automatic name and can be edited to add or remove aliases.
* Prism uses the name of the text layers to format the color of the cell, for example: if there's a text layer named "RGBA_CSS" , prism will try set the layer's text value to the specified format.


You can have as many text layers for formats as you want. Also, layers can be locked or invisible as long as they conform to this restrictions.

<p align="center">
  <img src="http://www.ment.com.mx/prism/EditTemplate.gif" style="width: 100%; max-width:800px;" />
</p>

If you wanna dive deeper on this process, you should check out the `Cell.coffee` and `Template.coffee` files.


<h2>Contribute</h2>
The best way to get things done is by doing them yourself, if you want to specify a format or a add a new feature or fix a bug, just submit a pull request!

I have included a `compile.sh` file that automatically compiles all the files inside the src/ folder into the build/ folder, however, if you add new files you must import them in the right order inside the `Prism.cocoascript` file.

*You will need coffescript v1 for the plugin to work as v1 compiles to EC5 syntax accepted by cocoascript*

You can easily install it with npm by running this:
`npm install --global coffeescript@1.12.7`

You can then run the compile.sh file by typing this in the terminal inside the Prism.sketchplugin/Content/Sketch folder:
```shell
  ./compile.sh
```
<h2>What's next</h2>

* Gradients support
* Better template selection


<h2>Credits</h2>

- [Lalo](https://github.com/LaloMrtnz) & [Adrxx](https://github.com/Adrxx): **Creators**
- Special thanks to [Gauth](http://gauth.fr/2011/09/get-a-color-name-from-any-rgb-combination/) for his color classifier and dataset.

[Download]:https://github.com/ment-mx/Prism/archive/master.zip
[Features]:https://github.com/LaloMrtnz/Prism#features
[Usage]:https://github.com/LaloMrtnz/Prism#usage
[Customization]:https://github.com/LaloMrtnz/Prism#customization
[Changelog]:https://github.com/LaloMrtnz/Prism/releases
[Next]:https://github.com/LaloMrtnz/Prism#whats-next
[Contribute]:https://github.com/LaloMrtnz/Prism#contribute
[Credits]:https://github.com/LaloMrtnz/Prism#credits
