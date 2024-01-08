  public class WaveGenerator{
  
  private int OFFSET_X = -10;
  private int OFFSET_Y = 10;
  private float maxX, maxY;
  
  public WaveGenerator(int maxX, int maxY) {
    //this.maxX = (float) abs(maxX) > abs(maxY)? maxY * Math.signum(maxX) : maxX;
    //this.maxY = (float) abs(maxX) > abs(maxY)? maxY : Math.signum(maxY) * maxX;
  
    this.maxX = maxX;
    this.maxY = maxY;
  }
  
  public List<Starship> Generator(int enemyCount){
      return Generator(int(random(1, 5)), enemyCount);
  }
  
  public List<Starship> Generator(int type, int enemyCount){
    List<Starship> enemies = new ArrayList<>();
    switch (type) {
      //ellipse
      case 1: 
      for(int i = 0; i < enemyCount; i++){
        enemies.add(new EnemyStarship(ENEMY_LIGHT_HEALTH, ENEMY_LIGHT_SHIELD, 
                                      lerp(maxX - OFFSET_X, OFFSET_X, 0.5 * (1 + sin( 2* PI * (float)i / enemyCount))),
                                      lerp(maxY - OFFSET_Y, OFFSET_Y, 0.5 * (1 + cos( 2* PI * (float)i / enemyCount))), 800) );
      }
      break;
      
      //astroid
      case 2: 
      for(int i = 0; i < enemyCount; i++){
          enemies.add(new EnemyStarship(ENEMY_LIGHT_HEALTH, ENEMY_LIGHT_SHIELD, 
                                        lerp(maxX - OFFSET_X, OFFSET_X, getHypocycloidX(4.0, (float)i / enemyCount)),
                                        lerp(maxY - OFFSET_Y, OFFSET_Y, getHypocycloidY(4.0, (float)i / enemyCount)), 800) );
      }
      break;
      
      //deltoid
      case 3: 
      for(int i = 0; i < enemyCount; i++){
          enemies.add(new EnemyStarship(ENEMY_LIGHT_HEALTH, ENEMY_LIGHT_SHIELD, 
                                        lerp(maxX - OFFSET_X, OFFSET_X, getHypocycloidX(3.0, (float)i / enemyCount)),
                                        lerp(maxY - OFFSET_Y, OFFSET_Y, getHypocycloidY(3.0, (float)i / enemyCount)), 800) );
      }
      break;
      
      //hypocycloid k = 5
      case 4: 
      for(int i = 0; i < enemyCount; i++){
          enemies.add(new EnemyStarship(ENEMY_LIGHT_HEALTH, ENEMY_LIGHT_SHIELD, 
                                        lerp(maxX - OFFSET_X, OFFSET_X, getHypocycloidX(5.0, (float)i / enemyCount)),
                                        lerp(maxY - OFFSET_Y, OFFSET_Y, getHypocycloidY(5.0, (float)i / enemyCount)), 800) );
      }
      break;
 
      //lissajous curve
      case 5: 
      for(int i = 0; i < enemyCount; i++){
        enemies.add(new EnemyStarship(ENEMY_LIGHT_HEALTH, ENEMY_LIGHT_SHIELD, 
                                      lerp(maxX - OFFSET_X, OFFSET_X, 0.5 * (1 + sin( 3 * 2* PI * (float)i / enemyCount))),
                                      lerp(maxY - OFFSET_Y, OFFSET_Y, 0.5 * (1 + sin( 2 * 2* PI * (float)i / enemyCount))), 800) );
      }
      break;
    }

  return enemies;
  }
  
  // r = 1
  // t0 from 0 to 1
  // return from 0 to 1
  private float getHypocycloidX(float k, float t0){
    float t = lerp(0.0, 2 * PI, t0) + PI / k;
    float r = 1 / k * (k - 1) * (cos(t) + cos( (k-1) * t ) / (k - 1));
    return (r + 1) / 2;
  }

  private float getHypocycloidY(float k, float t0){
    float t = lerp(0.0, 2 * PI, t0) + PI / k;
    float r = 1 / k * (k - 1) * (sin(t) - sin( (k-1) * t ) / (k - 1));
    return (r + 1) / 2;    
  }
}
