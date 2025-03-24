
--- 
--- Version: 2025-03-24
--- Author: xavixava (GH handle)
---

-- local dissector_list = Dissector.list()
local macsec_dissector = Dissector.get("macsec")
if macsec_dissector then
    print("MACsec dissector is callable")
else
    print("MACsec dissector is not callable. This dissector is not usable")
end

-- for i = 1,#dissector_list do
--     print(dissector_list[i])
-- end
