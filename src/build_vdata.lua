
local fs = require "fs"
local max = math.max
local format = string.format
local match = string.match
local bitmap = require "bitmap"

local encoder = {[0]='A','B','C','D','E','F','G','H','I','J',
'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
'3','4','5','6','7','8','9','+','/','='}
local concat,insert,lshift,rshift,bor,band
= table.concat,table.insert,bit.lshift,bit.rshift,bit.bor,bit.band
local function encode(num)
    local t = {}
    for i=0,4 do
        insert(t,encoder[rshift(band(num,lshift(63,6*i)),6*i)])
    end
    return concat(t)
end

-- N 번째 파일 명을 가지고옴
local function getFilename(idx)
    idx = tostring(idx)
    if #idx == 1 then
        idx = "0"..idx
    end
    return ("ffmpegout/%s.bmp"):format(idx)
end

-- 마지막 파일의 번째를 가지고옴
local endIdx = 0
for name in fs.scandirSync("ffmpegout") do
    local idx = tonumber(match(name,"(%d+)%.bmp"))
    if idx then
        endIdx = max(endIdx, idx)
    end
end

-- local insert table.insert
-- local concat = table.concat

local lastData = {}
local floor = math.floor
local readFileSync = fs.readFileSync
local appendFileSync = fs.appendFileSync
fs.writeFileSync("out/vdata.lua","local d={\n")
for idx = 1,endIdx do
    local filename = getFilename(idx)
    local file = readFileSync(filename)

    if not file then
        process.stderr.handle:write(format("File read fail! (%s)",filename))
        return process.exit(1)
    end

    local this = bitmap.from_string(file)
    if not this then
        process.stderr.handle:write(format("Bitmap decode fail! (%s)",filename))
        return process.exit(1)
    end

    local buffer = {"'"}
    local pixeldField = 0
    local pixeldCount = 0
    for x = 0,this.width-1 do
        for y = 0,this.height-1 do
            -- 총 4 가지 색깔이 나오도록함
            local r,g,b = this:get_pixel(x,y)
            local color = floor((r+g+b)/255)
            local pos = bor(x,lshift(y,7))
            local pixeld = bor(pos,lshift(color,14))
            -- Base64
            --       111111      111111      11(mod dec 2bit)
            -- 111111      111111      111111
            -- Binary
            -- 11111111111111111111111111111111
            -- PIXELD
            -- 1111111111111111                
            --                 1111111111111111
            
            -- PIXEL DATA (INT64)
            --        VPosY V
            -- 1111111111111111 V
            -- ^PosX ^       ^^ V CUTOFF
            --            Color V (ADD NEXT) - REPEAT 3 TIMES => 54 bit used
            -- to HEX => 0xFFFF...
            -- And append into buffer

            if lastData[pos] ~= color then
                lastData[pos] = color
                pixeldField = bor(pixeldField,lshift(pixeld,pixeldCount*16))
                pixeldCount = pixeldCount + 1
            end

            if pixeldCount == 2 then
                insert(buffer,encode(rshift(pixeldField,2)))
                insert(buffer,tostring(band(pixeldField,3)))
                -- insert(buffer,format("0x%x,",pixeldField))
                pixeldCount = 0
                pixeldField = 0
            end
        end
    end

    if pixeldCount ~= 0 then
        insert(buffer,encode(rshift(pixeldField,2)))
        insert(buffer,tostring(band(pixeldField,3)))
        -- insert(buffer,format("0x%x,",pixeldField))
    end

    -- local buflen = #buffer
    -- if buflen ~= 1 then
    --     buffer[buflen] = sub(buffer[buflen],1,-2)
    -- end
    insert(buffer,"',\n")

    appendFileSync("out/vdata.lua",concat(buffer))
    process.stdout.handle:write(("\27[2K\r\27[0m Frame %d/%d"):format(idx,endIdx))
end
appendFileSync("out/vdata.lua","}"..readFileSync"src/vdata_parser.lua")

process.stdout.handle:write(" [!OK]\n")

-- process.stdout.handle:write(" Checking . . .")
-- dofile("out/vdata.lua")
