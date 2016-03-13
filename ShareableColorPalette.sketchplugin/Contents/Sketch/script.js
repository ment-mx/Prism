 @import "color_classifier.js";

 var createColorPalette = function(context) {

  classifier = new ColorClassifier();

	doc = context.document;
	var app = NSApplication.sharedApplication();
	var appController= app.delegate();

	width = 200;
	height = 200;
	color_margin= 35;

	//Get document colors array
	colors = doc.documentData().assets().primitiveColors();
	palette = colors.array();

	//Gets array of artboards
	artboards = doc.currentPage().artboards()

	//Run only if there are colors
	if (colors.count() > 0) {

		if ( paletteExists() ){
			updateColorPalette(width,height);
		}
		else {
			addArtboard(context,width,height);
		}

	}

}

function paletteExists(){
	//Searches for the ShareableColorPalette in the artboards array
	for (var i = 0; i < artboards.count(); i++) {
		 if ([[artboards objectAtIndex:i] name] == "ShareableColorPalette"){
		 	artboard_palette = [artboards objectAtIndex:i];
		 	return true;
		 }
	}
}

function addArtboard(context,width,height) {
	//Creates a new arboard
	artboard_palette = MSArtboardGroup.new();

	//Gets all the other layers bounds
	var content = doc.currentPage().contentBounds();
	var content_x = content.origin.x
	var content_y = content.origin.y
	var margin = 200;

	//Sets Artboard Frame
	var frame = artboard_palette.frame()
	frame.setX(content_x)
	frame.setY(content_y-(height + margin))
	frame.setWidth(((width+color_margin)*palette.count())+ color_margin)

	//Sets Arboard Background Color 
	artboard_palette.hasBackgroundColor= true
	artboard_palette.backgroundColor = MSColor.colorWithRed_green_blue_alpha(.95, .95, .95, 1)

	[artboard_palette setName: 'ShareableColorPalette'];

	//Ads artboard to page
	doc.currentPage().addLayers([artboard_palette]);
	updateColorPalette(width,height);
}
function getColorStringWithAlpha(color){

      var red = Math.round(color.red() * 255)
      var green = Math.round(color.green() * 255)
      var blue = Math.round(color.blue() * 255)
      var alpha = color.alpha()
      return ("rgba(" + red + ", " + green + ", " + blue + ", " + alpha + ")")
}

function addColorGroup (color,height,width){

	//Create layer group
    var hexString = "#" + palette[color].hexValue()
   	var rgbaString = getColorStringWithAlpha(palette[color])

    var namedColor = classifier.classify(hexString);
	var layergroup = [artboard_palette addLayerOfType: "group"];
    [layergroup setName: namedColor + ": " + hexString ];
    layergroup.setIsLocked(true)

    //Adds shadow to the group
  	var groupshadow = layergroup.style().shadows().addNewStylePart();
  	groupshadow.offsetX = 0
  	groupshadow.offsetY = 3
  	groupshadow.blurRadius = 6
  	groupshadow.spread = 0
  	groupshadow.color = MSColor.colorWithRed_green_blue_alpha(0,0,0.0,0.25)

	//Create color rectangle
  	var colorbg = [layergroup addLayerOfType: "rectangle"];
    [colorbg setName: "" + " " +hexString ]

    //Define size and position
    var rectframe = colorbg.frame()

		rectframe.setWidth(width)
		rectframe.setHeight(height)
		rectframe.setY(color_margin)
		rectframe.setX(color*(width + color_margin)+color_margin)

  	//Add background color
  	var colorbgfill = colorbg.style().fills().addNewStylePart();
  	colorbgfill.color = MSColor.colorWithSVGString(hexString);
	
  	//Create data group
  	var datagroup = [layergroup addLayerOfType: "group"];
    [datagroup setName: hexString ]

    //Text layers Background
	var textbg = [datagroup addLayerOfType: "rectangle"];
    [textbg setName: "Data Background " + (color+1)]

    var textbgframe = textbg.frame()
		textbgframe.setWidth(width)
		textbgframe.setY([rectframe y] + [rectframe height])
		textbgframe.setX([rectframe x])

  	//Add data background color
  	var textbgfill = textbg.style().fills().addNewStylePart();
  	textbgfill.color = MSColor.colorWithSVGString("#ffffff");

    //Named Color Text Layer
	var namedLayer = newTextLayer(datagroup, namedColor, colorbg, 11, 15, namedColor, 0, 16,"Helvetica-Bold","#000000")

	//Hex Color Text Layer
	var hexLayer = newTextLayer(datagroup, hexString, namedLayer, 3, 0, hexString, 0, 13, "Helvetica-Oblique", "#444444")

	//RGB Color Text Layer
	var rgbLayer = newTextLayer(datagroup, rgbaString, hexLayer, 3, 0 , rgbaString, 0, 14, "Helvetica-Oblique", "#444444" )
	var rgbframe = rgbLayer.frame()

	//Sets Text Background Height
	textbgframe.setHeight(([rgbframe y]+[rgbframe height]) - ([rectframe y] + [rectframe height])+ 14)

  	//Resizes the layer group to fit the background and the text layers
  	layergroup.resizeToFitChildrenWithOption(1);
  	datagroup.resizeToFitChildrenWithOption(1);

  	//Sets group height to adapt artboard
	colorGroupHeight = ([textbgframe height] + [rectframe height])
}

