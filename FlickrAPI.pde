import java.util.*;

/**
 * Klasse, welche die Verbindung zur Flickr-API übernimmt,
 * implementiert die Klasse Runnable zum Aufruf von einem Thread
 */
class FlickrAPI implements Runnable {

   /**
    * Der FlickrAPI-Schlüssel
    */
   String flickrAPIKey = "cbf6f47b59eca237042bd43494d644fa";
   
   /**
    * Das FlickrAPI-Secret
    */
   String flickrAPISecret = "e0e6cebedec5bf75";

   /**
    * Die aufzurufende API-Methode
    */
   String method = "flickr.photos.search";
   
   /**
    * Das zurückzugebende Format
    */
   String format = "json";
   
   /**
    * Gibt an, ob ein JSON-Callback aufgerufen werden soll
    */
   String nojsoncallback = "1";
   
   /**
    * Genauigkeit der Ergebnisse (6 = Region)
    */
   String accuracy = "6";
   
   /**
    * Privatsphäre-Filter, 1 = private Ergebnisse filtern
    */
   String privacyFilter = "1";
   
   /**
    * Suchbegriff
    */
   String searchString = "";
   
   /**
    * Abfrage-URL
    */
   String URL = "http://api.flickr.com/services/rest/?method="+ method 
                + "&api_key=" + flickrAPIKey 
                + "&format=" + format 
                + "&nojsoncallback=" + nojsoncallback
                + "&accuracy=" + accuracy
                + "&privacy_filter=" + privacyFilter;
                      
   /**
    * Von der JSON-Abfrage zurückgeliefertes JSON-Objekt
    */
   JSONObject currentCallObject;
   
   /**
    * JSON-Array, welches alle Fotos auf einer zurückliefert
    */
   JSONArray allPhotos;
   
   /**
    * Zu durchsuchender Bereich (minimale, maximale Latitude und Longitude)
    */
   float latitude, longitude, maxLatitude, maxLongitude;
   
   /**
    * Aufrufende Instanz von Bundesland
    */
   Bundesland caller;
   
   /**
    * Konstruktor
    * @param latitude     Minimale Latitude der Ergebnisse
    * @param longitude    Minimale Longitude der Ergebnisse
    * @param maxLatitude  Maximale Latitude der Ergebnisse
    * @param maxLongitude Maximale Longitude der Ergebnisse
    * @param caller       Aufrufende Instanz von Bundesland
    */
   public FlickrAPI(float latitude, float longitude, float maxLatitude, float maxLongitude, Bundesland caller) {
     this.latitude = latitude;
     this.longitude = longitude;
     this.maxLatitude = maxLatitude;
     this.maxLongitude = maxLongitude;
     this.caller = caller;
   }

  /**
   * Run-Methode zum Aufrufen vom Thread.
   * Stellt eine Flickr-Abfrage und speichert die zurückgegebenen Daten in einem
   * JSON-Array. Ruft für jedes Bild die Methode setMosaicImage() auf, die das 
   * einzelne Bild speichert.
   */
  public void run() {
    int x = 0, y = 0;
    int maxCols = caller.tileSize * (caller.mosaic.width / caller.tileSize) + caller.tileSize;
    int maxLines = caller.tileSize * (caller.mosaic.height / caller.tileSize) + caller.tileSize;
    int neededPhotoCount = (maxCols * maxLines)/(caller.tileSize * caller.tileSize);
    setSearchString(searchStringField.getText());
    
    float sortByValue = sortByRadio.getValue();
    URL = appendToUrl(URL, "sort", sortByValue == 1 ? "interestingness-desc" : "date-posted-desc");
    
    allPhotos = new JSONArray();
    while(allPhotos.size() < neededPhotoCount) {
        JSONArray nextSet = getRandomResultSet();
        int remaining = neededPhotoCount - allPhotos.size();
        if(remaining > nextSet.size())
        {
          remaining = nextSet.size();
        }
        for (int i = 0; i < remaining; i++) {
          allPhotos.append(nextSet.getJSONObject(i));
        }
    }
    
    for(int i = 0; i < allPhotos.size(); i++) {
      String currentUrl = getPhotoUrlFromJSON(allPhotos, i);
      String title = getTitleFromJSON(allPhotos, i);
      PImage currentImage = null;
      try {
        currentImage = loadImage(currentUrl);
      }
      catch(Exception e) { // Fehler beim Laden des Bildes
        continue;
      }
      if(currentImage == null) continue;
      if(currentImage.width < 0 || currentImage.height < 0) continue;
      _logProgress(i, allPhotos.size());

      if(x == maxCols) {
        x = 0;
        y += caller.tileSize;
        if(y == maxLines)
          break;
      }
      currentImage.resize(caller.tileSize, caller.tileSize);
      caller.setMosaicImage(currentImage, x, y);
      caller.mosaicimages.add(new MosaicImage(currentUrl, title, x, y));
      x += caller.tileSize;
    }
    caller.setMosaicFinished();
  }

