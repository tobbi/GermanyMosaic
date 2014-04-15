/**
 * Aktuelle X- und Y-Koordinaten des Mauszeigers
 */
float currentX, currentY;

/**
 *  Klasse, die ein Bundesland beschreibt.
 */
class Bundesland {

  /**
   * Name des Bundeslandes
   */
  String name;
  
  /**
   * Referenzfarbe auf der bunten Karte, welche dieses Bundesland hat.
   * Wird zur Positionsbestimmung des Mauszeigers und zum Ersetzen des
   * Bundeslands mit Mosaikbildern verwendet.
   */
  color referenceColor;
  
  /**
   * Bezeichnet, ob der Mauszeiger gerade über dem Bundesland ist
   */
  Boolean active = false;
  
  /**
   * Gibt an, ob das Laden des Mosaiks für dieses Bundesland bereits 
   * erfolgt ist.
   */
  Boolean load_mosaic_finished = false;
  
  /**
   * Nördliche, östliche, südliche, westliche Grenzen für 
   * dieses Bundesland (Absolute Koordinaten).
   */
  float northBound, eastBound, southBound, westBound;
  
  /**
   * Nördlicher, östlicher, südlicher, westlicher Punkt für
   * dieses Bundesland (Punkte im Sketch)
   */
  int north, east, south, west;
  
  /**
   * Lokale Instanz von QueryThread, welches die Bilder
   * für dieses Bundesland abruft
   */
  FlickrAPI queryThread;
  
  /**
   * Bild, welches das Mosaik für dieses Bundesland enthält
   */
  PImage mosaic;
  
  /**
   * Größe eines einzelnen Mosaik-Bildes
   */
  int tileSize = 10;
  
  /*
   * Die aufrufende GermanyMap-Instanz
   */
  GermanyMap caller;
  
  /**
   * ArrayList, in welcher die Mosaik-Bilder gespeichert werden
   */
  ArrayList<MosaicImage> mosaicimages = new ArrayList<MosaicImage>();

  /**
   * Konstruktor für ein Bundesland
   * @param name             Name des Bundeslandes
   * @param referenceColor   Referenz-Farbe in der Karte 
   *                         (Farbe des Bundeslandes in der Originalkarte)
   * @param coords           Float-Array, das die Koordinaten des Bundeslandes enthält
   * @param caller           Aufrufende GermanyMap-Instanz   
   */
  public Bundesland(String name, color referenceColor, float[] coords, GermanyMap caller) {
    this.name = name;
    this.referenceColor = referenceColor;
    if (coords.length == 4) {
      this.setBounds(coords[0], coords[1], coords[2], coords[3]);
    }
    queryThread = new FlickrAPI(coords[3], coords[0], coords[1], coords[2], this);

    int[] positions = caller.getCoordsFromReferenceMap(referenceColor);
    this.setPositions(positions[3], positions[0], positions[1], positions[2]);
    this.caller = caller;
    mosaic = createImage(this.east - this.west, this.south - this.north, RGB);
  }

  /**
   * Speichert die Grenzen für dieses Bundesland in privaten Membervariablen (Koordinaten)
   */
  public void setBounds(float northBound, float eastBound, float southBound, float westBound) {
    this.northBound = northBound;
    this.eastBound = eastBound;
    this.southBound = southBound;
    this.westBound = westBound;
  }

  /**
   * Speichert die Grenzen für dieses Bundesland in privaten Membervariablen (Pixelwerte auf der Karte)
   */
  public void setPositions(int north, int east, int south, int west) {
    this.north = north;
    this.east = east;
    this.south = south;
    this.west = west;
  }

  /**
   * Speichert die aktuelle Mausposition in den globalen Variablen currentX und currentY
   */
  public void mousePosToAbsoluteCoordinates() {
    float[] returnVals = positionToCoordinates(mouseX, mouseY);
    currentX = returnVals[0];
    currentY = returnVals[1];
  }
  
  /**
   * Wandelt die Mausposition in absolute Koordinaten um
   * @returns float-Array mit den Zielkoordinaten
   */
  public float[] positionToCoordinates(int x, int y) {
    if(x < 0 || x > width) return null;
    if(y < 0 || y > height) return null;
    float targetX = map(mouseX, 0, this.west - this.east, eastBound, westBound);
    float targetY = map(mouseY, 0, this.south - this.north, southBound, northBound);
    float[] targetVals = {targetX, targetY};
    return targetVals;
  }

  /**
   * Wird ausgeführt, wenn die Maus bewegt wurde. Setzt 
   * active auf true wenn die aktuelle Referenzfarbe mit
   * der Farbe unter dem Mauszeiger übereinstimmt.
   */
  public void mouseMoved(color refColor) {
    this.mousePosToAbsoluteCoordinates();
    active = (refColor == referenceColor);
  }

  /**
   * Gibt zurück, ob das Bundesland gerade unter dem Mauszeiger ist.
   */
  public Boolean isActive() {
    return active;
  }
  
  /**
   * Führt den Thread zum Laden der Bilder aus
   */
  public void runQuery() {
    tileSize = (int)sizeSlider.getValue();
    queryThread.run();
  }
  
  /**
   * Speichert einen Mosaik-Pixel im aktuellen Mosaik-Bild
   * Wenn gewünscht, speichert das Mosaik auf der Festplatte
   */
  public void setMosaicImage(PImage img, int x, int y) {
    if(img == null) return;
    mosaic.copy(img, 0, 0, img.width, img.height, x, y, img.width, img.height);
    if(saveMosaik.getArrayValue(0) == 1) {
      mosaic.save("mosaik/" + name + ".jpg");
    }
  }
  
  /**
   * Wird ausgeführt, wenn das Laden des Mosaiks fertig ist.
   * Ruft die Funktion zum Ersetzen der Karte durch das Mosaik auf
   * und zeigt entsprechende Log-Ausgaben an.
   */
  public void setMosaicFinished() {
    load_mosaic_finished = true;
    caller.loaded_count++;
    caller.replaceWithMosaic(this);
    log("[" + name + "] Mosaik fertiggestellt...");
    if(caller.loaded_count == 16) {
        caller.saveMosaicImage();
      log("[Fertig]");
    }
  }
  
  /**
   * Ruft die Informationen (URL, Titel) über das aktuelle Foto
   * (das Foto, über dem sich der Mauszeiger befindet) ab und 
   * gibt diese in einem String-Array zurück.
   */
  public String[] getCurrentPhotoInfo() {
    if(mosaicimages == null || mosaicimages.size() == 0)
      return new String[2];
    
    for(int i = 0; i < mosaicimages.size(); i++)
    {
      MosaicImage current = mosaicimages.get(i);
      float valueX = west*mapScaleValue + current.positionX*mapScaleValue - tileSize / 2;
      float valueY = north*mapScaleValue + current.positionY*mapScaleValue - tileSize / 2;
      if(valueX > mouseX - tileSize && valueY > mouseY - tileSize) {
        String[] infoArray = {mosaicimages.get(i).url, mosaicimages.get(i).title};
        return infoArray;
      }
    }
    return new String[2];
  }
};
