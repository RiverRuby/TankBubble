/* 
  _____          _     ___      _    _    _     
 |_   ___ _ _ _ | |__ | _ )_  _| |__| |__| |___ 
   | |/ _` | ' \| / / | _ | || | '_ | '_ | / -_)
   |_|\__,_|_||_|_\_\ |___/\_,_|_.__|_.__|_\___|
                                                 
 Lexington High School APCS Final Project
 Written by Vivek Bhupatiraju and Harrison Liu
 Modified by Andrew Gritsevskiy '18
 */

/******************************
 IMPORT
 *******************************/

import java.util.LinkedList;
import java.util.HashMap;


/******************************
 Game variables
 *******************************/
boolean RESPECT_WALLS = false;
boolean BULLETS_RESPECT_WALLS = true;

/******************************
 CLASS DEFINITIONS
 *******************************/

class Tank
{
  float currentAngle;
  float x, y;
  int bulletCount = 5;
  int startTime = 0;
  boolean alive = true;

  Tank(float x, float y)
  {
    this.currentAngle = random(0, TWO_PI); // random angle
    this.x = x;
    this.y = y;
  }
}

class Bullet
{
  float currentAngle;
  float x, y;
  int timeLeft; // lasts for 5 seconds
  int id;
  color c;

  Bullet(float angle, float x, float y, int id, color c)
  {
    this.currentAngle = angle;
    this.x = x;
    this.y = y;
    timeLeft = millis();
    this.id = id;
    this.c = c;
  }
}

class Line
{
   int x1, y1, x2, y2;
   Line(int x1, int y1, int x2, int y2)
   {
     this.x1 = x1;
     this.x2 = x2;
     this.y1 = y1;
     this.y2 = y2;
   } 
}

class Coor
{
  public int x, y;
  Coor(int x, int y) {this.x = x; this.y = y;}
  
  public boolean equals (Object O) {
    if (!(O instanceof Coor)) return false;
    if (((Coor) O).x != x) return false;
    if (((Coor) O).y != y) return false;
    return true;
  }
  
  public int hashCode() {
    return (x << 16) + y;
  }
}

/******************************
 DATA STRUCTURES
 *******************************/

PFont font;
LinkedList<Bullet> activeBullet;
LinkedList<Tank> activeTank;
LinkedList<ArrayList<Integer>> border;
LinkedList<Line> maze;
HashMap<Coor, Integer> board;
boolean redChange, greenChange, loading, instructions;
boolean redDead = false, greenDead = false, redInd, greenInd;
int numDead;
double time;
boolean skip;

int loadpercent = 0, instpercent = 0, redScore = 0, greenScore = 0;

int count;
boolean[] keys;

/******************************
 SETUP / DRAW
 *******************************/

void setup()
{
  background(209);
  size(520, 640);
  imageMode(CENTER);
  ellipseMode(CENTER);
  
  font = createFont("Gill Sans MT", 36);
  loading = false; // for debugging
  
  loadGame();
}

void draw()
{
 if (redDead || greenDead) {
   delay(1000);
   redDead = greenDead = false;
   noStroke();
   fill(209);
   rect(0,520,520,640);
 }
 
 if (loading) loadingScreen(loadpercent++);
 else if (instructions) instructions(instpercent++);
 else makeBoard();
 
 if (skip) {
   newGame();
   loadGame();
 }
 if (redDead) {
   textSize(32);
   textAlign(CENTER, CENTER);
   textFont(font);
   fill(255,0,0);
   text("Red was popped!", 260, 580);
 } else if (greenDead) {
   textSize(32);
   fill(0,255,0);
   textAlign(CENTER, CENTER);
   textFont(font);
   text("Green was popped!", 260, 580);
 } else if (newGame()) loadGame();
}

/******************************
 FUNCTIONS
 *******************************/

void loadGame()
{
  numDead = 0;
  time = 0.0;
  redInd = greenInd = false;
  skip = false;
  redChange = true; greenChange = true;
  keys = new boolean[10000]; // Whatever
  activeBullet = new LinkedList<Bullet>();
  activeTank = new LinkedList<Tank>();
  border = new LinkedList<ArrayList<Integer>>();
  maze = new LinkedList<Line>();
  board = new HashMap<Coor, Integer>();
  generateMaze();
  addPoints();
  spawnTanks();
}

boolean newGame()
{
  if (time != 0.0 && numDead == 1 && millis() - time > 5000) {
    if (redInd) {
      greenScore++;
      textSize(32);
      fill(0,255,0);
      textAlign(CENTER, CENTER);
      textFont(font);
      text("Point for Green!", 260, 580);
    }
    
    if (greenInd) {
      redScore++;
      textSize(32);
      fill(255,0,0);
      textAlign(CENTER, CENTER);
      textFont(font);
      text("Point for Red!", 260, 580);
    }
    
    redDead = greenDead = true;
    
    return true;
  }
  
  else if (numDead == 2) {
    textSize(32);
    fill(0,0,255);
    textAlign(CENTER, CENTER);
    textFont(font);
    text("No points awarded.", 260, 580);
    redDead = greenDead = true;
    return true;
  }
  
  return false;
}

