OpenVPN-Setup
============

About
-----

Shell script to set up Raspberry Pi (TM) as a VPN server using the free, open-source
OpenVPN software. Includes templates of the necessary configuration files for easy
editing, as well as a script for easily generating client .ovpn profiles after
setting up the server.

To follow this guide, you will need to have a Raspberry Pi Model B or later (so long
as it has an ethernet port), an SD or microSD card (depending on the model) with
Raspbian installed, a power adapter appropriate to the power needs of your model,
and an ethernet cable to connect your Pi to your router or gateway. You will also
need to have your router assign a static IP address to your Pi and forward port 1194;
consult your router manufacturer's documentation to do this. You should also find
your Pi's local IP address on your network and the public IP address of your network
and write them down before beginning. Enabling SSH on your Pi is also highly
recommended, so that you can run a very compact headless server without a monitor or
keyboard.

Server-Side Setup
-----------------

You can download the OpenVPN setup script directly through the terminal or SSH using
Git. If you don't already have it, update your APT repositories and install it:

```shell
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git
```

Then download the latest setup script with:

```shell
cd
git clone --depth=1 git://github.com/StarshipEngineer/OpenVPN-Setup.git
```

Execute the script with:

```shell
cd OpenVPN-Setup
chmod +x openvpnsetup.sh
sudo ./openvpnsetup.sh
```

The script will first update your APT repositories, upgrade packages, and install OpenVPN,
which will take some time. It will then prompt you for input in several identifying information
fields as it generates your certificate authority and server certificate; you can ignore most
of these and hit 'enter' to skip them if you don't care to fill them out. Make sure to skip the
challenge field and leave it blank. However, after this, you will be asked whether you want to
sign the certificate; you must press 'y'. You'll also be asked if you want to commit - press 'y'
again. After this, the script will take a few minutes to build the server's Diffie-Hellman key
exchange. After this is complete, the script will then prompt you to enter the local IP address
of your Raspberry Pi on your network, and then the public IP address of your network. When the
script informs you that it has finished configuring OpenVPN, reboot the system and the VPN
server-side setup will be complete!

Making Client Profiles
----------------------

After the server-side setup is finished and the machine rebooted, you will use the MakeOVPN script
to generate the .ovpn profiles you will import on each of your client machines. To generate your
first client profile, execute the script with:

```shell
cd OpenVPN-Setup
chmod +x MakeOVPN.sh
./MakeOVPN.sh
```

You will be prompted to enter a name for your client. Pick anything you like and hit 'enter'. 
You will be asked to enter a pass phrase for the client key - you'll be asked twice, so you won't
accidentally mess it up, but make sure it's one you'll remember! You'll then be prompted for
input in another series of identification fields, which you can again ignore if you like; make
sure you again leave the challenge field blank. The script will then ask again whether you want
to sign the client certificate and commit; press 'y' for both. You'll then be asked to enter the
pass phrase you just entered in order to encrypt the client key, and immediately after to choose
another pass phrase for the encrypted key - if you're normal, just use the same one. After this,
the script will assemble the client .ovpn file and place it in your home directory to make it easy
to access using SFTP or SCP, which you'll need to do to move the profile to your client machine.

To generate additional client .ovpn profiles for other devices you'd like to connect to the VPN,
simply cd into OpenVPN-Setup, execute the MakeOVPN script, and repeat the above steps for each
client:

```shell
cd OpenVPN-Setup
./MakeOVPN.sh
```

Importing .ovpn Profiles on Client Machines
--------------------------------------------

To move a client .ovpn profile to Windows, use a program like WinSCP or Cyberduck. Note that
you may need administrator permission to move files to some folders on your Windows machine,
so if you have trouble transferring the profile to a particular folder, try moving it to your
desktop. To move a profile to Android, you can either retrieve it on PC and then move
it to your device via USB, or you can use an app like Turbo FTP & SFTP client to retrieve it
directly from your Android device.

To import the profile on Windows, download the OpenVPN GUI from the community downloads section
of openvpn.net, install it, and place the profile in the 'config' folder of your OpenVPN directory,
i.e., in 'C:\Program Files\OpenVPN\config'. To import the profile on Android, install the OpenVPN
Connect app, select 'Import' from the drop-down menu in the upper right corner of the main screen,
choose the directory on your device where you stored the .ovpn file, and select the file.

After importing, connect to the VPN server on Windows by running the OpenVPN GUI with
administrator permissions, right-clicking on the icon in the system tray, and clicking 'Connect',
or on Android by selecting the profile under 'OpenVPN Profile' and pressing 'Connect'. You'll be
asked to enter the pass phrase you chose. Do so, and you're in! Enjoy your ~$50 USD private VPN.

Thanks
------

This script automates and streamlines the process outlined by a great many people from many corners
of the internet for setting up OpenVPN on a Raspberry Pi. In particular, it is based on the steps
outlined by Lauren Orsini at readwrite.com in her excellent two-part tutorial, Building A Raspberry
Pi VPN, and many thanks go to her for bringing together the steps of the setup process
in a way that even I could understand. Thanks also go to the Raspberry Pi Foundation for the
awesome Raspberry Pi, and to OpenVPN and their fantastic open-source community.
