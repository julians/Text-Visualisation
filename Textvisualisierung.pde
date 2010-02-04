// different fonts
// 

//import processing.pdf.*;
import rita.wordnet.*;

RiWordnet wordnet;

String content = "";
HashMap chars;
PGraphics tp;
PImage ti;
HashMap blacknesses;
ArrayList uniqueChars;
String[] words;
int[][] wordProperties;
HashMap typeForWord;

int currentWord = 0;
int currentChar = 0;
int totalLines = 0;

float[][] maps = new float[6][2];

// prefs
String[] reversed = {"RATIO", "TOTALPIXELS", "BLACKPIXELS", "CHARWIDTH", "CHARHEIGHT", "OFF"};

int RATIO = 0;
int TOTALPIXELS = 1;
int BLACKPIXELS = 2;
int CHARWIDTH = 3;
int CHARHEIGHT = 4;
int WORD = 0;
int WORDTYPE = 1;
int MIN = 0;
int MAX = 1;
int OFF = 5;
int VERB = 0;
int ADVERB = 1;
int ADJECTIVE = 2;
int NOUN = 3;
int OTHER = 4;
int WHITESPACE = 5;
int PUNCTUATION = 6;
int OFFCOLOUR = 7;

int charsPerLine = 60;
int linesPerPage = 30;
int pY = OFF;
int pA = OFF;
int pC = OFF;
boolean drawText = false;
boolean drawAll = true;

int[] colours = new int[8];

// temp vars for draw method
int tx = 0;
int ty = 0;
String ts = "";

PImage bg;

int[] buttons;

void setup ()
{
    size(1024, 768);
    smooth();
    colorMode(HSB, 360, 100, 100, 100);
    frameRate(60);
    bg = loadImage("background.png");
    
    colours[VERB] = color(50, 98, 95); //yellow
    colours[ADVERB] = color(197, 98, 55); //blue
    colours[ADJECTIVE] = color(186, 98, 75); //light blue
    colours[NOUN] = color(355, 88, 95); //red
    colours[OTHER] = color(0, 0, 35); //dark grey
    colours[WHITESPACE] = color(0, 0, 70); //light grey
    colours[PUNCTUATION] = color(78, 86, 78); //green
    colours[OFFCOLOUR] = color(0, 0, 0); //black

    buttons = new int[height];
    for (int i = 0; i < buttons.length; i++) {
        buttons[i] = -1;
    }
    fillButton(47, RATIO);
    fillButton(68, TOTALPIXELS);
    fillButton(89, BLACKPIXELS);
    fillButton(110, CHARWIDTH);
    fillButton(131, CHARHEIGHT);
    fillButton(152, OFF);
    
    fillButton(223, RATIO);
    fillButton(244, TOTALPIXELS);
    fillButton(265, BLACKPIXELS);
    fillButton(286, CHARWIDTH);
    fillButton(307, CHARHEIGHT);
    fillButton(328, OFF);
    
    fillButton(399, WORDTYPE);
    fillButton(420, OFF);
    
    Locale.setDefault(Locale.ENGLISH);
    wordnet = new RiWordnet(this);
    
    chars = new HashMap(100);
    typeForWord = new HashMap();
    blacknesses = new HashMap(100);
    uniqueChars = new ArrayList(100);
    
    typeForWord.put("Buckminster", NOUN);
    
    analyseFile();
    
    /*
    Iterator i = blacknesses.entrySet().iterator();  // Get an iterator
    while (i.hasNext()) {
        Map.Entry me = (Map.Entry)i.next();
        print(me.getKey() + " is ");
        println(me.getValue());
    }
    */
    
    background(0, 0, 93);
    textFont(createFont("Courier", 14));
    updateUberList(charsPerLine*linesPerPage);
}

