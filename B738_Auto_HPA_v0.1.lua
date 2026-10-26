-- B738 Auto HPA - TEST v0.1 (X-Plane 11 / FlyWithLua NG)
-- Sets the CAPTAIN EFIS BARO DISPLAY UNIT to HPA once per aircraft/script load.
-- Does NOT alter QNH/altimeter pressure. Does NOT keep overriding manual choices.
-- Standalone test, not yet flight-tested; do not publish as verified yet.

local REF  = "laminar/B738/EFIS_control/capt/baro_in_hpa"
local CMD  = "laminar/B738/EFIS_control/capt/baro_in_hpa_up"
local completed = false
local checks = 0

function b738_auto_hpa_once()
    if completed then return end

    -- FlyWithLua reloads scripts after an aircraft change.
    if PLANE_ICAO ~= "B738" then
        completed = true
        return
    end

    checks = checks + 1
    if checks > 30 then
        completed = true  -- Avoid retrying indefinitely if a different B738 lacks this interface.
        return
    end

    local ok, current = pcall(get, REF)
    if not ok or type(current) ~= "number" then return end

    if current == 1 then
        completed = true
    elseif current == 0 then
        -- At startup the aircraft may initialize EFIS after FlyWithLua loaded.
        -- Retry until the unit is confirmed HPA, without changing the QNH value.
        pcall(command_once, CMD)
    end
end

do_often("b738_auto_hpa_once()")
