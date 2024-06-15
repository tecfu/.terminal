# Usage: python3 python-stdio-proxy.py --cmd "vscode-eslint-language-server --stdio" --port 12345

import socket
import threading
import subprocess
import argparse

# Logging setup
LOGFILE_IN = "python-proxy-in.log"
LOGFILE_OUT = "python-proxy-out.log"
RAW_LOGFILE = "python-proxy-raw.log"

def log_message(logfile, message):
    with open(logfile, 'a') as f:
        f.write(message + '\n')

def handle_client(client_socket, server_process):
    def forward_to_server():
        while True:
            try:
                # Receive message from client
                client_message = client_socket.recv(4096)
                if not client_message:
                    break

                # Log raw client message
                log_message(RAW_LOGFILE, f"CLIENT > SERVER: {client_message.decode('utf-8', errors='ignore')}")

                # Forward message to server
                server_process.stdin.write(client_message)
                server_process.stdin.flush()

            except Exception as e:
                log_message(RAW_LOGFILE, f"ERROR: {str(e)}")
                break

    def forward_to_client():
        while True:
            try:
                # Receive response from server
                server_response = server_process.stdout.read(4096)
                if not server_response:
                    break

                # Log raw server response
                log_message(RAW_LOGFILE, f"SERVER > CLIENT: {server_response.decode('utf-8', errors='ignore')}")

                # Forward response to client
                client_socket.sendall(server_response)

            except Exception as e:
                log_message(RAW_LOGFILE, f"ERROR: {str(e)}")
                break

    # Start threads to forward messages in both directions
    threading.Thread(target=forward_to_server, daemon=True).start()
    threading.Thread(target=forward_to_client, daemon=True).start()

def main():
    parser = argparse.ArgumentParser(description='Python proxy for language server.')
    parser.add_argument('--cmd', required=True, help='Command to start the language server.')
    parser.add_argument('--port', type=int, required=True, help='Port to listen on.')
    args = parser.parse_args()

    # Split the command into a list for Popen
    language_server_cmd = args.cmd.split()

    # Start the language server process
    server_process = subprocess.Popen(
        language_server_cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        bufsize=0
    )

    # Start the socket server
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('localhost', args.port))
    server_socket.listen(5)
    print(f"[*] Listening on localhost:{args.port}")

    while True:
        client_socket, addr = server_socket.accept()
        print(f"[*] Accepted connection from {addr}")

        client_handler = threading.Thread(target=handle_client, args=(client_socket, server_process))
        client_handler.start()

if __name__ == "__main__":
    main()
