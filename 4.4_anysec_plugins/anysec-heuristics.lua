---
--- Wireshark dissector for Nokia's ANYsec protocol over MPLS
--- https://documentation.nokia.com/sr/24-3/7750-sr/books/segment-routing-pce-user/anysec.html
--- 
-- Between the MPLS label and the SecTag, a ANYsec packet contains 2 Bytes
-- that match the MACsec frame Ethertype
-- We check for this "Ethertype" as an heuristic to identify ANYsec packets

-- TODO???: test decryption and test filters
---
--- Version: 2025-03-24
--- Author: xavixava (GH handle)
---

local anysec = Proto("ANYsec", "ANYsec");

-- Fields that will be shown by Wireshark
local fields = {
    anysec_header = ProtoField.uint16("anysec.header", "Ethertype", base.HEX),
}
anysec.fields = fields

-- Heuristic checker function
local function checker (buffer, pinfo, tree)
    local ETHERTYPE = 0x88E5
    
    -- 2 octets for the Ethertype + 8/16 octets for the SecTag
    if buffer:len() < 10 then return false end

    -- Extract the Ethertype
    local packet_header = buffer(0, 2):uint()
    
    -- Check if the Ethertype matches the MACsec one
    if packet_header == ETHERTYPE then
         anysec.dissector(buffer, pinfo, tree)
	 return true
    end
    return false
end

-- Heuristic dissector function
function anysec.dissector(buffer, pinfo, tree)

    -- Set protocol column in Wireshark
    pinfo.cols.protocol = anysec.name

    -- Create protocol tree
    local subtree = tree:add(anysec, buffer(), "ANYsec")

    -- Extract Ethertype and add it in the protocol tree
    local anysec_header = buffer(0, 2) 
    subtree:add(fields.anysec_header, anysec_header)

    -- Extract encapsulated 802.1AE header and payload
    local anysec_packet = buffer(2, buffer:len()-2)

    -- Check if 802.1AE dissector is callable in this wireshark version and call it
    local macsec_dissector = Dissector.get("macsec")
    if macsec_dissector then
        macsec_dissector:call(anysec_packet:tvb(), pinfo, tree)
    end
end


-- Register the heuristic dissector for MPLS
anysec:register_heuristic("mpls", checker)
