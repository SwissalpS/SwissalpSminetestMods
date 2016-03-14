
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

if nil == math.round then
	function math.round(fFloat, iDigits)
		-- taken from compassgps mod
		if 0 <= fFloat then
			return math.floor(fFloat * (10^iDigits) + 0.5) / (10^iDigits);
		else
			return math.ceil(fFloat * (10^digits) - 0.5) / (10^iDigits);
		end; -- if positive or negative number
	end; -- math.round
end; -- if function not set

if '(0.1,0.1,0.1)' ~= minecraft.pos_to_string({x = 0.1111, y = 0.1111, z = 0.111}, 1) then
	local outdatedPosToString = minecraft.pos_to_string;
	function minecraft.pos_to_string(tPos, iDigits)
		if nil == tPos then
			return '(nil)';
		end; -- if no pos given
		local fX = tPos.x or 0;
		local fY = tPos.y or 0;
		local fZ = tPos.z or 0;
		if nil == iDigits then
			return '(' .. fX .. ',' .. fY .. ',' .. fZ .. ')';
		end; -- if no didgits given
		return '('	.. string.format('%.' .. iDigits .. 'f', fX) .. ','
					.. string.format('%.' .. iDigits .. 'f', fY) .. ','
					.. string.format('%.' .. iDigits .. 'f', fZ) .. ')';
	end; -- minecraft.pos_to_string
end; -- if still old version of minecraft.pos_to_string

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
