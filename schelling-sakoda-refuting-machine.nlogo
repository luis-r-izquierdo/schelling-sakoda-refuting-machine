;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GNU GENERAL PUBLIC LICENSE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Schelling-Sakoda model of spatial segregation.
;; Schelling-Sakoda model of spatial segregation is a milestone in the study of emergent
;; global phenomena based on local social interactions
;; (Sakoda 1949, 1971; Schelling 1969, 1971, 1978).
;; Schelling-Sakoda model illustrates how clearly distinctive patterns
;; of spatial segregation (e.g. ghettos) can emerge even
;; if individuals are only weakly segregationist.
;;
;; Sakoda, J. M. (1949) Minidoka: An Analysis of Changing Patterns of Social Behavior.
;;   PhD thesis, University of California.
;; Sakoda, J. M. (1971) The Checkerboard Model of Social Interaction.
;;  Journal of Mathematical Sociology, 1(1):119–132.
;;  https://doi.org/10.1080/0022250X.1971.9989791
;; Schelling, T. C. (1969) Models of Segregation (RAND Memorandum RM-6014-RC).
;;   Technical report, RAND Corporation, Santa Monica, California, May 1969.
;;   http:// www.rand.org/pubs/research_memoranda/RM6014.html.
;; Schelling, T. C. (1971) Dynamic Models of Segregation.
;;   Journal of Mathematical Sociology, 1(2), pp. 143-186.
;;   https://doi.org/10.1080/0022250X.1971.9989794
;; Schelling, T. C. (1978) Micromotives and macrobehavior.
;;   New York: Norton.
;;
;; Copyright (C) 2022 Luis R. Izquierdo, Segismundo S. Izquierdo,
;;   José M. Galán, José I. Santos & William H. Sandholm
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
;;
;; Contact information:
;; Luis R. Izquierdo
;;   University of Burgos, Spain.
;;   e-mail: lrizquierdo@ubu.es

;;;;;;;;;;;;;;;;;
;;; VARIABLES ;;;
;;;;;;;;;;;;;;;;;

globals [
  avg-%-similar     ;; the average proportion (across agents with at least one neighbour)
                    ;; of an agent's neighbours that are the same color as the agent.
  %-discontent-agents  ;; percentage of discontent agents
]

turtles-own [
  content?         ;; indicates whether at least %-similar-wanted percent
                 ;; of my neighbours are the same colour as me.
  total-nbrs     ;; number of neighbours
  similar-nbrs   ;; number of neighbours with the same colour as me
]

