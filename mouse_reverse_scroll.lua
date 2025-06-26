
local log = hs.logger.new("mouse_reverse_scroll", "info")

-- Flip mouse wheel scroll: reverse scroll with trackpad
mouseScrollFlip = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
    local isMouseScroll = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous) == 0

    if isMouseScroll then
        -- Flip vertical scroll (Axis1), horizontal (Axis2) 保留原样
        local vertical = event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1)
        -- local horizontal = event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis2)

        event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1, -vertical)
        return true, {event}
    end

    return false
end):start()
