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
  layergroup = [artboard_palette addLayerOfType: "group"]
  [layergroup setName: namedColor + ": " + hexString ]
  layergroup.setIsLocked(true)

  //Adds shadow to the group
  var groupshadow = layergroup.style().shadows().addNewStylePart()
  groupshadow.offsetX = 0
  groupshadow.offsetY = 3
  groupshadow.blurRadius = 6
  groupshadow.spread = 0
  groupshadow.color = MSColor.colorWithRed_green_blue_alpha(0,0,0.0,0.25)

  //Create color rectangle
  var colorbg = [layergroup addLayerOfType: "rectangle"]
  [colorbg setName: "" + " " +hexString ]

  //Define size and position
  var rectframe = colorbg.frame()

  rectframe.setWidth(width)
  rectframe.setHeight(height)

  var calculatedY = (height + 83 + colorMargin) * Math.floor(color/colorsPerRow) + colorMargin

  rectframe.setY(calculatedY)
  var collapseRegression = colorsPerRow * Math.floor(color/colorsPerRow)
  rectframe.setX((color - collapseRegression) * (width + colorMargin) +colorMargin)

  //Add background color
  var colorbgfill = colorbg.style().fills().addNewStylePart()
  colorbgfill.color = MSColor.colorWithSVGString(hexString)

  //Create data group
  var datagroup = [layergroup addLayerOfType: "group"]
  [datagroup setName: hexString ]

  //Text layers Background
  var textbg = [datagroup addLayerOfType: "rectangle"]
  [textbg setName: "Data Background " + (color+1)]

  var textbgframe = textbg.frame()
  textbgframe.setWidth(width)
  textbgframe.setY([rectframe y] + [rectframe height])
  textbgframe.setX([rectframe x])

  //Add data background color
  var textbgfill = textbg.style().fills().addNewStylePart()
  textbgfill.color = MSColor.colorWithSVGString("#ffffff")

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
  layergroup.resizeToFitChildrenWithOption(1)
  datagroup.resizeToFitChildrenWithOption(1)
}


function newTextLayer(parent, name, aligner, margintop, marginleft, text, textalignment, fontsize, fontname, fontcolor){

  //Creates new layer & appends it to parent
  var newlayer = [parent addLayerOfType: "text"]
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

  //Sets text color depending on background: NOW WORKS AS EXPECTED BITCHES...
  //textlayer.setTextColor(MSColor.colorWithSVGString( contrastedColor(hexString) ))
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
