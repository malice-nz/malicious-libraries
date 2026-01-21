local ContentProvider = game:GetService("ContentProvider")

local Lucide	= {}
local Root		= "LucideIconsCache"
local Source	= "https://lucide.malice.nz/%s"

if(not isfolder(Root)) then
	makefolder(Root)
end;

setmetatable(Lucide, {
	__call = function(_, Icon)
		local Path = string.format("%s/%s.png", Root, Icon)

		if not isfile(Path) then
			local Success, Data = pcall(game.HttpGet, game, Source:format(Icon));
			assert(Success, `Icon "{Icon}" not found`);
			writefile(Path, Data);
		end;
        local asset = getcustomasset(Path);
        ContentProvider:PreloadAsync({ asset })
		return asset
	end;
});

return Lucide
