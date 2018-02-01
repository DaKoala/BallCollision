ArrayList<Ball> ballList = new ArrayList<Ball>();
PVector G; // Assigned by user. Is not used in this program
int LT, RT, TP, BM; // Bounds

void setup() {
  size(1600, 900);
  LT = 0;
  RT = width;
  TP = 0;
  BM = height;
  noStroke();
}

void draw() {
  background(0);
  for (int i = 0; i < ballList.size(); i++) {
    ballList.get(i).move();
    ballList.get(i).show();
    for (int j = i; j < ballList.size(); j++) {
      if (j != i && ballList.get(i).collideNextFrame(ballList.get(j))) {
        ballList.get(i).handleCollide(ballList.get(j));
      }
    }
  }
}


void mousePressed() {
  ballList.add(new Ball(mouseX, mouseY, random(-10, 10), random(-10, 10), (int) random(30, 100), color(random(0, 255), random(0, 255), random(0, 255))));
}