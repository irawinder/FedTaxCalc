// Ira Winder, jiw@mit.edu
// The following script computes and graphs a couple's federal income tax 
// as a function of their respective income and whether they are filing jointly or separately

// Based on 2017 US Tax Brackets
// https://taxfoundation.org/2017-tax-brackets/

// {income threshold, percent taxed after threshold}
float[][] singleBracket = {
  {0,      .1},
  {9325,   .15},
  {37950,  .25},
  {91900,  .28},
  {191650, .33},
  {416700, .35},
  {418400, .396}
};

// {income threshold, percent taxed after threshold}
float[][] marriedBracket = {
  {0,      .1},
  {18650,  .15},
  {75900,  .25},
  {153100, .28},
  {233350, .33},
  {416700, .35},
  {470700, .396}
};

// difference filing jointly vs filing single [n][n][2]
// [][][0] = federal tax if filing as single
// [][][1] = federal tax if filing as married
// [][][2] = total household income
float[][][] taxSummary;

int NUM_INTERVALS = 200;
float INTERVAL_RESOLUTION = 2500.0; // USD
float MAX_DIFF = 0.05;

void setup() {
  size(1100, 1100);
  
  taxSummary = new float[NUM_INTERVALS][NUM_INTERVALS][3];
  for (int i=0; i<NUM_INTERVALS; i++) {
    for (int j=0; j<NUM_INTERVALS; j++) {
      
      // Calculate Taxes if Filing Single
      taxSummary[i][j][0] = incomeTax(i*INTERVAL_RESOLUTION, "single") + incomeTax(j*INTERVAL_RESOLUTION, "single");
      
      // Calculate Taxes if Filing Jointly (Married)
      taxSummary[i][j][1] = incomeTax( (i+j)*INTERVAL_RESOLUTION, "married");
      
      // Calculate Taxes if Filing Jointly (Married)
      taxSummary[i][j][2] = (i+j)*INTERVAL_RESOLUTION;
     
    } 
  }
}

float CANVAS_X = 800;
float CANVAS_Y = 800;
int mouseU, mouseV;