void analyseFile ()
{
    String lines[] = loadStrings("text.txt");
    StringBuilder result = new StringBuilder();
    for (int i = 0; i < lines.length; i++) {
        result.append(lines[i]);
        result.append("\n");
    }
    content = result.toString();
    
    content = content.replaceAll("\\W+", " ");
    words = content.split(" ");
    
    char temp;
    for (int i = 0; i < content.length(); i++) {
        temp = content.charAt(i);
        if (chars.containsKey(temp)) {
            // this is shit
            int val = ((Integer) chars.get(temp)) + 1;
            chars.put(temp, val);
        } else {
            chars.put(temp, 1);
        }
    }
    totalLines = floor(content.length()/charsPerLine);
    
    uniqueChars.addAll(chars.keySet());
    //Collections.sort(uniqueChars);
    
    wordProperties = new int[content.length()][7];

    tp = createGraphics(128, 128, P2D);
    tp.beginDraw();
    tp.textFont(createFont("Courier", 64));
    tp.fill(0);
    tp.noStroke();
    tp.background(255);
    tp.textAlign(CENTER);
    tp.endDraw();
    
    int a = 0;
    int r = 0;
    int g = 0;
    int b = 0;
    int x = 0;
    int y = 0;
    int argb = 0;
    int minX = 128;
    int minY = 128;
    int maxX = 0;
    int maxY = 0;
    float charWidth = 0;
    float charHeight = 0;
    float blacks = 0;
    
    for (int j = 0; j < uniqueChars.size(); j++) {
        if (uniqueChars.get(j).toString().contentEquals(" ")) {
            float[] data = {0, 0, 0, 0, 0};
            blacknesses.put(uniqueChars.get(j), data);
            continue;
        }
        tp.beginDraw();
        tp.background(255);
        tp.text(uniqueChars.get(j).toString(), 64, 64);
        tp.endDraw();
        tp.loadPixels();

        minX = 128;
        minY = 128;
        maxX = 0;
        maxY = 0;
        charWidth = 0;
        charHeight = 0;
        blacks = 0;
        for (int i = 0; i < tp.pixels.length; i++) {
            argb = tp.pixels[i];
            if (argb != -1) {
                a = (argb >> 24) & 0xFF;
                r = (argb >> 16) & 0xFF;  // Faster way of getting red(argb)
                g = (argb >> 8) & 0xFF;   // Faster way of getting green(argb)
                b = argb & 0xFF;          // Faster way of getting blue(argb)

                x = i%128;
                y = (i - (i%128))/128;
                if (x < minX) minX = x;
                if (y < minY) minY = y;
                if (x > maxX) maxX = x;
                if (y > maxY) maxY = y;

                a = (argb >> 24) & 0xFF;
                r = (argb >> 16) & 0xFF;  // Faster way of getting red(argb)
                g = (argb >> 8) & 0xFF;   // Faster way of getting green(argb)
                b = argb & 0xFF;          // Faster way of getting blue(argb)

                if (r < 127 && g < 127 && b < 127) blacks++;
            }
        }
        charWidth = maxX - minX;
        charHeight = maxY - minY;
        
        if (maps[CHARWIDTH][MIN] > charWidth) maps[CHARWIDTH][MIN] = charWidth;
        if (maps[CHARWIDTH][MAX] < charWidth) maps[CHARWIDTH][MAX] = charWidth;

        if (maps[CHARHEIGHT][MIN] > charHeight) maps[CHARHEIGHT][MIN] = charHeight;        
        if (maps[CHARHEIGHT][MAX] < charHeight) maps[CHARHEIGHT][MAX] = charHeight;
        
        if (maps[BLACKPIXELS][MIN] > blacks) maps[BLACKPIXELS][MIN] = blacks;
        if (maps[BLACKPIXELS][MAX] < blacks) maps[BLACKPIXELS][MAX] = blacks;
        
        if (maps[TOTALPIXELS][MIN] > charWidth*charHeight) maps[TOTALPIXELS][MIN] = charWidth*charHeight;
        if (maps[TOTALPIXELS][MAX] < charWidth*charHeight) maps[TOTALPIXELS][MAX] = charWidth*charHeight;
        
        float[] data = {blacks/(charWidth*charHeight), charWidth*charHeight, blacks, charWidth, charHeight};
        blacknesses.put(uniqueChars.get(j), data);
    }
    
    maps[RATIO][MIN] = 0;
    maps[RATIO][MAX] = 1;
}

