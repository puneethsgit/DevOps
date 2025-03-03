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
If `ssh-copy-id` is unavailable, manually copy the key: or you copy using cat cmd and go to authorized_keys and paste it
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
server1 ansible_host=xxx.xxx.x.xx ansible_user=user
server2 ansible_host=xxx.xxx.x.xxansible_user=user

[dbservers]
server3 ansible_host=xxx.xxx.x.xx ansible_user=user
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
### Using SHELL MODULE

---
- name: Install and Start Nginx using Shell
  hosts: webservers
  become: true

  tasks:
    - name: Update package list
      shell: apt update -y

    - name: Install Nginx
      shell: apt install -y nginx

    - name: Start Nginx
      shell: systemctl start nginx

    - name: Enable Nginx on boot
      shell: systemctl enable nginx

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

## Another Way to Create Roles
Another way to create roles in Ansible is by using the `ansible-galaxy` command, which helps set up the directory structure automatically.

### Using `ansible-galaxy`
Run the following command:

```bash
ansible-galaxy init nginx
```

This will create a structured directory like this:

```
nginx/
├── defaults
│   ├── main.yml
├── files
├── handlers
│   ├── main.yml
├── meta
│   ├── main.yml
├── tasks
│   ├── main.yml
├── templates
├── tests
│   ├── inventory
│   ├── test.yml
├── vars
│   ├── main.yml
```

### Defining Tasks
Edit `nginx/tasks/main.yml` to include:

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
    enabled: yes
```

### Applying the Role in a Playbook
Create `site.yml`:

```yaml
---
- name: Setup Web Servers
  hosts: webservers
  roles:
    - nginx
```

### Running the Playbook
Execute the playbook with:

```bash
ansible-playbook -i inventory.ini site.yml
```

Using `ansible-galaxy init` is the recommended method as it ensures a well-structured role setup.

## What is `inventory.ini`?

The `inventory.ini` file in Ansible is an **inventory file** that defines the hosts and groups of machines that Ansible will manage. The `.ini` extension indicates that it's using the **INI file format**.

### Example `inventory.ini`
```ini
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.example.com
db2.example.com

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Alternative Inventory Formats
Besides `.ini`, Ansible also supports:
1. **YAML Inventory (`inventory.yml`)**
   ```yaml
   all:
     hosts:
       web1.example.com:
       web2.example.com:
     vars:
       ansible_user: ubuntu
       ansible_ssh_private_key_file: ~/.ssh/id_rsa
   ```
2. **Dynamic Inventory**
   - Fetches hosts from cloud providers (AWS, Azure, GCP) dynamically.

### Is `.ini` Required?
No, mentioning `.ini` is **not required** in the inventory file name. You can name the file anything you want, such as:
- `inventory`
- `hosts`
- `my_inventory.ini`
- `inventory.yml` (if using YAML format)

By default, Ansible looks for an inventory file named **`inventory`** in the project directory. If your file has a different name, you need to specify it explicitly when running the playbook:

```bash
ansible-playbook -i my_inventory site.yml
```

If you're using an **INI-style inventory file**, the `.ini` extension is optional, but it helps indicate the format for readability.


---
## Conclusion
This guide covered:
- Passwordless SSH setup
- Ansible inventory and groups
- Running ad-hoc Ansible commands
- Writing and executing playbooks
- Understanding and using Ansible roles

With these steps, you can efficiently manage servers using Ansible!

