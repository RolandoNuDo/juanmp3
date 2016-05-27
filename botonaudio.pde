import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.signals.*;
import javax.swing.*;
import ddf.minim.effects.*;
import ddf.minim.ugens.*;
import org.elasticsearch.action.admin.indices.exists.indices.IndicesExistsResponse;
import org.elasticsearch.client.Client;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.node.Node;
import org.elasticsearch.node.NodeBuilder;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.signals.*;
import javax.swing.*;
import ddf.minim.effects.*;
import ddf.minim.ugens.*;
import java.util.*;
import java.net.InetAddress;
import javax.swing.*;
import javax.swing.filechooser.FileFilter;
import javax.swing.filechooser.FileNameExtensionFilter;

import org.elasticsearch.action.admin.indices.exists.indices.IndicesExistsResponse;
import org.elasticsearch.action.admin.cluster.health.ClusterHealthResponse;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.client.Client;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.node.Node;
import org.elasticsearch.node.NodeBuilder;
//elastic search
ControlP5 cp5 ,cbar2,cp;
ControlP5 cp3;
ControlP5 cp2;
ControlP5 cp4;
ControlP5 cp6;
ControlP5  low;
ControlP5  med;
ControlP5  hi;

Minim minim;
AudioPlayer song;
Knob myKnobA;
AudioMetaData me;
JFileChooser FileSelector;
AudioMetaData meta;
AudioOutput output;
HighPassSP highpass;
LowPassSP lowpass;
BandPass bandpass;
Textarea myTextarea;
LowPassFS   lpf;
Client client;
Node node;
boolean si;
int Hpass;
int Lpass;
int Bpass;
FFT fft;
PImage img;
static String INDEX_NAME = "canciones";
static String DOC_TYPE = "cancion";
String can =" ";
ScrollableList list;


void setup() {
//  selectInput("Select a file to process:", "fileSelected");
  size(800,533);
  noStroke();
    // Configuracion basica para ElasticSearch en local
  Settings.Builder settings = Settings.settingsBuilder();
  // Esta carpeta se encontrara dentro de la carpeta del Processing
  settings.put("path.data", "esdata");
  settings.put("path.home", "/");
  settings.put("http.enabled", false);
  settings.put("index.number_of_replicas", 0);
  settings.put("index.number_of_shards", 1);

  // Inicializacion del nodo de ElasticSearch
  node = NodeBuilder.nodeBuilder()
          .settings(settings)
          .clusterName("mycluster")
          .data(true)
          .local(true)
          .node();

  // Instancia de cliente de conexion al nodo de ElasticSearch
  client = node.client();

  // Esperamos a que el nodo este correctamente inicializado
  ClusterHealthResponse r = client.admin().cluster().prepareHealth().setWaitForGreenStatus().get();
  println(r);

  // Revisamos que nuestro indice (base de datos) exista
  IndicesExistsResponse ier = client.admin().indices().prepareExists(INDEX_NAME).get();
  if(!ier.isExists()) {
    // En caso contrario, se crea el indice
    client.admin().indices().prepareCreate(INDEX_NAME).get();
  }

  // Agregamos a la vista un boton de importacion de archivos
 cp5 = new ControlP5(this);
  cp = new ControlP5(this);
  cp2 = new ControlP5(this);
 cp3 = new ControlP5(this);
  cp4 = new ControlP5(this);
   low = new ControlP5(this);
   med = new ControlP5(this);
   hi = new ControlP5(this);
  
  
  cp5.addButton("importFiles")
    .setPosition(70, 80)
     .setSize(230, 100)
     .setImages(loadImage("cargar.jpg"), loadImage("cargar.jpg"), loadImage("cargar.jpg"))
    .setLabel("Importar archivos");

  // Agregamos a la vista una lista scrollable que mostrara las canciones
  list = cp5.addScrollableList("playlist")
            .setPosition(480, 100)
            .setSize(230, 100)
            .setBarHeight(20)
            .setItemHeight(20)
            .setType(ScrollableList.LIST);
            
img = loadImage("tabl.jpg");
  cp5 = new ControlP5(this);
  FileSelector = new JFileChooser();
 
  // create a new button with name 'buttonA'
   
   cp5.addButton("PLAY")
     .setPosition(150,400)
     .setImages(loadImage("buplay.png"), loadImage("buplay.png"), loadImage("buplay.png"))
     ;
    
                 
  myTextarea = cp5.addTextarea("tet")
                  .setPosition(220,90)
                  .setSize(250,80)
                  .setFont(createFont("arial",15))
                  .setLineHeight(20)
                  .setColor(color(254-000-000))
                   .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100));
                  ;
                 
      
  
        hi.addSlider("Hpass")
     .setPosition(680,350)
     .setSize(20,100)
     .setRange(0,3000)
     .setValue(0)
      .setNumberOfTickMarks(30);
     
 low.addSlider("Lpass")
     .setPosition(620,350)
     .setSize(20,100)
     .setRange(3000,20000) //100-150
     .setValue(0)
     .setNumberOfTickMarks(30);
     
 med.addSlider("Bpass")
     .setPosition(650,350)
     .setSize(20,100)
     .setRange(100,1000)//250-2500
     .setValue(100)
     .setNumberOfTickMarks(30);
     
 hi.getController("Hpass").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingY(100);
 low.getController("Lpass").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingY(100);
 med.getController("Bpass").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingY(100);
 
  cp.addButton("ST")
     .setPosition(210,400)
     .setImages(loadImage("bustop.png"), loadImage("bustop.png"), loadImage("bustop.png"))
     ;
    
    cp2.addButton("PAUSE")
     .setPosition(100,400)
     .setSize(200,19)
     .setImages(loadImage("bupa.png"), loadImage("bupa.png"), loadImage("bupa.png"))
     ;
     
    cbar2 = new ControlP5(this);
 cbar2.addSlider("Volumen")
     .setPosition(400,400)
     .setSize(110,12)
     .setRange(-30,30)
     .setValue(0)
     .setNumberOfTickMarks(21);
   
 cbar2.getController("Volumen").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingY(100);
 cbar2.getController("Volumen").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(-28).setPaddingY(5);
     
     loadFiles();
}
public void PLAY(){
 // file.play();
  song.play();
}
public void ST(){
//mousePressed();
song.pause();
song.rewind();
song.cue(0);
}


