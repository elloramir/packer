local packer = require "packer"

function love.load()
	local files = love.filesystem.getDirectoryItems("test_images/")

	for _, file in ipairs(files) do
		local fileName = "test_images/" .. file

		packer:add(love.graphics.newImage(fileName), fileName)
	end

	packer:genAtlas()
	packer:saveAtlas("atlas.png")
end

function love.draw()
	love.graphics.draw(packer.atlas, 0, 0)
end