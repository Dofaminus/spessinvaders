enum ActionFieldState{
  INIT,
  PREPARING,
  PREBATTLE_INFO,
  BATTLE,
  GAMEOVER,
  CLEARED,
  VICTORY
}

class ActionField{
  private MainStarship mainStarship;
  private List<List<Starship>> enemies;
  private List<Bullet> bullets;
  private List<Planet> planets;
  private List<ExplosionEffect> effects;
  private Control control;
  private ControlKeyboard controlKeyboard;
  private WaveGenerator waveGenerator;
  private UIInfo uiInfo;
  
  private int bulletTiming = 50;
  private int prepareTiming;
  private int clearedTiming;

  private ActionFieldState state = ActionFieldState.INIT;
  private PreparingInfo preparingInfo;

  private int currentLevel;
  private int enemyNumber;
  private List<Starship> waveList;

  private PShape skySphereModel;
  private PImage skySphereTexture;


  
  private float skyBoxSize = 17000f;
  private float skyBoxRotation;
  
  private PImage crosshair = loadImage(CROSSHAIR_IMG_PATH);

  private int redScreenTiming = 0;

  private float camInitX = 0, camInitY = -18, camInitZ = -48;
  private float easing = 0.09;

  private StarDrawer sd;

  private BackgroundCamera cam = new BackgroundCamera(camInitX, camInitY, camInitZ,
                                                      camInitX, camInitY, camInitZ + 0.1,
                                                      0, 1, 0);

  public ActionField(List<Planet> planets){
    bullets = new ArrayList<>();
    this.planets = planets;

    skySphereModel = loadShape(PLANET_MODEL_PATH);
    skySphereTexture = loadImage(SKYSPHERE_TEXTURE_PATH);
    skySphereModel.setTexture(skySphereTexture);
    skySphereModel.scale(skyBoxSize);
    
    waveGenerator = new WaveGenerator(-WIDTH, HEIGHT);
    mainStarship = new MainStarship(PLAYER_HEALTH, PLAYER_SHIELD);

    if(DEVICE == Device.GAMEPAD){
      control = new Control();  
    } else if(DEVICE == Device.KEYBOARD){
      controlKeyboard = new ControlKeyboard();    
    }
  }
  
  private void displayScreen(color bgColor, String text, color textColor){
    pushMatrix();
    rotateY(PI);
    textSize(180);
    
    hint(DISABLE_DEPTH_TEST);
    fill(bgColor);
    rect(-width, -height, 3*width, 3*height);
    fill(textColor);
    //text(text, - cam.getX() - 1.9 * width, - 1.8 * height + cam.getY(), - 2 * height);
    text(text, - cam.getX(),cam.getY(), - 2 * height);
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }

  private void displayAxis(float x, float y, float z){
    pushMatrix();

      //X  - red
      stroke(192,0,0);
      line(x, y, z, x + AXIS_SCALE * 1000, y, z);
      text("X", x + AXIS_SCALE * 1000, y, z);

      //Y - green
      stroke(0,192,0);
      line(x, y, z, x, y + AXIS_SCALE * 1000, z);
      text("Y", x, y + AXIS_SCALE * 1000, z);

      //Z - blue
      stroke(0,0,192);
      line(x, y, z, x, y, z + AXIS_SCALE * 1000);
      text("Z", x, y, z + AXIS_SCALE * 1000);
    popMatrix();  
  }

