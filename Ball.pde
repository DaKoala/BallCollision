class Ball {
  PVector pos, vel, acc;
  int radius, mass;
  color cover;

  Ball(float _posX, float _posY, float _velX, float _velY, int _radius, color _cover) {
    this.pos = new PVector(_posX, _posY);
    this.radius = _radius;
    this.cover = _cover;
    this.mass = this.radius * this.radius; // Here I assume the mass is propotional to the square of radius
    this.vel = new PVector(_velX, _velY);
    this.acc = new PVector(0, 0);
  }

  void move() {
    checkBound(LT, RT, TP, BM);
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc = new PVector(0, 0);
  }
  
  /**
   * Check the bound and reset the position of the ball
   */
  void checkBound(int left, int right, int top, int bottom) {
    if (this.pos.x - this.radius < left || this.pos.x + this.radius > right) {
      applyForce(new PVector(-this.vel.x * 2, 0));
      float resetX = this.pos.x - this.radius < left ? left + this.radius : right - this.radius;
      this.pos = new PVector(resetX, this.pos.y);
    }

    if (this.pos.y - this.radius < top || this.pos.y + this.radius > bottom) {
      applyForce(new PVector(0, -this.vel.y * 2));
      float resetY = this.pos.y - this.radius < top ? top + this.radius : bottom - this.radius;
      this.pos = new PVector(this.pos.x, resetY);
    }
  }

  void applyForce(PVector force) {
    this.acc.add(force);
  }
  
  void gravity() {
    applyForce(G);
  }

  void show() {
    fill(this.cover);
    ellipse(this.pos.x, this.pos.y, this.radius * 2, this.radius * 2);
  }

  /** 
   * Compute the square of this ball and another ball. Use square rather than sqrt to save time
   * @param other: the other ball
   * @return: the square of the distance
   */
  float distSq(Ball other) {
    float dx = this.pos.x - other.pos.x;
    float dy = this.pos.y - other.pos.y;
    return dx * dx + dy * dy;
  }
  
  /**
   * Compute the distance between this ball and another ball.
   * @param other: the other ball
   * @return: the distance
   */
  float distOf(Ball other) {
    return this.pos.dist(other.pos);
  }
  
  /**
   * Determine whether two balls will collide in the next frame to avoid merging
   * @param other: the other ball
   * @return: whether they will collide in the next frame
   */
  boolean collideNextFrame(Ball other) {
    PVector thisNext = this.pos.copy();
    thisNext.add(this.vel);
    PVector otherNext = other.pos.copy();
    otherNext.add(other.vel);
    float dxNext = thisNext.x - otherNext.x;
    float dyNext = thisNext.y - otherNext.y;
    return dxNext * dxNext + dyNext * dyNext < (this.radius + other.radius) * (this.radius + other.radius);
  }
  
  /**
   * Use conservation of energy and conservation of momentum to handle the collision of two balls
   * @param other: the other ball
   */
  void handleCollide(Ball other) {
    float dx = this.pos.x - other.pos.x;
    float dy = this.pos.y - other.pos.y;
    PVector s = new PVector(dx, dy);
    s.normalize(); // Unit vector that in the same orientation of the connecting line of the two center
    PVector t = s.copy();
    t.rotate(HALF_PI); // Unit vector that is verticle to the orientation of the connection line of the two center
    
    // Decompose the velocity according to s and t
    float v1s = this.vel.dot(s);
    float v1t = this.vel.dot(t);
    float v2s = other.vel.dot(s);
    float v2t = other.vel.dot(t);
    
    // Combine conservation of energy and conservation of momentum to compute the new velocity in orientation s
    // Velocity in orientation t will not change
    float newV1s = ((this.mass - other.mass) * v1s + 2 * other.mass * v2s) / (this.mass + other.mass);
    float newV2s = ((other.mass - this.mass) * v2s + 2 * this.mass * v1s) / (this.mass + other.mass);
    
    // Add velocities in two orientation to get the final velocity
    PVector finalV1s = s.copy();
    finalV1s.mult(newV1s);
    PVector finalV1t = t.copy();
    finalV1t.mult(v1t);
    finalV1s.add(finalV1t);
    this.vel = finalV1s;

    PVector finalV2s = s.copy();
    finalV2s.mult(newV2s);
    PVector finalV2t = t.copy();
    finalV2t.mult(v2t);
    finalV2s.add(finalV2t);
    other.vel = finalV2s;
    
    // An interesting function. Exchange the color of two balls when they collide
    color tempColor = this.cover;
    this.cover = other.cover;
    other.cover = tempColor;
  }
}