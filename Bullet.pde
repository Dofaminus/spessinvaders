class Bullet extends GameObject{
  private int damage;
  private int lifeTime; // current living time
  private int maxLifeTime; // after this time the bullet disappears
  
  public Bullet(){
    //this.setCollisionR(3);
  }
    
  public void fly(){
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
}
