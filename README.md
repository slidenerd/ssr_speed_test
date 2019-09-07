# Fastest SSR Framework Benchmarks!

Hi! The goal of this repository is to find out which is the fastest SSR framework with Vue.js. 3 Frameworks have been tested in this repo. If you want to add another framework to this list, feel free to submit a PR or open an ISSUE. If you have any doubts, check out the .MD files in the root of this directory on GitHub.
 1. Plain Express Server with Webpack to render Vue components
 2. Vue SSR Native
 3. NuxtJS SSR

# Setup
- Best to run all tests on Virtual Box.
- Download and install Virtual Box
- Install Ubuntu Server 18.04 on Virtual Box.
- Select the option to enable SSH while installing Ubuntu Server.
- Update Ubuntu inside the server post installation by following instructions [HERE](https://askubuntu.com/questions/196768/how-to-install-updates-via-command-line/196777#196777)
- Reboot virtual box Ubuntu Server.
- Install nvm following instructions [HERE](https://github.com/nvm-sh/nvm)
- Run the command below to find out the latest version of stable node.js available in nvm
```
nvm ls-remote
nvm install v10.16.3 (if it is the latest version)
```
- Alternatively, you can directly install the latest stable version of node.js using the command below
```
nvm install --lts
```
- Now use the installed version as shown below
```
nvm use v10.16.3
or 
nvm use --lts
```
- Update npm for the current node.js version that you installed using the command below.
```
nvm install-latest-npm
```
- Open Virtual Box Settings and go to Network
- Set networking mode to Bridged Adapter, attached to en-1 Wifi Airport, allow all under advanced settings.
- Reboot virtual box Ubuntu Server.
- Check the status of the Uncomplicated FireWall with the command below.
```
sudo ufw status
```
- If this is the first time you are setting things up , status will be inactive.
- Allow ports 22, 80, 443, 9001, 9002, 9003 with the command below.
```
sudo ufw allow 22 80 443 9001 9002 9003
```
- Enable the firewall with the command below.
```
sudo ufw enable
```
- Inside the virtual machine, plain express server runs on port 8001, nuxt runs on port 3000 and vue ssr runs on port 8000.
- Modify the etc/hosts file to add a local domain name which will be used for NGINX configuration with the command below.
```
sudo vi /etc/hosts
```
- Add an entry there as shown below.
```
ssr.local 127.0.0.1
```
- Externally when accesed from outside the virtual box server, plain express will run on 9001, vue native ssr will run on 9002 and nuxt will run on 9003.
- Use the command below in the terminal of your Virtual Box Ubuntu Server to find the IP address of your Virtual Box Ubuntu Server which you can access from your HOST machine.
```
hostname -I
```
- For me it says 192.168.1.104.
- If using HTTPS on GitHub, clone the repo with the command below inside your home directory (cd $HOME if you dont know where that is...)
```
 git clone https://github.com/slidenerd/ssr_speed_test.git
 cd ssr_speed_test/
 ```
- We run each server one at a time to get accurate answers
- To run the express plain ssr server run the command below
```
cd test_plain_express_ssr/
npm i
npm run build && npm run start
```
- To test if this is working run the command below inside Virtual Box or from your Terminal connected to Virtual Box via SSH
```
curl http://127.0.0.1:8001/
```
- To run the vue ssr server go back to the root directory ssr_speed_test and run the command below
```
cd test_native_vue_ssr/
npm i
npm run build && npm run start
```
- To test if this is working run the command below inside Virtual Box or from your Terminal connected to Virtual Box via SSH
```
curl http://127.0.0.1:8000/
```
- To run the nuxt ssr server, go back to the root directory ssr_speed_test and run the command below
```
cd test_nuxt_ssr/
npm i
npm run build && npm run start
```
- To test if this is working run the command below inside Virtual Box or from your Terminal connected to Virtual Box via SSH
```
curl http://127.0.0.1:3000/
```
- In order to check if any of the packages are outdated, install node check updates from [HERE](https://www.npmjs.com/package/npm-check-updates)
- Go into any of our 3 servers root directory where package.json is present
- Run the command below to find all outdated packages
```
ncu
```
- If you are going to update, make a note of these versions just in case things dont work after updating
```
ncu -u
```
- Run the command above to update all dependencies to their latest version and test each curl request to check if we are still golden
- If you find any error, either try and fix it with stackoverflow or roll back to previous version which we noted earlier
- To make any of our servers accessible from outside Virtual Box through our host for example, we are going to setup NGINX as a reverse proxy
- Inside Virtual Box, run the command below to insall NGINX
```
sudo apt install nginx
```
- Check if NGINX is on by the running the command below after installation
```
sudo systemctl status nginx
```
- Now download this NGINX configuration https://nginxconfig.io/?0.domain=ssr.local&0.path=%2Fhome%2Fhexa%2Fssr_speed_test&0.document_root=%2Ftest_nuxt_ssr&0.redirect=false&0.https=false&0.php=false&0.proxy
- Note that we added ssr.local as a local domain name in the /etc/hosts file earlier
- Replace the configuration for /etc/nginx/sites-available/ssr.local.conf with the code below
'''
server {
        listen 9001;
        listen [::]:9001;

        server_name ssr.local;
        root /home/hexa/ssr_speed_test/test_plain_express_ssr;

        # security
        include nginxconfig.io/security.conf;

        # reverse proxy
        location / {
                proxy_pass http://127.0.0.1:8001;
                include nginxconfig.io/proxy.conf;
        }

        # additional config
        include nginxconfig.io/general.conf;
}

server {
        listen 9002;
        listen [::]:9002;

        server_name ssr.local
        root /home/hexa/ssr_speed_test/test_native_vue_ssr;

        #security
        include nginxconfig.io/security.conf;

        #reverse proxy
        location / {
                proxy_pass http://127.0.0.1:8000;
                include nginxconfig.io/proxy.conf;
        }

        # additional config
        include nginxconfig.io/general.conf;
}

server {
        listen 9003;
        listen [::]:9003;

        server_name ssr.local
        root /home/hexa/ssr_speed_test/test_nuxt_ssr;

        #security
        include nginxconfig.io/security.conf;

        #reverse proxy
        location / {
                proxy_pass http://127.0.0.1:8001;
                include nginxconfig.io/proxy.conf;
        }

        # additional config
        include nginxconfig.io/general.conf;
}
'''

http://www.bradlanders.com/2013/04/15/apache-bench-and-gnuplot-youre-probably-doing-it-wrong/

# Benchmarking Process
- We are using the apache bench tool to do all the benchmarks. Have a better tool in mind? Feel free to submit a PR or open an issue.
- It is preinstalled on OSX (host machine in my case), Type ab and see if you get an error
- If it is not installed, you may need to find out how to install it
- Below is a sample of how a test is done, we set concurrency to 1, number of requests to fire as 1000 and the option to not exit the test if we get any socket errors. Replace the IP address with yours
```
# for testing plain express ssr setup
ab -c 1 -n 1000 -r http://192.168.1.104:9001/

# for testing native vue ssr setup
ab -c 1 -n 1000 -r http://192.168.1.104:9002/

# for testing nuxt ssr setup
ab -c 1 -n 1000 -r http://192.168.1.104:9003/

```
- The full set of tests we do for plain express is given as per the commands below
```
# for testing plain express ssr setup with concurrency at 1 and 1000 requests
ab -c 1 -n 1000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 1 and 5000 requests
ab -c 1 -n 5000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 1 and 10000 requests
ab -c 1 -n 10000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 10 and 1000 requests
ab -c 10 -n 1000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 10 and 5000 requests
ab -c 10 -n 5000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 10 and 10000 requests
ab -c 10 -n 10000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 25 and 1000 requests
ab -c 25 -n 1000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 25 and 5000 requests
ab -c 25 -n 5000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 25 and 10000 requests
ab -c 25 -n 10000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 50 and 1000 requests
ab -c 50 -n 1000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 50 and 5000 requests
ab -c 50 -n 5000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 50 and 10000 requests
ab -c 50 -n 10000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 100 and 1000 requests
ab -c 100 -n 1000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 100 and 5000 requests
ab -c 100 -n 5000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 100 and 10000 requests
ab -c 100 -n 10000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 200 and 1000 requests
ab -c 200 -n 1000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 200 and 5000 requests
ab -c 200 -n 5000 -r http://192.168.1.104:9001/

# for testing plain express ssr setup with concurrency at 200 and 10000 requests
ab -c 200 -n 10000 -r http://192.168.1.104:9001/

```

# Results
- Check each of the benchmarks file in the apache benchmarks folder
- The tool used is Apache Bencharks 2.3 <$Revision: 1826891 $>
- Virtual Box Version 6.0.10 r132072 (Qt5.6.3)
- Host machine OSX High Sierra 10.13.6 (17G65)
- Virtual Machine version: Ubuntu 18.04 Bionic 10 GB HDD, 1GB RAM (default settings for everything except Network where we used Bridged Adapter)
- Did not enable Keep Alive for any of them (equal grounds for everyone)