patches-own [
  turtle-here? ;; for efficiency
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; SETUP PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to startup
  clear-all
  setup-agents
  ask turtles [update-happiness]
  ask patches [set turtle-here? any? turtles-here] ;; for efficiency
  do-plots-and-statistics
  reset-ticks
end

to setup-agents
  if number-of-agents >= count patches [
    user-message (word "This grid only has room for " (count patches - 1)" moving agents.")
    stop
  ]
  ;; create agents on random cells.
  set-default-shape turtles "person"
  ask n-of number-of-agents patches
    [ sprout 1 [set color cyan] ]
  ;; turn half the agents green
  ask n-of (number-of-agents / 2) turtles
    [ set color orange ]
end

;;;;;;;;;;;;;;;;;;;;;;
;;; MAIN PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;

to go
  if all? turtles [content?] [stop]
  ask one-of turtles with [not content?] [move]
  tick
  do-plots-and-statistics
end

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; AGENTS' PROCEDURES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to move
  let nbrs-before turtles-on neighbors
  let old-patch patch-here
  let empty-patches patches with [not turtle-here?]

  let my-color color
  set color black ; to avoid counting yourself
                  ; if the patch you are looking at is a neighbor

  (ifelse

    movement-rule = "random-cell" [
      ;; move to a random empty patch
      move-to one-of empty-patches
    ]

    movement-rule = "random-content-cell" [
      ;; move to a random empty patch where you would be content
      let good-patches empty-patches with [good-for-color? my-color]
      move-to one-of ifelse-value any? good-patches
      [good-patches] [empty-patches]
    ]

    movement-rule = "closest-content-cell" [
      ;; move to the closest empty patch where you would be content.
      ;; distance is taxicab (i.e. Manhattan) distance
      let good-patches empty-patches with [good-for-color? my-color]
      move-to ifelse-value any? good-patches
      [min-one-of good-patches [taxicab-distance-to myself]] [one-of empty-patches]
    ]

    movement-rule = "best-cell" [
      ;; move to one of the empty patches where you would have
      ;; the greatest proportion of color-like neighbors
      ;; (patches with no neighbors are as good as patches
      ;; where all neighbors are the same color as you)
      move-to max-one-of empty-patches [prop-similar-for-color? my-color]
    ]

  )

  set color my-color
  ask old-patch [set turtle-here? false]
  set turtle-here? true

  ;; now update agents' happiness, but ask only those
  ;; agents whose happiness may have changed.
  ask nbrs-before [update-happiness]
  ask turtles-on neighbors [update-happiness]
  update-happiness
end

to-report good-for-color? [c]
  report 100 * prop-similar-for-color? c >= %-similar-wanted
end

to-report prop-similar-for-color? [c]
  let nbrs (turtles-on neighbors)
  report ifelse-value any? nbrs [(count nbrs with [color = c]) / (count nbrs)] [1]
  ;; if there are no nbrs, it is assumed that the proportion of color-like nbrs is 1
end

to-report taxicab-distance-to [a]
  report abs (pxcor - [xcor] of a) + abs (pycor - [ycor] of a)
end

to update-happiness
  let my-nbrs (turtles-on neighbors)
  set total-nbrs   (count my-nbrs)
  set similar-nbrs (count my-nbrs with [color = [color] of myself])
  set content? similar-nbrs >= (%-similar-wanted * total-nbrs / 100)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PLOTS & STATISTICS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to do-plots-and-statistics
  set %-discontent-agents 100 * (count turtles with [not content?]) / (count turtles)
  let list-of-%-similar ([similar-nbrs / total-nbrs] of turtles with [total-nbrs > 0])
  set avg-%-similar ifelse-value (length list-of-%-similar > 0) [100 * mean list-of-%-similar] ["N/A"]

  set-current-plot "%-similar nbrs histogram"
  histogram list-of-%-similar
end
@#$#@#$#@
GRAPHICS-WINDOW
219
10
515
253
-1
-1
18.0
1
10
1
1
1
0
0
0
1
0
15
0
12
1
1
1
ticks
30.0

MONITOR
221
303
347
360
% discontent
%-discontent-agents
1
1
14

MONITOR
373
303
515
360
w (avg % similar)
avg-%-similar
2
1
14

PLOT
522
199
775
360
Avg Percentage Similar Nbrs
time
%
0.0
5.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -16777216 true "" "plot avg-%-similar"

PLOT
522
10
775
195
Percentage discontent agents
time
%
0.0
5.0
0.0
100.0
true
false
"" ""
PENS
"percent" 1.0 0 -16777216 true "" "plot %-discontent-agents"

SLIDER
6
112
214
145
number-of-agents
number-of-agents
80
200
138.0
2
1
NIL
HORIZONTAL

SLIDER
6
150
214
183
%-similar-wanted
%-similar-wanted
0
100
45.0
1
1
%
HORIZONTAL

BUTTON
7
10
90
43
setup
startup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
109
10
202
43
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
7
61
90
94
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
6
189
215
360
%-similar nbrs histogram
%-similar
#-agents
0.0
1.1
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 1 -16777216 true "" ""

MONITOR
110
47
201
104
NIL
ticks
17
1
14

CHOOSER
220
256
515
301
movement-rule
movement-rule
"closest-content-cell" "random-content-cell" "random-cell" "best-cell"
0

@#$#@#$#@
# MODEL DESCRIPTION

We use bold italicised font for _**parameters**_. The model assumptions are the following:

  * There is a 20x20 grid containing _**number-of-agents**_ agents. This number is assumed to be even and within the interval [100, 300]. Half of the agents are blue and the other half orange.
	
  * Initially, agents are distributed at random in distinct grid cells.
	
  * Agents may be content or discontent.
	
  * Each individual agent is content if it has no Moore neighbours, or if at least _**%-similar-wanted**_ of its neighbours are of its same colour. Otherwise the agent is discontent.
	
  * In each iteration of the model, one discontent agent is randomly selected to move according to the rule indicated with parameter _**movement-rule**_:
    * If _**movement-rule**_ = "closest-content-cell", the discontent agent will move to the closest empty cell in the grid where the moving agent will be content, if there is any available. Otherwise it will move to a random empty cell. We use taxicab distance.
    * If _**movement-rule**_ = "random-content-cell", the discontent agent will move to a random empty cell in the grid where the moving agent will be content, if there is any available. Otherwise it will move to a random empty cell.
    * If _**movement-rule**_ = "random-cell", the discontent agent will move to a random empty cell in the grid.
    * If _**movement-rule**_ = "best-cell", the discontent agent will move to a random empty cell where the proportion of color-like neighbours is maximal. If a cell has no neighbours, it is assumed that the proportion of color-like nbrs is 1.
    

  * The model stops running when there are no discontent agents.

# HOW TO USE THE MODEL

The model can be setup and run using the following **buttons**:

  * **setup**: Sets the model up, creating _**number-of-agents**_/2 blue agents and _**number-of-agents**_/2 orange agents at random locations.
  * **go once**: Pressing this button will run the model one tick only.
  * **go**: Pressing this button will run the model until this same button is pressed again.

# OUTPUT

The **avg-%-similar** is the average proportion (across all agents with at least one neighbour) of an agent's neighbours that are the same color as the agent.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -8630108 true false 90 19 150 37 210 19 195 4 105 4
Polygon -8630108 true false 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
