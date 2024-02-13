function love.load()
    wf = require 'libs/windfield'
    world = wf.newWorld(0,0)
    camera = require 'libs/camera'
    cam = camera()
    anim8 = require 'libs/anim8'
    love.graphics.setDefaultFilter('nearest', 'nearest')
    sti = require 'libs/sti'
    gameMap = sti('maps/testMap.lua')

    player = {}
    player.collider = world:newBSGRectangleCollider(1240,340,40,60,8)
    player.collider:setFixedRotation(true)
    player.x = 92
    player.y = 94
    player.speed = 240
    player.sprite = love.graphics.newImage('sprites/player.png')
    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid(12,18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    
    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2) , 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    player.anim = player.animations.down

    walls = {}
    if gameMap.layers["Walls"] then
	for i, obj in pairs(gameMap.layers["Walls"].objects) do
	    local wall = world:newRectangleCollider(obj.x,obj.y,obj.width,obj.height)           
	    wall:setType('static')
	    table.insert(wall,walls)
	end
    end
    
    sounds = {}
    sounds.blip = love.audio.newSource("sounds/blip.wav","static")
    sounds.music = love.audio.newSource("sounds/music.mp3","stream")
    sounds.music:setLooping(true)
--    sounds.music:play()

end

function love.update(dt)
    local isMoving = false
    local vx = 0
    local vy = 0

    if love.keyboard.isDown("right") then
    	vx = player.speed
    	player.anim = player.animations.right
    	isMoving = true
    end 
    if love.keyboard.isDown("left") then
    	vx = player.speed * -1
    	player.anim = player.animations.left
    	isMoving = true
    end 
    if love.keyboard.isDown("up") then
    	vy = player.speed * -1
    	player.anim = player.animations.up
    	isMoving = true
    end 
    if love.keyboard.isDown("down") then
    	vy = player.speed 
    	player.anim = player.animations.down
    	isMoving = true
    end 

    function love.keypressed(k)
    	if k == 'q' or k == 'escape' then
	    love.event.quit()
	end

	if k == 'z' then
	    sounds.blip:play()
	end
    end
    

    player.collider:setLinearVelocity(vx,vy)

    if isMoving == false then 
    	player.anim:gotoFrame(2)
    end
 
    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()
    player.anim:update(dt)

    cam:lookAt(player.x,player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    
    if cam.x < w/2 then
	cam.x = w/2
    end

    if cam.y < h/2 then
	cam.y = h/2
    end
    

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight
    
    if cam.x > (mapW-w/2) then
	cam.x = (mapW-w/2)
    end

     if cam.y > (mapH-w/2) then
	cam.y = (mapH-w/2)
    end

end
function love.draw()
    love.graphics.scale(1,1)  
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Ground"])
        gameMap:drawLayer(gameMap.layers["Trees"])
	player.anim:draw(player.spriteSheet,player.x,player.y,nil,4,nil,6,9)
        gameMap:drawLayer(gameMap.layers["Trees2"])
	-- world:draw()
    cam:detach()
end

