Vector2d = require("lib.Vector2d")

GameConfig = require("lib.GameConfig")
GameClock = require("lib.GameClock")
RenderManager = require("lib.RenderManager")
SoundManager = require("lib.SoundManager")

LuaApiSandbox = require("lib.LuaApiSandbox")

State = require("lib.State")
GameState = require("lib.GameState")
LocalGameState = require("lib.LocalGameState")

Match = require("lib.Match")
MatchEvent = require("lib.MatchEvent")

PlayerIdentity = require("lib.PlayerIdentity")
PlayerInput = require("lib.PlayerInput")

PhysicWorld = require("lib.PhysicWorld")

GameLogic = require("lib.GameLogic")
FallbackGameLogic = require("lib.FallbackGameLogic")
ScriptedGameLogic = require("lib.ScriptedGameLogic")

InputSource = require("lib.InputSource")
LocalInputSource = require("lib.LocalInputSource")
ScriptedInputSource = require("lib.ScriptedInputSource")

-- Enum PlayerSide
NO_PLAYER = -1
LEFT_PLAYER = 0
RIGHT_PLAYER = 1

-- Globals.h
BLOBBY_PORT = 1234
BASE_RESOLUTION_X = 800
BASE_RESOLUTION_Y = 600
ROUND_START_SOUND_VOLUME = 0.2
BALL_HIT_PLAYER_SOUND_VOLUME = 0.4
DEFAULT_RULES_FILE = "default.lua"

-- GameConstants.h
LEFT_PLANE = 0
RIGHT_PLANE = 800
BLOBBY_WIDTH = 75
BLOBBY_HEIGHT = 89
BLOBBY_UPPER_SPHERE = 19
BLOBBY_UPPER_RADIUS = 25
BLOBBY_LOWER_SPHERE = 13
BLOBBY_LOWER_RADIUS = 33
GROUND_PLANE_HEIGHT_MAX = 500
GROUND_PLANE_HEIGHT = GROUND_PLANE_HEIGHT_MAX - BLOBBY_HEIGHT / 2
BLOBBY_MAX_JUMP_HEIGHT = GROUND_PLANE_HEIGHT - 206.375	-- GROUND_Y - MAX_Y
BLOBBY_JUMP_ACCELERATION = -15.1
GRAVITATION = BLOBBY_JUMP_ACCELERATION * BLOBBY_JUMP_ACCELERATION / BLOBBY_MAX_JUMP_HEIGHT
BLOBBY_JUMP_BUFFER = GRAVITATION / 2
BALL_WIDTH = 64
BALL_HEIGHT = 64
BALL_RADIUS = 31.5
BALL_GRAVITATION = 0.287
BALL_COLLISION_VELOCITY = math.sqrt(0.75 * RIGHT_PLANE * BALL_GRAVITATION)
NET_POSITION_X = RIGHT_PLANE / 2
NET_POSITION_Y = 438
NET_RADIUS = 7
-- NET_SPHERE = 154		-- what is the meaning of this value ???????
NET_SPHERE_POSITION = 284
STANDARD_BALL_HEIGHT = 269 + BALL_RADIUS
BLOBBY_SPEED = 4.5 -- BLOBBY_SPEED is necessary to determine the size of the input buffer
STANDARD_BALL_ANGULAR_VELOCITY = 0.1

-- PhysicWorld.cpp
BLOBBY_ANIMATION_SPEED = 0.5

-- GameLogic.cpp
SQUISH_TOLERANCE = 11
FALLBACK_RULES_NAME = "__FALLBACK__"
TEMP_RULES_NAME = "server_rules.lua"

-- RenderManager.h
FONT_WIDTH_NORMAL =	24
FONT_WIDTH_SMALL = 12

-- ScriptedInputSource.h
WAITING_TIME = 1500 -- The time the bot waits after game start

local app = {}
app._VERSION = "0.1.0"
app.accumulator = 0.0
app.tickPeriod = 1/60 -- seconds per tick (60 ticks/s)

function love.load(...)
  love.window.setTitle(love.window.getTitle() .. " v" .. app._VERSION)

  GameConfig.load("conf/config.xml")

  RenderManager:init()
  RenderManager.showShadow = GameConfig.getBoolean("show_shadow")

  SoundManager.isMuted = GameConfig.getBoolean("mute")
  SoundManager.setGlobalVolume(GameConfig.getNumber("global_volume"))
  SoundManager.loadSound("res/sfx/bums.wav")
  SoundManager.loadSound("res/sfx/pfiff.wav")

  local bg = "res/gfx/backgrounds/" .. GameConfig.get("background")
  if love.filesystem.getInfo(bg) then
   	RenderManager:setBackground(bg)
  end

  app.state = State()
  app.state:update()
end

function love.update(dt)
  dt = math.min(app.tickPeriod, dt)

  app.accumulator = app.accumulator + dt
  while app.accumulator >= app.tickPeriod do
    app.accumulator = app.accumulator - app.tickPeriod
    app.state:update()
  end
end

function love.draw()
  RenderManager:draw()
  RenderManager:drawUi()
  RenderManager:refresh()

  -- temporary print winner on screen until we have game states :)
  if app.state.currentState and app.state.currentState.winner then
    local winningText = app.state.currentState.match:getPlayer(app.state.currentState.match:getWinningPlayer()).name .. " won!"
    love.graphics.printf(winningText:upper(), 400 - winningText:len() * FONT_WIDTH_NORMAL / 2, 276, winningText:len() * FONT_WIDTH_NORMAL, "center")
  end

  if GameConfig.getBoolean("showfps") then
    love.graphics.push()
      love.graphics.setColor(1, 1, 1, 0.66)
      love.graphics.scale(0.5, 0.5)
      love.graphics.print(string.format('FPS:%s', love.timer.getFPS()), 48, 12)
    love.graphics.pop()
  end
end

function love.focus(focused)

end

function love.quit()

end

function love.keypressed(key, scancode, isrepeat)
  app.state:keypressed(key)
end

function love.keyreleased(key, scancode)
  app.state:keyreleased(key)
end
