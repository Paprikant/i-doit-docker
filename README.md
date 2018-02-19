## i-doit image
This image is largely based on the official [install script](https://github.com/bheisig/i-doit-scripts/blob/master/idoit-install.sh). It contains all necessary software to run i-doit, including a mariadb database instance.

Therefore it closely resembles a standalone installation on ubuntu:16.04

# How to use this image
The most basic case is to just run an instance of i-doit for test or trial purposes. You can do this by using the following command:
```bash
docker run -p 80:80 -d paprikant/i-doit:open-1.10
```
If the container starts for the first time some setup has to be done. Its mainly the setup of the new i-doit instance. You can watch the process with
```bash
docker logs -f i-doit
```
After about a minute i-doit is reachable on http://localhost:80
Login with credentials admin:admin

# PRO vs OPEN
You may have noticed the tag "open-1.10" in the example. You want to use the open source edition of i-doit if you dont have a license. The pro version will bug you over the license on every click.

If you possess a license use the pro version (e.g. paprikant/i-doit:1.10) and [provide the license via the admin center](https://kb.i-doit.com/display/en/Install+License).

# Modify your i-doit
Most of your configuration is done via the webinterface. However there are some basic modifications you can do when deploying this image.
* MARIADB_SUPERUSER_PASSWORD

The default password is "password". Dont want the world to know your database root password? Change it using this environment variable.
* MARIADB_IDOIT_USERNAME and MARIADB_IDOIT_PASSWORD

This is the database user that i-doit will use. This account will only have permissions on i-doit tables. You can specify any username and password you want. Default is idoit:idoit

* IDOIT_TENANT

i-doit is a [multi tenant software](https://kb.i-doit.com/display/en/Multi-Tenants). The default tenant is created on setup. Set this to the name of your company or business unit 

* IDOIT_ADMINCENTER_PASSWORD

Password for the user that can manage the i-doit instance via the admincenter. Username is always admin. Default password is "admin".

**example:**
```bash
docker run --name i-doit -p 80:80 \
  -e MARIADB_SUPERUSER_PASSWORD=secret_password \
  -e MARIADB_IDOIT_USERNAME=idoit \
  -e MARIADB_IDOIT_PASSWORD=a_diffrent_password \
  -e IDOIT_TENANT=your_company \
  -e IDOIT_ADMINCENTER_PASSWORD=another_password \
  paprikant/i-doit:open-1.10 
```
