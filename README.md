# Malicious Libraries
> Simple utility libraries for my scripts and for *yours*

```lua
local malice = function(Module)
  return loadstring(game:HttpGet(`https://git.malice.nz/{Module}.lua`))':3'
end;

local Easing = malice'Easing';
print(Easing.Linear(1))

local Lucide = malice'Lucide';
local GitHub = Lucide'github';
```

*git.malice.nz is a redirect rule that redirects to this repo (easier)*