void draw ()
{
    if (drawAll) {
        background(0, 0, 93);
        image(bg, 0, 0);
        translate(232, 20);
        fill(0, 0, 100);
        noStroke();
        rect(0, 0, 560, 700);
        noFill();
        stroke(0, 0, 85);
        line(0, 700, 560, 700);
        if (drawText) drawText(24);
        drawAbstract();
        resetMatrix();
        
        fill(0, 40);
        noStroke();
        for (int i = 390; i < 500; i++) {
            if (buttons[i] == pC) {
                rect(860, i+2, 7, 7);
                break;
            }
        }
        for (int i = 220; i < 380; i++) {
            if (buttons[i] == pA) {
                rect(860, i+2, 7, 7);
                break;
            }
        }
        for (int i = 40; i < 210; i++) {
            if (buttons[i] == pY) {
                rect(860, i+2, 7, 7);
                break;
            }
        }
        if (drawText) rect(860, 493, 7, 7);
        
        drawAll = false;
    }
    fill(0, 0, 93);
    noStroke();
    rect(0, 0, 200, 200);
    if (drawAll || (mouseX > 272 && mouseX < 752 && mouseY > 60 - (600/linesPerPage) && mouseY < 60 - (600/linesPerPage) + 600)) {
        ts = "";
        tx = mouseX - 272;
        ty = mouseY - (60 - (600/linesPerPage));
        tx = floor(tx/8);
        ty = floor(ty/(600/linesPerPage));
        
        if (wordProperties[tx+(ty*charsPerLine)][WORD] >= 0) {
            fill(colours[wordProperties[tx+(ty*charsPerLine)][WORDTYPE]]);
            text(words[wordProperties[tx+(ty*charsPerLine)][WORD]], 40, 60);
        }
        
        fill(0, 24);
        text(content.charAt(tx+(ty*charsPerLine)), 40, 80);
        text("Zeile " + ty, 40, 100);
        text("Buchstabe " + tx, 40, 120);
    }
}

void fillButton (int start, int value)
{
    for (int i = start; i < start + 11; i++) {
        buttons[i] = value;
    }
}

void mouseClicked ()
{
    if (mouseX > 857 && mouseX < 870) {
        println(mouseY);
        if (mouseY > 532 && mouseY < 545) {
            if (linesPerPage > 1) {
                linesPerPage--;
                while (600%linesPerPage != 0) {
                    linesPerPage--;
                }
                drawAll = true;
            }
        } else if (mouseY > 511 && mouseY < 524) {
            if (linesPerPage < 600) {
                linesPerPage++;
                while (600%linesPerPage != 0) {
                    linesPerPage++;
                }
                drawAll = true;
            }
        } else if (mouseY > 490 && mouseY < 503) {
            drawText = !drawText;
            drawAll = true;
        } else if (mouseY > 390 && buttons[mouseY] > -1) {
            pC = buttons[mouseY];
            drawAll = true;
        } else if (mouseY > 220 && buttons[mouseY] > -1) {
            pA = buttons[mouseY];
            drawAll = true;
        } else if (mouseY > 40 && buttons[mouseY] > -1) {
            pY = buttons[mouseY];
            drawAll = true;
        }
    }
}

void keyPressed ()
{
    println("----------------------");
    switch (key) {
        case 't':
            drawText = !drawText;
            break;
        case '+':
            if (linesPerPage < 600) {
                linesPerPage++;
                while (600%linesPerPage != 0) {
                    linesPerPage++;
                }
            }
            println("lines per page: " + linesPerPage);
            break;
        case '-':
            if (linesPerPage > 1) {
                linesPerPage--;
                while (600%linesPerPage != 0) {
                    linesPerPage--;
                }
            }
            println("lines per page: " + linesPerPage);
            break;
        case 'c':
            pC = pC == WORDTYPE ? OFF : WORDTYPE;
            println("colour off");
            break;
    }
    if (key == CODED) {
        switch (keyCode) {
            case RIGHT:
                pA++;
                if (pA > 5) pA = 0;
                println("pA: " + reversed[pA]);
                break;
            case LEFT:
                pA--;
                if (pA < 0) pA = 5;
                println("pA: " + reversed[pA]);
                break;
            case DOWN:
                pY++;
                if (pY > 5) pY = 0;
                println("pY: " + reversed[pY]);
                break;
            case UP:
                pY--;
                if (pY < 0) pY = 5;
                println("pY: " + reversed[pY]);
                break;
        }
    }
    drawAll = true;
}

