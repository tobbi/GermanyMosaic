/**
 * Klasse welche Informationen für Mosaik-Bilder enthält
 */
class MosaicImage {

  /**
   * Konstruktor
   * @param url - Flickr-URL des Bildes
   * @param title - Titel des Bildes
   * @param positionX - Die X-Position des Bildes im Mosaik
   * @param positionY - Die Y-Position des Bildes im Mosaik
   */
  public MosaicImage(String url, String title, int positionX, int positionY) {
    this.url = url;
    this.positionX = positionX;
    this.positionY = positionY;
    this.title = title;
  }
  
  /**
   * Die URL des Bildes
   */
  String url;

  /** 
   * Der Titel des Bildes
   */
  String title;
  
  /** 
   * Die X-Position des Bildes im Mosaik
   */
  int positionX;

  /** 
   * Die Y-Position des Bildes im Mosaik
   */  
  int positionY;
}
