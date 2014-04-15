/**
 * Variable, welche eine Instanz von GermanyMap hält.
 */
GermanyMap map;

/**
 * Bild, das das Vergrößerungsglas darstellt
 */
PImage aktuellerCursor = createImage(100, 100, ARGB);

/**
 * Setup-Methode, welche die Größe des Sketches einstellt und
 * eine neue Instanz von GermanyMap() erstellt.
 * Initialisiert die ControlP5-GUI durch Aufruf von InitGUI()
 */
void setup() {
  size(1024, 768);
  map = new GermanyMap();
  initGUI();
}

/**
 * Lädt die URL des Fotos, über dem sich der Mauszeiger befindet
 * und weist es dem aktuellen Foto zu, welches in dem Sketch angezeigt wird.
 */
void loadCurrentPhotoURL() {
  if (current.getCurrentPhotoInfo() == null) return;
  if (current.getCurrentPhotoInfo().length == 0) return;
  if (current.getCurrentPhotoInfo()[0] != currentPhotoURL) return;

  PImage temp = null;
  try {
    temp = loadImage(currentPhotoURL.replaceAll("_s", "_n"));
  }
  catch(Exception ex) {
    // Photo konnte nicht geladen werden
  }
  if (current.getCurrentPhotoInfo()[0] != currentPhotoURL || temp == null)
    return;
  currentPhoto = temp;
}

/**
 * Speichert die Bilddaten vergrößert für die Pixel, welche sich unter dem Mauszeiger befinden.
 */
void setCurrentMagnifier() {
  if (enableMagnification.getArrayValue(0) != 1)
    return;

  int xRadius = magnifierSize;
  int yRadius = magnifierSize;
  for (int x = mouseX - xRadius; x < mouseX + xRadius; x++)
    for (int y = mouseY - yRadius; y < mouseY + yRadius; y++)
    {
      if (Math.pow(x + xRadius/2 - mouseX, 2) + Math.pow(y + yRadius/2 - mouseY, 2) >= Math.pow(xRadius / 2, 2))
        continue;
      aktuellerCursor.set(
      x - mouseX + xRadius, 
      y - mouseY + yRadius, 
      map.map_mosaicfilter.get(
      (int)(x/ mapScaleValue + xRadius * mapScaleValue + bundeslaender.get(0).tileSize / 2), 
      (int)(y/ mapScaleValue + yRadius * mapScaleValue + bundeslaender.get(0).tileSize / 2)
        ));
    }
}

/**
 * Draw-Methode, welche für jeden Frame einmal ausgeführt wird.
 * Zeichnet die Karte, Beschreibungen, Lupe, das aktuelle Foto etc.
 */
void draw() {
  background(255);
  map.drawCurrentDescription();
  map.soMoegeErDieKarteZeichnen();
  map.drawMagnifier();
  fill(255);
  map.loadCurrentPhoto();
  map.drawCurrentPhoto();
  map.mouseMotion = false;
}

/**
 * MouseMoved-Methode, welche bei Bewegung des Mauszeigers ausgeführt wird.
 * Ruft @setCurrentMagnifier auf.
 */
void mouseMoved() {
  println(red(get(mouseX, mouseY)), green(get(mouseX, mouseY)), blue(get(mouseX, mouseY)));
  thread("setCurrentMagnifier");
  map.mouseMoved();
}

/**
 * Log-Ausgabe-Methode
 * @param   logString   Der Text, der protokolliert werden soll.
 */
void log(String logString) {
  map.currentStatus = logString;
}

