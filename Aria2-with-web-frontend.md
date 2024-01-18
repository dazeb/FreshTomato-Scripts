# Aria2 with Web Front-end Installation Guide on FreshTomato

This guide will walk you through the installation of Aria2 and its web front-ends (webui-aria2 or AriaNG) on a router running FreshTomato firmware.

## 1. Prepare a Partition for Entware

You will need a HDD box or USB Flash drive to install Entware. A minimum of 512 MB is required for the Entware partition. The rest of the storage can be used for data.

### SSH into your router:

```bash
df -h
fdisk -l
```

**Note:** If your HDD already contains data, you will need to resize the partition to create space for Entware. I recommend using [MiniTool Partition Wizard Free 12.1](https://cdn2.minitool.com/?p=pw&e=pw-free) and formatting it as NTFS.

### Enable the following settings in the FreshTomato web interface:

- Administration -> Scripts
- USB and NAS -> USB Support

### Unmount the HDD box from the web interface and format the Entware partition:

```bash
mkfs.ext3 -L ENTWARE /dev/sda1
```

Then mount the partition and save the settings. If it does not work, reboot your router.

## 2. Install Entware

SSH into your router and check the kernel version:

```bash
uname -a
```

Navigate to the [Entware binaries website](http://bin.entware.net/) and select the appropriate subfolder for your hardware type and kernel version.

### Install Entware using the following commands:

```bash
cd /opt
wget http://bin.entware.net/armv7sf-k2.6/installer/generic.sh
chmod +x generic.sh
./generic.sh
```

Verify the installation with `opkg --help`.

## 3. Install Aria2

```bash
opkg update
opkg install aria2
```

### Optional: Install additional tools

```bash
opkg install bash bind-dig binutils bzip2 coreutils-sha1sum coreutils-sort curl diffutils file gawk gdb hdparm less lsof objdump patch perl rsync sed strace tar tcpdump vim vim-runtime wget unzip unrar
```

Create a directory for downloads and modify the Aria2 configuration file:

```bash
mkdir /mnt/USB500GB/downloads
vi /opt/etc/aria2.conf
```

Change the following values:

- `dir=/mnt/USB500GB/downloads`
- `rpc-secret=Passw0rd`

Start or stop Aria2 with:

```bash
/opt/etc/init.d/S81aria2 start
/opt/etc/init.d/S81aria2 stop
```

## 4. Enable Web Server on FreshTomato

Enable the web server from the FreshTomato web interface:

- Web server -> Hginx & PHP

## 5. Install a Web Front-end for Aria2

Choose between AriaNG and webui-aria2 for the web front-end.

### Option 1: Install AriaNG

```bash
mkdir /opt/share/www
```

Download AriaNG to your PC from the [releases page](https://github.com/mayswind/AriaNg/releases), extract it, and upload all files to the `www` folder using WinSCP.

Access AriaNG from your browser:

```
http://<router-ip>:85/
```

### Option 2: Install webui-aria2

```bash
mkdir /opt/share/www
curl -SL https://github.com/rgnldo/knot-resolver-suricata/raw/master/aria2_ui.tar.gz | tar -zxC /opt/share/www
```

Access webui-aria2 from your browser:

```
http://<router-ip>:85/aria2
```

Configure the connection settings with your router's IP, port, and secret.

## 6. Enable SSL/TLS for RPC (Optional)

Enable HTTPS in the FreshTomato web interface:

- Administration -> Admin Access

Edit the Aria2 configuration to enable secure RPC:

```bash
vi /opt/etc/aria2.conf
```

Add the following lines:

```
rpc-certificate=/etc/cert.pem
rpc-private-key=/etc/key.pem
rpc-secure=true
```

Restart Aria2 to apply the changes:

```bash
/opt/etc/init.d/S81aria2 stop
/opt/etc/init.d/S81aria2 start
```

Access the web front-end using HTTPS:

```
https://<router-ip>:85/
```

Congratulations! Your connection to Aria2 is now encrypted.

---

**Bonus: Check Listening Ports**

```bash
netstat -tulpn | grep LISTEN
```

or

```bash
lsof -i -P -n | grep LISTEN
```

---

### Additional Resources

- [Tutorial - Aria2 - WebUI on AsusWRT-Merlin](https://www.snbforums.com/threads/aria2-webui-on-asuswrt-merlin.63290/)
- [How to install Entware on a router](http://www.giuseppeparrello.it/en/net_router_install_entware.php)
- [HOWTO: Install entware on Shibby TomatoUSB](https://gist.github.com/dferg/833aade513965d78b43d)
- [How to check if port is in use on Linux or Unix](https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/)

---

For automation, you can create bash scripts for steps that involve SSH commands, such as partitioning, formatting, installing Entware, and configuring Aria2. The web interface steps and file uploads would still need to be performed manually by the user.
