import os

from netmiko import ConnectHandler

def main():
    cisco = {
        "device_type": "cisco_ios",
        "host": os.environ.get('HOST'),
        "username": os.environ.get('USER'),
        "password": os.environ.get('PASSWORD'),
        "secret": os.environ.get('PASSWORD')
    }
    net_connect = ConnectHandler(**cisco)
    net_connect.enable()

    commands = [
        "router bgp " + os.environ.get('LOCAL_ASN'), 
        "address-family ipv4 vrf cloud",         
        "redistribute connected"
    ]
    
    output = net_connect.send_config_set(commands)
    output += net_connect.save_config()

    output += net_connect.send_command("sh run | section bgp")

    net_connect.disconnect()

    print(output)


if __name__ == "__main__":
    main()