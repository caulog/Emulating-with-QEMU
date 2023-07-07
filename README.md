# qemu-environment
## Install Vagrant
1. Check if vagrant is installed with `vagrant --version`
2. If vagrant is not installed, install it here: https://developer.hashicorp.com/vagrant/tutorials/getting-started/getting-started-install
3. Verify that vagrant has been installed with `vagrant --version`

## Pull the Vagrant Box
1. cd into the directory where you want the vagrant file to be (ex. `cd Research`)
2. Clone this repo into the directory with your vagrant file
   ```
   git clone https://github.com/caulog/qemu-environment.git
   ```
3. Run the `vagrant up` command in the directory with the Vagrantfile
4. Provision the file with `vagrant provision`

## After provisioning
1. Ssh into the VM `vagrant ssh`
2. cd into linux-envs directory `cd linux-envs`
3. Run `sudo qemu-system-aarch64 -M virt,mte=on -m 4096 -cpu max -drive format=raw,file=disk.img -nographic -append "root=/dev/vda2 net.ifaces=0 rootwait" -initrd initrd.img-6.0.0-6-arm64 -kernel vmlinuz-6.0.0-6-arm64` to enter qemu
4. Login with `root` and no password
5. Run MTE test program to ensure that qemu is working
   i. `nano test.c` to create a file for the test program
   b. Copy the program from the bottom of this page https://docs.kernel.org/arm64/memory-tagging-extension.html and paste it into test.c
   c. Compile it `gcc test.c -march=armv8.5-a+memtag`
   d. Run the program `./a.out` and if you see a Segmentation fault after " Expecting SIGSEGV " then MTE is working.  

