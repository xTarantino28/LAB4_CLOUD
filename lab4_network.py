import paramiko
import sys
import subprocess

# Direcciones y credenciales de los nodos
headnode_address = "headnode.example.com"
worker_addresses = ["10.0.0.30", "10.0.0.40", "10.0.0.50"]
username = "ubuntu"
password = "ubuntu"

# Parámetros para los scripts
headnode_ovs_name = "br-int"
headnode_interfaces = "ens5"  # Coloca las interfaces del HeadNode aquí
worker_ovs_name = "br-int"
worker_interfaces = "ens4"  # Coloca las interfaces de los Workers aquí
vlan_parameters = [("vlan100", "100", "10.0.101.0/24", "10.0.101.3,10.0.101.100,255.255.255.0"),
                   ("vlan200", "200", "10.0.102.0/24", "10.0.102.3,10.0.102.100,255.255.255.0"),
                   ("vlan300", "300", "10.0.103.0/24", "10.0.103.3,10.0.103.100,255.255.255.0")]
vm_parameters = [("vm1", "br-int", "100", "5901"),  # Coloca los parámetros de las VMs aquí
                 ("vm2", "br-int", "200", "5902"),
                 ("vm3", "br-int", "300", "5903")]

# Conexión SSH y ejecución de scripts en el HeadNode
#def execute_on_headnode(script):
#    ssh_client = paramiko.SSHClient()
#    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#    ssh_client.connect(headnode_address, username=username, password=password)
#    stdin, stdout, stderr = ssh_client.exec_command(script)
#    print(stdout.read().decode("utf-8"))
#    ssh_client.close()

# ejecución de scripts en el HeadNode local
def execute_on_headnode(script):
    try:
        subprocess.run(script, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print("Error al ejecutar el script en el HeadNode:", e)

# Conexión SSH y ejecución de scripts en los Workers
def execute_on_worker(worker_address, script):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(hostname=worker_address, username=username, password=password)
    
    
      #stdin, stdout, stderr = ssh_client.exec_command("sudo -i")
    # Proporcionar la contraseña a través de stdin

    # Establecer una shell interactiva
    #ssh_session = ssh_client.invoke_shell()
    
    #ssh_session.send('cd /home/ubuntu\n')
    #while not ssh_session.recv_ready():
    #    pass
    #ssh_session.send(script + '\n')
    # Esperar a que se solicite la contraseña
    #while not ssh_session.recv_ready():
    #    pass
    # Enviar la contraseña
    #ssh_session.send(password + '\n')

    
    #stdin, stdout, stderr = ssh_client.exec_command("cd /home/ubuntu")
    stdin, stdout, stderr = ssh_client.exec_command(script, get_pty=True)
    print(stderr.read().decode("utf-8"))
    print(stdout.read().decode("utf-8"))
    #output = ssh_session.recv(65535).decode('utf-8')
    #print(output)
    ssh_client.close()




# Ejecución de los scripts en el HeadNode
execute_on_headnode(f"bash init_orchestrator/init_headnode.sh {headnode_ovs_name} {headnode_interfaces}")
for vlan_param in vlan_parameters:
    print(f"bash init_orchestrator/internal_net_headnode.sh {' '.join(vlan_param)}")
    execute_on_headnode(f"bash init_orchestrator/internal_net_headnode.sh {' '.join(vlan_param)}")
    


# Ejecución de los scripts en los Workers
for worker_address in worker_addresses:
    execute_on_worker(worker_address, f"sudo bash -S LAB4_CLOUD/init_orchestrator/init_worker.sh {worker_ovs_name} {worker_interfaces}")
    #for vlan_param in vlan_parameters:
    #    execute_on_worker(worker_address, f"./vlan_comm.sh {' '.join(vlan_param)}")
    #for vm_param in vm_parameters:
    #    execute_on_worker(worker_address,f"bash implement_orchestrator/vm_script.sh {' '.join(vm_param)}")

for worker_address in worker_addresses:
    for vm_param in vm_parameters:
        execute_on_worker(worker_address,f"sudo bash -S LAB4_CLOUD/implement_orchestrator/vm_script.sh {' '.join(vm_param)}")

#for vlan_param in vlan_parameters:
#    vlan_id = vlan_param[1]
#    execute_on_headnode(f"bash implement_orchestrator/vlan_internet.sh {vlan_id}")


print("Orquestador de cómputo inicializado exitosamente.")
