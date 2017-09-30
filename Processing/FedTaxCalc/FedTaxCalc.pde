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
  size(1200, 800);
  
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

float CANVAS_X = 400;
float CANVAS_Y = 400;
float OFFSET_X = 0.15;
float OFFSET_Y = 0.55;

int mouseU, mouseV;

void draw() {
  background(0);
  stroke(255); fill(255);
  
  translate(OFFSET_X*(width - CANVAS_X), OFFSET_Y*(height - CANVAS_Y));
  drawGraph1(); 
  translate(-OFFSET_X*(width - CANVAS_X), -OFFSET_Y*(height - CANVAS_Y));
  
  translate((1.0 - OFFSET_X)*(width - CANVAS_X), OFFSET_Y*(height - CANVAS_Y));
  drawGraph2();
  translate(-(1.0 - OFFSET_X)*(width - CANVAS_X), OFFSET_Y*(height - CANVAS_Y));
  
  noLoop();
}

void drawGraph1() {
  fill(255);
  textAlign(LEFT);
  text("Filing US Federal Income Taxes Jointly VS Separately\n" + 
       "for Two Individuals with Variable Income in 2017\n" + 
       "Ira Winder, jiw@mit.edu", 0, -160 + 10);
  
  text("Effect of Filing Jointly" + "\n" + "[% of total income]", 0, -80 + 10);
  
  // Legend
  noStroke();
  for (int i=0; i<20; i++) {
    fill(#00FF00, 255*i/20.0);
    rect(3*i + CANVAS_X - 110, -80, 3, 12);
  }
  for (int i=0; i<20; i++) {
    fill(#FF0000, 255*i/20.0);
    rect(-3*i + CANVAS_X - 110, -80, 3, 12);
  }
  noStroke();
       
  textAlign(RIGHT);
  fill(255);
  text(int(1000*MAX_DIFF)/10.0 + "% +", CANVAS_X, -80 + 10);
  text("- " + int(1000*MAX_DIFF)/10.0 + "% ", CANVAS_X - 1.6*110, -80 + 10);
  textAlign(LEFT);
  text("Penalty", CANVAS_X - 110 - 60, -60 + 10);
  textAlign(RIGHT);
  text("Benefit", CANVAS_X - 50, -60 + 10);
  
  textAlign(LEFT);
  stroke(255);
  strokeWeight(1);
  line(0, -24, 30, -24);
  text("Threshold for Solo Tax Filing", 40, -30 + 10);
    
  noStroke();
  float diff;
  float MAX = 10.0;
  for (int i=0; i<NUM_INTERVALS; i++) {
    for (int j=0; j<NUM_INTERVALS; j++) {
      if (i+j > NUM_INTERVALS) break;
      diff = taxSummary[i][j][0] - taxSummary[i][j][1]; // single - married
      fill(0, 0, 0);
      if (diff >  0) fill(0, 255, 0, 255*diff/taxSummary[i][j][2]/MAX_DIFF);
      if (diff <  0) fill(255, 0, 0, 255*abs(diff)/taxSummary[i][j][2]/MAX_DIFF);
      rect((i-1)*CANVAS_X/NUM_INTERVALS, (NUM_INTERVALS-j)*CANVAS_Y/NUM_INTERVALS, CANVAS_X/NUM_INTERVALS, CANVAS_Y/NUM_INTERVALS);
    }
  }
  
  // Tax Bracket
  int U;
  noFill();
  stroke(255, 100);
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
  textAlign(RIGHT);
  fill(#999999);
  text("Partner A\nIncome", -10, + 12);
  text("Partner B\nIncome", CANVAS_X - 5, CANVAS_Y + 20);
  
  noFill();
  stroke(#00FFFF);
  strokeWeight(3);
  // Mouse Cursor
  mouseU = int( NUM_INTERVALS * (mouseX - OFFSET_X*(width  - CANVAS_X)) / CANVAS_X);
  mouseV = int( NUM_INTERVALS * (mouseY - OFFSET_Y*(height - CANVAS_Y)) / CANVAS_Y);
  if (mouseU >=0 && mouseU < NUM_INTERVALS && mouseV >=0 && mouseV < NUM_INTERVALS && mouseV < NUM_INTERVALS && mouseU+(NUM_INTERVALS - mouseV - 1) < NUM_INTERVALS) {
    rect((mouseU - 2)*CANVAS_X/NUM_INTERVALS, (mouseV)*CANVAS_Y/NUM_INTERVALS, 3*CANVAS_X/NUM_INTERVALS, 3*CANVAS_Y/NUM_INTERVALS, 5);
    
    fill(#00FFFF, 50); stroke(#00FFFF); strokeWeight(2);
    rect(-5, CANVAS_Y + 30, 310, 105, 5); 
    
    fill(#00FFFF);
    textAlign(LEFT);
    text( "\n" + //"(" + mouseU + "," + (NUM_INTERVALS - mouseV - 1) + ")" + "\n" + 
          "Partner A Income:" + "\n" + 
          "Partner B Income:" + "\n" + "\n" +
          "Tot. Tax Filing Separately:" + "\n" + 
          "Tot. Tax Filing Jointly:" + "\n" + 
          "Difference [$]:" + "\n" +
          "Difference [% of total income]:",
          0, CANVAS_Y + 30);
    textAlign(RIGHT);
    text( "\n" + //"(" + mouseU + "," + (NUM_INTERVALS - mouseV - 1) + ")" + "\n" + 
          "$" + int((NUM_INTERVALS - mouseV - 1)*INTERVAL_RESOLUTION) + "\n" + 
          "$" + int(mouseU*INTERVAL_RESOLUTION) + "\n" + "\n" +
          "$" + int(taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][0]) + "\n" + 
          "$" + int(taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][1]) + "\n" + 
          "$" + int(taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][0] - taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][1]) + "\n" + 
          int(1000*(taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][0] - taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][1])/taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][2])/10.0 + "%",
          300, CANVAS_Y + 30);
        
  }
}