void generateMaze()
{
  int[][][] segment = {
    {{20, 20, 20, 500},
    {20, 20, 500, 20},
    {500, 20, 500, 500},
    {20, 500, 500, 500},
    {100, 20, 100, 340},
    {20, 420, 180, 420},
    {180, 260, 180, 420},
    {180, 100, 180, 180},
    {180, 100, 260, 100},
    {260, 100, 260, 420},
    {260, 420, 340, 420},
    {340, 340, 340, 420},
    {340, 100, 340, 260},
    {340, 100, 500, 100},
    {420, 180, 420, 500}}
    
    ,
    
    {{20, 20, 20, 500},
    {20, 20, 500, 20},
    {500, 20, 500, 500},
    {20, 500, 500, 500},
    {100, 20, 100, 100},
    {100, 100, 340, 100},
    {20, 180, 340, 180},
    {100, 260, 340, 260},
    {100, 340, 340, 340},
    {100, 420, 500, 420},
    {420, 20, 420, 340}}
    
    ,
    
    {{20, 20, 20, 500},
    {20, 20, 500, 20},
    {500, 20, 500, 500},
    {20, 500, 500, 500},
    {100, 100, 420, 100},
    {100, 420, 420, 420},
    {260, 100, 260, 420},
    {100, 260, 420, 260},
    {100, 180, 100, 340},
    {100, 180, 180, 180},
    {100, 340, 180, 340},
    {420, 180, 420, 340},
    {340, 180, 420, 180},
    {340, 340, 420, 340}}
    
    ,
    
    {{20, 20, 20, 500},
    {20, 20, 500, 20},
    {500, 20, 500, 500},
    {20, 500, 500, 500},
    {250, 20, 250, 100},
    {250, 120, 250, 360},
    {250, 380, 250, 480}}    
  };
  
  int ii = int(random(0, segment.length));
  
  for (int[] l : segment[ii]) maze.add(new Line(l[0], l[1], l[2], l[3])); 
}

void addPoints()
{
  for (Line l : maze)
  {
     if (l.x1 == l.x2) { // vertical
       for (int i = min(l.y1, l.y2); i <= max(l.y1, l.y2); i++) {
          board.put(new Coor(l.x1, i), 1);
       }
     }
     
     else { // horizontal
       for (int i = min(l.x1, l.x2); i <= max(l.x1, l.x2); i++) {
          board.put(new Coor(i, l.y1), 2);
       }
     }
  }
}

boolean moveValid(int id, float xc, float yc)
{
  Tank t = activeTank.get(id);
  for (int i = max(20, (int)(t.x+xc)-30); i <= min(500, (int)(t.x+xc)+30); i++)
  for (int j = max(20, (int)(t.y+yc)-30); j <= min(500, (int)(t.y+yc)+30); j++)
    if (board.containsKey(new Coor(i, j)) && board.get(new Coor(i, j)) != 0)
    {
      if (within(20, i, j, (int)(activeTank.get(id).x + xc), (int)(activeTank.get(id).y + yc))) return false;
    }
  
  return true;
}




void spawnTanks()
{
  activeTank.add(new Tank(60, 60));
  activeTank.add(new Tank(460, 460));
}

