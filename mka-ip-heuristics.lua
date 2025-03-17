-- MKA over UDP using an heuristics dissector
--

local mkaudp = Proto("MKAoUDP", "MACsec Key Agreement over UDP");
-- local mkaudp = Proto("MKA", "MACsec Key Agreement over UDP")

-- Protocol header definition the protocol
local fields = {
    mka_header = ProtoField.uint16("mka.header", "Ethertype", base.HEX),
}
mkaudp.fields = fields

-- Define known header

local function checker (buffer, pinfo, tree)
    local ETHERTYPE = 0x888E
    if buffer:len() < 2 then return false end

    -- TODO: Add check for mka in within eapol heade

    -- Extract the potential header
    local packet_header = buffer(0, 2):uint()
    
    -- Check if the header matches the known pattern
    if packet_header == ETHERTYPE then
         mkaudp.dissector(buffer, pinfo, tree)
	 return true
    end
    return false
end

-- Heuristic dissector function
function mkaudp.dissector(buffer, pinfo, tree)
    -- Ensure there is enough data
    if buffer:len() < 4 then return end  

    -- Set protocol column in Wireshark
    pinfo.cols.protocol = mkaudp.name

    -- Create protocol tree
    local subtree = tree:add(mkaudp, buffer(), "MKA over UDP")

    -- Extract MKA header (assuming 2-byte header for example)
    local mka_header = buffer(0, 2) -- Do I need to process the MKA header before IEEE 802.1X header?
    subtree:add(fields.mka_header, mka_header)

    -- Extract encapsulated 802.1X PDU
    local eapol_pdu = buffer(2, buffer:len()-2)

    local eapol_dissector = Dissector.get("eapol")
    if eapol_dissector then
        eapol_dissector:call(eapol_pdu:tvb(), pinfo, tree)
    end
end

-- Register the heuristic dissector for UDP
-- udp_table = DissectorTable.get("udp")
-- udp_table:add_heuristic("mkaudp", mkaudp.dissector)
mkaudp:register_heuristic("udp", checker)

print("mkaudp heuristic dissector loaded for all UDP packets")
