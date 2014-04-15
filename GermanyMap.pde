import java.text.SimpleDateFormat;
import java.text.DateFormat;

/**
 * ArrayList, welche die Bundesländer enthält
 */
static ArrayList<Bundesland> bundeslaender = new ArrayList<Bundesland>();

/**
 * Farbe des Bundeslandes unter dem Mauszeiger
 */
static color previousRefColor;

/**
 * Skalierungswert der aktuellen Karte
 */
static float mapScaleValue = .6033;

/**
 * Das Bundesland, über dem sich der Mauszeiger aktuell befindet
 */
Bundesland current = null;

/**
 * URL des Fotos unter dem Mauszeiger
 */
String currentPhotoURL = "";

/**
 * Titel des Fotos unter dem Mauszeiger
 */
String currentPhotoTitle = "";

/**
 * Foto unter dem Mauszeiger
 */
PImage currentPhoto;

/**
 * GermanyMap-Klasse, welche eine Deutschland-Karte bezeichnet
 */
class GermanyMap {

  /**
   * Bilder-Versionen der aktuellen Karte, zum Ersetzen
   * mit Mosaik-Bildern und zum Ermitteln des Bundeslandes
   * unter der Mausposition.
   */
  PImage map_raw_image, map_mosaicfilter;

  /**
   * Name des aktuellen Bundeslandes
   */
  String currentName;
  
  /**
   * Aktueller Status
   */
  String currentStatus = "[Fertig]";
  
  /**
   * Datumsformat zum Speichern der fertigen Mosaik-Bilder
   */
  DateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
  
  /**
   * Anzahl der geladenen Bundesländer
   */
  int loaded_count = 0;
  
  /**
   * Zeigt an, ob gerade eine Mausbewegung stattfindet
   */
  Boolean mouseMotion = false;

