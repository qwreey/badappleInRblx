local function run(gui)
    local runService = game:GetService("RunService")

    local vdata = require(script.vdata)

    local band = bit32.band
    local rshift = bit32.rshift
    local fps = 22
    local delayTick = 1/fps

    local PIXELD_BAND = 65535
    local function get_PIXELD_LEFT(PIXELD_FEILD)
        return rshift(PIXELD_FEILD,16)
    end
    local function get_PIXELD_RIGHT(PIXELD_FEILD)
        return band(PIXELD_FEILD,PIXELD_BAND)
    end

    local PIXELD_POS_BAND = 16383
    local PIXELD_POS_XY_BAND = 127
    local PIXELD_COLOR = 3
    local function get_PIXELD_DATA(PIXELD)
        -- pos,x,y,color
        return
            band(PIXELD,PIXELD_POS_BAND),
            band(PIXELD,PIXELD_POS_XY_BAND),
            band(rshift(PIXELD,7),PIXELD_POS_XY_BAND),
            band(rshift(PIXELD,14),PIXELD_COLOR)
    end

    local colors = {
        [0] = Color3.fromRGB(0,0,0),
        Color3.fromRGB(85,85,85),
        Color3.fromRGB(170,170,170),
        Color3.fromRGB(255,255,255),
    }
    local instances = {}
    local items = {}
    local function renderFIXELD(FIXELD)
        if FIXELD == 0 then return end
        local pos,x,y,color = get_PIXELD_DATA(FIXELD)
        if items[pos] ~= color then
            items[pos] = color
            local this = instances[pos]
            if not this then
                this = Instance.new("Frame")
                this.Position = UDim2.fromOffset(8*x,8*y)
                this.BorderSizePixel = 0
                this.Parent = gui
                this.Size = UDim2.fromOffset(8,8)
                instances[pos] = this
            end
            this.BackgroundColor3 = colors[color]
        end
    end

    local renderIDX = 1
    local function renderFrame()

        local renderData = vdata[renderIDX]
        if not renderData then return end

        for _,PIXELD_FEILD in ipairs(renderData) do
            renderFIXELD(get_PIXELD_LEFT(PIXELD_FEILD))
            renderFIXELD(get_PIXELD_RIGHT(PIXELD_FEILD))
        end

        renderIDX = renderIDX + 1
    end

    local last = tick()
    local evnet
    evnet = runService.Heartbeat:Connect(function ()
        local now = tick()
        if now > last then
            if not gui.Parent then evnet:Disconnect(); return end
            renderFrame()
            last = last + delayTick
        end
    end)
end
return run