void updateTanks()
{
  if (keys[0] && moveValid(0, cos(-activeTank.get(0).currentAngle)*3, sin(-activeTank.get(0).currentAngle)*3)) {
    activeTank.get(0).y += sin(-activeTank.get(0).currentAngle)*3;
    activeTank.get(0).x += cos(-activeTank.get(0).currentAngle)*3;
  } else if (keys[0] && !RESPECT_WALLS) {
    activeTank.get(0).y += sin(-activeTank.get(0).currentAngle)*0.3;
    activeTank.get(0).x += cos(-activeTank.get(0).currentAngle)*0.3;
  } 
  if (keys[1] && moveValid(0, -cos(-activeTank.get(0).currentAngle)*3, -sin(-activeTank.get(0).currentAngle)*3)) {
    activeTank.get(0).y -= sin(-activeTank.get(0).currentAngle)*3;
    activeTank.get(0).x -= cos(-activeTank.get(0).currentAngle)*3;
  } else if (keys[1] && !RESPECT_WALLS) {
    activeTank.get(0).y -= sin(-activeTank.get(0).currentAngle)*0.3;
    activeTank.get(0).x -= cos(-activeTank.get(0).currentAngle)*0.3;
  } 
  if (keys[2]) {
    activeTank.get(0).currentAngle += PI/48;
  } 
  if (keys[3]) {
    activeTank.get(0).currentAngle -= PI/48;
  } 
  if (keys[5] && moveValid(1, cos(-activeTank.get(1).currentAngle)*3, sin(-activeTank.get(1).currentAngle)*3)) {
    activeTank.get(1).y += sin(-activeTank.get(1).currentAngle)*3;
    activeTank.get(1).x += cos(-activeTank.get(1).currentAngle)*3;
  } else if (keys[5] && !RESPECT_WALLS) {
    activeTank.get(1).y += sin(-activeTank.get(1).currentAngle)*0.3;
    activeTank.get(1).x += cos(-activeTank.get(1).currentAngle)*0.3;
  } 
  if (keys[6] && moveValid(1, -cos(-activeTank.get(1).currentAngle)*3, -sin(-activeTank.get(1).currentAngle)*3)) {
    activeTank.get(1).y -= sin(-activeTank.get(1).currentAngle)*3;
    activeTank.get(1).x -= cos(-activeTank.get(1).currentAngle)*3;
  } else if (keys[6] && !RESPECT_WALLS) {
    activeTank.get(1).y -= sin(-activeTank.get(1).currentAngle)*0.3;
    activeTank.get(1).x -= cos(-activeTank.get(1).currentAngle)*0.3;
  } 
  if (keys[7]) {
    activeTank.get(1).currentAngle += PI/48;
  } 
  if (keys[8]) {
    activeTank.get(1).currentAngle -= PI/48;
  }
  if (keys[4] && redChange && activeTank.get(0).bulletCount > 0 && activeTank.get(0).alive) {
    activeTank.get(0).bulletCount--;
    Tank t = activeTank.get(0);
    activeBullet.add(new Bullet(TWO_PI - t.currentAngle, t.x + 20*(cos(TWO_PI - t.currentAngle)), t.y + 20*(sin(TWO_PI - t.currentAngle)), 0, randColor()));
    redChange = false;
  }
  if (keys[9] && greenChange && activeTank.get(1).bulletCount > 0 && activeTank.get(1).alive) {
    activeTank.get(1).bulletCount--;
    Tank t = activeTank.get(1);
    activeBullet.add(new Bullet(TWO_PI - t.currentAngle, t.x + 20*(cos(TWO_PI - t.currentAngle)), t.y + 20*(sin(TWO_PI - t.currentAngle)), 1, randColor()));
    greenChange = false;
  }
  if (keys[10]) {
    skip = true;
  }
  
}

void displayTanks()
{
  for (int i = 0; i < 2; i++)
    if (activeTank.get(i).alive)
    {
      Tank t = activeTank.get(i);
      PImage img = loadImage(Integer.toString(i+1) + ".png");
      img.resize(40, 40);
  
      translate(int(t.x), int(t.y));
      rotate(-t.currentAngle);
      image(img, 0, 0);
  
      rotate(t.currentAngle);
      translate(-t.x, -t.y);
    } else {
      Tank t = activeTank.get(i);
      PImage img = loadImage(Integer.toString(i+1) + "dead.png");
      img.resize(40, 40);
  
      translate(int(t.x), int(t.y));
      rotate(-t.currentAngle);
      image(img, 0, 0);
  
      rotate(t.currentAngle);
      translate(-t.x, -t.y);
    }
}

double bulletXSpeed = 3;
double bulletYSpeed = 3;

void updateBullets()
{
  for (int i = 0; i < activeBullet.size(); i++)
  {
    Bullet b = activeBullet.get(i);
    if (millis() - b.timeLeft > 8000)
    {
      activeTank.get(activeBullet.get(i).id).bulletCount++;
      activeBullet.remove(i);
      
      i--;
    } 
     
    else 
    {
      b.y += sin(b.currentAngle) * bulletXSpeed;
      b.x += cos(b.currentAngle) * bulletYSpeed;
      
      if (BULLETS_RESPECT_WALLS) { 
        for (int k = (int)b.x-8; k <= b.x+8; k++)
          for (int j = (int)b.y-8; j <= b.y+8; j++)
             if (board.containsKey(new Coor(k, j)) && board.get(new Coor(k, j)) != 0)
             {
               if (within(3, k, j, (int)(b.x), (int)(b.y)))
               {
                  if (board.get(new Coor(k, j)) == 1) b.currentAngle = ((PI - b.currentAngle) + TWO_PI) % TWO_PI;
                  else if (board.get(new Coor(k, j)) == 2) b.currentAngle = TWO_PI - b.currentAngle;
               }
             }
      }
      }
    
  }  
}