 /**
  * Konstruktor
  * Lädt das letzte gespeicherte Mosaik aus dem Cache, sofern es existiert.
  * Instantiiert für jedes Bundesland ein Objekt der Klasse Bundesland.
  * Enthält hardcoded die Koordinaten und die Referenz-Farben.
  * Ruft loadCache() auf, um den Cache zu laden.
  */
  public GermanyMap() {
    try {
      map_mosaicfilter = loadImage("cache/mosaik_current.jpg");
      if(map_mosaicfilter == null) {
        map_mosaicfilter = loadImage("Germany_location_map_markers.png");
      }

      map_raw_image = loadImage("Germany_location_map_markers.png");
      this.setCurrentName("Deutschland");

      /* BUNDESLAENDER HINZUFUEGEN */
      float[] shBorders = {
        55.056823, 11.313317, 53.359808, 7.864751
      };
      bundeslaender.add(new Bundesland("Schleswig-Holstein", color(128, 0, 0), shBorders, this));

      float[] bremenBorders = {
        53.228969, 8.990593, 53.011035, 8.481599
      };
      bundeslaender.add(new Bundesland("Bremen", color(255, 1, 255), bremenBorders, this));

      float[] hamburgBorders = {
        53.7394463, 10.3252766, 53.3951194, 9.7301317
      };
      bundeslaender.add(new Bundesland("Hamburg", color(117, 0, 190), hamburgBorders, this));

      float[] meckPommBorders = {
        54.684885, 14.412257, 53.109846, 10.59383
      };
      bundeslaender.add(new Bundesland("Mecklenburg-Vorpommern", color(212, 165, 0), meckPommBorders, this));

      float[] brandenburgBorders = {
        53.559955, 14.765478, 51.359063, 11.268721
      };
      bundeslaender.add(new Bundesland("Brandenburg", color(0, 105, 193), brandenburgBorders, this));

      float[] berlinBorders = {
        52.675323, 13.760909, 52.338079, 13.088304
      };
      bundeslaender.add(new Bundesland("Berlin", color(52, 255, 0), berlinBorders, this));

      float[] bayernBorders = {
        50.564736, 13.839928, 47.270127, 8.976041
      };
      bundeslaender.add(new Bundesland("Bayern", color(128, 162, 255), bayernBorders, this));

      float[] bawueBorders = {
        49.791114, 10.495406, 47.532304, 7.511678
      };
      bundeslaender.add(new Bundesland("Baden-Württemberg", color(255, 0, 47), bawueBorders, this));

      float[] niedersachsenBorders = {
        53.891965, 11.598119, 51.294714, 6.654307
      };
      bundeslaender.add(new Bundesland("Niedersachsen", color(0, 212, 51), niedersachsenBorders, this));

      float[] nrwBorders = {
        52.531417, 9.461595, 50.322572, 5.866357
      };
      bundeslaender.add(new Bundesland("Nordrhein-Westphalen", color(251, 255, 128), nrwBorders, this));

      float[] hessenBorders = {
        51.657816, 10.236479, 49.395175, 7.772406
      };
      bundeslaender.add(new Bundesland("Hessen", color(0, 191, 85), hessenBorders, this));

      float[] rheinlandBorders = {
        50.942325, 8.508119, 48.966662, 6.112366
      };
      bundeslaender.add(new Bundesland("Rheinland-Pfalz", color(0, 255, 240), rheinlandBorders, this));

      float[] saarlandBorders = {
        49.639427, 7.404843, 49.111889, 6.356483
      };
      bundeslaender.add(new Bundesland("Saarland", color(0, 52, 255), saarlandBorders, this));

      float[] sachsenAnhaltBorders = {
        53.041521, 13.18687, 50.937987, 10.560813
      };
      bundeslaender.add(new Bundesland("Sachsen-Anhalt", color(212, 0, 159), sachsenAnhaltBorders, this));

      float[] sachsenBorders = {
        51.684874, 15.041854, 50.171303, 11.872253
      };
      bundeslaender.add(new Bundesland("Sachsen", color(255, 244, 0), sachsenBorders, this));

      float[] thueringenBorders = {
        51.649199, 12.654036, 50.204348, 9.87672
      };
      bundeslaender.add(new Bundesland("Thüringen", color(191, 15, 0), thueringenBorders, this));
      
      loadCache();
    }
    catch(Exception e) {
      println(e.getMessage());
    }
  }
  
  /**
   * Zeichnet den aktuellen Namen  des Bundeslandes und den aktuellen Status
   */
  void drawCurrentDescription() {
    textSize(20);
    fill(0, 102, 153);
    text(currentName, 700, height - 20);
    
    textSize(10);
    text(currentStatus, 660, 10);
  }
  
  /**
   * Zeichnet das aktuell ausgewählte Foto zusammen 
   * mit umgebendem Rahmen und Beschreibungstext
   */
  void drawCurrentPhoto() {
    if (currentPhoto != null && currentPhoto.width > 0 && currentPhoto.height > 0) {
      rect(669 + 160 - currentPhoto.width / 2, 299 + 160 - currentPhoto.height/2, currentPhoto.width + 1, currentPhoto.height + 1);
      try {
        image(currentPhoto, 670 + 160 - currentPhoto.width / 2, 300 + 160 - currentPhoto.height/2);
        fill(0);
        text(currentPhotoTitle, 670 + 160 - currentPhoto.width / 2, 300 + 160 - currentPhoto.height/2 + currentPhoto.height + 20);
      }
      catch(Exception e) {
        // Could not find a method to load error
      }
    }
  }
  
  /**
   * Lädt das aktuelle Foto, allerdings nur wenn keine Mausbewegung stattfindet.
   * Setzt die aktuelle URL und den aktuellen Titel für das Bild
   */
  void loadCurrentPhoto() {
    if (map.mouseMotion)
      return;

    if (current == null || !current.load_mosaic_finished)
      return;

    String[] currentInfo = current.getCurrentPhotoInfo();

    if (currentInfo == null || currentInfo.length == 0 || currentInfo[0] == currentPhotoURL)
      return;

    currentPhotoURL = currentInfo[0];
    currentPhotoTitle = currentInfo[1];
    thread("loadCurrentPhotoURL");
  }
  
