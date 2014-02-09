# Alfred 2 Network Information Workflow

Get information about network and/or look up MAC addresses.

## Usage:

* Type **subnet [IP]/netmask**
  * **NOTE THAT THIS RELIES ON THE ipcalc UTILITY** which can be downloaded [here](http://jodies.de/ipcalc), or through Homebrew.
  * IP defaults to 192.168.1.0 if not specified
  * netmask can be specified using traditional or CIDR notation
* Type **mac \<MAC address or subset\>**
  * MAC address can be specified with any or no separators (they will be stripped from the string)
  * Only the first three hex values must be specified
