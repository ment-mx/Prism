 @import "color_classifier.js";

 var generateSASS = function(context)
{

  // Save panel settings
    var savePanel = NSSavePanel.savePanel();
    savePanel.setNameFieldStringValue("_colors.scss");
    savePanel.setAllowedFileTypes([@"scss"]);
    savePanel.setAllowsOtherFileTypes(false);
    savePanel.setExtensionHidden(false);

    // Open save dialog and run if Save was clicked
    if (savePanel.runModal()) {

      // Get Colors
      var colors = context.document.documentData().assets().primitiveColors();
      var palette = colors.array();

      // Convert MSColors into hex strings
      var classifier = new ColorClassifier();

      var sass_colors = [];
      for (var i = 0; i < palette.count(); i++) {
        const hexString = "#" + palette[i].hexValue();
        const namedColor = classifier.classify(hexString);
        const sassVariableName = "$"+ namedColor.toLowerCase().split(" ").join("-");

        //Count repeated
        var rep = 0;
        for (var j = 0; j < sass_colors.length; j++)
        {
          if (sass_colors[j].startsWith(sassVariableName)) rep++;
        }

        const line = sassVariableName + (rep > 0 ? rep : "") + ": " + hexString + ";";
        sass_colors.push(line);

      }

      var fileString = NSString.stringWithString(sass_colors.join("\n"));

      // Get chosen file path
      var filePath = savePanel.URL().path();

      // Request permission to write for App Store version of Sketch
      [fileString writeToFile:filePath atomically:true encoding:NSUTF8StringEncoding error:null];


    }

}
