# Gemalto DPOD Automation Examples

## Introduction

This repo contains example automation code for setting up DPOD services, and instructions for how to
use them.

At a high-level, the steps are:

1. Modify the configuration files to use your credentials.
2. Run two docker containers.
3. Add your chosen DPOD automation to the Cloudsoft AMP catalog.
4. Use the DPOD marketplace web-console to provision your service.

If you want to write your own automation code, then step (3) will first involve modifying/extending
one of the examples.


## Prerequisites

1. DPOD credentials, and URL, for an "application owner" account.

   The oauth url is where you are redirected to in your browser when logging into the DPOD web-console.

   For example:
   * https://cloudsoft.market.staging-dpondemand.io
       https://cloudsoft.uaa.system.mayfly.dpsas.io

2. The DPOD oath endpoint configured to whitelist redirect back to localhost:8080 (this is for 'dev mode',
   where we can use a custom local marketplace UI).

3. Docker installed and ready to use. This could be on your laptop, or on a remote machine.

   If using a remote machine, you will require:

    * ssh access (to run the docker commands, etc)
    * access to TCP ports 8080 and 8081.

4. Ability to provision a VM (in a cloud of your choice), or ssh access to a pre-existing machine
   on which automated commands can be run.

   This machine will require outbound internet access, to DPOD and to install additional packages
   as necessary.


## Setup and Running

0. Clone this gihub repository:

    git clone https://github.com/cloudsoft/gemalto-dpod-examples.git

1. Customize the endpoints for your own environment:

   1. Modify `docker/amp/etc/brooklyn.cfg` to set the URIs, username and password
      for your DPOD login.

   2. Modify `docker-compose.yaml` to set the URIs for your DPOD login
      (i.e. environment variables `UAA_URL` and `API_URL`).

   3. (Optional) Add to `docker/amp/ssh/` any ssh keys that you will need later.

      1. (Optional) See 5.2 for creating a location, such as AWS which uses a keypair .pem file.

      2. (Optional) Replace the id_rsa files, which are used when setting up a user on a newly provisioned VM.

         ```bash
         ssh-keygen -t rsa -N "" -f docker/amp/ssh/id_rsa
         ```

2. Launch the local docker containers for the DPOD UI, and for Cloudsoft AMP automation server:

   ```bash
   docker-compose up -d
   ```

   Other useful commands include:

   ```bash
   # List the containers
   docker ps

   # View the logs from the containers
   docker-compose logs | less

   # Shutdown the containers
   docker-compose down
   ```

3. Go to the DPOD web-console (i.e. http://localhost:8080/).

   You will be redirected to the login page; once you login, you will be redirected back to localhost:8080.

4. Open Cloudsoft AMP (e.g. if the above setup is used, this will be http://localhost:8081 with admin:password).

   Wait for Cloudsoft AMP to start up (i.e. as reported in the AMP web-console).

5. Populate the Cloudsoft AMP catalog:

   1. Download the `br` command line tool.

      FIXME: add instructions.

      ```bash
      br login http://localhost:8081 admin password
      ```

   2. (Optional) You can deploy to a public or private cloud. Create a *location* with details of that cloud.

      For detailed instructions, see https://docs.cloudsoft.io/locations/

      As an example, see `samples/location.bom`. You can modify this to add your Cloud credentials,
      and a reference to your AWS keypair file (see 1.3.1). Other clouds, including GCE and Azure, are also
      supported.

      To add this location to the catalog, run:

      ```bash
      br catalog add samples/location.bom
      ```

   3. Add the DPOD application building blocks to the Cloudsoft AMP catalog:

      ```bash
      br catalog add http://hackathon:rightPonyCellPaperclip@developers-origin.cloudsoftcorp.com/gemalto-hackathon/dpod-1.1.0-SNAPSHOT.jar
      ```

6. (Optional) Test the above location by deploying a simple app, which provisions a VM:

   Create a file (e.g. samples/vanilla-server.yaml) containing:

   ```yaml
   location: hackathon-cloud
   services:
     - type: server
   ```

   Deploy this app:

   ```bash
   br deploy samples/vanilla-server.yaml
   ```

   If you prefer to use the graphical web-console rather than the CLI, you can use the Blueprint Composer
   to write such blueprints graphically. For more information, see
   https://docs.cloudsoft.io/tutorials/tutorial-3-ui-3tier.html

7. Add the jar-signing demo to the Cloudsoft AMP catalog:

   ```bash
   br catalog add dpod-jar-signer/
   ```

   This command bundles up the contents of the directory, and adds it to the Cloudsoft AMP catalog.

8. Go back to DPOD web-console (http://localhost:8080/) and refresh the page.

   You should now see a new marketplace tile for the "DPOD Jar Signer".

9. Deploy this service by clicking on the tile, and filling out the options:

   * _Service Name_: name of the app within Cloudsoft AMP.
   * _Target Environment_: whether provisioning a new Cloud VM, or configuring an existing server.
   * If using an existing server:
     * _Connection Type_: ssh key or password
     * _Host_: hostname or IP
     * _User_: username to use when ssh'ing
     * _Private key_: ssh private key to use when ssh'ing
     * _Password_: password to use when ssh'ing
   * If provisioning automatically in a cloud:
     * _Location_: the location id within Cloudsoft AMP (see step 5.2)
   * _Service Type_: the type of DPOD service (e.g. 'tde_database', 'digital_signing', etc)
   * _Initialize_: whether to create a new partition (true/false)
   * _Partition Label_
   * _Partition Domain_
   * _Security Officer password_
   * _Crypto Officer Password_

    Once deployed, refresh the page to see the service, and to see
    the JAR Signer Service VM info (once available).

11. (Optional) Watch the progress in Cloudsoft AMP.

    a. See the activity in the "App Inspector" view, by clicking on the entity in the tree, and selecting the 'Activities' tab.

    b. Debug any problems by clicking on the failed activity in the 'kilt diagram', in the activity view.

    c. View the AMP log file by running `docker-compose logs | less`.
