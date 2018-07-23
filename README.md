# BeliefTrees

1. About
- This processing sketch is intended to visualize a state or belief tree of a pomdp solution.
- The nodes of the tree are read from a json file in the data folder that contains a vector of children nodes, and N and Q values for each node, stored as three separate vectors, and names "children", "N", and "V" respectively.
- Each integer in the array represents the index of a child node of the node in question.
- To save such a file in julia, create the vector of children nodes (i.e. with D3Trees) and save it as JSON.json(:children => Vector{Vector{Int}}(...), "N" => Vector{Int}(...), "V" => Vector{Float64}(...)).
- Once the file is in place, change the global String `file` to the filename (without the json extension).

2. Keybindings

- `r`          - save pdf
- `s`          - save png
- `b`          - draw circle border
- `c`          - choose new seed color
- `i`          - show indices of nodes (for degbugging)
- `p`          - toggle between simplified drawing and nice drawing
- `spacebar`   - recalculate node positions
- `up arrow`   - increase root node size
- `down arrow` - decrease root node size