  /**
   * Löscht die Daten des Mosaiks für jedes Bundesland
   */
  void clearMosaic() {
    for(int i = 0; i < bundeslaender.size(); i++)
      bundeslaender.get(i).mosaicimages.clear();
  }

  /**
   * Zeichnet die Karte mit dem Mosaik
   */
  void soMoegeErDieKarteZeichnen() {
    pushMatrix();
    scale(mapScaleValue);
    image(map_mosaicfilter, 0, 0);
    popMatrix();
  }
  
  /**
   * Ersetzt die Farbe des übergebenen Bundeslandes mit dem Mosaik
   * @param land   Bundesland für welches wir das Mosaik ersetzen wollen
   */
  void replaceWithMosaic(Bundesland land) {
    for(int x = land.west; x < land.east; x++)
      for(int y = land.north; y < land.south; y++)
    {
      color target = land.mosaic.get(x - land.west, y - land.north);
      if(map_mosaicfilter.get(x, y) == land.referenceColor)
        map_mosaicfilter.set(x, y, target);
    }
  }

  /**
   * Wird ausgeführt, wenn die Maus bewegt wurde. 
   * Setzt die aktuelle Referenzfarbe, setzt den Namen des 
   * aktuellen Bundeslandes und ruft MouseMoved dieses Bundeslandes auf
   */
  void mouseMoved() {
    mouseMotion = true;
    color refColor = map_raw_image.get(int(mouseX/mapScaleValue), int(mouseY/mapScaleValue));

    if (refColor != 0 && previousRefColor == refColor && current != null) {
      current.mouseMoved(refColor);
      return;
    }
    previousRefColor = refColor;

    Bundesland aktuelles;
    for (int i = 0; i < bundeslaender.size(); i++) {
      aktuelles = bundeslaender.get(i);
      aktuelles.mouseMoved(refColor);
      cursor(ARROW);
      if (aktuelles.active) {
        cursor(HAND);
        current = aktuelles;
        this.setCurrentName(current.name);
        return;
      }
    }
    this.setCurrentName("Deutschland");
  }

  /**
   * Setzt den Namen des aktuellen Bundeslandes
   * @param value Name des Bundeslandes
   */
  void setCurrentName(String value) {
    currentName = value;
  }
  
  /**
   * Holt sich die Koordinaten des Bundeslandes mit der Referenzfarbe
   * Dazu werden für jeden Punkt jeweils zwei Schleifen durchlaufen. 
   * Annährung aus Nord, Ost, Süd, West-Richtung
   * Sobald die Farbe auftaucht werden die X- und Y-Werte dieses Punktes gesetzt.
   * @param refColor - Referenzfarbe des Bundeslandes
   */
  int[] getCoordsFromReferenceMap(color refColor) {
    int topLeftX = 0, topLeftY = 0;
    int bottomRightX = 0, bottomRightY = 0;
    for (int x = 0; x < map_raw_image.width; x++)
      for (int y = 0; y < map_raw_image.height; y++)
      {
        color c = map_raw_image.get(x, y);
        if (c == refColor) {
          topLeftX = x;
          break;
        }
      }
      
   for (int y = 0; y < map_raw_image.height; y++)
    for (int x = 0; x < map_raw_image.width; x++)
      {
        color c = map_raw_image.get(x, y);
        if (c == refColor) {
          topLeftY = y;
          break;
        }
      }                
      
    for (int x = map_raw_image.width; x > 0; x--)
      for (int y = map_raw_image.height; y > 0; y--)
      {
        color c = map_raw_image.get(x, y);
        if (c == refColor) {
          bottomRightX = x;
          break;
        }
      }
      
      for (int y = map_raw_image.height; y > 0; y--)
       for (int x = map_raw_image.width; x > 0; x--)
      {
        color c = map_raw_image.get(x, y);
        if (c == refColor) {
          bottomRightY = y;
          break;
        }
      }
      
    int[] result = {topLeftX, topLeftY, bottomRightX, bottomRightY};
    return result;
  }
  