void draw() {
  background(0);
  stroke(255); fill(255);
  
  translate(0.5*(width - CANVAS_X), 0.5*(height - CANVAS_Y));
  
  // Legend
  noStroke();
  for (int i=0; i<20; i++) {
    fill(#FF0000, 255*i/20.0);
    rect(3*i + CANVAS_X - 110, -80, 3, 12);
  }
  for (int i=0; i<20; i++) {
    fill(#00FF00, 255*i/20.0);
    rect(3*i + CANVAS_X - 110, -55, 3, 12);
  }
  noStroke();
  
  textAlign(RIGHT);
  fill(255);
  text("Cheaper to File Taxes Separately", CANVAS_X - 110, -80 + 10);
  text("Cheaper to File Taxes Jointly", CANVAS_X - 110, -55 + 10);
  text(int(1000*MAX_DIFF)/10.0 + "% +", CANVAS_X, -80 + 10);
  text(int(1000*MAX_DIFF)/10.0 + "% +", CANVAS_X, -55 + 10);
  
  fill(255);
  textAlign(LEFT);
  text("Filing US Federal Income Taxes Jointly VS Separately\n" + 
       "for Two Individuals with Variable Income in 2017\n" + 
       "Ira Winder, jiw@mit.edu", 0, -80 + 10);
  
  stroke(255);
  strokeWeight(1);
  line(0, -24, 30, -24);
  text("Tax Bracket Threshold for Single-filer", 40, -30 + 10);
  noStroke();
  
  
  
  noStroke();
  float diff;
  float MAX = 10.0;
  for (int i=0; i<NUM_INTERVALS; i++) {
    for (int j=0; j<NUM_INTERVALS; j++) {
      diff = taxSummary[i][j][0] - taxSummary[i][j][1]; // single - married
      fill(0, 0, 0);
      if (diff >  +0.5) fill(0, 255, 0, 255*diff/taxSummary[i][j][2]/MAX_DIFF);
      if (diff <  -0.5) fill(255, 0, 0, 255*abs(diff)/taxSummary[i][j][2]/MAX_DIFF);
      rect((i-1)*CANVAS_X/NUM_INTERVALS, (NUM_INTERVALS-j)*CANVAS_Y/NUM_INTERVALS, CANVAS_X/NUM_INTERVALS, CANVAS_Y/NUM_INTERVALS);
    }
  }
  
  // Tax Bracket
  int U;
  noFill();
  stroke(255);
  strokeWeight(1);
  for (int i=1; i<singleBracket.length; i++) {
    U = int(singleBracket[i][0]/INTERVAL_RESOLUTION);
    line(-10, (NUM_INTERVALS - U)*CANVAS_X/NUM_INTERVALS, U*CANVAS_X/NUM_INTERVALS, (NUM_INTERVALS - U)*CANVAS_X/NUM_INTERVALS);
    line(U*CANVAS_X/NUM_INTERVALS, (NUM_INTERVALS - U)*CANVAS_Y/NUM_INTERVALS, U*CANVAS_X/NUM_INTERVALS, CANVAS_Y + 10);
    //line(0, CANVAS_Y, CANVAS_X, 0);
    fill(255);
    textAlign(RIGHT);
    if (i<singleBracket.length-1) {
      text("$" + int(singleBracket[i][0]), -20, (NUM_INTERVALS - U)*CANVAS_X/NUM_INTERVALS + 8);
    } else {
      text("$" + int(singleBracket[i][0]), -20, (NUM_INTERVALS - U)*CANVAS_X/NUM_INTERVALS - 4);
    }

    //text(int(1000*singleBracket[i][1])/10.0 + "%", -10, (NUM_INTERVALS - 1.5*U)*CANVAS_X/NUM_INTERVALS - 4);
  }
  textAlign(CENTER);
  fill(#999999);
  text("Partner A\nIncome", -75, CANVAS_Y/2 + 12);
  text("Partner B\nIncome", CANVAS_X/2 - 5, CANVAS_Y + 50);
  
  // Mouse Cursor
  mouseU = int( NUM_INTERVALS * (mouseX - 0.5*(width  - CANVAS_X)) / CANVAS_X);
  mouseV = int( NUM_INTERVALS * (mouseY - 0.5*(height - CANVAS_Y)) / CANVAS_Y);
  
//  mouseU = max(mouseU, 0);
//  mouseV = max(mouseV, 0);
//  
//  mouseU = min(mouseU, NUM_INTERVALS-1);
//  mouseV = min(mouseV, NUM_INTERVALS-1);
  
  noFill();
  stroke(#00FFFF);
  strokeWeight(3);
  if (mouseU >=0 && mouseU < NUM_INTERVALS && mouseV >=0 && mouseV < NUM_INTERVALS) {
    rect((mouseU - 2)*CANVAS_X/NUM_INTERVALS, (mouseV)*CANVAS_Y/NUM_INTERVALS, 3*CANVAS_X/NUM_INTERVALS, 3*CANVAS_Y/NUM_INTERVALS);
    fill(#00FFFF);
    textAlign(LEFT);
    text( "\n" + //"(" + mouseU + "," + (NUM_INTERVALS - mouseV - 1) + ")" + "\n" + 
          "Income A:" + "\n" + 
          "Income B:" + "\n" +
          "Tax Filing Separately:" + "\n" + 
          "Tax Filing Jointly:" + "\n" + 
          "Difference [$]:" + "\n" +
          "Difference [$]:",
          0, CANVAS_Y + 30);
    textAlign(RIGHT);
    text( "\n" + //"(" + mouseU + "," + (NUM_INTERVALS - mouseV - 1) + ")" + "\n" + 
          "$" + int((NUM_INTERVALS - mouseV - 1)*INTERVAL_RESOLUTION) + "\n" + 
          "$" + int(mouseU*INTERVAL_RESOLUTION) + "\n" +
          "$" + int(taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][0]) + "\n" + 
          "$" + int(taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][1]) + "\n" + 
          "$" + int(taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][0] - taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][1]) + "\n" + 
          int(1000*(taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][0] - taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][1])/taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][2])/10.0 + "%",
          200, CANVAS_Y + 30);
        
  }
  
  noLoop();
}

float incomeTax(float income, String fileType) {
  
  float tax = 0;
  float bracketIncome;
  float[][] bracket;
  
  if (fileType.equals("single")) {
    bracket = singleBracket;
  } else if (fileType.equals("married")) {
    bracket = marriedBracket;
  } else {
    println("Filing Type not Recognized.  Set to default 'filing single'");
    bracket = singleBracket;
  }
  
  for (int i=bracket.length-1; i>=0; i--) {
      
    if (income > bracket[i][0]) {
      bracketIncome = income - bracket[i][0];
      tax += bracket[i][1] * bracketIncome;
      income -= bracketIncome;
    }
    
  }
  
  return tax;
  
}

void mouseMoved() {
  loop();
}
