import socket
import threading
import subprocess
import os
bind_ip = '0.0.0.0'
bind_port = 9998

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind((bind_ip, bind_port))
server.listen(5)  # max backlog of connections

print(f'Listening on {bind_ip}:{bind_port}')


def handle_client_connection(client_socket):
    request = client_socket.recv(1024)
    print('Received {}'.format(request))
    request = request.decode('utf-8')
    if ":A:" in request:
        type = 'developer'
    else:
        type = 'lease'
    p = subprocess.Popen([os.path.abspath('./sig01'), 'sha256', "/mnt/{}".format(type)], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                                 stderr=subprocess.PIPE)
    out, err = p.communicate(request.encode('utf8'))
    client_socket.send(out)
    client_socket.close()

while True:
    client_sock, address = server.accept()
    client_handler = threading.Thread(
        target=handle_client_connection,
        args=(client_sock,)
    )
    client_handler.start()
