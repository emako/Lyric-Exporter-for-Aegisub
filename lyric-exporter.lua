local tr = aegisub.gettext
script_name = tr"Export Lyric File"
script_description = tr"Export Lyric File For Aegisub"
script_author = "ema"
script_version = "1"

local function strip_tags(text)
	text = text:gsub('{[^}]+}', '')
	text = text:gsub('\\N', '')
	text = text:gsub('\\n', '')
	text = text:gsub('\\h', ' ')
	return text
end

local function lrc_header()
	return table.concat( {
		string.char(239, 187, 191), -- UTF8-BOM: EF BB BF
		'[ti:None]\n',
		'[ar:None]\n',
		'[al:None]\n',
		'[by:aegisub]\n',
	} )
end

local function to_timecode(time_ms)
	time_sec = time_ms / 1000
	h = math.floor(time_sec / 3600)
	m = math.floor(time_sec % 3600 / 60)
	s = math.floor(time_sec % 60)
	ms = math.floor( ((time_sec % 60) - math.floor(time_sec % 60)) * 100 )
	if h >= 1 then
		m = 59
		s = 59
		ms = 99
	end
	return string.format('%02d:%02d.%02d', m, s, ms)
end

local function to_lrc_line(start_time, text)
	return string.format('[%s]%s\n', to_timecode(start_time), text)
end

local function endswith(str, substr)
	if str == nil or substr == nil then
		return false
	end
	str_tmp = string.reverse(str)
	substr_tmp = string.reverse(substr)
	if string.find(str_tmp, substr_tmp) ~= 1 then
		return false
	else
		return true
	end
end

function ass_to_lyric(subs, sel)
	local filename = aegisub.dialog.save('Save Lyric File', '', '', 'Lyrics File(*lrc)|*lrc')
	
	if not filename then
		aegisub.cancel()
	end
	
	if endswith(string.lower(filename), '.lrc') == false then
		filename = filename .. '.lrc'
	end

	local output_file = io.open(filename, 'w+')
	if not output_file then
		aegisub.debug.out('Failed to open file')
		aegisub.cancel()
	end

	output_file:write(lrc_header())

	for i = 1, #subs, 1 do
		local line = subs[i]
		if line.class == 'dialogue' then
			output_file:write(to_lrc_line(line.start_time, strip_tags(line.text)))
		end
	end

	output_file:close()
end

aegisub.register_macro(script_name, script_description, ass_to_lyric)
