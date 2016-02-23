 @import "color_classifier.js";

 var createColorPalette = function(context) {

  classifier = new ColorClassifier();

	doc = context.document;
	var app = NSApplication.sharedApplication();
	var appController= app.delegate();

	width = 300;
	height = 65;

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

	var content = doc.currentPage().contentBounds();
	var content_x = content.origin.x
	var content_y = content.origin.y

	var margin = 100;

	var frame = artboard_palette.frame()
	frame.setX(content_x-(width + margin))
	frame.setY(content_y)
	frame.setWidth(width)

	frame.setHeight((height*palette.count()))
	[artboard_palette setName: 'ShareableColorPalette'];

	//Ads artboard to page
	doc.currentPage().addLayers([artboard_palette]);

	updateColorPalette(width,height);
}


function addColorGroup (color,height,width){
		//Create layer group

    var hexString = "#" + palette[color].hexValue();

    var namedColor = classifier.classify(hexString);
		var layergroup = [artboard_palette addLayerOfType: "group"];
    [layergroup setName: namedColor + ": " + hexString ];
    	layergroup.setIsLocked(true)

		//Create rectangle
  	colorbg = [layergroup addLayerOfType: "rectangle"];
    [colorbg setName: "background" + (color+1) ];

    	//Define size and position
    var rectframe = colorbg.frame()
		rectframe.setX(0)
		rectframe.setY(color*height)
		rectframe.setWidth(width)
		rectframe.setHeight(height)

  	//Add background color
  	var fill = colorbg.style().fills().addNewStylePart();
  	fill.color = MSColor.colorWithSVGString(hexString);

  	//Create text layer
  	var textlayer = [layergroup addLayerOfType: "text"];
  	[textlayer setName: namedColor + ": " + hexString ];

	//Defines center based on the rectangle
  	var rectmidx = [rectframe midX]
  	var rectmidy = [rectframe midY]

  	//Position
  	var textframe = textlayer.frame()
  	textframe.setMidX(rectmidx)
  	textframe.setMidY(rectmidy)

  	//Sets text visual properties
  	textlayer.stringValue = namedColor + ": " + hexString;
  	textlayer.setTextAlignment(2)
  	textlayer.setFontSize(14)

    //Sets text color depending on background: NOW WORKS AS EXPECTED BITCHES...
  	textlayer.setTextColor(MSColor.colorWithSVGString( contrastedColor(hexString) ));

  	//Resizes the layer group to fit the background and the text layers
  	layergroup.resizeToFitChildrenWithOption(1);

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

	artboard_palette.frame().setHeight((height*palette.count()))
}


/*
//Creates export but does not create a slice.
function makeExportable(layer){
	log('starslice')
	aslice= layer.slice()
	exportslice = aslice.exportOptions().addExportFormat()
	exportslice.setFileFormat('PDF')
	return aslice
}

function createSlice(context,layer){

	shareable_slice = MSSliceLayer.new();
	var frame = layer.absoluteRect().rect();

	makeExportable(shareable_slice);
	log('created a slice:'+ shareable_slice)

	doc.currentPage().addLayers([shareable_slice]);
}
*/

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


