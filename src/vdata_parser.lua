
local encoder = {[0]='A','B','C','D','E','F','G','H','I','J',
'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
'3','4','5','6','7','8','9','+','/','='}
local bit = bit or bit32
local insert,lshift,bor
= table.insert,bit.lshift,bit.bor
local decoder = {["A"]=0};
for i,v in ipairs(encoder) do decoder[v]=i end
local gmatch = string.gmatch
local function decode(str)
    local num,i = 0,0
    for char in gmatch(str,".") do
        num = bor(num,lshift(decoder[char],6*i))
        i = i + 1
    end
    return num
end
for i,line in ipairs(d) do
    local t = {}
    for encoded,modbit in gmatch(line,"(.....)(%d)") do
        insert(t,bor(lshift(decode(encoded),2),tonumber(modbit)))
    end
    d[i] = t
end
return d