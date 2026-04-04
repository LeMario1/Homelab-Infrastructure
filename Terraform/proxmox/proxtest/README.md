This is meant to be a minimal working config to spin up a vm in proxmox. I can 
use it as a template or a reference for coming projects.

I declare a provider here in terraform.tf, and then define how to access the pve cluster in the provider block.

The config file is what actually defines the hardware and paramaters of the vm or 
the "resource." In this example we clone it from a cloud-init enabled vm template 
called "cloud-init-test." Ordinarily this should work on it's own but there is a 
bug that requires us to manually define the disk else it be left unnatached and 
unbootable.