public void PAUSE(){
song.pause();

}
public void controlEvent(ControlEvent theEvent) {
  println(theEvent.getController().getName());
}
int ys = 25;
int yi = 15;


void draw(){
  image(img, 0, 0);
  if(si){
   highpass.setFreq(Hpass);
    lowpass.setFreq(Lpass);
    bandpass.setFreq(Bpass);
   
   fft.forward(song.mix);
  for(int i = 0; i < fft.specSize()-100; i++)
  {
    float band = fft.getBand(i);
    float vo = 370 - band * 4;
    stroke(255);
    line(i +100 , 370, i+100 , vo);
    }
  } 
  
  }
  
 


 void Volumen (float theColor) {
  float mycolor=theColor;
  if (mycolor==-30) {
    song.mute();
  } else{ 
   song.setGain(mycolor); 
   song.unmute();
//song.rewind();
  }
   
  }
  

void iniciar(){
  fft = new FFT(song.bufferSize(), song.sampleRate());
   highpass = new HighPassSP(300, song.sampleRate());
   song.addEffect(highpass);
   lowpass = new LowPassSP(300, song.sampleRate());
   song.addEffect(lowpass);
   bandpass = new BandPass(300, 300, song.sampleRate());
   song.addEffect(bandpass);
     fft = new FFT(song.bufferSize(), song.sampleRate());
   myTextarea.setText( "Artista: " +meta.author() + "    " +" Album: " + meta.album()
  +"      \n          Nombre de la cancion:  " + meta.title());
}

public void importFiles(){
   JFileChooser jfc = new JFileChooser();
   jfc.setFileFilter(new FileNameExtensionFilter("MP3 File", "mp3"));
   jfc.setMultiSelectionEnabled(true);
   jfc.showOpenDialog(null);
   
   for(File f : jfc.getSelectedFiles()) {
    GetResponse response = client.prepareGet(INDEX_NAME, DOC_TYPE, f.getAbsolutePath()).setRefresh(true).execute().actionGet();
    
    if(minim != null){
      minim.stop();
      minim = new Minim(this);
      song = minim.loadFile(f.getAbsolutePath());
      meta = song.getMetaData();
      iniciar();
      si = true;
    } else {
      minim = new Minim(this);
      song = minim.loadFile(f.getAbsolutePath());
      meta = song.getMetaData();
      iniciar();
      si=true;
    }
    
    if(response.isExists()) {
      continue;
    }
   
   Map<String, Object> doc = new HashMap<String, Object>();
    doc.put("author", meta.author());
    doc.put("title", meta.title());
    doc.put("path", f.getAbsolutePath());
    
    try {
      client.prepareIndex(INDEX_NAME, DOC_TYPE, f.getAbsolutePath())
        .setSource(doc)
        .execute()
        .actionGet();

      addItem(doc);
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
}

// Al hacer click en algun elemento de la lista, se ejecuta este metodo
void playlist(int n) { 
    Map<String, Object> value = (Map<String, Object>) list.getItem(n).get("value");
  if(minim != null){
    si=true;
      minim.stop();
      minim = new Minim(this);
      song = minim.loadFile((String)value.get("path"));
      meta = song.getMetaData();
      iniciar();
      si =true;
      
    } else {
   minim = new Minim(this);
   song = minim.loadFile((String)value.get("path"));
   meta = song.getMetaData();
    //text("Title: " + meta.title(), 280, 90);
     fft.logAverages(22, 10);
   iniciar();
   si=true;
    }
}
void loadFiles() {
  try {
    // Buscamos todos los documentos en el indice
    SearchResponse response = client.prepareSearch(INDEX_NAME).execute().actionGet();

    // Se itera los resultados
    for(SearchHit hit : response.getHits().getHits()) {
      // Cada resultado lo agregamos a la lista
      addItem(hit.getSource());
     
    }
  } catch(Exception e) {
    e.printStackTrace();
  }
}

// Metodo auxiliar para no repetir codigo
void addItem(Map<String, Object> doc) {
  // Se agrega a la lista. El primer argumento es el texto a desplegar en la lista, el segundo es el objeto que queremos que almacene
  list.addItem(doc.get("author") + " - " + doc.get("title"), doc);
}

 
 