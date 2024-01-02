import random
import time
import RPi.GPIO as GPIO
from paho.mqtt import client as mqtt_client
import json

broker = 'mqtt.things.ph' 
port = 1883
topic = "RasPiTransPlantMQTT" #INPUT TOPIC NAME
client_id = f'publish-{random.randint(0, 1000)}'

username = '64c14253811ec75105c1948a' 
password = 'QuRHxlbi8RDbkv7Nkq77N3Ps' 
LampPin = 11
PumpPin = 12 

startTime = time.time()
neededTime = 30 #CHANGE THIS

def setup():
    GPIO.setmode(GPIO.BOARD)
    GPIO.setup(LampPin, GPIO.OUT)
    GPIO.output(LampPin, GPIO.HIGH)
    GPIO.setup(PumpPin, GPIO.OUT)
    GPIO.output(PumpPin, GPIO.LOW)

def connect_mqtt() -> mqtt_client:
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker!")
        else:
            print("Failed to connect, return code %d\n", rc)

    client = mqtt_client.Client(client_id)
    client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.connect(broker, port)
    return client

def subscribe(client: mqtt_client):
    def on_message(client, userdata, msg):
        print(f"Received `{msg.payload.decode()}` from `{msg.topic}` topic")

        payload = msg.payload.decode()
        payloadDic = json.loads(payload)
        light = payloadDic['payload_fields']['light']
        moisture = payloadDic['payload_fields']['moisture']

        if(light < 400):
            GPIO.output(LampPin, GPIO.LOW)
            #publish(client, "light", 1)
        else:
            GPIO.output(LampPin, GPIO.HIGH)
            #publish(client, "light", 0)
            
        if(moisture < 60):
            GPIO.output(PumpPin, GPIO.HIGH)
            time.sleep(450)
            GPIO.output(PumpPin, GPIO.LOW)
            time.sleep(600)
            #publish(client, "pump", 1)
        else:
            GPIO.output(PumpPin, GPIO.LOW)
            #publish(client, "pump", 0)
            
    client.subscribe(topic)
    client.on_message = on_message

def publish(client, relay, msg):
    msg_count = 1
    while True:
        time.sleep(1)
        msg = {"hardware_serial": "RasPiTransPlantMQTT",
		"payload_fields": {
			f"{relay}relay": msg,
	         }
	      }         
        
        result = client.publish(topic, payload=json.dumps(msg),qos=0,retain=False)
        status = result[0]
        if status == 0:
            print(f"Send `{msg}` to topic `{topic}`")
        else:
            print(f"Failed to send message to topic {topic}")

def destroy():
    GPIO.output(PumpPin, GPIO.LOW)
    GPIO.output(LampPin, GPIO.HIGH)
    GPIO.cleanup()

def run(): 
    client = connect_mqtt()
    subscribe(client)
    client.loop_forever()

if __name__ == '__main__':
    setup()
    try:
        run()
    except KeyboardInterrupt:
        destroy()
