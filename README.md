[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7065865.svg)](https://doi.org/10.5281/zenodo.7065865)

# Schelling-Sakoda refuting machine
NetLogo implementation of Schelling-Sakoda model of spatial segregation (see [Schelling (1971, pp. 154-158)](https://doi.org/10.1080/0022250X.1971.9989794)). The repository contains two main files:
  * **schelling-sakoda-refuting-machine.nlogo** is the NetLogo model, which can be run with [NetLogo Desktop](https://ccl.northwestern.edu/netlogo/) or [NetLogo Web](http://www.netlogoweb.org).
  * **index.html** is an HTML file where the model is embedded, so it can be run in any browser. You can do so by clicking [here](https://luis-r-izquierdo.github.io/schelling-sakoda-refuting-machine/).

This model has been included as appendix A in the paper "Social simulation models as refuting machines", by Mauhe, Izquierdo & Izquierdo (2022).

# Model description

We use bold italicised font for _**parameters**_. The model assumptions are the following:
  * There is a 16x13 grid containing _**number-of-agents**_ agents. This number is assumed to be even and within the interval [100, 200]. Half of the agents are blue and the other half orange.
  * Initially, agents are distributed at random in distinct grid cells.
  * Agents may be content or discontent.
  * Each individual agent is content if it has no Moore neighbours, or if at least _**%-similar-wanted**_ of its neighbours are of its same colour. Otherwise the agent is discontent.
  * In each iteration of the model, one discontent agent is randomly selected to move according to the rule indicated with parameter _**movement-rule**_:
    * If _**movement-rule**_ = "closest-content-cell", the discontent agent will move to the closest empty cell in the grid where the moving agent will be content, if there is any available. Otherwise it will move to a random empty cell. We use taxicab distance.
    * If _**movement-rule**_ = "random-content-cell", the discontent agent will move to a random empty cell in the grid where the moving agent will be content, if there is any available. Otherwise it will move to a random empty cell.
    * If _**movement-rule**_ = "random-cell", the discontent agent will move to a random empty cell in the grid.
    * If _**movement-rule**_ = "best-cell", the discontent agent will move to a random empty cell where the proportion of color-like neighbours is maximal. If a cell has no neighbours, it is assumed that the proportion of color-like nbrs is 1.
  * The model stops running when there are no discontent agents.

# How to use the model

The model can be setup and run using the following **buttons**:
  * **setup**: Sets the model up, creating _**number-of-agents**_/2 blue agents and _**number-of-agents**_/2 orange agents at random locations.
  * **go once**: Pressing this button will run the model one tick only.
  * **go**: Pressing this button will run the model until this same button is pressed again.

# Output

The **avg-%-similar** is the average proportion (across all agents with at least one neighbour) of an agent's neighbours that are the same color as the agent.

# References

* Mauhe, N., Izquierdo, L.R. & Izquierdo S.S. (2022). Social simulation models as refuting machines. Working paper
* Schelling, T. C. (1971). Dynamic models of segregation. _The Journal of Mathematical Sociology_, 1(2), 143–186.
[doi: 10.1080/0022250X.1971.9989794](https://doi.org/10.1080/0022250X.1971.9989794)
