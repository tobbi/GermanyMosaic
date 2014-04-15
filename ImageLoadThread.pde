/**
 * Lädt die Bilder für jedes Bundesland
 * Instantiiert ein ImageLoadThread-Objekt
 * und startet es.
 */
public void ThreadedLoadImages() {
  if (frameCount < 2) return;
  map.reloadMap();
  for (int i = 0; i < bundeslaender.size(); i++) {
    new ImageLoadThread(i).start();
  }
}

/**
 * ImageLoadThread leitet von Thread ab
 * und laedt die Bilder von Flickr
 */
class ImageLoadThread extends Thread {

  /**
   * Der Index des Bundeslandes, für das die Bilder geladen werden 
   */
  private int i;

  /**
   * Constructor
   * @param i  Der Index des Bundeslandes für das die Bilder geladen werden.
   */
  public ImageLoadThread(int i) {
    this.i = i;
  }
  
  /**
   * Thread::run()-Methode, erfordert von Thread
   * Führt das Laden der Bilder für Bundesland mit Index i aus.
   */
  void run() {
    bundeslaender.get(i).runQuery();
  }
}
