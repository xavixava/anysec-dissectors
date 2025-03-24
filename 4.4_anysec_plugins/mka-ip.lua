--- NOTE: NOT IN USE! RESERVERD FOR FUTURE USE IF: a port is reserved for MKA over UDP by IANA
---
--- Wireshark dissector for MKA over UDP
--- https://www.ietf.org/archive/id/draft-hb-intarea-eap-mka-00.html
--- https://documentation.nokia.com/sr/24-3/7750-sr/books/segment-routing-pce-user/anysec.html
--- 
--- MKPDU encapsulated in UDP packets are used for signaling for Nokia's ANYsec protocol
---
--- Currently there is not a port reserved for MKA over UDP by IANA,
--- but as per Nokia's ANYsec documentation, the network administrator should 
--- reserve a port on the network for MKA over UDP, as such it is possible to register
--- a dissector for that port
---
--- Version: 2025-03-24
--- Author: xavixava (GH handle)
---

local mkaudp = Proto("MKAoUDP", "MACsec Key Agreement over UDP");

-- Fields that will be shown by Wireshark
local fields = {
    mka_header = ProtoField.uint16("mka.header", "Ethertype", base.HEX),
}
mkaudp.fields = fields

-- Dissector function
function mkaudp.dissector(buffer, pinfo, tree)
    -- 2 octets for the Ethertype + 5 octets for the 802.1X header
    if buffer:len() < 7 then return end  

    -- Set protocol column in Wireshark
    pinfo.cols.protocol = mkaudp.name

    -- Create protocol tree
    local subtree = tree:add(mkaudp, buffer(), "MKA over UDP")

    -- Extract Ethertype and add it in the protocol tree
    local mka_header = buffer(0, 2):uint()
    subtree:add(fields.mka_header, buffer(0, 2))

    -- Extract encapsulated 802.1X PDU
    local eapol_pdu = buffer(2, buffer:len()-2)

    -- Check if 802.1X dissector is callable in this wireshark version and call it
    local eapol_dissector = Dissector.get("eapol")
    if eapol_dissector then
        eapol_dissector:call(eapol_pdu:tvb(), pinfo, tree)
    end
end

-- Define the target UDP port HERE (update according to your network)
local MKA_PORT = 10000

-- Register the protocol on the UDP dissector table
udp_table = DissectorTable.get("udp.port")
udp_table:add(MKA_PORT, mkaudp)
