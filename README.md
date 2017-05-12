Author  - Thiyagu Loganathan
Purpose - To use wordpress-setup-ansible tool from your system. wordpress-setup-ansible will provision a server on AWS and brings Wordpress over the EC2 Instance.

Requirement - Linux machine Ansible setup with python, pytjon-pip & python-docker

Steps:-

1. Clone the git repository <> on ansible server.
   
   git clone
   
2. Create an AWS IAM user with admin previleges for Ansible and have AWS Access key and Secret access key. 

3. Create KeyPair for wordpress web server. Copy the pem key file to ansible host. Make the key file to have read-only permission.

4. Setup AWS network layer and webserver to launch wordpress blog using following command :

   Command : ansible-playbook 1-infra-playbook.yml -i inventory -e @vars.yml

   Output:-
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible# ansible-playbook 1-infra-playbook.yml -i inventory -e @vars.yml
   [DEPRECATION WARNING]: ec2_ami_search is kept for backwards compatibility but usage is discouraged. The module documentation details page may explain more about this
   rationale..
   This feature will be removed in a future release. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
   
   PLAY [local] ***********************************************************************************************************************************************************
   
   TASK [Gathering Facts] *************************************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Create VPC] **********************************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Set VPC ID in variable] **********************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Create Public Subnet] ************************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Set Public Subnet ID in variable] ************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Create Internet Gateway for VPC] *************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Set Internet Gateway ID in variable] *********************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Set up public subnet route table] ************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Create WordPress Security Group] *************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Search for Ubuntu AMI] ***********************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Set Image ID in variable] ********************************************************************************************************************************
   ok: [localhost]
   
   TASK [infra : Create the WebServer Instances] **************************************************************************************************************************
   changed: [localhost]
   
   PLAY RECAP *************************************************************************************************************************************************************
   localhost                  : ok=12   changed=1    unreachable=0    failed=0
   
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible#
   

5. Update hosts file with IP of the webserver created by above step as follows:

   root@ip-10-96-2-5:/opt/wordpress-setup-ansible# cat hosts
   [webserver]
   107.23.7.237

6. Enable Passwordless authentication between ansible host and webserver using 2-enable-passwordless-authentication.sh script.

   root@ip-10-96-2-5:/opt/wordpress-setup-ansible# bash 2-enable-passwordless-authentication.sh -h
   Usage: To enable passwordless authentication on a server.
   2-enable-passwordless-authentication.sh -u user_name -i ip_of_server -k [path_of_keypair]
               user_name        :     Mandatory - Username in server to enable passwordless authentication
               ip_of_server     :     Mandatory - IP of server to enable passwordless authentication
               path_of_keypair  :     Optional - complete of ssh keypair to login with server
			   
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible# bash 2-enable-passwordless-authentication.sh -u ubuntu -i 107.23.7.237 -k /opt/WP_keypair.pem
   The authenticity of host '107.23.7.237 (107.23.7.237)' can't be established.
   ECDSA key fingerprint is SHA256:mHgI5rgVK47MaGSO7FiN8NZPnv4gzNMuv++oZWbY8b0.
   Are you sure you want to continue connecting (yes/no)? yes
   Warning: Permanently added '107.23.7.237' (ECDSA) to the list of known hosts.
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible# ssh ubuntu@107.23.7.237
   Welcome to Ubuntu 14.04.5 LTS (GNU/Linux 3.13.0-117-generic x86_64)
   
    * Documentation:  https://help.ubuntu.com/
   
     System information as of Fri May 12 09:14:04 UTC 2017
   
     System load:  0.0               Processes:           100
     Usage of /:   10.1% of 7.74GB   Users logged in:     0
     Memory usage: 1%                IP address for eth0: 10.0.1.93
     Swap usage:   0%
   
     Graph this data and manage this system at:
       https://landscape.canonical.com/
   
     Get cloud support with Ubuntu Advantage Cloud Guest:
       http://www.ubuntu.com/business/services/cloud
   
   0 packages can be updated.
   0 updates are security updates.
   
   New release '16.04.2 LTS' available.
   Run 'do-release-upgrade' to upgrade to it.
   
   
   ubuntu@ip-10-0-1-93:~$ exit
   logout
   Connection to 107.23.7.237 closed.
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible#