  private void displayAll(){
    pushMatrix();
    noLights();
    rotateY(skyBoxRotation);
    //translate(-skyBoxSize / 2, -skyBoxSize / 2, -skyBoxSize / 2);
    //shape(skyBoxModel);
    shape(skySphereModel);
    popMatrix();
    lights();


    float tx = cam.getX();
    float ty = cam.getY();

    Iterator<ExplosionEffect> iterEffect = effects.iterator();
    while(iterEffect.hasNext()){
      ExplosionEffect effect = iterEffect.next(); 
      if(!effect.display()){
        iterEffect.remove();
      }
    }

    switch(DEVICE){
      case MOUSE:
        cam.setX(lerp(cam.getX(), -coeffX*mouseX, easing));
        cam.setY(lerp(cam.getY(), coeffY*mouseY, easing));
    
        bulletTiming--;
        if(mousePressed && (mouseButton == LEFT) && state == ActionFieldState.BATTLE){
          if( bulletTiming < 0 ){
              bullets.add(mainStarship.shot());
              audioController.playOnceShot();
            bulletTiming = (int)(10 / MULTIPLIER_FIRE_RATE_PLAYER);    
          }
        }
        break;
      case GAMEPAD:
        cam.setX(lerp(cam.getX(), -coeffX*control.getX(), easing));
        cam.setY(lerp(cam.getY(), coeffY*control.getY(), easing));
    
        bulletTiming--;
        if(control.isPressed() && state == ActionFieldState.BATTLE){
          if( bulletTiming < 0 ){
              bullets.add(mainStarship.shot());
              audioController.playOnceShot();
            bulletTiming = (int)(10 / MULTIPLIER_FIRE_RATE_PLAYER);    
          }
        }
        break;
        
      case KEYBOARD:
        cam.setX(lerp(cam.getX(), -coeffX*controlKeyboard.getX(), easing));
        cam.setY(lerp(cam.getY(), coeffY*controlKeyboard.getY(), easing));
    
        bulletTiming--;
        if(controlKeyboard.isPressed() && state == ActionFieldState.BATTLE){
          if( bulletTiming < 0 ){
              bullets.add(mainStarship.shot());
              audioController.playOnceShot();
            bulletTiming = (int)(10 / MULTIPLIER_FIRE_RATE_PLAYER);    
          }
        }
        break;
      }
    
    mainStarship.setPosX(cam.getX() - camInitX);
    mainStarship.setPosY(cam.getY() - camInitY);
    mainStarship.setPosZ(cam.getZ() - camInitZ);
    pointLight(255,255,127, cam.getX() - camInitX + random(-5, 5), cam.getY() - camInitY + 1 + random(-5, 5), cam.getZ() - camInitZ - 40 + random(-5, 5));
    mainStarship.display(cam.getX(), cam.getY(), cam.getZ(), 0, 0, 1, 0.015 * (tx - cam.getX()));

    //displayAxis(cam.getX() - camInitX, cam.getY() - camInitY, cam.getZ() - camInitZ);

    pushMatrix();
    //translate(cam.getX(), cam.getY(), -cam.getZ());
    translate(tx, ty, -cam.getZ());
    sd.update();
    sd.show();
    popMatrix();

    pushMatrix();
    translate(cam.getX() - camInitX - 100, cam.getY() - camInitY - 100, cam.getZ() - camInitZ + 600); 
    scale(2);
    hint(DISABLE_DEPTH_TEST);
    image(crosshair, 0, 0);
    hint(ENABLE_DEPTH_TEST);
    popMatrix();

    camera(cam.getX(), cam.getY(), cam.getZ(), cam.getX(), cam.getY(), cam.getZ() + 0.1, 0, 1, 0);
  }

  private void displayAllEnemies(){
    for(List<Starship> ssList : enemies){
      for(Starship ss : ssList){
        ss.display(cam.getX(), cam.getY(), cam.getZ(), 0, 0, 1); 
      }
    }
  }

