 @import "color_classifier.js";

//=========================================
// Constants
//=========================================

const width = 200
const height = 200
const colorMargin = 35
const artboardMargin = 60
const colorsPerRow = 4

//=========================================
// Main flow
//=========================================

var startColorPalette = function(context) {

  classifier = new ColorClassifier()

  doc = context.document
  var app = NSApplication.sharedApplication()
  var appController= app.delegate()

	//Get document colors array
	colors = doc.documentData().assets().primitiveColors()
	palette = colors.array()

	//Gets array of artboards
	artboards = doc.currentPage().artboards()

  //If there are colors.
	if (colors.count() > 0) {

 	 //Generates Artboard if doesn't exist
 	 if ( !paletteExists() ) {

 	  	generateArtboard()
 	 }
		updateArtboard()

	} else {
    app.displayDialog_withTitle("Drag the colors you want to the Document Colors palette and then run the command [ctrl + cmd + c]" , "No colors to create Shareable Color Palette®")
  }

}

function generateArtboard() {
  //Creates a new arboard
  artboard_palette = MSArtboardGroup.new()

  //Gets all the other layers bounds
  var content = doc.currentPage().contentBounds()
  var content_x = content.origin.x
  var content_y = content.origin.y

  //Set Artboard Position and Size
  artboard_palette.frame().setX(content_x - artboardMargin)
  artboard_palette.frame().setY(content_y)

  //Sets Arboard Background Color
  artboard_palette.hasBackgroundColor= true
  artboard_palette.backgroundColor = MSColor.colorWithRed_green_blue_alpha(.95, .95, .95, 1)

  [artboard_palette setName: 'ShareableColorPalette']

  //Ads artboard to page
  doc.currentPage().addLayers([artboard_palette])
}

function updateArtboard() {

  var layer = [artboard_palette layers]
  layers = layer.array()

  //Removes layers in the ShareableColorPalette artboard
  if (layers.count() > 0) {
    for (var i = 1; i < (layers.count()+i); i++) {
      var parent = [[layer objectAtIndex:0] parentGroup]
      if (parent) {
        [parent removeLayer: [layer objectAtIndex:0]]
      }
    }
  }

  //Creates color group for each color in the Documents Colors array and sets artboard size
  for (var i = 0; i < palette.count(); i++) {
    addColorGroup(i)
  }

  updateArboardSize()
}

//=========================================
// HELPERS
//=========================================

function addColorGroup (color){

  //Create layer group
  var hexString = "#" + palette[color].hexValue()
  var rgbaString = getColorStringWithAlpha(palette[color])

  var namedColor = classifier.classify(hexString)
  layergroup = MSLayerGroup.new()
  [layergroup setName: namedColor + ": " + hexString ]
  layergroup.setIsLocked(true)

  //Adds shadow to the group
  var groupshadow = layergroup.style().addStylePartOfType(2)
  groupshadow.offsetX = 0
  groupshadow.offsetY = 3
  groupshadow.blurRadius = 6
  groupshadow.spread = 0
  groupshadow.color = MSColor.colorWithRed_green_blue_alpha(0,0,0.0,0.25)

  //Define size and position

  var calculatedY = (height + 83 + colorMargin) * Math.floor(color/colorsPerRow) + colorMargin

  var collapseRegression = colorsPerRow * Math.floor(color/colorsPerRow)
  var definedX = (color - collapseRegression) * (width + colorMargin) + colorMargin

  //Create color rectangle path
  var colorbgPath = MSRectangleShape.alloc().initWithFrame_(NSMakeRect(definedX, calculatedY, width, height))

  //Create color rectangle layer
  var colorbg = MSShapeGroup.shapeWithPath(colorbgPath)
  [colorbg setName:  "#" + hexString ]

  //Add background color
  var colorbgfill = colorbg.style().addStylePartOfType(0)
  colorbgfill.setColor(MSColor.colorWithSVGString(hexString))

  //Create data group
  var datagroup = MSLayerGroup.new()
  [datagroup setName: hexString ]

  //Named Color Text Layer
  var namedLayer = newTextLayer(datagroup, namedColor, colorbg, 11, 15, namedColor, 0, 16,"Helvetica-Bold","#000000")

  //Hex Color Text Layer
  var hexLayer = newTextLayer(datagroup, hexString, namedLayer, 3, 0, hexString, 0, 13, "Helvetica-Oblique", "#444444")

  //RGB Color Text Layer
  var rgbLayer = newTextLayer(datagroup, rgbaString, hexLayer, 3, 0 , rgbaString, 0, 14, "Helvetica-Oblique", "#444444" )
  var rgbframe = rgbLayer.frame()

  //Sets Text Background Height
  var rectframe = colorbg.frame()

  var dataHeight = ([rgbframe y]+[rgbframe height]) - ([rectframe y] + [rectframe height])+ 14
  var dataY = [rectframe y] + [rectframe height]
  var dataX = [rectframe x]

    //Text layers Background
  var textbgPath = MSRectangleShape.alloc().initWithFrame_(NSMakeRect(dataX, dataY, width, dataHeight))
  
  var textbg = MSShapeGroup.shapeWithPath(textbgPath)
  [textbg setName: "Data Background " + (color+1)]

  //Add data background color
  var textbgfill = textbg.style().addStylePartOfType(0)
  textbgfill.setColor(MSColor.colorWithSVGString("#ffffff"))


  //Adds the layers inside the groups
  datagroup.addLayers([textbg, hexLayer, rgbLayer])
  layergroup.addLayers( [datagroup, namedLayer, colorbg])

  //Resizes the layer group to fit the background and the text layers
  datagroup.resizeToFitChildrenWithOption(0)
  layergroup.resizeToFitChildrenWithOption(0)

  artboard_palette.addLayers([layergroup])

}


