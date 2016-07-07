<p align="center">
  <img src="http://198.199.69.85/prism/logo.png" style="width: 100%; max-width:800px;" />
</p>

|  [Download][] | [Features][] | [Usage][] | [Customization][] | [Changelog][] | [Next][] | [Contribute][] | [Credits][] | [Donate][] |
|---|---|---|---|---|---|---|---|---|---|

<p align="center">
  <img src="http://198.199.69.85/prism/ClassicSample.png" style="width: 100%; max-width:800px;" />
</p>

_(Formerly **ShareableColorPalette**)_

Creates a beautiful artboard with all the colors in your 'Document Colors' with its respective color label in a variety of formats.  _(Sketch 3.8.3+)_ 

***


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
  <img src="http://198.199.69.85/prism/CreatePalette.gif" style="width: 100%; max-width:800px;" />
</p>

<h4>Changing a Color Alias</h4>

To change the color alias, just change the text on the *Name* layer. If you want the default color name, just delete the text on that same layer. 

<p align="center">
  <img src="http://198.199.69.85/prism/changealias.gif" style="width: 100%; max-width:800px;" />
</p>

<h4>Exporting Colors as Code</h4>

1. Select the colors you want to export *(optional)*
2. Click Export Selected Colors **[ctrl cmd s]** or Export All Colors **[ctrl cmd e]**
3. Select the format to export. 
4. Save your color code file or copy the colors to clipboard. 

<p align="center">
  <img src="http://198.199.69.85/prism/ExportColorCode.gif" style="width: 100%; max-width:800px;" />
</p>

<h2>Customization</h2>
Under the Prism menu, there's an option called **Show Template File...** that opens the Template.sketch file located under the Prism.sketchplugin package, this file contains the all the layers that are used as templates and are later copied over to your palette. 

<h4>Changing Palette Template</h4>
The template file is a normal sketch file that has multiple pages, each page with its own cell Template, you can add or remove all the pages you want to manage your own templates, to select the style you want just open the file and save it on the page your desired template is. Now just generate your palette to see the changes.

<p align="center">
  <img src="http://198.199.69.85/prism/ChangeTemplate.gif" style="width: 100%; max-width:800px;" />
</p>
  
<h4>Editing Template</h4>
Prism offers a lot of freedom to let you customize your own templates, however, in order for your template to play nicely with Prism you just have a few restrictions:
* Your template page must have only one artboard layer that is exactly named "Prism Palette", users can then change the name of the artboard once the palatte is generated in their sketch files. Your cell doesn't have to be inside this artboard, but it would be good practice, as future releases may use this cell-inside-arboard to specify the spacing between cells.
* Your template **must** have a layer group named exactly "Cell", everything that your cell includes must be inside this group, you can then go ahead and add as many groups as you like inside of it ;)
* Inside the "Cell" group there must be a layer named exactly "Color", it must have at least one solid Fill and this fill must be on the bottom of all the other fills, this layer is the one that Prism uses to display the real color.
* Inside the "Cell" group there must be a **text** layer named exactly "Name" (lol), this is the layer that Prism uses to display the automatic name and can be edited to add or remove aliases.
* Prism uses the name of the text layers to format the color of the cell, for example: if there's a text layer named "RGBA_CSS" , prism will try set the layer's text value to the specified format. this format must be specified and implemented inside the `ColorFormatter.coffee` file. Here is the "RGBA_CSS" format specification:

_ColorFormatter.coffee_ This is where the format is registered
```coffeescript
  # This is were formats are registered, the ID must be unique, the name is a human readable mini description, the format is used to use a custom file extension when saving colors to a file
  FORMATS: [
    { id: "HEX", name: "HEX CSS", format: "colors.css" }
    { id: "RGBA_CSS", name: "RGBA CSS", format: "colors.css" }
    { id: "SASS", name: "SASS variables", format: "_colors.scss" }
    { id: "UICOLOR_SWIFT", name: "UIColor (Swift)", format: "colors.swift" }
    { id: "UICOLOR_OBJC", name: "UIColor (Objective-C)", format: "colors.m" }
    { id: "ANDROID", name: "Android ARGB Color", format: "colors.java" }
  ]
```

Then implement it in the same file
```coffeescript
  ###
    HERE is when you have to do the implementation of the new format you want to add.
    all these methods must be prefixed with "format_" and then the format ID specified in the FORMATS array
    The commented flag is used to add comments (like when we export colors)
    or removing them (like when we are populating the cell layers with color data)
    
    the color variable that is passed is a dictionary with all the information you need:
      name: the default name of the color or the alias if it exists
      hex: color's hex value without the leading '#'
      red: color's red value from 0 to 1
      blue: color's blue value from 0 to 1
      green: color's green value from 0 to 1
      alpha: color's alpha value from 0 to 1
  ###
  format_RGBA_CSS: (color, commented) ->
    alpha = if color.alpha < 1
      color.alpha.toFixed(2)
    else
      color.alpha
    formattedColor = "rgba(#{Math.round(color.red * 255)},#{Math.round(color.green * 255)},#{Math.round(color.blue * 255)},#{alpha});"
    if commented
      "#{formattedColor} /* #{color.name} */"
    else
      formattedColor
```
You can have as many text layers for formats as you want. Also, layers can be locked or invisible as long as they conform to this restrictions.

<p align="center">
  <img src="http://198.199.69.85/prism/EditTemplate.gif" style="width: 100%; max-width:800px;" />
</p>

If you wanna dive deeper on this process, you should check out the `Cell.coffee` and `Template.coffee` files.


<h2>Contribute</h2>
The best way to get things done is by doing them yourself, if you want to specify a format or a add a new feature or fix a bug, just submit a pull request!

I have included a `compile.sh` file that automatically compiles all the files inside the src/ folder into the build/ folder, however, if you add new files you must import them in the right order inside the `Prism.cocoascript` file.
You can run the compile.sh file by typing this in the terminal inside the Prism.sketchplugin/Content/Sketch folder:
```shell
  ./compile.sh
```
This will compile your files as soon as they are saved, as long as the process is running. To stop the process just `Ctrl-C` out of it ;)


<h2>What's next</h2>
* Gradients support
* Better template selection


<h2>Credits</h2>
- [Adrxx](https://github.com/Adrxx) & [L__A__L__O](https://github.com/L__A__L__O): **Creators**
- Special thanks to [Gauth](http://gauth.fr/2011/09/get-a-color-name-from-any-rgb-combination/) for his color classifier and dataset. 

[Download]:https://github.com/LaloMrtnz/Prism/archive/1.0.zip
[Features]:https://github.com/LaloMrtnz/Prism#features
[Usage]:https://github.com/LaloMrtnz/Prism#usage
[Customization]:https://github.com/LaloMrtnz/Prism#customization
[Changelog]:https://github.com/LaloMrtnz/Prism/releases
[Next]:https://github.com/LaloMrtnz/Prism#whats-next
[Contribute]:https://github.com/LaloMrtnz/Prism#contribute
[Credits]:https://github.com/LaloMrtnz/Prism#credits
[Donate]:https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QBFHGZHWJNLEG

