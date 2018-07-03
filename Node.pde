class Node {

    Node parent = null;
    Node [] children;
    int nchild;           //how many children does this node have

    PVector pos;
    float size;
    int n;                // which of its parent's children is this one
    int level;            // how deep in the tree
    int hue;

    Node(float x, float y, float size_) {
        this.pos = new PVector(x, y);
        this.size = size_;
        this.level = 1;

        this.nchild = 0;
        this.hue = 0; //round(random(0, 360));
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

        setSize(0); //dummy value
        setPosition(); // parent based
        setHue();      // parent based
    }

    void setHue(){

        if (this.parent != null)
            this.hue = (this.parent.hue + round(random(20)))%255;
    }

    void randomHue(){
        this.hue = round(random(0, 360));
    }

    void setSize(float s){

        if (this.parent == null) this.size = s;
        // else                     this.size = this.parent.size / 1.5;
        // else                     this.size = sqrt(this.parent.size) * 1.5;
        else                     this.size = pow(this.parent.size, 0.9);
    }


    void setPosition() {

        if (this.parent == null)
            return;


        float angle, r;
        PVector offset;

        // r = this.size;// * this.size / 10;
        r = this.parent.size;
        // r = 0;
        // r += 10*random(dist, 6*dist);
        r += random(this.size, 2*this.size);
        r += 10*random(0, 4*dist);



        // angle is the allotted angle for each sibling node. For increasing levels, a smaller portion of a full circle is allocated
        angle = TWO_PI / (this.parent.nchild * (this.level-1));
        angle *= (this.n - parent.nchild/2.0 + 0.5);

        // push the position in the direction of "inertia"
        if (this.parent.parent != null) {
            PVector diff = PVector.sub(this.parent.pos, this.parent.parent.pos);

            angle += diff.heading();
        }

        offset = PVector.fromAngle(angle);
        offset.mult(r);
        this.pos = PVector.add(this.parent.pos, offset);
    }

    // check whether in a bounding ellipse with proportions to width/height
    boolean outOfBounds(float xf, float yf){

        float rx = xf*width/2;
        float ry = yf*height/2;

        float relx = this.pos.x - width/2;
        float rely = this.pos.y - height/2;

        relx /= rx;
        rely /= ry;


        return relx*relx + rely*rely > 1;
    }

    void show() {
        colorMode(HSB);
        fill(this.hue, 255, 255, 3); // consider writing a shader to do the fade just right
        noStroke();

        float rad;
        // float s = pow(this.size, 0.25);
        for (float r = 0.05; r < 1.5; r *= 1.05) {
            // rad = 20 * r * s;
            rad = this.size * r;
            ellipse(this.pos.x, this.pos.y, rad, rad);
        }
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

        stroke(255 - back, 255);
        fill(255 - back);
        textSize(14);

        pushMatrix();
        translate(this.pos.x, this.pos.y);
        text(n, 0, 0);
        popMatrix();
    }
}