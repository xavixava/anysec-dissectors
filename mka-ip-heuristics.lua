---
--- Wireshark dissector for MKA over UDP
--- https://www.ietf.org/archive/id/draft-hb-intarea-eap-mka-00.html
--- 
--- MKPDU encapsulated in UDP packets are used for signaling for Nokia's ANYsec protocol
---
--- Currently there is not a port reserved for MKA over UDP by IANA,
--- as such this version of the dissector uses an heuristic to be able
--- to identify MKPDUs without the need for user configuration
---

local mkaudp = Proto("MKAoUDP", "MACsec Key Agreement over UDP");

-- Fields that will be shown by Wireshark
local fields = {
    mka_header = ProtoField.uint16("mka.header", "Ethertype", base.HEX),
}
mkaudp.fields = fields

-- Heuristic checker function
local function checker (buffer, pinfo, tree)
    local ETHERTYPE = 0x888E
    local EAPOL_TYPE = 0x05

    -- 2 octets for the Ethertype + 5 octets for the 802.1X header
    if buffer:len() < 7 then return false end

    -- Extract the Ethertype
    local packet_header = buffer(0, 2):uint()
    
    -- Extract the EAPOL frame type from the potential packet
    local eapol_type = buffer(3, 1):uint()

    -- Check if the EtherType and EAPOL type matches the MKA ones
    if packet_header == ETHERTYPE and eapol_type == EAPOL_TYPE then
         mkaudp.dissector(buffer, pinfo, tree)
	 return true
    end
    return false
end

-- Heuristic dissector function
function mkaudp.dissector(buffer, pinfo, tree)

    -- Set protocol column in Wireshark
    pinfo.cols.protocol = mkaudp.name

    -- Create protocol tree
    local subtree = tree:add(mkaudp, buffer(), "MKA over UDP")

    -- Extract Ethertype and add it in the protocol tree
    local mka_header = buffer(0, 2)
    subtree:add(fields.mka_header, mka_header)

    -- Extract encapsulated 802.1X PDU
    local eapol_pdu = buffer(2, buffer:len()-2)

    -- Check if 802.1X dissector is callable in this wireshark version and call it
    local eapol_dissector = Dissector.get("eapol")
    if eapol_dissector then
        eapol_dissector:call(eapol_pdu:tvb(), pinfo, tree)
    end
end

-- Register the heuristic dissector for UDP
mkaudp:register_heuristic("udp", checker)
