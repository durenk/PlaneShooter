LevelVO = {}

function LevelVO:new()
	local level = {}

	level.name = "?"
	level.description = "???"
	level.events = {} -- MovieVO or EnemyVO's
	level.totalTime = 0
	level.classType = "LevelVO"
	level.fileName = nil


	return level
end

return LevelVO