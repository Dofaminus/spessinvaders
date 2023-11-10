import java.util.List;
import java.util.Iterator;

// --------------------------------------- CUSTOMIZABLE ---------------------------------------
int NUMBER_OF_PLANETS =         4;     // Also number of levels
float MULTIPLIER_ENEMIES =      1.0f;  // Multiplier for the numbers of enemies
float MULTIPLIER_FIRE_RATE =    1.0f;
float MULTIPLIER_SPEED_ENEMY =  1.0f;
float MULTIPLIER_SPEED_PLAYER = 1.0f;
float FPS = 40.0f;

int PLAYER_HEALTH = 50;
int PLAYER_SHIELD = 0;

int ENEMY_LIGHT_HEALTH = 10;
int ENEMY_LIGHT_SHIELD = 0;

int ENEMY_MEDIUM_HEALTH = 30;
int ENEMY_MEDIUM_SHIELD = 10;

int ENEMY_HEAVY_HEALTH = 50;
int ENEMY_HEAVY_SHIELD = 30;

int ENEMY_BOSS_HEALTH = 100;
int ENEMY_BOSS_SHIELD = 60;

float HORIZONTAL_SPEED = 10.0f;
// --------------------------------------- END CUSTOMIZABLE ---------------------------------------

// --------------------------------------- BETTER DO NOT TOUCH ---------------------------------------
float PLANET_SIZE = 10.0f;
float STAR_SIZE = 50.0f;

float LBOUND = 0.0f;
float RBOUND = 800.0f;

float INERTIA = 0.95f;
// --------------------------------------- END BETTER DO NOT TOUCH ---------------------------------------

// --------------------------------------- FILE PATHS ---------------------------------------

String SKYBOX_TEXTURE_PATH = "assets/background/skybox.png";
String SKYBOX_MODEL_PATH = "assets/background/skybox.obj";

String STAR_TEXTURE_PATH = "assets/starSystem/star2.jpg";
String PLANET_TEXTURE_PATH = "assets/starSystem/earth.jpg";
String PLANET_MODEL_PATH = "assets/starSystem/sphere.obj";

String PLAYER_TEXTURE_PATH = "assets/starship/.png";
String PLAYER_MODEL_PATH = "assets/starship/.obj";

String ENEMY_TEXTURE_PATH = "assets/starship/.png";
String ENEMY_MODEL_PATH = "assets/starship/.obj";

String CROSSHAIR_IMG_PATH = "assets/starship/crosshair.png";

// --------------------------------------- END FILE PATHS ---------------------------------------

class Main{
  private ActionField actionField;
  private Background background;
  private List<Planet> planets;
  
  private int currentLevel;

  private int playerShield;
  private int playerHealth;

  public Main(){    
    playerHealth = PLAYER_HEALTH;
    playerShield = PLAYER_SHIELD;
    
    planets = new ArrayList<Planet>();
    for(int i = 0; i < NUMBER_OF_PLANETS; i++){
      int enemyNumber = (int)(MULTIPLIER_ENEMIES * (i + 1) * 10);
      println("Enemy number: " + enemyNumber);
      
      // The last planet always contain boss
      planets.add( new Planet(enemyNumber, i - 1 == NUMBER_OF_PLANETS, PLANET_SIZE ) );
    }
  
    actionField = new ActionField();
    background = new Background(planets);
    currentLevel = 0;
  }
  
  void drawBackground(){
    background.drawBG();
  }
  
  void drawActionField(){
    this.actionField.calculateActions();
  }
   
}

Main main;

void setup(){
  fullScreen(P3D);
  //size(800, 800, P3D);
  main = new Main();
  
  Thread gameThread = new Thread(new Runnable(){
    @Override
    
    // Here is the game actions
    public void run(){
      try{
        while(true){
          Thread.sleep( (long)(1000 / FPS) );
          redraw();
          }
        }catch(InterruptedException e){

        }
      }
  });
  
  gameThread.start();
  noLoop();
}



void draw(){
  background(0);
  
  main.drawBackground();
  
  main.drawActionField();
  
}