  /**
   * Lädt die Karte von der Festplatte neu, löscht die 
   * gespeicherten Mosaik-Informationen
   */
  public void reloadMap() {
    loaded_count = 0;
    clearMosaic();
    map_mosaicfilter = null;
    map_mosaicfilter = loadImage("Germany_location_map_markers.png");
  }
  
  /**
   * Speichert das fertige Mosaik-Bild, zusammen mit einem
   * Cache mit Bildinformationen auf der Festplatte.
   */
  public void saveMosaicImage() {
    if(saveMosaik.getArrayValue(0) == 1) {
      Date jetzt = new Date();
      map_mosaicfilter.save("mosaik/mosaik_" + dateFormat.format(jetzt) + ".jpg");
    }

    map_mosaicfilter.save("cache/mosaik_current.jpg");
    
    for(int i = 0; i < bundeslaender.size(); i++)
    {
      JSONObject bundesland = new JSONObject();
      bundesland.setInt("tileSize", bundeslaender.get(i).tileSize);
      JSONArray images = new JSONArray();
      for(int x = 0; x < bundeslaender.get(i).mosaicimages.size(); x++) {
        MosaicImage currentMosaic = bundeslaender.get(i).mosaicimages.get(x);
        JSONObject _image = new JSONObject();
        _image.setString("url", currentMosaic.url);
        _image.setString("title", currentMosaic.title);
        _image.setInt("posX", currentMosaic.positionX);
        _image.setInt("posY", currentMosaic.positionY);
        images.append(_image);
      }
      bundesland.setJSONArray("images", images);
      saveJSONObject(bundesland, "cache/mosaik_" + bundeslaender.get(i).name + ".json");
    }
  }
  
  /**
   * Lädt den gespeicherten Cache von der Festplatte.
   */
  void loadCache() {
    for(int i = 0; i < bundeslaender.size(); i++) {
      try {
        JSONObject current = loadJSONObject("cache/mosaik_" + bundeslaender.get(i).name + ".json");
        if(current == null) continue;
        bundeslaender.get(i).tileSize = current.getInt("tileSize");
        JSONArray images = current.getJSONArray("images");
        for(int x = 0; x < images.size(); x++) {
          JSONObject currentImage = images.getJSONObject(x);
          String url = currentImage.getString("url");
          String title = currentImage.getString("title");
          int posX = currentImage.getInt("posX");
          int posY = currentImage.getInt("posY");
          bundeslaender.get(i).mosaicimages.add(new MosaicImage(url, title, posX, posY));
          bundeslaender.get(i).load_mosaic_finished = true;
        }
      }
      catch(Exception e) {
        // Irgendwo war ein Fehler!
      }
    }
  }

  /**
   * Zeichnet die aktuelle Lupe in den Sketch ein.
   */
  void drawMagnifier() {
    if(enableMagnification.getArrayValue(0) != 1)
      return;

    if(mouseX > map.map_mosaicfilter.width * mapScaleValue
    || mouseY > map.map_mosaicfilter.height * mapScaleValue)
      return;
      
    pushMatrix();
    scaleValue = scaleValueSlider.getValue();
    scale(scaleValue);
    translate(mouseX / scaleValue, mouseY / scaleValue);
    imageMode(CENTER);
    image(aktuellerCursor, 0, 0);
    fill(0, 0, 0, 0);
    ellipse(0, 0, magnifierSize, magnifierSize);
    popMatrix();
    imageMode(CORNER);
  }
}
