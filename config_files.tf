locals {
  iq_cloud_config    = <<CLOUD
#cloud-config
# Creates sdm user
groups:
  - ${var.sybase_iq_linux_usergroup}
users:
  - default
  - name: ${var.sybase_iq_linux_username}
    ssh_authorized_keys:
    - ${var.sybase_iq_ssh_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
    primary_group: ${var.sybase_iq_linux_usergroup}
# Install unzip
package_update: true
packages:
- unzip
- libaio
- ksh
- csh
write_files:
- content: |
${local.iq_response_file}
  path: /opt/sybase/response_file.txt
- content: |
${local.iq_userdata}
  path: /opt/sybase/sybase_setup.sh
  permissions: '0664'
runcmd:
- [ "/bin/bash", "/opt/sybase/sybase_setup.sh" ]
CLOUD

#################
# The 4 spaces are an intentional part of the Cloud Init formatting. 
#################
#################
# This is essentially the user_data script, but due to cloud init limitations it is being loaded as a file and run as a local script.
#################
  iq_userdata        = <<NOTES
    #!/bin/bash -xv

    # install AWS CLI to download file from S3
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    # Set Sybase User as owner of directory
    chmod u+x /opt/sybase
    chown -R ${var.sybase_iq_linux_username}:${var.sybase_iq_linux_usergroup} /opt/sybase

    # Download and expand Sybase IQ 16 
    cd /opt/sybase
    /usr/local/bin/aws s3 cp ${var.sybase_iq_s3_link} .
    tar zxvf ${ split("/", var.sybase_iq_s3_link)[length(split("/", var.sybase_iq_s3_link)) - 1] }

    echo "kernel.shmmax = 300000000" >> /etc/sysctl.conf
    /sbin/sysctl -p

    # if no response file create manually
    # ./Linux64-iq16*_eval/setup.bin -i console -r response_file.txt 

    # install Sybase IQ
    echo "start Sybase IQ install: this may take a while..."
    ./Linux64-iq16*_eval/setup.bin -f /opt/sybase/response_file.txt -i silent 
    chown -R ${var.sybase_iq_linux_username}:${var.sybase_iq_linux_usergroup} ${var.sybase_iq_install_path}

    # start Sybase IQ demo server 
    source ${var.sybase_iq_install_path}/SYBASE.sh
    source ${var.sybase_iq_install_path}/IQ.sh
    cd $IQDIR16/demo
    ./mkiqdemo.sh -dba ${var.sybase_iq_db_admin} -pwd ${random_password.sybase_iq.result} -port ${var.sybase_iq_port}  -y
    start_iq @iqdemo.cfg iqdemo.db

NOTES
#################
# Any of the settings in this response file can be modified to adjust the Sybase IQ installation.
#################
  iq_response_file   = <<NOTES
    # Tue Jul 28 22:03:08 UTC 2020
    # Replay feature output
    # ---------------------
    # This file was built by the Replay feature of InstallAnywhere.
    # It contains variables that were set by Panels, Consoles or Custom Code.



    #Validate Response File
    #----------------------
    RUN_SILENT=true

    #Choose Install Folder
    #---------------------
    USER_INSTALL_DIR=${var.sybase_iq_install_path}

    #Install older version
    #---------------------

    #Choose Install Set
    #------------------
    CHOSEN_FEATURE_LIST=fiq_shared,fiq_server,fconn_add_lm,fiq_client_common,fiq_client_web,fiq_odbc,fiq_cfw,fiq_cmap,fiq_cockpit_agent,fjconnect70,fsysam_util
    CHOSEN_INSTALL_FEATURE_LIST=fiq_shared,fiq_server,fconn_add_lm,fiq_client_common,fiq_client_web,fiq_odbc,fiq_cfw,fiq_cmap,fiq_cockpit_agent,fjconnect70,fsysam_util
    CHOSEN_INSTALL_SET=Custom

    #Choose Product License Type
    #---------------------------
    SYBASE_PRODUCT_LICENSE_TYPE=evaluate

    #Install
    #-------
    -fileOverwrite_${var.sybase_iq_install_path}/sybuninstall/IQSuite/uninstall.lax=Yes

    #Cockpit - Configure HTTP/HTTPS Ports
    #------------------------------------
    CONFIG_COCKPIT_HTTP_PORT=4282
    CONFIG_COCKPIT_HTTPS_PORT=4283

    #Cockpit - Configure RMI Port
    #----------------------------
    COCKPIT_RMI_PORT_NUMBER=4992

    #Cockpit - Configure TDS Port
    #----------------------------
    COCKPIT_TDS_PORT_NUMBER=4998

    #Start Cockpit
    #-------------
    START_COCKPIT_SERVER=Yes

    #Agree to license
    #----------------
    AGREE_TO_SYBASE_LICENSE=true
    AGREE_TO_SAP_LICENSE=true
NOTES

  iq_troubleshooting = <<NOTES
Troubleshooting Notes
=====================
Setup guide
http://infocenter.sybase.com/help/topic/com.sybase.infocenter.dc10083.1604/doc/html/title.html

helpful commands
=====
source ${var.sybase_iq_install_path}/SYBASE.sh
source ${var.sybase_iq_install_path}/IQ.sh
NOTES
}