  public Signal calculateActions(int level){    
    switch(state){
      case INIT:
        mainStarship.setShield(PLAYER_SHIELD);
        preparingInfo = new PreparingInfo();
        effects = new ArrayList<>();
        skyBoxRotation = random(-PI, PI);
        bullets.clear();
        currentLevel = level;
        enemies = new ArrayList<>();
        for(int j = 0; j < NUMBER_OF_WAVES; j++){
          List<Starship> waveListGen = new ArrayList<>();
        
          enemyNumber = planets.get(currentLevel).getEnemyNumber();
          for(int i = 0; i < enemyNumber; i++){
            for(int k = 0; k < enemyNumber; k++){
              //waveListGen.add(new EnemyStarship(ENEMY_LIGHT_HEALTH, ENEMY_LIGHT_SHIELD, -80 - i * 130, 80 + k * 130, 1400 * (1 + j)));        
            }            
          }
          
          waveListGen = waveGenerator.Generator(enemyNumber);
          
          for(int i = 0; i < waveListGen.size(); i++){
              waveListGen.get(i).setVelZ(-0.5f * MULTIPLIER_SPEED_ENEMY);
              waveListGen.get(i).setPosZ(800 * (j + 1));
          }
                        

          enemies.add(waveListGen);
        }
        uiInfo = new UIInfo(mainStarship, enemies);

        sd = new StarDrawer();
        
        state = ActionFieldState.PREPARING;
        prepareTiming = (int)(80 * MULTIPLIER_SCREEN_TRANSISTION);
        clearedTiming = (int)(80 * MULTIPLIER_SCREEN_TRANSISTION);
        break;
      case PREPARING: 
        displayAllEnemies();
        displayAll();
        //displayScreen(prepareScreen);
        displayScreen(color(0,0,0, 180), "PREPARE", color(240,200,80));

        
        pushMatrix();
        preparingInfo.display(cam.getX() + WIDTH / 2, cam.getY() - HEIGHT / 2, cam.getZ()+10);
        popMatrix();
        
        prepareTiming--;
        if(prepareTiming == 0) state = ActionFieldState.BATTLE;
          return Signal.CONTINUE;
      case CLEARED:
        displayAll();
        //displayScreen(clearedScreen);
        displayScreen(color(0,0,0, 180), "CLEARED", color(95,85,149));
        clearedTiming--;
        if(clearedTiming == 0){
          state = ActionFieldState.INIT;
          return Signal.SWITCH;
        }
        return Signal.CONTINUE;
      case VICTORY:
        displayAll();
        //displayScreen(victoryScreen);
        displayScreen(color(0,0,0, 180), "VICTORY", color(102,185,42));
        audioController.stopLoopSounds(false);
        return Signal.CONTINUE;
      case GAMEOVER:
        //displayScreen(gameoverScreen);
        displayScreen(color(0,0,0, 180), "GAME OVER", color(115,41,25));
        audioController.stopLoopSounds(true);
        return Signal.CONTINUE;
      default:
        break;
      }
    
      audioController.playLoopSounds();

    ////Enemy collision check
    
    waveList = enemies.get(0);
    Iterator<Starship> enemyIterator = waveList.iterator();
    while(enemyIterator.hasNext()){
      if(!bullets.isEmpty()){
        Starship enemy = enemyIterator.next();
        Iterator<Bullet> bulletIterator = bullets.iterator();
          while(bulletIterator.hasNext()){
            Bullet bullet = bulletIterator.next();
            if(bullet.isTimeOver()){
              bulletIterator.remove();
              continue;
            }else if(bullet.checkCollision(enemy)){
              bulletIterator.remove();
              if(enemy.setDamage( bullet.getDamage() )){
                enemyIterator.remove();
                effects.add( new ExplosionEffect( enemy.getPosX(), enemy.getPosY(), enemy.getPosZ() ) );
              }; 
              break;      
            }
        }    
      } else {
        break;
      }
    }
    
    //  //enemy.move();                                      // HERE I NEED TO MOVE ENEMY'S STARSHIP
    //}
    
    ////Player collision check
    if(!bullets.isEmpty()){
      Iterator<Bullet> bulletIterator = bullets.iterator();
      while(bulletIterator.hasNext()){
        Bullet bullet = bulletIterator.next();
        if(bullet.checkCollision(mainStarship)){
          audioController.playOnceDamage();
          redScreenTiming = 4;
          bulletIterator.remove();
          if(mainStarship.setDamage( bullet.getDamage() )){
            state = ActionFieldState.GAMEOVER;
            audioController.playOnceExplosion();
            return Signal.CONTINUE;      
          }    
        }
      }
    }

    for(Bullet bullet : bullets){
      bullet.frameMove();
      bullet.display(cam.getX(), cam.getY(), cam.getZ(), 0, 0, 1);
    }
    
    for(List<Starship> wl : enemies){
      for(Starship ss : wl){
        ss.frameMove();      
      }
    }

    displayAllEnemies();

    for(Starship ss: waveList){
        if(random(0, 100) < 1 * MULTIPLIER_FIRE_RATE_ENEMY){
          bullets.add(ss.shot());
        }
    }

    if(waveList.isEmpty()){
      enemies.remove(0);
      if(!enemies.isEmpty()) waveList = enemies.get(0);
    }

    if(!enemies.isEmpty())
      if(waveList.get(0).getPosZ() < 0){
        audioController.playOnceExplosion();
        state = ActionFieldState.GAMEOVER;
        return Signal.CONTINUE;      
      }

    displayAll();

    if(redScreenTiming > 0){
      redScreenTiming--;
      //displayScreen(redScreen);
      displayScreen(color(255,0,0, 180), "DAMAGE!", color(0,0,0));
    }

    uiInfo.display(cam.getX(), cam.getY(), cam.getZ());

    if(enemies.isEmpty()){
      if(currentLevel == planets.size() - 1){
        state = ActionFieldState.VICTORY;
      } else {
        state = ActionFieldState.CLEARED;
      }
    }    
    return Signal.CONTINUE;    
  }
}
