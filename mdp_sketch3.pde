
import processing.pdf.*;

Tree tree;

final int back = 0;  // background tint
float wf, hf; // width and height factors for display circle.
float startSize;
float rotation;
int minN, maxN, hue1, hue2;
float minV, maxV;
color col1, col2;


boolean record = false;     // produces pdf; mapped to "r" key.
boolean border = false;     // circular border; "b" key
boolean showInds = false;   // for debug; "i" key
boolean simple  = true;     // faster rendering but ugly, "p" key


String file = "baby3";  // filename with no folder or extension for image-naming purposes
// String file = "tiger2";

void setup() {
    size(700, 700);
    wf = 0.98 * width;
    hf = 0.98 * height;
    startSize = (float) width / 15;
    rotation = PI;

    // read json
    String jsonfile = "data/" + file + ".json";
    JSONObject json = loadJSONObject(jsonfile);

    int [][] children = childrenFromJSON(json);
    float [] Vs       = jsonToFloat(json.getJSONArray("V"));
    int []   Ns       = jsonToInt(json.getJSONArray("N"));

    minN = min(Ns);
    maxN = max(Ns);
    minV = min(Vs);
    maxV = max(Vs);

    // hue1 = 0;
    // hue2 = 300;

    col2 = color(236, 224, 69);
    col1 = color(255, 86, 82);

    increment(children, -1); // from 1 to 0 based indexing

    tree = new Tree(children, Ns, Vs);

    if (isCyclic(children))
        println("NOTE: THIS GRAPH CONTAINS CYCLES!!");

}

void draw() {

    if (record)
        beginRecord(PDF, safeFilename("images/pomdpsketch_" + file, "pdf"));

    pushMatrix();

    translate(tree.root.pos.x, tree.root.pos.y);
    rotate(rotation);
    translate(-tree.root.pos.x, -tree.root.pos.y);


    background(back);

    if (border){
        noFill();
        stroke(255-back);
        ellipse(width/2, height/2, wf, hf);
    }


    // lines first
    stroke(255-back, 50);
    tree.connect();

    // glows second
    noStroke();
    colorMode(HSB);
    if (simple) tree.showSimple();
    else        tree.show();


    if (showInds){
        fill(255 - back);
        for (int i = 0; i < tree.nodes.size(); i++)
            tree.nodes.get(i).showInd(i);

    }

    if (record) {
        endRecord();
        record = false;
        println("saved");
    }

    popMatrix();
    noLoop();
}

void keyPressed() {

    if (key == CODED){

        if (keyCode == DOWN){
            startSize -= 5;
            tree.setSize(startSize);
        }
        else if (keyCode == UP){
            startSize += 5;
            tree.setSize(startSize);
        }
        else if (keyCode == LEFT)   rotation -= PI/6;
        else if (keyCode == RIGHT)  rotation += PI/6;
    }
    else{
        switch(key){

            case ' ': // spacebar
                tree.setPosition();
                break;

            case 's':

                saveFrame(safeFilename("images/pomdpsketch_" + file, "png"));
                println("saved");
                break;

            case 'c':

                tree.root.randomHue();
                tree.setHue();
                break;

            case 'b':

                border = !border;
                break;

            case 'r':

                record = true;
                break;
            case 'i':

                showInds = !showInds;
                break;

            case 'p':

                simple = !simple;
                break;
        }
    }
     
    redraw();
}


void mousePressed(){

    tree.root.pos = new PVector(mouseX, mouseY);
    tree.setPosition();

    redraw();
}


String safeFilename(String prefix, String extension) {
    int savecnt = 0;
    String filename = "";
    File f;

    while (true) {
        filename = prefix;
        if     (savecnt < 10)  filename += "_00";
        else if(savecnt < 100) filename +=  "_0";

        filename += savecnt + "." + extension;

        // Check to see if file exists, using the undocumented
        // savePath() to find sketch folder.
        // Break when file doesn't already exist
        f = new File(savePath(filename));
        if(!f.exists())
            break;

        savecnt++;
    }

    return filename;
}


int[][] childrenFromJSON(JSONObject json){

    JSONArray  arrayOfArrays  = json.getJSONArray("children");

    int[][] fullarray = new int[arrayOfArrays.size()][];


    JSONArray childList;
    ArrayList<Integer> subarray;
    int val;

    for (int i = 0; i < arrayOfArrays.size(); i++) {

        subarray = new ArrayList();
        childList = arrayOfArrays.getJSONArray(i);

        for (int j = 0; j < childList.size(); j++){

            val = (int) childList.get(j);
            if (val < fullarray.length){
                subarray.add(val);
            }
        }

        fullarray[i] = toIntArray(subarray);
    }

    return fullarray;
}

float[] jsonToFloat(JSONArray arr){

    float[] floatarr = new float[arr.size()];
    for (int i = 0; i < arr.size(); i++) {
        floatarr[i] = arr.getFloat(i);
    }

    return floatarr;
}
int[] jsonToInt(JSONArray arr){

    int[] intarr = new int[arr.size()];
    for (int i = 0; i < arr.size(); i++) {
        intarr[i] = arr.getInt(i);
    }

    return intarr;
}

void increment(int[][] A, int val){

    for (int i = 0; i < A.length; i++)
        increment(A[i], val);
}

void increment(int[] A, int val){

    for (int i = 0; i < A.length; i++)
        A[i] += val;
}

// Converts Arraylist<Integer> to int[]
// There is definitely definitely a library function for this
int[] toIntArray(ArrayList<Integer> integers) {
    int[] ints = new int[integers.size()];
    int i = 0;
    for (Integer n : integers) {
        ints[i++] = n;
    }
    return ints;
}
