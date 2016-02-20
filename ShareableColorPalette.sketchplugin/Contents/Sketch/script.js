 var createColorPalette = function(context) {
	doc = context.document;
	var app = NSApplication.sharedApplication();
	var appController= app.delegate();

	width =300;
	height=65;

	//Get document colors array
	colors = doc.documentData().assets().primitiveColors();
	palette = colors.array(); 
	palette_exists=false;

	//Gets array of artboards
	artboards = doc.currentPage().artboards()

	//Run only if there are colors
	if (colors.count() > 0) {

		searchPalette();

		if (palette_exists==true){
			updateColorPalette(width,height);
		}
		else {
			addArtboard(context,width,height);
		}
	}
}

function searchPalette(){

	//Searches for the ShareableColorPalette in the artboards array
	for (var i = 0; i < artboards.count(); i++) {
		 if ([[artboards objectAtIndex:i]name]=="ShareableColorPalette"){
		 	artboard_palette = [artboards objectAtIndex:i];
		 	palette_exists=true;
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
		var layergroup = [artboard_palette addLayerOfType: "group"];
    	[layergroup setName: "#" + palette[color].hexValue() ];
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
    	fill.color = MSColor.colorWithSVGString("#" + palette[color].hexValue());

    	//Create text layer 
    	var textlayer = [layergroup addLayerOfType: "text"];
    	[textlayer setName: "#" + palette[color].hexValue() ];

		//Defines center based on the rectangle 
    	var rectmidx = [rectframe midX]
    	var rectmidy = [rectframe midY]
    	
    	//Position
    	var textframe = textlayer.frame()
    	textframe.setMidX(rectmidx)
    	textframe.setMidY(rectmidy)

    	//Sets text visual properties
    	textlayer.stringValue = "#" + palette[color].hexValue();
    	textlayer.setTextAlignment(2)
    	textlayer.setFontSize(14)

    	//Sets text color depending on backgrouwn   *does not work as expected*
    	bgcolor = MSColor.colorWithSVGString("#" + palette[color].hexValue())

	    	if (bgcolor.isWhite() == 1){
	    		var textcolor= "000000"
	    	}
	    	else if (bgcolor.isBlack() == 1){
	    		 var textcolor= "ffffff"
	    	}
	    	else {
	    		var textcolor= "222222"
	    	}

    	textlayer.setTextColor(MSColor.colorWithSVGString("#" + textcolor));

    	//Resizes the layer group to fit the background and the text layers
    	layergroup.resizeToFitChildrenWithOption(1);

  return;
}

function updateColorPalette(width,height){
	var layer = [artboard_palette layers]
	layers = layer.array();
	
	//Removes layers in the ShareableColorPalette artboard
		if (layers.count()>0){
			for (var i=1; i<(layers.count()+i); i++){
			var parent = [[layer objectAtIndex:0] parentGroup];
  			if (parent)[parent removeLayer: [layer objectAtIndex:0]];
		}
	}
	
	//Creates color group for each color in the Documents Colors array and sets artboard size
	for (var i = 0; i < palette.count(); i++) {
		addColorGroup(i,height,width);
			};
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

