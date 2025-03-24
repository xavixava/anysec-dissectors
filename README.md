# ANYsec Packet Dissectors for Wireshark

ANYsec is a Nokia quantum-safe technology that provides low-latency, line-rate native encryption for any transport, on any service, at any time, and under any load conditions without impacting performance.

[Nokia's ANYsec](https://www.nokia.com/networks/technologies/fp5/) is based on [IEEE 802.1AE MACsec](https://1.ieee802.org/security/802-1ae/) (Media Access Control Security) and MKA (MACsec Key Agreement), but it extends their capabilities beyond Layer 2. In the control plane, it modifies the MKA protocol from L2 Ethernet to UDP over IP, enabling its use in L3 networks. In the data plane it allows encryption for any transport technology.

This technology can be tested using [ContainerLab (CLAB)](https://containerlab.dev/) with available projects from [SRL-Labs](https://github.com/srl-labs), such as the [ANYsec/MACsec](https://github.com/srl-labs/sros-anysec-macsec-lab) lab. [Wireshark](https://www.wireshark.org/) is an essential tool for testing and validate ANYsec; however, since this technology is still a proprietary network encryption solution, public releases of Wireshark do not yet include ANYsec packet dissectors. 

This repository provides ANYsec Packet Dissectors for Wireshark. 


## Installation

### Prerequisites/Requirements

The dissectors were tested on Wireshark version 4.4.5 with lua support for Linux and Windows 10 and 11 (not tested for MAC).

The 64-bit Windows version has lua support built-in. The official [installer](https://www.wireshark.org/download.html) for the x64 was used for development and tests.

On linux, there are different Wireshark builds for each different distribution, which means the dissectors might not work for all. In some Wireshark builds there is no lua support and some distributions maintain older Wireshark versions, that don't make the MACsec dissector available to be called through the lua API. We explain how to check for [lua support](#check-for-lua-support) and if the MACsec dissector is [callable through the lua API](#check-for-macsec-support).

If you own a Mac or a ARM windows and would like to test the dissector, please give us some feedback.

### [Check for Lua support](#check-for-lua-support)

In order to check if your Wireshark build has lua support, from the GUI select:
* "Tools" > "Lua Console"

 This option should open the lua console as shown in the picture below. If you don't see the option then lua is not supported.

![Wireshark Lua Console](images/wireshark_lua_console.png)

Alternatively, if you're using linux you can run on your terminal:
```bash 
wireshark --version | grep Lua
``` 
 or if you're using Windows:
 ```bash 
 "C:\Program Files\Wireshark\Wireshark.exe" --v | findstr Lua
 ``` 

The output should return "with Lua <lua version>" if there is lua support.


### [Check for macsec support](#check-for-macsec-support)

In order to check if your Wireshark build has macsec support, open the lua console:
* "Tools" > "Lua Console"

and evaluate the following code (plugin file helper.lua):
```bash  
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
 ```


The console will display if macsec is supported as shown in the picture below:

![Wireshark Lua Console macsec support](images/wireshark_macsec_support.png)

### Install the plugins

While starting the Wireshark will check on specific directories if there are any lua files to load. 
To install the ANYsec dissectors you just need to copy the dissector folder to the plugins directory and restart the wireshark. The dissector files under the "4.4_anysec_plugins" folder are:
* anysec-heuristics.lua
* mka-ip-heuristics.lua
* helper.lua ???


To find your Wireshark plugin folder, where you should place the dissectors, select:
* "Help" > "About Wireshark" > "Folders" 

You may search by lua and you'll get an output similar to the picture bellow. You may choose the "Global Lua Plugins" or the "Personal Lua Plugins" folders.

![Wireshark plugin folder for Lua dissector files ](images/wireshark_lua_folders.png)


In summary, the general steps to be followed independently on your operating system should be:

1. Clone the repository or download the lua folder/files.

2. Copy the folder with the anysec-heuristics.lua and mka-ip-heuristics.lua files to the "Lua Plugins" folder and (re)start Wireshark.


The successful loading of the dissectors can be checked by selecting:
* "Help" > "About Wireshark" > "Plugins", and then search by "Lua"

![Wireshark plugin files ](images/wireshark_lua_plugins.png)

### Linux

In Linux, the "Personal Lua Plugins" folder usually is $HOME/.local/lib/wireshark/plugins, as such to setup the dissectors:

1. Clone the repository: ```git clone https://github.com/xavixava/anysec-dissectors.git```

2. Create the "Personal Lua Plugins" directory, if it doesn't exist: ```mkdir -p $HOME/.local/lib/wireshark/plugins```

3. Copy the dissectors to the "Personal Lua Plugins": ```cp anysec-dissectors/anysec-heuristics.lua $HOME/.local/lib/wireshark/plugins/.; cp anysec-dissectors/mka-ip-heuristics.lua $HOME/.local/lib/wireshark/plugins/."

It might be necessary to change your "Personal Lua Plugins" on these instructions according to the one on your Wireshark installation.

### Windows ???

In Linux ???, the "Personal Lua Plugins" folder usually is $HOME/.local/lib/wireshark/plugins, as such to setup the dissectors:

(The commands will only work after the repository is public)

1. Download the repository: ```curl -o <name-of-the-file> https://github.com/xavixava/anysec-dissectors/archive/refs/heads/main.zip``` 

2. Create the "Personal Lua Plugins" directory, if it doesn't exist: ```mkdir -p $HOME/.local/lib/wireshark/plugins```

3. Copy the dissectors to the "Personal Lua Plugins": ```cp anysec-dissectors/anysec-heuristics.lua $HOME/.local/lib/wireshark/plugins/.; cp anysec-dissectors/mka-ip-heuristics.lua $HOME/.local/lib/wireshark/plugins/."

It might be necessary to change your "Personal Lua Plugins" on these instructions according to the one on your Wireshark installation.


## Usage

Once you successful install the wireshark plugins you can start playing with it, but you need a ANYsec setup.

> [!TIP]  
> If you don't have a setup but want to test the dissectors anyway, you may simply used the example pcap file provided in this repo.

> [!IMPORTANT]  
> You may use [ContainerLab (CLAB)](https://containerlab.dev/) and [EdgeShark](https://containerlab.dev/manual/wireshark/#edgeshark-integration) to build and test ANYsec your setup.

> [!IMPORTANT]  
> You may also use available projects from [SRL-Labs](https://github.com/srl-labs), such as the [ANYsec/MACsec](https://github.com/srl-labs/sros-anysec-macsec-lab) lab. 


### Display Filters

You may apply display filters to your wireshark capture to make it easier to identify the packets and inspect the contents. 
The most relevante filters are shown in the table below:

| Filter            | Description   |
| ----------------- |-------------  | 
| mkaoudp           | display MKA UDP over IP packets only                                                     |
| mka               | display all MKA (UDP over IP and standard MKA over Ethernet)                             |
| mka && !mkaoudp   |display only standard MKA over Ethernet (excludes mkaoudp)                                | 
| anysec            | display anysec data plane packets only (mpls labels followed by the macsec header)       |
| macsec            | display anysec and standard macsec packets (Ethernet followed by the macsec header)      |
| macsec && !anysec | display only the standard macsec packets (excludes anysec)                               | 



### Tests

The following picture displays an ANYsec packet:
> [!Note]  
> There are 2 MPLS Labels (transport and Encryption SID (ES)) followed by the ANYsec header (EtherType (0x88e5) and the 802.1AE header). The payload is encrypted.

![Wireshark anysec capture ](images/wireshark_anysec.png)


The following picture displays MACsec frame:
> [!Note] 
> The Ethernet header is followed by the MACsec/802.1AE header. The EtherType 0x88e5 is part of the Ethernet header.

![Wireshark macsec capture ](images/wireshark_macsec.png)


The following picture displays MKA UDP over IP packet:

![Wireshark mkaoudp capture ](images/wireshark_mkaoudp.png)


The following picture displays MKA Ethernet frame:

![Wireshark mka capture ](images/wireshark_mka.png)


### Tests with command line ???

include tshark outputs

# Conclusion
These wiresharks dissectors are very useful and powerful tool to filter and inspect anysec and mka packets.



