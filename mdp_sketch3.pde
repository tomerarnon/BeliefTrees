
import processing.pdf.*;


ArrayList<Node> nodes = new ArrayList<Node>();

final int back = 0;  // background tint
float wf, hf; // width and height factors for display circle.
float dist;
float startSize;
float rotation;
int minN, maxN, hue1, hue2;
float minV, maxV;
color col1, col2;


boolean record = false;     // produces pdf; mapped to "r" key.
boolean border = false;      // circular border; "b" key
boolean showInds = false;   // for debug; "i" key
boolean mustFit = true;     // nodes must fit in circle. "f" key

String file = "baby2";  // filename with no folder or extension for image-naming purposes
// String file = "tiger";

void setup() {
    size(700, 700);
    wf = 0.98 * width;
    hf = 0.98 * height;
    dist = (float) width / 1400;
    startSize = (float) width / 15;
    rotation = 0;

    // read json
    String jsonfile = "data/" + file + ".json";
    JSONObject json = loadJSONObject(jsonfile);
    int[][] children = childrenFromJSON(json);
    increment(children, -1); // from 1 to 0 based indexing
    float [] Vs = jsonToFloat(json.getJSONArray("V"));
    int [] Ns = jsonToInt(json.getJSONArray("N"));

    minN = min(Ns); maxN = max(Ns);
    minV = min(Vs); maxV = max(Vs);

    // hue1 = 0;
    // hue2 = 300;

    col1 = color(36, 224, 69, 3);
    col2 = color(70, 26, 142, 3);

    nodes = populateTree(children, Ns, Vs);

    if (isCyclic(children))
        println("NOTE: THIS GRAPH CONTAINS CYCLES!!");

}

void draw() {

    pushMatrix();
    translate(width/2, height/2);
    rotate(rotation);
    translate(-width/2, -height/2);

    if (record)
        beginRecord(PDF, safeFilename("images/pomdpsketch_" + file, "pdf"));

    background(back);

    // if (mustFit){
    //     // reset the random distance factor to the default,
    //     // then check if it should be decreased to allow all the nodes to fit
    //     // break if computation exceeds 2 seconds to avoid infinite loop case
    //     dist = (float) width / 1400;
    //     int start = millis();
    //     while (!allFit() && (millis() - start < 2000))
    //         cramNodes();
    // }

    if (border){
        noFill();
        stroke(255-back);
        ellipse(width/2, height/2, wf, hf);
    }


    // lines first
    stroke(255-back, 50);
    for (Node n : nodes){
        n.connect();
    }

    // glows second
    noStroke();
    colorMode(HSB);
    for (Node n : nodes){
        n.show();
    }

    if (showInds){
        fill(255 - back);
        for (int i = 0; i < nodes.size(); i++)
            nodes.get(i).showInd(i);

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
            startSize -= 0.5;
            recursiveSetSize(nodes.get(0), startSize);
        }
        else if (keyCode == UP){
            startSize += 0.5;
            recursiveSetSize(nodes.get(0), startSize);
        }
        else if (keyCode == LEFT)   rotation -= PI/6;
        else if (keyCode == RIGHT)  rotation += PI/6;
    }
    else{
        switch(key){

            case ' ': // spacebar
                recursiveSetPosition(nodes.get(0));
                break;

            case 's':

                saveFrame(safeFilename("images/pomdpsketch_" + file, "png"));
                println("saved");
                break;

            case 'c':

                nodes.get(0).randomHue();
                recursiveSetHue(nodes.get(0));
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

            case 'f':

                mustFit = !mustFit;
                break;
        }
    }
     
    redraw();
}


void mousePressed(){

    // for (Node n : nodes){

    //     n.selected = false;

    //     if (n.mouseOver())
    //         n.selected = true;
    // }

    Node root = nodes.get(0);
    root.pos = new PVector(mouseX, mouseY);

    recursiveSetPosition(root);

    redraw();
}

boolean allFit(){

    for(int i = nodes.size() -1; i >= 0; i--)
        if (nodes.get(i).outOfBounds(wf, hf))
            return false;

    return true;
}

void cramNodes(){

    dist -= 0.01;

    recursiveSetPosition(nodes.get(0));
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


ArrayList<Node> populateTree(int [][] children, int[] Ns, float[] Vs){

    // First create "blank" nodes
    // then assign parent-children relationships
    // recursively down the tree

    ArrayList<Node> nodesTree = new ArrayList<Node>(children.length);

    for (int i = 0; i < children.length; i++){

        Node n = new Node(width/2, height/2, Ns[i], Vs[i]);
        nodesTree.add(n);

    }

    recursiveAssignChildren(nodesTree, children, 0);

    return nodesTree;
}

void recursiveAssignChildren(ArrayList<Node> nodesTree, int[][] children, int i){

    // assign this node's children
    Node n = nodesTree.get(i);
    n.assignChildren(nodesTree, children[i]);
    n.setParameters();


    // iterate over the indices of the children and recurse
    for (int j : children[i]){
        recursiveAssignChildren(nodesTree, children, j);
    }
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
