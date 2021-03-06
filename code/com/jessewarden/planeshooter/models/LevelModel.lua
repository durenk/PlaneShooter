LevelModel = {}

function LevelModel:new()

	local model = {}
	model.classType = "LevelModel"
	model.level = nil
	model.oldEvents = nil
	model.totalMilliseconds = nil
	model.paused = true
	model.started = false

	function model:init(level)
		print("LevelModel::init, level: ", level)
		assert(level ~= nil, "You cannot pass a nil level to LevelModel.")
		self:stop()
		self.level = level

		--[[
		local oldEvents = self.oldEvents
		local events = self.level.events
		if oldEvents ~= nil then
			local i = #oldEvents
			while oldEvents[i] do
				local event = oldEvents[i]
				table.remove(oldEvents, i)
				table.insert(events, event)
				i = i - 1
			end
		end
		]]--

		self.oldEvents = {}
		self.totalMilliseconds = 0
		self.started = false
	end

	function model:setLevelTime(milliseconds)
		self.totalMilliseconds = milliseconds
	end

	function model:getMemento()
		local json = require "json"
		return {
			classType = self.classType,
			totalMilliseconds = self.totalMilliseconds,
			paused = self.paused,
			started = self.started,
			level = self.level,
			oldEvents = self.oldEvents
		}
	end

	function model:setMemento(memento)
		self.level = mememto.level
		self.oldEvents = mememto.oldEvents
		self.totalMilliseconds = mememto.totalMilliseconds
		self.paused = mememto.paused
		self.started = mememto.started
	end

	function model:start()
		print("LevelModel::start")
		if self.paused == true then
			self.paused = false
			gameLoop:addLoop(self)
		end
	end

	function model:stop()
		print("LevelModel::stop")
		if self.paused == false then
			self.paused = true
			gameLoop:removeLoop(self)
		end
	end

	function model:tick(milliseconds)
		self.totalMilliseconds = self.totalMilliseconds + milliseconds
		local progress = self.totalMilliseconds / (self.level.totalTime * 1000)
		local level = self.level
		local events = level.events
		local totalMilliseconds = self.totalMilliseconds
		local seconds = totalMilliseconds / 1000
		local oldEvents = self.oldEvents
		if self.started == false then
			self.started = true
			Runtime:dispatchEvent({name="LevelModel_levelStart", target=self})
		end
		
		local i = 1
		--print(">>>>>>>>>>")
		while events[i] do
			local event = events[i]
			--print("when: ", event.when, ", seconds: ", seconds, ", type: ", event.classType)
			if event.when <= seconds then
				table.remove(events, i)
				table.insert(oldEvents, event)
				if event.pause == true then
					self:stop()
				end
				
				-- TODO: use proper classType's in level editor
				if event.classType == "EnemyVO" or event.classType == "enemy" then
					--print("LevelModel_onEnemyEvent")
					if event.pause == true then
						event.unpauseCallback = function()
							--print("unpauseCallback")
							self:start()
						end
					end
					Runtime:dispatchEvent({name="LevelModel_onEnemyEvent", target=self, event=event})
				elseif event.classType == "MovieVO" or event.classType == "movie" then
					--print("LevelModel_onMovieEvent")
					Runtime:dispatchEvent({name="LevelModel_onMovieEvent", target=self, event=event})
					return true
				end
			end
			i = i + 1
		end

		-- TODO: the last one that has a pause is still considered the end of a level...
		
		local index = #events
		if seconds >= level.totalTime and index == 0 and self.paused == false then
			print("LevelModel_levelComplete")
			self:stop()
			Runtime:dispatchEvent({name="LevelModel_levelComplete", target=self})
			return true
		end
	end


	return model

end

return LevelModel