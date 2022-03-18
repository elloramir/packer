-- created by: github.com/cripboy
-- references: https://codeincomplete.com/articles/bin-packing/
local packer = {}
packer.blocks = {}
packer.dictionary = {}

function packer.sort(a, b)
	return math.min(a.w, a.h) > math.min(b.w, b.h)
end

function packer:add(image, tag)
	assert(image:type() == "Image", "Packer only acepts images")
	table.insert(self.blocks, {
		image = image,
		x = 0,
		y = 0,
		w = image:getWidth(),
		h = image:getHeight()
	})

	-- a tag is necessary to recovery this image
	-- position after joined into the atlas
	if tag then
		self.dictionary[tag] = self.blocks[#self.blocks]
	end
end

local function newNode(x, y, w, h)
	return {x = x, y = y, w = w, h = h, used = false, right = nil, down = nil}
end

local function findNode(node, w, h)
	-- node filled
	if node.used then
		return findNode(node.right, w, h) or findNode(node.down, w, h)
	
	-- you can place it here
	elseif (w <= node.w) and (h <= node.h) then
		return node

	-- no space to this shape
	else
		return nil
	end
end

-- fill this node and generated two more
-- OBS: down and right can be w = 0 and h = 0
local function splitNode(node, w, h)
	node.used = true
	node.right = newNode(node.x + w, node.y, node.w - w, h)
	node.down =  newNode(node.x, node.y + h, node.w, node.h - h)
end

-- wrap the old node in a new one
local function growRight(node, w, h)
	local growedNode = newNode(node.x, node.y, node.w + w, node.h)
	growedNode.used = true
	growedNode.down = node
	growedNode.right = newNode(node.w, node.y, w, node.h)

	return growedNode
end

-- wrap the old node in a new one
local function growDown(node, w, h)
	local growedNode = newNode(node.x, node.y, node.w, node.h + h)
	growedNode.used = true
	growedNode.down = newNode(node.x, node.h, node.w, h)
	growedNode.right = node

	return growedNode
end

-- choose wich direction are better to growup
local function growNode(node, w, h)
	local canGrowRight = h <= node.h
	local canGrowDown = w <= node.w
	local shouldGrowRight = canGrowRight and node.h >= node.w + w
	local shouldGrowDown = canGrowDown and node.w >= node.h + h

	if shouldGrowRight then
		return growRight(node, w, h)
	elseif shouldGrowDown then
		return growDown(node, w, h)
	elseif canGrowRight then
		return growRight(node, w, h)
	elseif canGrowDown then
		return growDown(node, w, h)
	end
end

function packer:genAtlas()
	assert(#self.blocks > 0, "You can't generate an atlas without images")

	-- sorting (standard sort)
	table.sort(self.blocks, self.sort)

	-- initial size
	local initialNode = newNode(0, 0, self.blocks[1].w, self.blocks[1].h)

	-- put blocks into the initialNode and future nodes
	for _, block in ipairs(self.blocks) do
		-- try to find nearest not used node
		local node = findNode(initialNode, block.w, block.h)

		-- need to growup
		if not node then
			initialNode = growNode(initialNode, block.w, block.h)
			node = findNode(initialNode, block.w, block.h)
		end

		splitNode(node, block.w, block.h)
		block.x = node.x
		block.y = node.y
	end

	-- make the atlas
	self.atlas = love.graphics.newCanvas(initialNode.w, initialNode.h)
	love.graphics.setCanvas(self.atlas)
	love.graphics.setColor(1, 1, 1)

	for _, block in ipairs(self.blocks) do
		love.graphics.draw(block.image, block.x, block.y)
	end

	love.graphics.setCanvas()
end

function packer:getBlock(tag)
	assert(self.dictionary[tag], "Invalid tag " .. tag)
	return self.dictionary[tag]
end

function packer:getRect(tag)
	local block = self:getBlock(tag)
	return block.x, block.y, block.w, block.h
end

-- we don't need generate all quads at same time
function packer:getQuad(tag)
	local block = self:getBlock(tag)

	if not block.quad then
		block.quad = love.graphics.newQuad(
			block.x,
			block.y,
			block.w,
			block.h,
			self.atlas)
	end

	return block.quad
end

-- dirty serialization, but works ~fast~ fine ¯\_(ツ)_/¯
function packer:serialize()
	assert(self.atlas, "Generate an atlas before the serial")
	local content = "return {\n"

	for key, block in pairs(self.dictionary) do
		content = content .. '  ["' .. key .. '"]' .. " = {"
		content = content .. "x = " .. block.x .. ","
		content = content .. " y = " .. block.y .. ","
		content = content .. " w = " .. block.w .. ","
		content = content .. " h = " .. block.h .. "},\n"
	end

	return content .. "}"
end

function packer:saveAtlas(dir)
	local imageFile, err = io.open(dir, "wb")

	if imageFile then
		local imgData = self.atlas:newImageData()
		local fileData = imgData:encode("png")

		imageFile:write(fileData:getString())
		imageFile:close()
	end

	return err
end

function packer:saveSerial(dir)
	local serialFile, err = io.open(dir, "w")

	if serialFile then
		serialFile:write(self:serialize())
		serialFile:close()
	end

	return err
end

return packer
