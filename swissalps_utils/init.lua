
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

if nil == table.containsString then
	function table.containsString(tHayStack, sNeedle)
		assert('table' == type(tHayStack), 'argument 1 must be of type table');
		assert('string' == type(sNeedle), 'argument 2 must be of type string');
		for mIndex, mValue in pairs(tHayStack) do
			if 'string' == type(mValue) then
				if mValue == sNeedle then
					return mIndex;
				end; -- if match found
			end; -- if value is string
		end -- loop all values
		return false;
	end; -- table.containsString
end; -- if field not set

if nil == table.implodeStrings then
	function table.implodeStrings(tTable, sDelimiter)
		assert('table' == type(tTable), '');
		assert('string' == type(sDelimiter), '');
		local sOut = '';
		for _, mValue in pairs(tTable) do
			if 'string' == type(mValue) then
				sOut = sOut .. mValue .. sDelimiter;
			end; -- if value is string
		end; -- loop all values
		-- drop the last delimiter
		local iLength = string.len(sDelimiter);
		if 0 < iLength and iLength < string.len(sOut) then
			local iLast = -1 * (iLength +1);
			sOut = string.sub(sOut, 1, iLast);
		end; -- if delimiter has length and is shorter than sOut
	end; -- table.implodeStrings
end; -- if field not set

SwissalpS.info.timerDiffLog(SwissalpS.utils);
