import nico
import nico/vec
const orgName = "plikins"
const appName = "breakout"
import std/math

var buttonDown = false

type Abstract = ref object of RootObj
  pos:Vec2f
  vel:Vec2f

type Ball = ref object of Abstract
  color:int

type 
  Tile = ref object of Abstract
    health: int
    w,h:int
  Player = ref object of Abstract
  

var tiles: seq[Tile]
var objects: seq[Abstract]
var gridWidth = 6
var gridHeight = 2
var screenWidth = 60
const blockwidth = 10
const blockheight = 3
var player: Player
var gamestate: bool

var cursorX: int
proc newTile(x,y,w,h:int): Tile =
  result = new(Tile)
  result.pos.x=x
  result.pos.y=y
  result.w=w
  result.h=h
  result.health=2


proc newBall(x,y,xv,yv:int): Ball=
  result = new(Ball)
  result.pos.x = x
  result.pos.y = y
  result.vel.x = 0.3
  result.vel.y = 0.3
  result.color = 1

proc newBarrier(x:int): Tile=
  result = new(Tile)
  result.w=1
  result.h=screenHeight
  result.pos.x=x
  result.pos.y=0
  result.health=int(fcInf)


proc newPlayer(): Player=
  result = new(Player)
  result.pos.x=screenWidth div 2
  result.pos.y = 120
  result.vel.x = 0
  result.vel.y = 0
method draw(self: Abstract) {.base.}=
  setColor(0)
method draw(self: Player)=
  rectfill(self.pos.x,self.pos.y,self.pos.x+10,self.pos.y+3)
method draw(self: Tile)=
  setColor(self.health)
  boxfill(self.pos.x,self.pos.y,self.w,self.h)
method draw(self: Ball) =
  circfill(self.pos.x, self.pos.y, r=0)
proc gameInit() =
  loadFont(0, "font.png")
  player = newPlayer()
  objects.add(player)
  objects.add(newBall(screenWidth div 2, screenHeight div 2, -1,1))
  #tiles = newSeq[Tile](gridHeight*gridWidth)
  for x in 0..<gridWidth:
    for y in 0..<gridHeight:
      objects.add(newTile(x*blockwidth,
                          y*blockheight,
                          w=x*blockwidth+blockwidth,
                          h=y*blockheight+blockheight)
                  )
  #add barriers
  objects.add(newBarrier(0))
  objects.add(newBarrier(screenWidth-1))



proc overlaps(a,b: Abstract): bool =
  false
proc overlaps(a: Ball, b: Tile): bool =
  overlaps(b, a) 
proc overlaps(a: Tile, b: Ball): bool =
  let ax0 = a.pos.x 
  let ax1 = a.pos.x + a.w - 1
  let ay0 = a.pos.y 
  let ay1 = a.pos.y + a.h - 1

  let bx0 = b.pos.x #+ b.hitbox.x
  let bx1 = b.pos.x #+ b.hitbox.x + b.hitbox.w - 1
  let by0 = b.pos.y #+ b.hitbox.y
  let by1 = b.pos.y #+ b.hitbox.y + b.hitbox.h - 1
  return not ( ax0 > bx1 or ay0 > by1 or ax1 < bx0 or ay1 < by0 )


# colission detection
method collide(a,b: Abstract) {.base.} =
  discard
method collide(a: Ball, b: Abstract) =
  #get surface orientation
    #get contact surface
    #get contact vector
  discard
  #update block health
  
method collide(a: Abstract, b: Ball) =
  collide(b,a)
method collide(a: Tile, b:Ball)=
  collide(b,a)
method collide(a: Ball, b:Tile)=
  b.health -= 1
  if (b.health <= 0):
    var idx = system.find(objects, b)# O(N) 
    objects.del(idx)
  


proc gameUpdate(dt: float32) =
  if btn(pcLeft):
    player.pos.x = max(0,player.pos.x-1)
  if btn(pcRight):
    player.pos.x = min(screenWidth-10,player.pos.x+1)
  for obj in objects:
    if obj of Ball:
      obj.pos += obj.vel

proc gameDraw() =
  cls()
  for obj in objects:
    obj.draw()


nico.init(orgName, appName)
nico.createWindow(appName, screenWidth, 128, 3, false)
nico.run(gameInit, gameUpdate, gameDraw)
