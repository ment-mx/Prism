var ab=false;
var createColorPalette = function(context) {
	doc = context.document;
	var app = NSApplication.sharedApplication();
	var appController= app.delegate();


	//Get document colors array
	var colors = doc.documentData().assets().primitiveColors();
		palette = colors.array(); 

	//Run only if there are colors
	if (colors.count() > 0) {

			addArtboard();
	
	}
}

var addArtboard =function (context) {

	//Creates a new arboard
	artboard_palette = MSArtboardGroup.new();

	frame = artboard_palette.frame()
	frame.setX(-200)
	frame.setY(0)
	frame.setWidth(300)
	frame.setHeight((65*palette.count()))
	[artboard_palette setName: 'ShareableColorPalette'];
	doc.currentPage().addLayers([artboard_palette]);
		
	makeExportable();
	updateColorPalette();

}


var addColorGroup = function (color,height,width){
		//Create layer group
		var layergroup = [artboard_palette addLayerOfType: "group"];
    	[layergroup setName: (color+1) + ".- #" + palette[color].hexValue() ];


		//Create rectangle 
  		var colorbg = [layergroup addLayerOfType: "rectangle"];
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

function makeExportable(){
	slice = artboard_palette.exportOptions().addExportFormat()
	slice.setFileFormat('PDF')
	return slice
}

function updateColorPalette(){

	//Creates color group for each color in the Documents Colors array and sets artboard size
	for (i = 0; i < palette.count(); i++) {
		addColorGroup(i,65,300);
			};

	frame.setHeight((65*palette.count()))
}
