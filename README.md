
# BadApple With Roblox. . . and lua things

[제목 없음.webm](https://user-images.githubusercontent.com/46598063/202782654-1e234f85-bcd5-422c-b1bf-cdb6ca0e2185.webm)

## Why?? WHY

Just for fun. nothing else...  

## Used sources

**Lua bitmap handler**: https://github.com/max1220/lua-bitmap/blob/master/lua/lua-bitmap/init.lua  
 + Under MIT License  

**ffmpeg**: https://ffmpeg.org/
 * Under LGPL License

# Prebuilt Place File

Check [releases](https://github.com/qwreey75/badappleInRblx/releases)

# Run

Execute this on command line!
```lua
require(game.ReplicatedFirst.BadApple)(Instance.new("ScreenGui",game.StarterGui))
```

# Building

## Requirements

 + This project needs [luvit](https://github.com/luvit/luvit) You can compile It your self or use [prebuilt](https://github.com/truemedian/luvit-bin)
 + GNU-Make or CMD
 + [FFmpeg](https://ffmpeg.org/)

# How it works

```lua
-- PIXEL DATA (INT64)
--        VPosY V
-- 1111111111111111 V
-- ^PosX ^       ^^ V CUTOFF
--            Color V (NEXT DATA) - REPEAT 2 TIMES => 32 bit used
```

Using bitfield, Convert two pixel change information into one int32 number  
With using bit32 lib, ~~just compress every data! (130MB=>10MB)~~  
And using base64 to avoid overhead of hex
