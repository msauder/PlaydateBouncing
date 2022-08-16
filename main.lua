import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

local NUM_BALLS <const> = 7
local g <const> = 10
local dt <const> = 0.5
local shkx, shky = 0, 0

local width <const> = pd.display.getWidth()
local height <const> = pd.display.getHeight()
local palette <const> = {
  {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF},
  {0x77, 0x77, 0xDD, 0xDD, 0x77, 0x77, 0xDD, 0xDD},
  {0x88, 0x88, 0x22, 0x22, 0x88, 0x88, 0x22, 0x22},
  {0x0, 0x22, 0x0, 0x88, 0x0, 0x22, 0x0, 0x88},
  {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}
}

balls = {}
particles = {}

--particle functions
local function drawParticle(p)
  if p.r < 5 then
	gfx.setPattern(p.clr)
    gfx.fillCircleAtPoint(p.x, p.y, p.r)
	return
  end
  for i=1, #palette - 1, 1 do
    gfx.setPattern(palette[#palette - i+1])
    gfx.fillCircleAtPoint(p.x + i, p.y - i, p.r - (i-1)*2)
  end
end

local function createParticle(x, y, r)
  local a = math.random()*2*math.pi
  table.insert(particles, {
    id = pd.string.UUID(8),
    x = x,
    y = y,
    r = math.random(math.floor(r))/3 + 1,
    vx = (math.random(10)+10)*math.cos(a),
    vy = (math.random(10)+10)*math.sin(a),
    clr = palette[math.random(3)+2]
  })
end

local function updateParticle(p, index)
  p.vy += g/p.r * dt
  if math.abs(p.vx) < 1 then
    p.vx *= 1.1
  end
  p.x += p.vx
  p.y += p.vy

  if p.x + p.r < 0 or p.x - p.r > width then
    table.remove(particles, index)
    return
  end
    if p.y + p.r > height then
        p.vy = -math.abs(p.vy/1.4)
    p.y = height - p.r
  end
end

--shake functions
local function updateShake()
  if math.abs(shkx) + math.abs(shky) < 0.5 then
    shkx, shky = 0, 0
  end
  shkx *= -0.6-math.random()*0.3
  shky *= -0.6-math.random()*0.3
end

local function addShake(p)
  local a = math.random()
  shkx = p*math.cos(a)
  shky = p*math.sin(a)
end

--ball functions
local function drawBall(b)
  for i=1, #palette, 1 do
    gfx.setPattern(palette[#palette - i+1])
    gfx.fillCircleAtPoint(b.x + i-1, b.y - i+1, b.r - (i-1)*3)
  end
end

local function createBall()
  table.insert(balls, {
    id = pd.string.UUID(8),
    x = math.random(width/2) + width/4,
    y = -20,
    r = math.random(100)/5 + 10,
    vx = 1 - math.random(200)/100,
    vy = 0,
    t = math.random(60, 250)
  })
end

local function updateBall(b, index)
  b.t -= dt
  if b.t < 0 then
    for i=1, math.floor(b.r)*2, 1 do
      createParticle(b.x, b.y, b.r)
    end
    addShake(6)
    table.remove(balls, index)
    return
  end

  b.vy += g/b.r * dt
  b.x += b.vx
  b.y += b.vy

  if b.x - b.r < 0  then
    b.vx = math.abs(b.vx/1.05)
    b.x = b.r
  elseif b.x + b.r > width then
    b.vx = -math.abs(b.vx/1.05)
    b.x = width - b.r
  end
    if b.y + b.r > height then
        b.vy = -math.abs(b.vy/1.15)
    b.y = height - b.r
  end
end

local function init()
  --pd.display.setMosaic(1,1)
  pd.display.setRefreshRate(50) -- Sets framerate to 50 fps
  math.randomseed(pd.getSecondsSinceEpoch()) -- seed for math.random

  createBall()
end

init()

local function updateGame()
  for i,b in ipairs(balls) do
    updateBall(b, i)
  end
  for i,p in ipairs(particles) do
    updateParticle(p, i)
  end
  if #balls == 1 or (#balls <= NUM_BALLS and math.random(100) < 5) then
    createBall()
  end
end

local function drawGame()
  gfx.clear()
  pd.display.setOffset(shkx, shky)
  gfx.pushContext()

  for _,b in ipairs(balls) do
    drawBall(b)
  end

  for _,p in ipairs(particles) do
    drawParticle(p)
  end

  gfx.popContext()
end

function pd.update()
  updateGame()
  updateShake()
  drawGame()
  --pd.drawFPS(0,0) -- FPS widget
end
