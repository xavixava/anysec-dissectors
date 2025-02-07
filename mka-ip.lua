-- MKA over UDP protocol dissector
-- https://www.ietf.org/archive/id/draft-hb-intarea-eap-mka-00.html
--

-- Define the protocol
local mkaudp = Proto("MKAoUDP", "MACsec Key Agreement over UDP");
-- local mkaudp = Proto("MKA", "MACsec Key Agreement over UDP")

-- Define protocol fields
local fields = {
    -- mka_header = ProtoField.uint16("mka.header", "MKA Header", base.HEX),
    eapol_pdu = ProtoField.bytes("mka.eapol_pdu", "Encapsulated EAPOL PDU")
}

-- Assign fields to the protocol
mkaudp.fields = fields

-- Dissector function
function mkaudp.dissector(buffer, pinfo, tree)
    -- Ensure there is enough data
    if buffer:len() < 4 then return end  

    -- Set protocol column in Wireshark
    pinfo.cols.protocol = mkaudp.name

    -- Create protocol tree
    local subtree = tree:add(mkaudp, buffer(), "MKA over UDP")

    local eapol_pdu = buffer(0, buffer:len())
    subtree:add(fields.eapol_pdu, eapol_pdu)

    local eapol_dissector = Dissector.get("eapol")
    if eapol_dissector then
        eapol_dissector:call(eapol_pdu:tvb(), pinfo, tree)
    end
end

-- Define the target UDP port (update according to your network)
local MKA_PORT = 10000

-- Register the protocol on the UDP dissector table
udp_table = DissectorTable.get("udp.port")
udp_table:add(MKA_PORT, mkaudp)

print("MKA dissector loaded for UDP port " .. MKA_PORT)