void displayBullets()
{
  for (int i = 0; i < activeBullet.size(); i++)
  {
      fill( activeBullet.get(i).c );
      ellipse(activeBullet.get(i).x, activeBullet.get(i).y, 10, 10);
  }
}

void checkAlive()
{
  for (int i = 0; i < 2; i++)
    if (activeTank.get(i).alive)
    {
      Tank t = activeTank.get(i);
      for (int j = 0; j < activeBullet.size(); j++)
      {
        Bullet b = activeBullet.get(j);
        if (within(20, (int)t.x, (int)t.y, (int)b.x, (int)b.y)) 
        {          
          if (t.alive == true) t.alive = false;
          
          activeBullet.remove(j);
          j--;
          
          if (i == 0) {redDead = true; return ;}
          else {greenDead = true; return ;}
        }
      }
    }
}

void updateScore()
{   
   textAlign(LEFT, CENTER);
   textSize(64);
   textFont(font);
   fill(255,0,0);
   text(redScore, 50, 580);
   
   textAlign(RIGHT, CENTER);
   textSize(64);
   textFont(font);
   fill(0,255,0);
   text(greenScore, 470, 580);
}

void makeBoard()
{
  checkAlive();
  
  if (redDead) {
    if (time == 0) time = millis();
    redInd = true;
    numDead++; return ;
  }
  if (greenDead) {
    if (time == 0) time = millis();
    greenInd = true;
    numDead++; return ;
  }
  if (skip) {
    return ;
  }
  
  clearBoard();
  
  // UPDATES and ADDS tanks
  updateTanks();
  displayTanks();
  
  // UPDATES and ADDS bullets
  updateBullets();
  displayBullets();
  
  // UPDATES scores
  updateScore();
}

void keyPressed()
{
  if (key == CODED) {
    if (keyCode == UP) keys[0] = true;
    if (keyCode == DOWN) keys[1] = true;
    if (keyCode == LEFT) keys[2] = true;
    if (keyCode == RIGHT) keys[3] = true;
  } else {
    if (key == 'm' || key == 'M') {keys[4] = true;}
    if (key == 'e' || key == 'E') keys[5] = true;
    if (key == 'd' || key == 'D') keys[6] = true;
    if (key == 's' || key == 'S') keys[7] = true;
    if (key == 'f' || key == 'F') keys[8] = true;
    if (key == 'q' || key == 'Q') keys[9] = true;
    if (key == 'z' || key == 'Z') keys[10] = true;
  }
}

void keyReleased()
{
  if (key == CODED) {
    if (keyCode == UP) keys[0] = false;
    if (keyCode == DOWN) keys[1] = false;
    if (keyCode == LEFT) keys[2] = false;
    if (keyCode == RIGHT) keys[3] = false;
  } else {
    if (key == 'm' || key == 'M') {keys[4] = false; redChange = true;}
    if (key == 'e' || key == 'E') keys[5] = false;
    if (key == 'd' || key == 'D') keys[6] = false;
    if (key == 's' || key == 'S') keys[7] = false;
    if (key == 'f' || key == 'F') keys[8] = false;
    if (key == 'q' || key == 'Q') {keys[9] = false; greenChange = true;}
    if (key == 'z' || key == 'Z') keys[10] = false;
  }
}

void waitMSec(int time)
{
  int start = millis();
  while (millis() - start < time) ;
}

/******************************
 UTILITY
 *******************************/

void clearBoard()
{
  noStroke();
  fill(255);
  rect(0, 0, 520, 520);
  fill(200);
  rect(20, 20, 480, 480);
  for (Line l : maze) {
    stroke(0);
    line(l.x1, l.y1, l.x2, l.y2);
  }
}

void loadingScreen(int frac)
{  
  imageMode(CENTER);
  PImage img = loadImage("logo.png");
  image(img, 260, 300, img.width/1.4, img.height/1.4);  
  
  if (frac == 101) {
    waitMSec(1000);
    loading = false;
    instructions = true;
    return ;
  }
  
  fill(255);
  noStroke();
  rect(240, 345, 200, 20);
  fill(45);
  noStroke();
  rect(240, 345, 2*frac, 20);
}

void instructions(int frac)
{
  background(255);
  imageMode(CENTER);
  PImage img = loadImage("instructions.png");
  image(img, 260, 320, img.width*0.9, img.height*0.9);
 
  if (frac == 150) {
     instructions = false;
     background(209);
     return ;
  }
}

boolean within(int w, int x1, int y1, int x2, int y2)
{
  if ((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) <= w*w) return true;
  else return false;  
}

int rand(int min, int max) {
  return (int) random(max - min) + min;
}

color randColor() {
  return color(rand(0, 255), rand(0, 255), rand(0, 255));
}
