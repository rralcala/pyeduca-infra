import base64
import boto3
import bz2
import hashlib
import io
import json
import logging
import socket
import urllib.request
import os

s3 = boto3.client('s3')
logging.basicConfig(format='%(asctime)s %(levelname)-8s %(message)s', level=logging.INFO)
HOST = 'bureaucrat' # Bureaucrat
PORT = 9998            # The same port as used by the server
INVENTARIO_PORT=30080
USER=os.environ['INV_USER']
PASS=hashlib.sha1(bytes(os.environ['INV_PASSWD'], 'utf8')).hexdigest()
URL=f'http://inventario/'
ENCODING='utf-8'

def request_laptops_list(url, user, passw):
    password_mgr = urllib.request.HTTPPasswordMgrWithDefaultRealm()
    loc = f'{URL}places/schools_leases_json.json?hostnames=schoolserver.escuela0.caacupe.paraguayeduca.org'
    req = urllib.request.Request(loc)
    passman = urllib.request.HTTPPasswordMgrWithDefaultRealm()
    passman.add_password(None, url, user, passw)
    authhandler = urllib.request.HTTPBasicAuthHandler(passman)
    opener = urllib.request.build_opener(authhandler)
    urllib.request.install_opener(opener)
    req.add_header('Host', 'inventario.paraguayeduca.org')
    req.add_header('Content-Type', 'application/json')
    laptops = None
    try:
        with urllib.request.urlopen(req) as response:
            laptops = json.load(response)
    except Exception as e:
        logging.exception(f"Failed to request laptops from {loc}")
        exit(1)
    return laptops[0]['serials_uuids'], laptops[0]['expiry_date']

def sign_laptop(serial, uuid, date):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        s.sendall(f"{serial}:{uuid}:K:{date}".encode(ENCODING))
        results = f"act01: {serial} K {date} " + s.recv(1024).decode(ENCODING)
    return results

def sign_em(laptop_list, expiration):
    #with open('/root/lease.sig', 'r') as file:
    #    data = file.read().replace('\n', '')
    #d2 = data.replace("\n", "")
    laptops = {} #json.loads(d2)[1]
    for laptop in laptop_list:
        laptops[laptop['serial_number']] = sign_laptop(
            laptop['serial_number'],
            laptop['uuid'],
            expiration).rstrip()
    return [1, laptops]

def upload_results(leases):
    leases_json = json.dumps(leases,indent=2, sort_keys=True).encode(ENCODING)
    leases_json = bz2.compress(leases_json, compresslevel=9)
    s3.put_object(
        Body=leases_json,
        Bucket='pye-leases',
        Key='leases.dat.bz2',
    )

if __name__ == '__main__':
    laptop_list, expiration = request_laptops_list(URL, USER, PASS)
    logging.info("Got {} laptops".format(len(laptop_list)))
    if len(laptop_list) > 0:
        signed_leases = sign_em(laptop_list, expiration)
    else:
        exit(1)
    logging.info("Signed {} laptops".format(len(signed_leases[1])))
    upload_results(signed_leases)
