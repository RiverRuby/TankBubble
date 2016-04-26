/* 
  _____          _     _____             _    _     
 |_    __ _ _ _ | |__ |_   __ _ ___ _  _| |__| |___ 
   | |/ _` | ' \| / /   | || '_/ _ | || | '_ | / -_)
   |_|\__,_|_||_|_\_\   |_||_| \___/\_,_|_.__|_\___|
   
   Lexington High School APCS Final Project
   Written by Vivek Bhupatiraju and Harrison Liu
*/

/*
    Table of Contents
    -----------------
    
    - Import
      - LinkedList, HashMap
    - Class Definitions
      - Tank, Bullet, Coordinate
    - Data Structures
      - LinkedList, HashMap
    - Functions
      - makeMaze();
      - spawnTanks();
      - updateBoard();
      - keyPressed();
    - Main Functions
      - Setup, Draw
*/

/******************************
           IMPORT
*******************************/

import java.util.LinkedList;
import java.util.HashMap;

/******************************
       CLASS DEFINITIONS
*******************************/

class Tank
{
  float currentAngle;
  float x, y;
  int bulletCount;
  int startTime = 0;
  
  Tank(float x, float y)
  {
    this.currentAngle = random(0, TWO_PI); // random angle
    println(currentAngle);
    this.x = x;
    this.y = y;
  }
}

class Bullet
{
  float currentAngle;
  int x, y;
  int timeLeft; // lasts for 5 seconds
  
  Bullet(float angle, int x, int y)
  {
    this.currentAngle = angle;
    this.x = x;
    this.y = y;
    timeLeft = millis();
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

LinkedList<Bullet> activeBullet = new LinkedList<Bullet>();
LinkedList<Tank> activeTank = new LinkedList<Tank>();
LinkedList<ArrayList<Integer>> border = new LinkedList<ArrayList<Integer>>();
HashMap<Coor, Integer> board = new HashMap<Coor, Integer>();
int count;
boolean[] keys;

/******************************
         SETUP / DRAW
*******************************/

void setup()
{
 size(520, 520);
 clearBoard();
 imageMode(CENTER);
 
 // Adds Randomized Tanks
 keys = new boolean[2*5];
 
 generateMaze();
 spawnTanks();
}

void draw()
{
  makeBoard();
}

/******************************
          FUNCTIONS
*******************************/

void generateMaze()
{
  
  
}

void spawnTanks()
{
  activeTank.add(new Tank(60, 60));
  activeTank.add(new Tank(460, 460));
}

void updateTanks()
{
  if (keys[0]) {
    activeTank.get(0).y += sin(-activeTank.get(0).currentAngle)*3;
    activeTank.get(0).x += cos(-activeTank.get(0).currentAngle)*3;
  } if (keys[1]) {
    activeTank.get(0).y -= sin(-activeTank.get(0).currentAngle)*3;
    activeTank.get(0).x -= cos(-activeTank.get(0).currentAngle)*3;            
  } if (keys[2]) {
        
  } if (keys[3]) {
        
  }
}

void makeBoard()
{
   clearBoard();
   updateTanks();
   for (int i = 0; i < 2; i++)
   {
      Tank t = activeTank.get(i);
      PImage img = loadImage(Integer.toString(i+1) + ".png");
      
      translate(int(t.x), int(t.y));
      rotate(-t.currentAngle);
      image(img, 0, 0);
      
      rotate(t.currentAngle);
      translate(-t.x, -t.y);
   }
}

void keyPressed()
{
  if (key == CODED) {
     if (keyCode == UP) keys[0] = true;
     if (keyCode == DOWN) keys[1] = true;
     if (keyCode == LEFT) keys[2] = true;
     if (keyCode == RIGHT) keys[3] = true;
  } else {
    if (key == 'm' || key == 'M') keys[4] = true;
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
    if (key == 'm' || key == 'M') keys[4] = false;
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
  displayMaze();
}

void displayMaze()
{
  
}