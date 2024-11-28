---


---


<table>
<thead>
<tr>
<th>Hardware</th>
<th>Confirmed working</th>
<th>Expected to work</th>
<th>Notes</th>
</tr>
</thead>
<tbody>
<tr>
<td>LoRa radios (working with Meshtasticd)</td>
<td><li><a href="https://www.waveshare.com/sx1262-lorawan-hat.htm?sku=22002">Waveshare RPi LoRa hat without GNSS</a>*</li><li><a href="https://www.seeedstudio.com/Wio-SX1262-Wireless-Module-p-5981.html">Seeed Wio SX1262</a></li><li><a href="https://aliexpress.com/item/4000543921245.html">Ebyte E220900M30S</a></li><li>RA-01SH</li><li>HT-RA62</li></td>
<td><li>E22-900mm22s</li><li>E22-900m22s</li><li>Any SPI LoRa radio that’s Meshtastic compatible</li></td>
<td>*Waveshare RPi hat is not recommended as it has issues with sending longer messages.</td>
</tr>
<tr>
<td>RTC (real time clock)</td>
<td><li><a href="https://vi.aliexpress.com/item/1005007143842437.html">DS3231M</a></li><li><a href="https://vi.aliexpress.com/item/1005007143542894.html">DS1307</a></li></td>
<td>DS1337, DS1338, DS1340, other DS3231 variants</td>
<td>Some DS3231 modules are listed as having a supercapacitor - these are usually actually lithium coin cells.</td>
</tr>
<tr>
<td>Meshtastic nodes</td>
<td>USB+UART: <a href="https://store.rakwireless.com/products/wisblock-meshtastic-starter-kit">RAK4631 with RAK19007 or RAK19003 base board</a></td>
<td></td>
<td>RAK4630 and 4631 are the same.</td>
</tr>
<tr>
<td>USB wifi adapter chipsets</td>
<td>See below.</td>
<td>See below.</td>
<td>WORK IN PROGRESS.</td>
</tr>
<tr>
<td>Misc. hardware</td>
<td><li>USB hubs (powered or not)</li><li>Thumb drives</li><li>SD card readers</li></td>
<td></td>
<td>If power draw exceeds supply, the device will reboot, bootloop or hard crash.</td>
</tr>
</tbody>
</table><h3 id="wifi-chipsets">Wifi chipsets</h3>
<p>The following wifi chipsets/devices have their drivers included in the OS images. Most of these have not been tested. Note that power consumption metrics are for a specific version of a chipset and may not apply to all implementations.</p>

<table>
<thead>
<tr>
<th>Chipset:</th>
<th>Tested?</th>
<th>Recommended?</th>
<th>Power usage</th>
<th>Notes</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong><u>Realtek:</u></strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rl8188cu</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8187</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8187b</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8188[cr]u</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8188cu</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8188ee</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8188eu, rtl8188eus</td>
<td><strong>✔</strong></td>
<td><strong>✔</strong></td>
<td>Idle: 0.25w<br>TXing: 0.4w<br>Off: 0.025w</td>
<td>Tested: <a href="https://techinfodepot.shoutwiki.com/wiki/TP-LINK_TL-WN725N_v2">TP-LINK TL-WN725N <strong>V2</strong></a></td>
</tr>
<tr>
<td>rtl8188ru</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl819[12]cu</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8191cu</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8192ce</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8192cu</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8192cu</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8192de</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8192e</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8192ee</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8192se</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8273,8188,8191,8192</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8712u</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8723ae</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8723au</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8723be</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8821ae</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rtl8xxx other</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><strong><u>Mediatek:</u></strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>mt7601u</td>
<td><strong>✔</strong></td>
<td><strong>✔</strong></td>
<td>Idle: 0.739w</td>
<td></td>
</tr>
<tr>
<td>mt76x0u</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>mt76x2u</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>mt7663s</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>mt7663u</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><strong><u>Atheros:</u></strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ar5008</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ar5523</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ar6003</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ar6004</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ar9001</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ar9002</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ar9170</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ar9271</td>
<td><strong>✔</strong></td>
<td><strong>X</strong></td>
<td></td>
<td>Buggy</td>
</tr>
<tr>
<td>ar9k</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ath11k</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>ar10k</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>wcn3660</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>wcn3680</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><strong><u>Ralink:</u></strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt2501/rt73</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt2571</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt2571w</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt2572</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt2573</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt25xx</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt2671</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt27xx</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt28xx</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt28xx unknown</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt30xx</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt33xx</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt3573</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt35xx</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt53xx</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>rt55xx</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><strong><u>Atmel:</u></strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>at76c503</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>at76c505</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>at76c505a</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><strong><u>Microchip Atmel:</u></strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>wilc1000</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><strong><u>Zydas:</u></strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>zd1201</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>zd1211</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>zd1211b</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td><strong><u>RNDIS USB:</u></strong></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Asus WL169gE</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Belkin F5D7051</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>BT Voyager 1055</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Buffalo WLI-U2-KG125S</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>BUFFALO WLI-USB-G54</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Eminent EM4045</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Linksys WUSB54GSC</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Linksys WUSB54GSv1</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>Linksys WUSB54GSv2</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>U.S. Robotics USR5420</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td>U.S. Robotics USR5421</td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
</tbody>
</table>