void drawGraph2() {
    fill(255);
    textAlign(LEFT);
//    text("Filing US Federal Income Taxes Jointly VS Separately\n" + 
//         "for Two Individuals with Variable Income in 2017\n" + 
//         "Ira Winder, jiw@mit.edu", 0, -160 + 10);
    
    text("Effect of Filing Jointly" + "\n" + "[% of total income]", 0, -80 + 10);
    
    // Legend
    noStroke();
    for (int i=0; i<20; i++) {
      fill(#00FF00, 255*i/20.0);
      rect(3*i + CANVAS_X - 110, -80, 3, 12);
    }
    for (int i=0; i<20; i++) {
      fill(#FF0000, 255*i/20.0);
      rect(-3*i + CANVAS_X - 110, -80, 3, 12);
    }
    noStroke();
         
    textAlign(RIGHT);
    fill(255);
    text(int(1000*MAX_DIFF)/10.0 + "% +", CANVAS_X, -80 + 10);
    text("- " + int(1000*MAX_DIFF)/10.0 + "% ", CANVAS_X - 1.6*110, -80 + 10);
    textAlign(LEFT);
    text("Penalty", CANVAS_X - 110 - 60, -60 + 10);
    textAlign(RIGHT);
    text("Benefit", CANVAS_X - 50, -60 + 10);
    
    textAlign(LEFT);
    stroke(255);
    strokeWeight(1);
    line(0, -24, 30, -24);
    text("Threshold for Joint Tax Filing", 40, -30 + 10);
      
    // Draw Graph  
    noStroke();
    float diff;
    float tot;
    float ratio;
    float MAX = 10.0;
    for (int i=0; i<NUM_INTERVALS; i++) {
      for (int j=i; j<NUM_INTERVALS; j++) {
        diff = taxSummary[i][j][0] - taxSummary[i][j][1]; // single - married
        tot = taxSummary[i][j][2]; // [$]
        fill(0, 0, 0);
        if (diff >  0) fill(0, 255, 0, 255*diff/tot/MAX_DIFF);
        if (diff <  0) fill(255, 0, 0, 255*abs(diff)/tot/MAX_DIFF);
        ratio = min(i, j) / float(max(i, j)); // 0 - 1
        if (ratio > 1) ratio = 1;
        if (tot / (NUM_INTERVALS * INTERVAL_RESOLUTION) <= 1)
          rect(ratio*CANVAS_X, (1 - tot / (NUM_INTERVALS * INTERVAL_RESOLUTION)) * CANVAS_Y, 1.5*CANVAS_X/NUM_INTERVALS, 1.5*CANVAS_Y/NUM_INTERVALS);
      }
    }
    
    // Tax Bracket
    int U;
    noFill();
    stroke(255, 100);
    strokeWeight(1);
    for (int i=1; i<marriedBracket.length; i++) {
      U = int(marriedBracket[i][0]/INTERVAL_RESOLUTION);
      line(-10, (NUM_INTERVALS - U)*CANVAS_X/NUM_INTERVALS, CANVAS_X, (NUM_INTERVALS - U)*CANVAS_X/NUM_INTERVALS);
      fill(255);
      textAlign(RIGHT);
      text("$" + int(marriedBracket[i][0]), -20, (NUM_INTERVALS - U)*CANVAS_X/NUM_INTERVALS + 5);
      
  
      //text(int(1000*singleBracket[i][1])/10.0 + "%", -10, (NUM_INTERVALS - 1.5*U)*CANVAS_X/NUM_INTERVALS - 4);
    }
    
    textAlign(RIGHT);
    fill(#999999);
    text("Total Income", -10, + 12);
    text("\nEqual Earners", CANVAS_X, CANVAS_Y + 25);
    textAlign(LEFT);
    text("\nSole Earner", 0, CANVAS_Y + 25);
    
    for (int i=0; i<=10; i++) {
      stroke(255, 100);
      line(CANVAS_X*float(i)/10, CANVAS_Y - 5, CANVAS_X*float(i)/10, CANVAS_Y + 5);
      textAlign(CENTER);
      if (i%2 == 0)
        text(100-int(10*float(i)/2) + "/" + int(10*float(i)/2) + "%", CANVAS_X*float(i)/10, CANVAS_Y + 20);
    }
    
    noFill();
    stroke(#00FFFF);
    strokeWeight(3);

    if (mouseU >=0 && mouseU < NUM_INTERVALS && mouseV >=0 && mouseV < NUM_INTERVALS && mouseU+(NUM_INTERVALS - mouseV - 1) < NUM_INTERVALS) {
      ratio = min(mouseU, NUM_INTERVALS - mouseV - 1) / float(max(mouseU, NUM_INTERVALS - mouseV - 1)); // 0 - 1
      tot = taxSummary[mouseU][NUM_INTERVALS - mouseV - 1][2]; // [$]
      rect(ratio*CANVAS_X, (1 - tot / (NUM_INTERVALS * INTERVAL_RESOLUTION)) * CANVAS_Y, 3*CANVAS_X/NUM_INTERVALS, 3*CANVAS_Y/NUM_INTERVALS, 5);
      
      fill(#00FFFF, 50); stroke(#00FFFF); strokeWeight(2);
      rect(-5, CANVAS_Y + 58, 310, 50, 5); 
      
      fill(#00FFFF);
      textAlign(LEFT);
      text( "\n" + //"(" + mouseU + "," + (NUM_INTERVALS - mouseV - 1) + ")" + "\n" + 
            "\n" + 
            "\n" + 
            "Total Income:" + "\n" + "\n" +
            "Earning Ratio:",
            0, CANVAS_Y + 30);
      textAlign(RIGHT);
      text( "\n" + //"(" + mouseU + "," + (NUM_INTERVALS - mouseV - 1) + ")" + "\n" + 
            "\n" +
            "\n" + 
            "$" + int((NUM_INTERVALS - mouseV - 1 + mouseU)*INTERVAL_RESOLUTION) + "\n" + "\n" +
            int(1000*(1-ratio/2))/10.0 + "% / " + int(1000*(ratio/2))/10.0 + "%",
            300, CANVAS_Y + 30);
          
    }
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
