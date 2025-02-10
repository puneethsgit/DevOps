# Ansible Setup Guide for Ubuntu

## 1. Setting Up Passwordless SSH Authentication
To allow Ansible to connect to remote servers without requiring a password:

### Step 1: Generate SSH Key
```bash
ssh-keygen -t rsa -b 4096
```
- Press `Enter` to save the key in the default location (`~/.ssh/id_rsa`).
- Leave the passphrase empty for passwordless login.

### Step 2: Copy Public Key to Target Server
```bash
ssh-copy-id user@target-server
```
If `ssh-copy-id` is unavailable, manually copy the key:
```bash
cat ~/.ssh/id_rsa.pub | ssh user@target-server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### Step 3: Verify Passwordless Login
```bash
ssh user@target-server
```
If successful, no password will be required.

---
## 2. Setting Up Ansible Directory and Inventory

### Step 1: Create Ansible Directory
```bash
mkdir -p ~/ansible
cd ~/ansible
```

### Step 2: Create an Inventory File
Create `inventory.ini`:
```ini
[webservers]
server1 ansible_host=192.168.1.10 ansible_user=user
server2 ansible_host=192.168.1.11 ansible_user=user

[dbservers]
server3 ansible_host=192.168.1.12 ansible_user=user
```

---
## 3. Running Ansible Ad-hoc Commands
Run a simple ad-hoc command to create a file on all target servers:
```bash
ansible all -i inventory.ini -m file -a "path=/tmp/ansible_test.txt state=touch" --become
```
- `-i inventory.ini`: Specify inventory file.
- `-m file`: Use the file module.
- `-a "path=/tmp/ansible_test.txt state=touch"`: Create a file.
- `--become`: Run with sudo privileges.

To check system uptime on all servers:
```bash
ansible all -i inventory.ini -m command -a "uptime"
```

---
## 4. Writing and Executing an Ansible Playbook

### Create Playbook File
Create `nginx_setup.yml`:
```yaml
---
- name: Install and Start nginx
  hosts: webservers
  become: true

  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present

    - name: Start nginx
      service:
        name: nginx
        state: started
```

### Execute Playbook
```bash
ansible-playbook -i inventory.ini nginx_setup.yml
```

---
## 5. Understanding Ansible Roles
Roles in Ansible allow better organization of tasks and configurations. To create a role:

```bash
mkdir -p ~/ansible/roles/nginx/{tasks,handlers,templates,files,vars,defaults,meta}
```

### Create `tasks/main.yml`
```yaml
---
- name: Install nginx
  apt:
    name: nginx
    state: present

- name: Start nginx
  service:
    name: nginx
    state: started
```

### Apply Role in Playbook
Create `site.yml`:
```yaml
---
- name: Setup Web Servers
  hosts: webservers
  roles:
    - nginx
```

### Run Playbook with Role
```bash
ansible-playbook -i inventory.ini site.yml
```

---
## Conclusion
This guide covered:
- Passwordless SSH setup
- Ansible inventory and groups
- Running ad-hoc Ansible commands
- Writing and executing playbooks
- Understanding and using Ansible roles

With these steps, you can efficiently manage servers using Ansible!

