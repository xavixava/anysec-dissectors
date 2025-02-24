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
    local anysec_packet = buffer(0, buffer:len())

    local dissector_list = Dissector.list()
    for i=0, #dissector_list do
        print(dissector_list[i])
    end
    local macsec_dissector = Dissector.get("macsec")
    print(macsec_dissector)
    if macsec_dissector then
	print("Found MACsec dissector")
        macsec_dissector:call(macsec_pdu:tvb(), pinfo, tree)
    elseif macsec_dissector == nil then
	print("Dissector is nil")
    end
end

-- Define the reserved label space
-- Taken from this example
local MIN_LABEL = 2000
local MAX_LABEL = 5999
local TEST_LABEL = 2201

-- Register the protocol on the UDP dissector table
mpls_table = DissectorTable.get("mpls.label") -- TODO: Discover how to check for label range without for
mpls_table:add(TEST_LABEL, anysec)

print("Dissector loaded for label " .. TEST_LABEL)