7. Install docker on Webserver using following command :
   
   Command: ansible-playbook -i hosts 3-install-docker.yml
   
   Output:-
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible# ansible-playbook -i hosts 3-install-docker.yml
   [DEPRECATION WARNING]: Instead of sudo/sudo_user, use become/become_user and make sure become_method is 'sudo' (default).
   This feature will be removed in a future
   release. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
   
   PLAY [install docker] **************************************************************************************************************************************************
   
   TASK [Update apt] ******************************************************************************************************************************************************
    [WARNING]: Consider using apt module rather than running apt-get
   
   changed: [107.23.7.237]
   
   TASK [Install apt-transport-https] *************************************************************************************************************************************
   changed: [107.23.7.237]
   
   TASK [Add key] *********************************************************************************************************************************************************
   changed: [107.23.7.237]
   
   TASK [Add docker repo] *************************************************************************************************************************************************
   changed: [107.23.7.237]
   
   TASK [Update apt] ******************************************************************************************************************************************************
   changed: [107.23.7.237]
   
   TASK [Install recommended packages] ************************************************************************************************************************************
   changed: [107.23.7.237]
   
   TASK [Install docker version 1.10] *************************************************************************************************************************************
   changed: [107.23.7.237]
   
   TASK [Start docker service] ********************************************************************************************************************************************
   ok: [107.23.7.237]
   
   PLAY RECAP *************************************************************************************************************************************************************
   107.23.7.237               : ok=8    changed=7    unreachable=0    failed=0
   
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible#
   
8. Setup MySQL DB on docker host using following command:

   Command: ansible-playbook -i hosts 4-setup-db-docker.yml -e @vars.yml
   
   Output:-
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible# ansible-playbook -i hosts 4-setup-db-docker.yml -e @vars.yml
   [DEPRECATION WARNING]: Instead of sudo/sudo_user, use become/become_user and make sure become_method is 'sudo' (default).
   This feature will be removed in a future
   release. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
   
   PLAY [install docker] **************************************************************************************************************************************************
   
   TASK [Install pip] *****************************************************************************************************************************************************
    [WARNING]: Consider using apt module rather than running apt-get
   
   changed: [107.23.7.237]
   
   TASK [Install dependencies] ********************************************************************************************************************************************
   changed: [107.23.7.237]
   
   TASK [MySQL docker container] ******************************************************************************************************************************************
   changed: [107.23.7.237]
   
   TASK [Wait a few minutes for the IPs to be set to the container] *******************************************************************************************************
   ok: [107.23.7.237]
   
   TASK [Fetch the MySQL Container IP] ************************************************************************************************************************************
   changed: [107.23.7.237]
   
   TASK [print the mysql ip] **********************************************************************************************************************************************
   ok: [107.23.7.237] => {
       "changed": false,
       "msg": "172.17.0.2"
   }
   
   PLAY RECAP *************************************************************************************************************************************************************
   107.23.7.237               : ok=6    changed=4    unreachable=0    failed=0
   
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible#

9. Update MySQL IP (mysql_db_host) returned by previous command output & required blog URL wp_blog_url in vars.yml file.

10. Setup wordpress with apache2 server on webserver host by using following command:
   
   Command: ansible-playbook -i hosts 5-setup-wordpress.yml -e @vars.yml

   Output:-
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible# ansible-playbook -i hosts 5-setup-wordpress.yml -e @vars.yml
   [DEPRECATION WARNING]: Instead of sudo/sudo_user, use become/become_user and
   make sure become_method is 'sudo' (default).
   This feature will be removed in a
   future release. Deprecation warnings can be disabled by setting
   deprecation_warnings=False in ansible.cfg.
   
   PLAY [setup wordpress] *********************************************************
   
   TASK [install php] *************************************************************
    [WARNING]: Consider using apt module rather than running apt-get
   
   changed: [107.23.7.237]
   
   TASK [Update apt cache] ********************************************************
   ok: [107.23.7.237]
   
   TASK [Install required software] ***********************************************
   ok: [107.23.7.237] => (item=[u'apache2', u'php5-mysql', u'php5', u'libapache2-mod-php5', u'php5-mcrypt', u'python-mysqldb'])
   
   TASK [Download WordPress] ******************************************************
   changed: [107.23.7.237]
   
   TASK [Remove old deployables] **************************************************
    [WARNING]: Consider using 'become', 'become_method', and 'become_user' rather
   than running sudo
   
   changed: [107.23.7.237]
   
   TASK [Extract WordPress] *******************************************************
   changed: [107.23.7.237]
   
   TASK [Update default Apache site] **********************************************
   changed: [107.23.7.237]
   
   TASK [Copy sample config file] *************************************************
   changed: [107.23.7.237]
   
   TASK [Update WordPress DB Name  in config file] ********************************
   changed: [107.23.7.237]
   
   TASK [Update WordPress DB User  in config file] ********************************
   changed: [107.23.7.237]
   
   TASK [Update WordPress DB Password  in config file] ****************************
   changed: [107.23.7.237]
   
   TASK [Update WordPress DB Host  in config file] ********************************
   changed: [107.23.7.237]
   
   RUNNING HANDLER [restart apache] ***********************************************
   changed: [107.23.7.237]
   
   PLAY RECAP *********************************************************************
   107.23.7.237               : ok=13   changed=11   unreachable=0    failed=0
   
   root@ip-10-96-2-5:/opt/wordpress-setup-ansible#

11. You are good to access wordpress site. Open browser and hit http://<EC2_Web_server_Public_IP>/wp-admin

12. You will see Install wordpress page. Procced with setup as shown on ScreenShot document.

