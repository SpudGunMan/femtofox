# file name: send-environment-metrics.py
# https://github.com/pdxlocations/Meshtastic-Python-Examples/blob/main/send-environment-metrics.py

from meshtastic.protobuf import portnums_pb2, telemetry_pb2
from meshtastic import BROADCAST_ADDR
import time

# For connection over serial
# import meshtastic.serial_interface
# interface = meshtastic.serial_interface.SerialInterface()

# For connection over TCP
import meshtastic.tcp_interface
interface = meshtastic.tcp_interface.TCPInterface(hostname='127.0.0.1', noProto=False)

telemetry_data = telemetry_pb2.Telemetry()
telemetry_data.time = int(time.time())
# cpu temp 
with open('/sys/class/thermal/thermal_zone0/temp', 'r') as cpu_temp:
    telemetry_data.environment_metrics.temperature = int(cpu_temp.read()) / 1000
#telemetry_data.environment_metrics.relative_humidity = 69
# telemetry_data.environment_metrics.barometric_pressure = 0
# telemetry_data.environment_metrics.gas_resistance = 0
# telemetry_data.environment_metrics.voltage = 0
# telemetry_data.environment_metrics.current = 0
# telemetry_data.environment_metrics.iaq = 0
# telemetry_data.environment_metrics.distance = 0
# telemetry_data.environment_metrics.lux = 0
# telemetry_data.environment_metrics.white_lux = 0
# telemetry_data.environment_metrics.ir_lux = 0
# telemetry_data.environment_metrics.uv_lux = 0
# telemetry_data.environment_metrics.wind_direction = 0
# telemetry_data.environment_metrics.wind_speed = 0
# telemetry_data.environment_metrics.wind_gust = 0
# telemetry_data.environment_metrics.wind_lull = 0
# telemetry_data.environment_metrics.weight = 0

interface.sendData(
    telemetry_data,
    destinationId=BROADCAST_ADDR,
    portNum=portnums_pb2.PortNum.TELEMETRY_APP,
    wantResponse=False,
)

interface.close()