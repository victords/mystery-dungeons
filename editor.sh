cp main.lua main1.lua
sed -i -e 's|require("src.game")|require("src.editor")|' main.lua
sed -i -e 's|controller = Game|controller = Editor|' main.lua
love .
rm main.lua
mv main1.lua main.lua
mv ~/.local/share/love/mystery-dungeons/editor/*.txt ./data/scene/
