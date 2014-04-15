import controlP5.Textlabel;
import controlP5.CheckBox;
import controlP5.*;

/**
 * Öffentliche Variablen, welche die GUI-Elemente beinhalten
 */
ControlP5 cp5;
CheckBox saveMosaik, enableMagnification;
RadioButton sortByRadio;
RadioButton searchAsRadio;
Textfield searchStringField;
Slider sizeSlider, scaleValueSlider;

/**
 * Lupengröße
 */
Integer magnifierSize = 100;

/**
 * Skalierungswert
 */
float scaleValue = 4;

/**
 * Initialisiert die grafische Benutzeroberfläche
 * (Alle ControlP5-Kontrollen)
 */
void initGUI() {
  cp5 = new ControlP5(this);
    cp5.addTextlabel("searchBoxText")
      .setText("Suchbegriff eingeben (optional):")
      .setColor(0)
      .setPosition(670, 13);
 
  searchStringField = cp5.addTextfield("searchString")
     .setPosition(670, 25)
     .setFont(createFont("", 10))
     .setSize(230, 20)
     .setAutoClear(false)
     ;
  cp5.addButton("ThreadedLoadImages")
     .setValue(0)
     .setPosition(width - 120, 25)
     .setSize(60, 20)
     .setOff()
     .setLabel("Laden...");
  
    searchAsRadio = cp5.addRadioButton("searchAs")
                   .setPosition(670, 47)
                   .setSize(10,10)
                   .setColorForeground(color(120))
                   .setColorActive(color(255,0,0))
                   .setColorLabel(color(0))
                   .setItemsPerRow(2)
                   .setSpacingColumn(100)
                   .addItem("Volltext", 1)
                   .addItem("Tags", 2)
                   .activate(0);

  saveMosaik = cp5.addCheckBox("SaveMosaik")
              .setPosition(670, 60)
              .setColorForeground(color(120))
              .setColorActive(color(255,0,0))
              .setColorLabel(color(0))
              .setSpacingRow(20)
              .addItem("Mosaik auf Festplatte schreiben", 0);
  
  cp5.addTextlabel("SortBy")
     .setText("Mosaikbilder sortieren nach:")
     .setPosition(670,75)
     .setColor(0x00000000);

  sortByRadio = cp5.addRadioButton("sortBy")
                   .setPosition(670, 90)
                   .setSize(10,10)
                   .setColorForeground(color(120))
                   .setColorActive(color(255,0,0))
                   .setColorLabel(color(0))
                   .setItemsPerRow(1)
                   .setSpacingColumn(100)
                   .addItem("Interessantheit (mehr Variation)", 1)
                   .addItem("Datum hinzugefuegt (weniger Variation)", 2)
                   .activate(0);
         
    cp5.addTextlabel("SizeLabel")
                    .setText("Groesse eines Mosaikpixels (in Pixeln):")
                    .setPosition(670,120)
                    .setColor(0x00000000);
                    
  sizeSlider = cp5.addSlider("mosaicSizeValue")
                  .setPosition(670, 135)
                  .setRange(1, 100)
                  .setValue(50)
                  .setDecimalPrecision(0)
                  .setSize(300,20);

  cp5.addTextlabel("sizeWarning")
      .setText("Hinweis: Das Einstellen eines kleinen Wertes\r\nkann die Ladezeit drastisch erhoehen!\r\n\r\nBitte nach der Aenderung die Bilder neu laden!")
      .setPosition(670,160)
      .setFont(createFont("", 14))
      .setColor(color(255,0,0));
    
        cp5.addTextlabel("LupeLabel")
           .setText("Vergroesserungsfaktor:")
           .setPosition(670,225)
           .setColor(0x00000000);

        enableMagnification = cp5.addCheckBox("LupeAktivieren")
              .setPosition(790, 225)
              .setColorForeground(color(120))
              .setColorActive(color(255,0,0))
              .setColorLabel(color(0))
              .setSpacingRow(20)
              .addItem("Lupe aktivieren", 1)
              .activate(0);
              
   scaleValueSlider = cp5.addSlider("scaleValue")
                  .setPosition(670, 240)
                  .setRange(1, 3)
                  .setValue(2)
                  .setSize(300,20);
}
