## explanation and methods
- packer have a method called sort that can be overrided, but i recommend to keep as default (max side)
- after genAtlas exec, packer.atlas will be a canvas
- save methods use lua io.open as default, if are necessary to change it, you can replace these functions

| function | param | return | 
|--|--|--|
| add | image: **Image**, tag: **string** (optional) | 
| genAtlas |  |  |
| getRect | tag: **string** | x: **int**, y: **int**, w: **int**, h: **int** |
| getQuad | tag: **string** | quad: **Quad** |
| serialize |  | serial: **string** |
| saveAtlas | path: **string** | error: **error** |
| saveSerial | path: **string** | error: **error** |

### code example
```lua
local packer = require "packer"

function love.load()
	local files = love.filesystem.getDirectoryItems("test_images/")

	for _, file in ipairs(files) do
		local fileName = "test_images/" .. file

		packer:add(love.graphics.newImage(fileName))
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
