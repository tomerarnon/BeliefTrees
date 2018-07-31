
import processing.pdf.*;

Tree tree;

int back = 0;  // background tint
float wf, hf; // width and height factors for display circle.
float startSize;
float rotation;
int minN, maxN, hue1, hue2;
float minV, maxV;
color col1, col2;
int seed = 0;
float branchingAngle = 1.0;   // factor that determines branching (bigger for wider branches, 'q'/'w' keys).

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
    startSize = (float) height / 15 * 3/4;
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

    // red/yellow
    col1 = color(235, 254, 100);
    col2 = color(200, 26, 22);

    // teal/yellow
    // col2 = color(60, 235, 235);
    // col1 = color(225, 110, 2);

    // purple/yellow
    // col2 = color(90, 90, 235);
    // col1 = color(245, 225, 0);
    // col1 = color(225, 225, 150);

    // col2 = color(255);
    // col1 = color(0, 150, 150);

    // dark theme
    // col2 = color(70, 44, 109);
    // col1 = color(10, 10, 10);
    // col1 = color(255, 44, 109);
    // col2 = color(10, 10, 10);

    increment(children, -1); // from 1 to 0 based indexing

    tree = new Tree(children, Ns, Vs);

    if (isCyclic(children))
        println("NOTE: THIS GRAPH CONTAINS CYCLES!!");

}

void draw() {

    if (record)
        beginRecord(PDF, safeFilename("images/pdf/" + file, "pdf"));

    background(back);

    pushMatrix();

    if (border){
        noFill();
        strokeWeight(0.5);
        stroke(255-back, 100);
        ellipse(width/2, height/2, wf, hf);
    }


    translate(tree.root.pos.x, tree.root.pos.y);
    rotate(rotation);
    translate(-tree.root.pos.x, -tree.root.pos.y);

    // lines first
    stroke(255-back, 30);
    tree.connect();

    // glows second
    noStroke();
    if (simple)
        tree.showSimple();
    else
        tree.show();


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
    // noLoop();
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
        else if (keyCode == LEFT)   rotation -= PI/64;
        else if (keyCode == RIGHT)  rotation += PI/64;
    }
    else{
        switch(key){

            case ' ': // spacebar
                noiseSeed(++seed);
                tree.setPosition();
                break;

            case 's':

                // saveFrame(safeFilename("images/png/" + file, "png"));
                String bk = "";
                if (back == 255)
                    bk = "wht";
                String cols = hex(col1)+"_"+hex(col2);
                String name = "images/png/" + file + "_" + cols + bk + ".png";
                saveFrame(name);
                println("saved", name);
                break;

            case 'c':

                col1 = color(random(255), random(255), random(255));
                col2 = color(random(255), random(255), random(255));
                for (Node n : tree.nodes)
                    n.setCol();
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

            case 'q':

            branchingAngle += 0.05;
            tree.setPosition();
            break;

            case 'w':

            branchingAngle -= 0.05;
            tree.setPosition();
            break;

            case 'g':
                back = 255 - back;
                break;
        }
    }
     
    // redraw();
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
