class Node {

    Node parent = null;
    Node [] children;
    int nchild;           //how many children does this node have

    PVector pos;
    float size;
    int n;                // which of its parent's children is this one
    int level;            // how deep in the tree
    int hue;

    boolean selected = false;

    Node(float x, float y, float size_) {
        this.pos = new PVector(x, y);
        this.size = size_;
        this.level = 0;

        this.nchild = 0;
        this.hue = 0; //round(random(0, 360));
        this.children = new Node[0];
    }

    void assignParent(Node parent_, int n_){

        this.parent = parent_;
        this.n = n_;
        this.level = parent_.level + 1;
    }

    void assignChildren(ArrayList<Node> nodes, int [] child_inds){

        this.nchild = child_inds.length;
        this.children = new Node[this.nchild];

        if (this.nchild != 0){

            Node child;
            for (int n = 0; n  < this.nchild; n++){

                child = nodes.get(child_inds[n]);
                child.assignParent(this, n);

                this.children[n] = child;
            }
        }
    }

    void setParameters(){

        setSize(startSize); //dummy value
        setPosition(); // parent based
        setHue();      // parent based
    }

    void setHue(){

        if (this.parent != null){
                this.hue = this.parent.hue + round(random(20));
                this.hue %= 255;
            }
        }

    void randomHue(){
        this.hue = round(random(0, 360));
    }

    void setSize(float s){

        if (this.parent == null) this.size = s;
        else                     this.size = pow(this.parent.size, 0.95);
    }


    void setPosition() {

        if (this.parent == null)
            return;


        float angle, r;

        r = this.parent.size;
        r += this.size;
        // r += random(0, this.size);
        // r += random(0, 40*dist);

        // angle is the allotted angle for each sibling node. For increasing levels,
        // a smaller portion of a full circle is allotted for all the siblings.
        // The vector grandparent --> parent is used to adjust the angle
        // in the direction of "inertia" to set the overall trend
        angle = TWO_PI / (this.parent.nchild * (this.level));
        angle *= (this.n - parent.nchild/2.0 + 0.5);

        if (this.parent.parent != null) {
            PVector diff = PVector.sub(this.parent.pos, this.parent.parent.pos);

            angle += diff.heading();
        }

        PVector offset = PVector.fromAngle(angle).mult(r);
        this.pos = PVector.add(this.parent.pos, offset);
    }

    boolean outOfBounds(float xProp, float yProp){
        // check whether the node is inside a centered bounding ellipse proportional to width/height
        // out of bounds condition: (x/a)^2 + (y/b)^2 > 1

        // normalize and translate to center:
        float x = this.pos.x/width  - 0.5;
        float y = this.pos.y/height - 0.5;

        // note that xProp is the x-diameter of the ellipse,so
        // xProp/2 is the constant `a` in the above equation
        x /= (0.5 * xProp);
        y /= (0.5 * yProp);

        return x*x + y*y > 1;
    }

    void show() {
        colorMode(HSB);
        fill(this.hue, 255, 255, 3);
        noStroke();

        float rad;
        for (float r = 0.05; r < 1.5; r *= 1.05) {
            rad = this.size * r;
            ellipse(this.pos.x, this.pos.y, rad, rad);
        }

        if (this.selected)
            showSelected();
    }

    void connect() {

        stroke(255-back, 50);
        strokeWeight(0.5);
        for (Node child : this.children){
            line(this.pos.x, this.pos.y, child.pos.x, child.pos.y);
        }
    }

    // debug
    void showInd(int n){

        textSize(14);

        pushMatrix();
        translate(this.pos.x, this.pos.y);
        text(n, 0, 0);
        popMatrix();
    }

    boolean mouseOver(){

        return (abs(mouseX - this.pos.x) < this.size) &&
               (abs(mouseY - this.pos.y) < this.size);
    }

    void arrow(){

        stroke(255 - back);
        fill(255 - back);
        strokeWeight(1);

        PVector diff;
        for (Node child : this.children){

            line(this.pos.x, this.pos.y, child.pos.x, child.pos.y);
            diff = PVector.sub(child.pos, this.pos);

            pushMatrix();
            translate(child.pos.x, child.pos.y);
            rotate(diff.heading() - HALF_PI);
            triangle(0, 0, -4, -6, 4, -6);

            popMatrix();
        }
    }

    void showSelected(){

        markSelected();
        for (Node child : this.children){
            child.markSelected();
        }

        arrow();
    }

    void markSelected(){

        // recolor the node to anti-background
        fill(255-back, 150);
        stroke(back);

        ellipse(this.pos.x, this.pos.y, this.size, this.size);
        // mark with a cross
        line(this.pos.x - 10, this.pos.y,      this.pos.x + 10,  this.pos.y);
        line(this.pos.x,      this.pos.y - 10, this.pos.x,       this.pos.y + 10);

    }

} // Node end


// return longest path to a leaf node.
int treeHeight(Node root, int n){

    if (root.children.length == 0)  // leaf node
        return n;

    // compute height of each subtree and keep the maximum.
    int h = 0;
    int temp_h = 0;

    for (Node child : root.children){

        temp_h = treeHeight(child, n + 1);

        h = (temp_h > h) ? temp_h : h;
    }

    return h;
}

int treeHeight(Node root){
    return treeHeight(root, 1);
}



boolean isCyclicUtil(int i, boolean[] visited, boolean[] recStack, int[][] adj){

    if (recStack[i]) return true;
    if (visited[i])  return false;

    // Mark the current node as visited and
    // part of recursion stack
    visited[i]  = true;
    recStack[i] = true;

    for (int child : adj[i]){
        if (isCyclicUtil(child, visited, recStack, adj))
            return true;
    }

    recStack[i] = false;

    return false;
}

boolean isCyclic(int[][] adj) {

    // Mark all the vertices as not visited and
    // not part of recursion stack
    boolean[] visited  = new boolean[adj.length];
    boolean[] recStack = new boolean[adj.length];

    // Call the recursive isCyclicUtil function
    for (int i = 0; i < adj.length; i++){
        if (isCyclicUtil(i, visited, recStack, adj))
            return true;
    }

    return false;
}

void recursiveSetPosition(Node parent){

    for (Node child : parent.children){
        child.setPosition();
        recursiveSetPosition(child);
    }

}

void recursiveSetHue(Node parent){

    for (Node child : parent.children){
        child.setHue();
        recursiveSetHue(child);
    }
}