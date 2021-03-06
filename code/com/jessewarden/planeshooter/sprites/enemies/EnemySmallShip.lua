require "com.jessewarden.planeshooter.core.constants"
require "org.robotlegs.globals"
require "com.jessewarden.planeshooter.sprites.enemies.EnemyBulletSingle"
require "com.jessewarden.planeshooter.sounds.SoundManager"

EnemySmallShip = {}
EnemySmallShip.soundsInited = false

function EnemySmallShip:new(startX, startY, bottom)
	--print("EnemySmallShip::new, bottom: ", bottom)
	if(EnemySmallShip.soundsInited == false) then
		EnemySmallShip.soundsInited = true
		--EnemySmallShip.smallShipDeathSound = audio.loadSound("enemy_death_1.mp3")
	end
	
	local img = display.newImage("enemy_1.png")
	img.classType = "EnemySmallShip"
	img.name = "Enemy1"
	img.ID = globals.getID()
	img.speed = constants.SMALL_SHIP_SPEED
	img.x = startX
	--img.y = startY
	
	img.bottom = bottom
	img.fireTime = constants.SMALL_SHIP_FIRE_INTERVAL -- milliseconds
	img.fired = false

	function img:init()
		img.collision = onHit
		img:addEventListener("collision", img)
		img:setY(startY)
		gameLoop:addLoop(self)
		physics.addBody( img, { density = 1.0, friction = 0.3, bounce = 0.2, 
								bodyType = "kinematic", 
								isBullet = true, isSensor = true, isFixedRotation = true,
								filter = { categoryBits = 4, maskBits = 3 }
							} )
	end
	
	function img:setY(value)
		assert(value ~= nil, "Setting Y to nil, are we?")
		self.y = value
	end
	
	
	
	
	function onHit(self, event)
		-- TODO/FIXME: string names? Really? That's great man..........
		if(event.other.name == "Bullet") then
			-- TODO: create enemy death
			--createEnemyDeath(self.x, self.y)
			--print("ship is dead, ID: ", self.ID)
			event.other:destroy()
		elseif(event.other.name == "Player") then
			event.other:onBulletHit()
		end
		--local smallShipDeathSoundChannel = audio.play(EnemySmallShip.smallShipDeathSound)
		--audio.setVolume(.4, {channel = smallShipDeathSoundChannel})
		SoundManager.inst:playSmallPlaneDeathSound()
		Runtime:dispatchEvent({name="onShowFloatingText", 
								x=self.x, y=self.y, target=self, amount=100})
		self:destroy()
	end
	
	function img:destroy()
		gameLoop:removeLoop(self)
		self:removeEventListener("collision", img)
		self:dispatchEvent({name="onDestroy", target=self})
		self:removeSelf()
	end
	
	function img:tick(millisecondsPassed)
		if(self.y == nil) then
			return
		end
		
		if(self.fired == false) then
			self.fireTime = self.fireTime - millisecondsPassed
			if(self.fireTime <= 0) then
				self.fired = true
				SoundManager.inst:playSmallPlaneShootSound()
				local bullet = EnemyBulletSingle:new(self.x, self.y, playerView)
				self.parent:insert(bullet)
			end
		end
		
		if(self.y > bottom) then
			return
		else
			local deltaX = 0
			local deltaY = self.y - bottom
			local dist = math.sqrt((deltaX * deltaX) + (deltaY * deltaY))

			local moveX = self.speed * (deltaX / dist) * millisecondsPassed
			local moveY = self.speed * (deltaY / dist) * millisecondsPassed

			if (math.abs(moveX) > dist or math.abs(moveY) > dist) then
				--self.y = bottom
				self:setY(bottom)
				self:destroy()
			else
				--self.y = self.y - moveY
				self:setY(self.y - moveY)
			end
		end
			
	end

	img:init()
	


	return img	
end

return EnemySmallShip