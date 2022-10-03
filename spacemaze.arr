use context essentials2021
include shared-gdrive("dcic-2021", "1wyQZj_L0qqV9Ekgr9au6RX2iqt2Ga8Ep")

include shared-gdrive("project-2-support-fall-2021", "12RtBw6X8lHH-1jTHUpZY9Clg2_hUFu2A")

include image
include tables
include reactors
import lists as L

ssid = "1BO3pAfwG2q1A5qRQuz0c_RypndDTAFaNPBlPLXVzpwQ"
maze-data = load-maze(ssid)
item-data = load-items(ssid)

#******** DATATYPES ********

data Gadgets:
  | oxygen-g(
      x :: Number,
      y :: Number,
      img :: Image)
  | star-g(
      x :: Number,
      y :: Number,
      img :: Image)
  | alien-g(
      x :: Number,
      y :: Number,
      img :: Image)
  | spaceship-g(
      x :: Number,
      y :: Number,
      img :: Image)
end

data Player:
    player(x :: Number, y :: Number, 
      img :: Image, 
      stamina :: Number)
end 

## NEED TO ADD IN THE STAMINA BAR
data GameState:
  | state(player :: Player, 
      gadgets :: List<Gadgets>)
end


  
      
    


fun get-item(l :: List<List<String>>, x :: Number, y :: Number) -> String:
  l.get(y).get(x)
end
check:
get-item(load-maze-n(ssid, 35), 0, 5) is "x"
get-item(load-maze-n(ssid, 35), 10, 15) is "o"
end

#********* RENDERING IMAGES ************ 
wall-image = load-texture("wall.png")
tile-image = load-texture("tile.png")
oxygen = load-texture("oxygen.png")
star-image = load-texture("star.png")
alien = load-texture("alien.png")
spaceship = load-texture("spaceship.png")
player-down = load-texture("milda-down.png")

#********* BUILDING BACKGROUND OF MAZE ********
fun image-maze(s :: String) -> Image:
  doc: "call the image for wall or tile"
  if s == "x":
    wall-image
  else if s == "o":
    tile-image
  else:
    empty
  end
end


fun build-row(s :: List<String>) -> Image:
  doc: "build maze by row, put individual cell images next to each other"
  cases (List) s:
    | empty => empty-image
    | link(fst, rst) => beside(image-maze(fst), build-row(rst))
  end
end

fun build-maze(maze :: List<List<String>>) -> Image:
  doc: "place rows on top of one another to create final maze background (no gadgets yet)"
  cases (List) maze:
    | empty => empty-image
    | link(fst, rst) => above(build-row(fst), build-maze(rst))
  end
end

generate-maze = build-maze(maze-data)

generate-maze

# ********** ADDING GADGETS ONTO MAZE ************

fun row-to-gadget(r :: Row) -> Gadgets:
  doc: "turn rows from item-data table into Gadgets"
  if r["name"] == "Oxygen":
    oxygen-g(
      r["x"],
      r["y"],
      load-texture(r["url"]))
  else if r["name"] == "Star":
    star-g(
      r["x"],
      r["y"],
      load-texture(r["url"]))
  else if r["name"] == "Alien":
    alien-g(
      r["x"],
      r["y"],
      load-texture(r["url"]))
  else:
    spaceship-g(
      r["x"],
      r["y"],
      load-texture(r["url"]))
  end
end

table-w-gadgets = build-column(item-data, "Gadgets", row-to-gadget)

# LIST OF GADGETS (from turning the column into a list)
gadgets-list = table-w-gadgets.get-column("Gadgets")
    

fun map-gadgets(list-gadgets :: List, i :: Image) -> Image:
  cases (List) list-gadgets:
    | empty => i
    | link(fst, rst) => place-image(fst.img, ((fst.x * 30) + 12) + 3, ((fst.y * 30) + 12) + 3, map-gadgets(rst, i))
  end
end
  
fun map-milda(d1 :: Player, i1 :: Image) -> Image:
  fun milda-only(d2 :: Player, i :: Image):
    place-image(player-down, ((d2.x * 30) + 12) + 3, ((d2.y * 30) + 12) + 3,  i)
  end
  overlay-align("left", "bottom", (spaceship), milda-only(d1, i1))
end
  
with-gadgets = map-gadgets(gadgets-list, generate-maze) 


fun map-stamina(milda :: Player) -> Image:
  if milda.stamina < 0:
    rectangle(0,20, "solid", "yellow")
    else:
    rectangle(milda.stamina,20, "solid", "yellow")
end
end

fun draw-game(gs1 :: GameState) -> Image:
  fun draw-gadgets( gs2 :: GameState) -> Image:
    map-gadgets(gs2.gadgets, generate-maze)
  end
  
  overlay-align("center","bottom", map-stamina(gs1.player),map-milda(gs1.player, draw-gadgets(gs1)))
end



#********** INITIAL STATE ********

init-state = state(player(1, 1, player-down, 1050), gadgets-list)




#********** ENDING THE GAME ************

fun game-complete(gs :: GameState) -> Boolean:
  gs.player.stamina == 0
  #check if player.x = ship.x
end

#********** BUILDING THE ON-KEY FUNCTION ***********  


#TESTS FOR FUNCTIONS
test-oxygen = oxygen-g(1,1, load-texture("oxygen.png"))
  test-star = star-g(2,2, load-texture("star.png"))
test-alien = alien-g(3,3, load-texture("alien.png"))
test-ship = spaceship-g(32,5, load-texture("spaceship.png"))
test-player = player(2,3, load-texture("milda-down.png"), 10)
test-list-gadgets = [list: test-oxygen, test-star, test-alien, test-ship]
test-gs = state(test-player,test-list-gadgets)


fun key-pressed(gs :: GameState, key :: String) -> GameState:
  doc:"``takes in the x coordinates and y coordinates and updates the the position of ccoordinate based on the key pressed"
  
  fun help-x(gameS :: GameState, number1 :: Number, number2 :: Number) -> Player:
    player(gameS.player.x + number1, 
      gameS.player.y, 
      gameS.player.img, 
      gameS.player.stamina + number2)
  end
  
  fun help-y(gameS :: GameState, number1 :: Number, number2 :: Number) -> Player:
    player(gameS.player.x , 
      gameS.player.y + number1, 
      gameS.player.img, 
      gameS.player.stamina + number2)
  end
  
  x = gs.player.x
  y = gs.player.y
  
  if (key == "w") and (get-item(maze-data, x, y - 1) == "o"): 
    state(help-y(gs, -1, -75), 
      gs.gadgets) 
    
    
    
  else if (key == "a") and (get-item(maze-data, x - 1, y) == "o"):
    state(help-x(gs, -1, -75),
      gs.gadgets)
    
  else if (key == "s") and (get-item(maze-data, x, y + 1) == "o"):
    state(help-y(gs, 1, -75), 
      gs.gadgets)
    
  else if (key == "d") and (get-item(maze-data, x + 1, y) == "o"):
    state(help-x(gs, 1, -75), 
      gs.gadgets)   
 
  else:
    state(gs.player,gs.gadgets)
  end
end
    
 

maze-game =
  reactor:
    init              : init-state,
    to-draw           : draw-game,
    # on-mouse        : mouse-click, # portals only
    on-key            : key-pressed,
     stop-when       : game-complete, # [up to you]
    # close-when-stop : true, # [up to you]
    title             : "Milda's Great Space Race!"
  end 

interact(maze-game)
