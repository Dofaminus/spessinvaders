class Bullet extends GameObject{
  private int damage;
  private int lifeTime; // current living time
  private int maxLifeTime; // after this time the bullet disappears
  private PShape model;
  
  public Bullet(float x, float y, float z, float vx, float vy, float vz, float r, int maxLifeTime, int damage){
    super();
    this.setCollisionR(r);
    setPosX(x); setPosY(y); setPosZ(z);
    setVelX(vx); setVelY(vy); setVelZ(vz);
    this.maxLifeTime = maxLifeTime;
    this.damage = damage;
    this.model = PLAYER_BULLET_MODEL;
  }
  
  @Override
  public void frameMove(){
    super.frameMove();
    if(lifeTime >= maxLifeTime){
      println("Delete");
    }
    lifeTime++;
  }
  
  public int getDamage(){
    return damage;
  }
  
  public boolean isTimeOver(){
    return lifeTime >= maxLifeTime;
  }
  
  public void display(){
    pushMatrix();
    translate(getPosX(), getPosY(), getPosZ());
    shape(model);
    popMatrix();
  }
}
