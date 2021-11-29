## explanation and methods
- packer have a method called sort that can be overrided, but i recomend to keep it default (max side)
- after genAtlas exec, packer.atlas will be type: canvas

| function | param | return | 
|--|--|--|
| add | tag: **string**, image: **Image** | 
| genAtlas |  |  |
| getRect | tag: **string** | x: **int**, y: **int**, w: **int**, h: **int** |
| getQuad | tag: **string** | quad: **Quad** |
| saveAtlas | path: **string** | error: **error** |

### code example
```lua
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
```

### credits
- [test images](https://pipoya.itch.io/pipoya-free-rpg-character-sprites-nekonin)
- [article about binary packing](https://codeincomplete.com/articles/bin-packing/)
- [cripboy](https://github.com/cripboy)