function newTextLayer(parent, name, aligner, margintop, marginleft, text, textalignment, fontsize, fontname, fontcolor){

  	//Creates new layer & appends it to parent
  	var newlayer = [parent addLayerOfType: "text"];
  	[newlayer setName: name ];

  	//Positions based on aligner
  	var alignerframe = aligner.frame()

  	var layerframe = newlayer.frame()
  	layerframe.setX([alignerframe x] + marginleft)
  	layerframe.setY([alignerframe y] + [alignerframe height] + margintop)

  	//Sets text visual properties
  	newlayer.stringValue = text;
  	newlayer.setTextAlignment(textalignment)
  	newlayer.setFontSize(fontsize)
  	newlayer.setFontPostscriptName(fontname)
  	newlayer.setTextColor(MSColor.colorWithSVGString(fontcolor ));
  	return newlayer

    //Sets text color depending on background: NOW WORKS AS EXPECTED BITCHES...
  	//textlayer.setTextColor(MSColor.colorWithSVGString( contrastedColor(hexString) ));
  	}

function updateColorPalette(width,height){
	var layer = [artboard_palette layers]
	layers = layer.array();

	//Removes layers in the ShareableColorPalette artboard
		if (layers.count()>0){
			for (var i=1; i < (layers.count()+i) ; i++){
			var parent = [[layer objectAtIndex:0] parentGroup];
  			if (parent)[parent removeLayer: [layer objectAtIndex:0]];
		}
	}

	//Creates color group for each color in the Documents Colors array and sets artboard size
	for (var i = 0; i < palette.count(); i++) {
		addColorGroup(i,height,width);
	}

	var artPalette = artboard_palette.frame()
	artPalette.setWidth(((width+color_margin)*palette.count())+ color_margin)
	artPalette.setHeight((colorGroupHeight +( 2*color_margin)))
}
/*
//Takes BG color and makes it to a contrasted readable color
function contrastedColor(col) {

  // GET COLOR RGB
  var c = col.substring(1);    // strip #
  var rgb = parseInt(c, 16);   // convert rrggbb to decimal
  var r = (rgb >> 16) & 0xff;  // extract red
  var g = (rgb >>  8) & 0xff;  // extract green
  var b = (rgb >>  0) & 0xff;  // extract blue

  //GET LUMA
  var luma = 0.2126 * r + 0.7152 * g + 0.0722 * b; // per ITU-R BT.709

  // DEFINES DE AMOUNT OF DARKENING OR LIGHTENING WHEN CONTRASTING COLOR
  const intensity = 80;
  //MIN LUM TO BE CONSIDERED A LIGHT COLOR
  const lumaThreshold = 55;
  var amt = intensity * ((luma < lumaThreshold) ? 1 : -1);

  // DARKEN LIGHTEN
  var usePound = false;

  if (col[0] == "#") {
      col = col.slice(1);
      usePound = true;
  }

  var num = parseInt(col,16);

  var r = (num >> 16) + amt;

  if (r > 255) r = 255;
  else if  (r < 0) r = 0;

  var b = ((num >> 8) & 0x00FF) + amt;

  if (b > 255) b = 255;
  else if  (b < 0) b = 0;

  var g = (num & 0x0000FF) + amt;

  if (g > 255) g = 255;
  else if (g < 0) g = 0;

  return (usePound?"#":"") + (g | (b << 8) | (r << 16)).toString(16);

}
*/