  /**
   * Erzeugt aus den gelieferten Parametern eine URL zum direkten Foto
   * @param farmId    Flickr-Farm-ID der Farm, in dem der Server des Bildes sich befindet.
   * @param serverId  Server-ID des Servers, auf dem das Bild liegt
   * @param photoId   ID des Fotos
   * @param secret    Secret des Fotos, welches zum Anzeigen verwendet wird
   * @returns URL des Bildes
   */
  public String composePhotoURL(int farmId, String serverId, String photoId, String secret) {
    return "http://farm" + farmId + ".staticflickr.com/" + serverId + "/" + photoId + "_" + secret + "_s.jpg";
  }
  
  /**
   * Speichert den übergebenen String in einer privaten Variable.
   * @searchString Übergebener Suchbegriff-String
   */
  public void setSearchString(String searchString) {
    this.searchString = searchString;
  }
  
  /**
   * Liest eine bestimmte Foto-URL aus einem übergebenen JSON-Array mit Fotos aus.
   * @param allPhotos   JSON-Array, welches die Ergebnisse enthält
   * @param i           Index der auszulesenden Foto-URL
   * @returns Eine Foto-URL des gegebenen Bildes
   */
  public String getPhotoUrlFromJSON(JSONArray allPhotos, int i) {
    JSONObject current = allPhotos.getJSONObject(i);
    String id = current.getString("id");
    String secret = current.getString("secret");
    String server = current.getString("server");
    int farm = current.getInt("farm");
    return composePhotoURL(farm, server, id, secret);
  }
  
  /**
   * Liest einen bestimmten Foto-Titel aus einem übergebenen JSON-Array mit Fotos aus.
   * @param allPhotos   JSON-Array, welches die Ergebnisse enthält
   * @param i           Index der auszulesenden Foto-URL
   * @returns Eine Beschreibung des gegebenen Bildes
   */
  public String getTitleFromJSON(JSONArray allPhotos, int i) {
     return allPhotos.getJSONObject(i).getString("title");
  }
  
  /**
   * Hängt der übergebenen Url einen Parameter mit Namen und Wert an.
   * @param Url   Die URL, an welchen der Parameter angehängt werden soll.
   * @param param Parametername
   * @param value Parameterwert
   * @returns Url mit angehängtem Parameter
   */
  public String appendToUrl(String Url, String param, String value) {
    return Url += "&" + param + "=" + value;
  }
  
  /**
   * Protokolliert den Fortschritt des Ladens der Bilder
   * @param i     Index aktuelles Bild
   * @param max   Anzahl des Gesamtbilder
   */
  public void _logProgress(int i, int max) {
    int currentPercentage = (int)map(i, 0, max, 0, 100);
    log("[" + caller.name + "] " + currentPercentage + "%");
  }
  
  /**
   * Liefert einen zufälligen Ergebnissatz zurück
   * @returns JSON-Array mit den Fotos des Ergebnissatzes
   */
  public JSONArray getRandomResultSet() {
    int maxPages, pageNum;
    JSONObject photos = new JSONObject();
    // Flickr-Bug-Workaround: Anstatt nur einer zufaellig ausgewaehlten Seite wird hier auch eine random Bounding-Box gewaehlt //
    float longitudeFactor = Math.abs((maxLongitude - longitude) / 2);
    float latitudeFactor = Math.abs((maxLatitude - latitude) / 2);
    float newMinLongitude = random(longitude, longitude + longitudeFactor);
    float newMaxLongitude = random(maxLongitude - longitudeFactor, maxLongitude);
    float newMinLatitude = random(latitude, latitude + latitudeFactor);
    float newMaxLatitude = random(maxLatitude - latitudeFactor, maxLatitude);
    String currentURL = appendToUrl(URL, "bbox", newMaxLongitude + "," + newMinLatitude + "," + newMinLongitude + "," + newMaxLatitude);
    if(!searchString.isEmpty()) {
        float searchAsValue = searchAsRadio.getValue();
        if(searchAsValue == 1) { //<>//
          currentURL = appendToUrl(currentURL, "text", searchString);
        }
        else {
          currentURL = appendToUrl(currentURL, "tags", searchString);
        };
    }
    log("[GermanyMap] Lade Bilder von Flickr. Bitte warten...");
    currentCallObject = loadJSONObject(currentURL);
    maxPages = currentCallObject.getJSONObject("photos").getInt("pages");
    pageNum = (int)random(maxPages);
    currentURL = appendToUrl(currentURL, "page", String.valueOf(pageNum));
    currentCallObject = loadJSONObject(currentURL);
    photos = currentCallObject.getJSONObject("photos");
    return photos.getJSONArray("photo");
  }
}
