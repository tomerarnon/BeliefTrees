# BeliefTrees

1.

- This processing sketch is intended to visualize a state or belief tree of a pomdp solution.
- The nodes of the tree are read from a json file in the data folder with the format {"children:Vector-Of-Vectors-Of-Integers"} (eg: {"children":[[2,3],[],[4],[]]}).
- Each integer in the array represents the index of a child node of the node in question.
- To save such a file in julia, create the vector of children nodes (i.e. with D3Trees) and save it as the pair :children => JSON.json(vector).
- Once the file is in place, change the global variable `file` to the filename (without the json extension).

2. keybindings

- `r` save pdf
- `s` save png
- `b` draw circle border
- `c` choose new seed color
- `i` show indices of nodes (for degbugging)
- `f` toggle requirement for the nodes to fit within the circle boundary
- spacebar (broken): recalculate node positions
- up arrow (broken): increase root node size
- down arrow (broken): decrease root node size