function newTextLayer(parent, name, aligner, margintop, marginleft, text, textalignment, fontsize, fontname, fontcolor){

  //Creates new layer & appends it to parent
  var newlayer = MSTextLayer.alloc().init()
  [newlayer setName: name ]

  //Positions based on aligner
  var alignerframe = aligner.frame()

  var layerframe = newlayer.frame()
  layerframe.setX([alignerframe x] + marginleft)
  layerframe.setY([alignerframe y] + [alignerframe height] + margintop)

  //Sets text visual properties
  newlayer.stringValue = text
  newlayer.setTextAlignment(textalignment)
  newlayer.setFontSize(fontsize)
  newlayer.setFontPostscriptName(fontname)
  newlayer.setTextColor(MSColor.colorWithSVGString(fontcolor))
  return newlayer
}

function paletteExists(){
  //Searches for the ShareableColorPalette in the artboards array
  for (var i = 0; i < artboards.count(); i++) {
    if ([[artboards objectAtIndex:i] name] == "ShareableColorPalette"){
      artboard_palette = [artboards objectAtIndex:i]
      return true
    }
  }
}

function getColorStringWithAlpha(color){

  var red = Math.round(color.red() * 255)
  var green = Math.round(color.green() * 255)
  var blue = Math.round(color.blue() * 255)
  var alpha = color.alpha()
  return ("rgba(" + red + ", " + green + ", " + blue + ", " + alpha + ")")
}

function updateArboardSize(){

  //Sets Artboard Frame
  var frame = artboard_palette.frame()

  var previousWidth = frame.width()
  var previousX= frame.x()

  if (palette.count() <= colorsPerRow){
  	frame.setWidth( (width + colorMargin) * palette.count() + colorMargin)
  } else {
  	frame.setWidth( (width + colorMargin) * colorsPerRow + colorMargin)
  }

  frame.setHeight(colorMargin + (layergroup.frame().height() + colorMargin) * Math.ceil(palette.count()/colorsPerRow) )
  frame.setX((previousX + previousWidth) - frame.width())
}

/*
//Takes BG color and makes it to a contrasted readable color
function contrastedColor(col) {

  // GET COLOR RGB
  var c = col.substring(1)    // strip #
  var rgb = parseInt(c, 16)   // convert rrggbb to decimal
  var r = (rgb >> 16) & 0xff  // extract red
  var g = (rgb >>  8) & 0xff  // extract green
  var b = (rgb >>  0) & 0xff  // extract blue

  //GET LUMA
  var luma = 0.2126 * r + 0.7152 * g + 0.0722 * b // per ITU-R BT.709

  // DEFINES DE AMOUNT OF DARKENING OR LIGHTENING WHEN CONTRASTING COLOR
  const intensity = 80
  //MIN LUM TO BE CONSIDERED A LIGHT COLOR
  const lumaThreshold = 55
  var amt = intensity * ((luma < lumaThreshold) ? 1 : -1)

  // DARKEN LIGHTEN
  var usePound = false

  if (col[0] == "#") {
      col = col.slice(1)
      usePound = true
  }

  var num = parseInt(col,16)

  var r = (num >> 16) + amt

  if (r > 255) r = 255
  else if  (r < 0) r = 0

  var b = ((num >> 8) & 0x00FF) + amt

  if (b > 255) b = 255
  else if  (b < 0) b = 0

  var g = (num & 0x0000FF) + amt

  if (g > 255) g = 255
  else if (g < 0) g = 0

  return (usePound?"#":"") + (g | (b << 8) | (r << 16)).toString(16)

}
*/

