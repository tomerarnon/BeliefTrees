
import processing.pdf.*;


ArrayList<Node> nodes = new ArrayList<Node>();

final int back = 20;  // background tint
float wf, hf; // width and height factors for display circle.
float dist;
float startSize;

boolean record = false;     // produces pdf; mapped to "r" key.
boolean border = true;      // cicular border; "b" key
boolean showInds = false;   // for debug; "i" key
boolean mustFit = true;     // nodes must fit in circle. "f" key

// String file = "baby";  // filename with no folder or extension for image-naming purposes
String file = "tiger";

void setup() {
    size(800, 800);
    wf = 0.98 * width;
    hf = 0.98 * height;
    dist = (float) width / 1400;
    startSize = (float) width / 30;

    // read json
    String jsonfile = "data/" + file + ".json";
    int[][] children = childrenFromJSON(jsonfile);
    increment(children, -1); // from 1 to 0 based indexing

    nodes = populateTree(children);

    if (isCyclic(children))
        println("NOTE: THIS GRAPH CONTAINS CYCLES!!");

}

void draw() {

    if (record)
        beginRecord(PDF, safeFilename("images/pomdpsketch_" + file, "pdf"));

    background(back);

    if (mustFit){
        // reset the random distance factor to the default,
        // then check if it should be decreased to allow all the nodes to fit
        // break if computation exceeds 2 seconds to avoid infinite loop case
        dist = (float) width / 1400;
        int start = millis();
        while (!allFit() && (millis() - start < 2000))
            cramNodes();
    }

    if (border){
        noFill();
        stroke(255-back);
        ellipse(width/2, height/2, wf, hf);
    }


    for (Node n : nodes) n.connect(); // lines first
    for (Node n : nodes) n.show();    // glows second

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

    noLoop();
}

void keyPressed() {

    if (key == CODED){

        if      (keyCode == DOWN) startSize -= 0.5;
        else if (keyCode == UP)   startSize += 0.5;

        nodes.get(0).size = startSize;
        for (int i = 1; i < nodes.size(); i++)
            nodes.get(i).setSize(startSize);
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

    for (Node n : nodes){

        n.selected = false;

        if (n.mouseOver())
            n.selected = true;
    }

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

    for(int i = 1; i < nodes.size(); i++)
        nodes.get(i).setPosition();
}


String safeFilename(String prefix, String extension) {
    int savecnt = 0;
    String filename = "";
    File f;

    while (true) {
        filename = prefix;
        if     (savecnt < 10)  filename += "00";
        else if(savecnt < 100) filename +=  "0";

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


ArrayList<Node> populateTree(int [][] children){

    // super inefficient function that does 3 separate passes over the array for safety's sake;
    // 1. do an initialization pass for the nodes
    // 2. assign parent-child relationships once all nodes exist
    // 3. set parameters once all relationships are set

    ArrayList<Node> nodesTree = new ArrayList<Node>(children.length);

    for (int i = 0; i < children.length; i++)
        nodesTree.add(new Node(width/2, height/2, startSize));

    recursiveAssignChildren(nodesTree, children, 0);

    return nodesTree;
}

void recursiveAssignChildren(ArrayList<Node> nodesTree, int[][] children, int i){

    nodesTree.get(i).assignChildren(nodesTree, children[i]);

    for (int j : children[i]){
        nodesTree.get(j).setParameters();
        recursiveAssignChildren(nodesTree, children, j);
    }
}


int[][] childrenFromJSON(String filename){

    JSONObject json = loadJSONObject(filename);
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
