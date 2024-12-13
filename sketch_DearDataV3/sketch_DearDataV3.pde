import processing.sound.*;

SoundFile[] soundFiles = new SoundFile[8];

// Data variables
String[] foodData;
String[][] data;
ArrayList<ArrayList<Float>> foodValues;
int valueCount = 8;

// Max and min values for scaling the graph
float[] maxValue = {0, 0, 0, 0, 0, 0, 0, 0};
float[] minValue = {Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE};

// Graph margin and color arrays
final float margin = 50;
int[] colour1 = {0, 0, 0, 0, 0, 0, 0, 0};
int[] colour2 = {0, 0, 0, 0, 0, 0, 0, 0};
int[] colour3 = {0, 0, 0, 0, 0, 0, 0, 0};

// Movement variables
float gradient;
float lineSpeed = 0;
float xStep;
int valueNum = 0;

void setup() {
  // Setup canvas and framerate
  size(1200, 600);
  frameRate(60);


  // Load specific sounds for each food type
  soundFiles[0] = new SoundFile(this, "guitarSlap.wav");
  soundFiles[1] = new SoundFile(this, "synthSfx1.wav");
  soundFiles[2] = new SoundFile(this, "kickRock.wav");
  soundFiles[3] = new SoundFile(this, "coffeeTin.wav");
  soundFiles[4] = new SoundFile(this, "chimes.wav");
  soundFiles[5] = new SoundFile(this, "retroSfx.wav");
  soundFiles[6] = new SoundFile(this, "cowBell.wav");
  soundFiles[7] = new SoundFile(this, "pop1.wav");

  // Generate random colors for graphs
  for (int colourFood = 0; colourFood < 8; colourFood++) {
    colour1[colourFood] = (int) (Math.random() * 100 + 155);
    colour2[colourFood] = (int) (Math.random() * 100 + 155);
    colour3[colourFood] = (int) (Math.random() * 100 + 155);
  }

  // Load CSV data
  foodData = loadStrings("Dear data project(Sheet1).csv");
  data = new String[foodData.length][];
  for (int i = 0; i < foodData.length; i++) {
    data[i] = split(foodData[i], ",");
    for (int d = 0; d < data[i].length; d++) {
      data[i][d] = data[i][d].trim();
    }
  }

  // Initialize food values array
  foodValues = new ArrayList<>(valueCount);
  for (int i = 0; i < valueCount; i++) {
    foodValues.add(new ArrayList<>());
  }

  // Parse and process data
  for (int i = 2; i < data.length; i++) {
    for (int j = 2; j <= 5; j++) {
      foodValues.get((i - 2) % 8).add(float(data[i][j]));
      float value = float(data[i][j]);
      if (value > maxValue[(i - 2) % 8]) maxValue[(i - 2) % 8] = value;
      if (value < minValue[(i - 2) % 8]) minValue[(i - 2) % 8] = value;
    }
  }

  // Calculate spacing between points
  xStep = (width - 2 * margin) / (foodValues.get(0).size() - 1);
}

void draw() {
  drawGraph();
}

void drawGraph() {
  gradient = width / 500; // Adjust gradient for movement
  background(255);
  strokeWeight(3);
  stroke(255,0,0,70);
  line(margin, height, margin, 0);

  // Plot the food values as continuous lines
  strokeWeight(2);
  for (int foodType = 0; foodType < 8; foodType++) {
    stroke(colour1[foodType], colour2[foodType], colour3[foodType]); // Set the line color
    noFill();

    beginShape(); // Begin drawing the line
    float xStep = (width - 2 * margin) / (foodValues.get(foodType).size() - 1); // Calculate spacing between points
    for (int i = 0; i < foodValues.get(foodType).size(); i++) {
      float x = margin + i * xStep; // Map x-coordinate
      float y = height - margin - map(foodValues.get(foodType).get(i), minValue[foodType], maxValue[foodType], 0, height - 2 * margin); // Map y-coordinate
      vertex(x, y); // Add a point to the line
    }
    endShape();

    // Draw marks for each point on the graph
    for (int i = 0; i < foodValues.get(foodType).size(); i++) {
      float x = margin + i * xStep;
      float y = height - margin - map(foodValues.get(foodType).get(i), minValue[foodType], maxValue[foodType], 0, height - 2 * margin);
      fill(255, 0, 0);
      ellipse(x, y, 6, 6);
    }
  }

  // Play sound and draw the moving line
  float xStep = (width - 2 * margin) / (foodValues.get(0).size() - 1);

  if (lineSpeed < width - margin) {
    lineSpeed += gradient;
    // Draw the moving vertical line
    stroke(0, 70);
    line(lineSpeed, height, lineSpeed, 0);
  }

  // Play sound when line crosses a point
  if (lineSpeed >= margin && (lineSpeed - margin) % xStep < gradient) {
    for (int foodType = 0; foodType < 8; foodType++) {
      if (foodValues.get(foodType).size() > valueNum) {
        float currentValue = foodValues.get(foodType).get(valueNum);
        float pitch = map(currentValue, minValue[foodType], maxValue[foodType], 5.0, 0.1);
        pitch = constrain(pitch, 0.1, 5.0);
        float volume = map(currentValue, minValue[foodType], maxValue[foodType], 0, 3);
        volume = constrain(volume, 0, 3);
        // Play specific sound for the food type
        soundFiles[foodType].set(pitch, 0, volume);
        soundFiles[foodType].play();
      }
    }
    valueNum++; // Increment valueNum after all food types are processed
  }
}
