
SwissalpS = SwissalpS or {};
SwissalpS.utils = {
	version = 0.1,
	sSwissalpSmodTag = 'mod_utils',
	sSwissalpSmodTitle = 'utils',
};
local bHaveSssSinfo = (nil ~= SwissalpS.info);
SwissalpS.info.timerStart(SwissalpS.utils);

if nil == boolToString then
    function boolToString(b)
        b = not (not b);
        local sOut = 'false';
        if b then sOut = 'true'; end
        return sOut;
    end -- boolToString
end -- if field not set

SwissalpS.info.timerDiffLog(SwissalpS.utils);
