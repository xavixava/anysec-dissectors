-- Wireshark version in console
--

local anysec = Proto("ANYsec", "ANYsec");
-- local anysec = Proto("MKA", "MACsec Key Agreement over UDP")

-- Protocol header definition the protocol
--  local fields = {
--      mka_header = ProtoField.uint16("mka.header", "Ethertype", base.HEX),
--  }
-- anysec.fields = fields

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

-- Define the reserved label space
-- Taken from this example
local MIN_LABEL = 2000
local MAX_LABEL = 5999
local TEST_LABEL = 2201

-- Register the protocol on the UDP dissector table
mpls_table = DissectorTable.get("mpls.label") -- TODO: Discover how to check for label range without for

for i=MIN_LABEL, MAX_LABEL do
    mpls_table:add(i, anysec)
end

print("Dissector loaded for labels " .. MIN_LABEL .. " to " .. MAX_LABEL)
