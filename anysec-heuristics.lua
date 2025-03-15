local anysec = Proto("ANYsec", "ANYsec");
-- local anysec = Proto("MKA", "MACsec Key Agreement over UDP")

-- Protocol header definition the protocol
--  local fields = {
--      mka_header = ProtoField.uint16("mka.header", "Ethertype", base.HEX),
--  }
-- anysec.fields = fields

local function checker (buffer, pinfo, tree)
    local ETHERTYPE = 0x88E5
    if buffer:len() < 2 then return false end

    -- Extract the potential header
    local packet_header = buffer(0, 2):uint()
    
    -- Check if the header matches the known pattern
    if packet_header == ETHERTYPE then
         anysec.dissector(buffer, pinfo, tree)
	 return true
    end
    return false
end

-- Dissector function
function anysec.dissector(buffer, pinfo, tree)
    -- Ensure there is enough data
    if buffer:len() < 4 then return end  -- TODO: Change this value to ANYsec's min length

    -- Set protocol column in Wireshark
    pinfo.cols.protocol = anysec.name

    -- Create protocol tree
    local subtree = tree:add(anysec, buffer(), "ANYsec")

    -- Extract encapsulated 802.1X PDU
    local anysec_packet = buffer(2, buffer:len()-2)

    local dissector_list = Dissector.list()
    local macsec_dissector = Dissector.get("macsec")
    if macsec_dissector then
        macsec_dissector:call(anysec_packet:tvb(), pinfo, tree)
    end
end


-- Register the protocol on the UDP dissector table
anysec:register_heuristic("mpls", checker) -- TODO: Discover how to check for label range without for

print("Anysec Heuristic Dissector loaded")