void drawAbstract ()
{
    float [] ftemp;
    PVector lastPoint = new PVector(0, 0);
    PVector thisPoint = new PVector(0, 0);
    noFill();
    strokeWeight(1);
    
    color c;
    float a;
    float y;
    
    int in;
    float [] fl;
    
    updateUberList(charsPerLine*linesPerPage);
    for (int k = 0; k < linesPerPage; k++) {
        for (int j = 0; j < charsPerLine; j++) {
            in = charsPerLine*k+j;
            fl = (float[]) blacknesses.get(content.charAt(in));
            
            if (thisPoint.x != 0 && thisPoint.y != 0) lastPoint.set(thisPoint.x, thisPoint.y, 0);
            
            a = pA == OFF ? 100 : map(fl[pA], maps[pA][MIN], maps[pA][MAX], 10, 100);
            y = pY == OFF ? 0 : map(fl[pY], maps[pY][MIN], maps[pY][MAX], 0, 12);
            c = pC == OFF ? OFFCOLOUR : wordProperties[in][WORDTYPE];
            stroke(colours[c], a);
            thisPoint.set(40+(j*8)+4, k*(600/linesPerPage)+40-y, 0);
        
            if (j > 1) {
                line(lastPoint.x+1, lastPoint.y, thisPoint.x, thisPoint.y);
            } else if (j == 1) {
                line(lastPoint.x, lastPoint.y, thisPoint.x, thisPoint.y);
            }
        }
    }
}

void drawText (float tAlpha)
{
    fill(0, tAlpha);
    for (int k = 0; k < linesPerPage; k++) {
        StringBuilder l = new StringBuilder();
        for (int j = 0; j < charsPerLine; j++) {
            l.append(content.charAt(charsPerLine*k+j));
        }
        text(l.toString(), 40, k*(600/linesPerPage)+40);
    }
}

void updateUberList (int num)
{
    if (num > currentChar) {
        char tc;
        for (int i = currentChar; i < num; i++) {
            tc = content.charAt(i);
            if (Character.isLetter(tc) || Character.isDigit(tc)) {
                wordProperties[i][WORD] = currentWord;

                if (typeForWord.containsKey(currentWord)) {
                    wordProperties[i][WORDTYPE] = (Integer) typeForWord.get(currentWord);
                } else {
                    if (wordnet.isVerb(words[currentWord])) {
                        wordProperties[i][WORDTYPE] = VERB;
                    } else if (wordnet.isAdverb(words[currentWord])) {
                        wordProperties[i][WORDTYPE] = ADVERB;
                    } else if (wordnet.isAdjective(words[currentWord])) {
                        wordProperties[i][WORDTYPE] = ADJECTIVE;
                    } else if (wordnet.isNoun(words[currentWord])) {
                        wordProperties[i][WORDTYPE] = NOUN;
                    } else {
                        wordProperties[i][WORDTYPE] = OTHER;
                    }
                    typeForWord.put(currentWord, wordProperties[i][WORDTYPE]);
                }
            } else if (Character.isWhitespace(tc)) {
                wordProperties[i][WORDTYPE] = WHITESPACE;
                wordProperties[i][WORD] = -2;
                if (i > 0 && wordProperties[i-1][WORD] != -2) currentWord += 1;
            } else {
                wordProperties[i][WORDTYPE] = PUNCTUATION;
                wordProperties[i][WORD] = -1;
                currentWord += 1;
            }
        }
        currentChar = num;
    }
}