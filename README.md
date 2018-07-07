# Gemalto DPOD Automation Examples

## Contents

* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Before the Hackathon](#before-the-hackathon)
* [Setup and Running](#setup-and-running)
* [Customizing the Automation](#customizing-the-automation)
* [Other Docker Commands](#other-docker-commands)
* [Cloudsoft AMP: Under the Covers](#cloudsoft-amp-under-the-covers)


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

These steps will involve us working with several different machines:
* Local machine, for working on the code and running Docker.
* Docker containers, for running the DPOD UI and Cloudsoft AMP.
* A VM in the cloud, which we will set up to use DPOD.


## Prerequisites

1. DPOD credentials, and URL, for an "application owner" account.

   The oauth url is where you are redirected to in your browser when logging into the DPOD web-console.

   For example:
   * https://cloudsoft.market.staging-dpondemand.io
   * https://cloudsoft.uaa.system.mayfly.dpsas.io

   The DPOD oath endpoint configured to whitelist redirect back to localhost:8080 (this is for 'dev mode',
   where we can use a custom local marketplace UI).

2. [Docker](https://www.docker.com/community-edition#/download) installed and ready to use.
   This could be on your laptop, or on a remote machine.

   If using a remote machine, you will require:

    * ssh access (to run the docker commands, etc)
    * access to TCP ports 8080 and 8081.

3. [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed locally.

4. A github account, for sharing private repos with you.

5. Ability to provision a VM (in a cloud of your choice), or ssh access to a pre-existing machine
   on which automated commands can be run.

   This machine will require outbound internet access, to DPOD and to install additional packages
   as necessary.


## Before the Hackathon

There are several steps you can do ahead of the hackathon, which can save a lot
of time (e.g. waiting for downloads).

1. Ensure the [prerequisites](https://github.com/cloudsoft/gemalto-dpod-examples#prerequisites)
  are met.

2. Download the docker images:

   ```bash
   docker login -u _json_key --password-stdin https://eu.gcr.io < docker/creds/gemalto-hackathon-603254e71c34.json
   docker pull eu.gcr.io/gemalto-hackathon/cloudsoft/amp:latest
   docker pull eu.gcr.io/gemalto-hackathon/cloudsoft/dpod-ui:latest
   ```

3. Download and install the Cloudsoft AMP command line tool (named `br` - the name
   comes from Apache Brooklyn, on which AMP is built).

   1. Download from http://developers-origin.cloudsoftcorp.com/amp-cli/5.2.0/

   2. Make the file executable, and add it to your path. For example:

      ```bash
      chmod u+x br
      mkdir ~/bin/
      mv br ~/bin/
      echo "export PATH=$PATH:~/bin/" >> ~/.bashrc
      source ~/.bashrc
      ```


## Setup and Running

0. Clone this gihub repository:

   ```bash
   git clone https://github.com/cloudsoft/gemalto-dpod-examples.git
   cd gemalto-dpod-examples
   ```

   (All paths used in these steps are relative to the root directory of this repo.)

1. Customize the endpoints for your own environment.

   (These configuration values will subsequently be used _inside_ the docker containers,
   by a combination of passing environment variables, and mounting files/directories from
   your local disk into the container).

   (The text to be replaced in the configuration files uses placeholder 'xxxxxxxx'.)

   1. Modify `docker-compose.yaml` to set the URIs for your DPOD login
      (i.e. environment variables `UAA_URL` and `API_URL`).

   2. Modify `docker/amp/etc/brooklyn.cfg` to set the URIs, username and password
      for your DPOD login (using the 'application owner' account).

   3. (Optional) Add to `docker/amp/ssh/` any ssh keys that you will need later.

      1. (Optional) See 5.4 for creating a location, such as AWS which uses a keypair .pem file.

      2. (Optional) Replace the id_rsa files, which are used when setting up a user on a newly provisioned VM.
         If you skip this step, the default id_rsa key from this repo will be used.

         ```bash
         ssh-keygen -t rsa -N "" -f docker/amp/ssh/id_rsa
         ```

2. Launch the local docker containers for the DPOD UI, and for Cloudsoft AMP automation server:

   1. First you'll need to set up credentials to access the Docker Repository:

      ```bash
      docker login -u _json_key --password-stdin https://eu.gcr.io < docker/creds/gemalto-hackathon-603254e71c34.json
      ```

   2. Then use [Docker Compose](https://docs.docker.com/compose/) to run the
      multi-container application:

      ```bash
      docker-compose up -d
      ```

3. Go to the DPOD web-console (i.e. http://localhost:8080/).

   You will be redirected to the login page; once you login, you will be redirected back to localhost:8080.

4. Open Cloudsoft AMP (e.g. if the above setup is used, this will be http://localhost:8081
   with credentials 'admin' and 'password').

   Wait for Cloudsoft AMP to start up (i.e. as reported in the AMP web-console).

5. Populate the Cloudsoft AMP catalog:

   1. Download and install the Cloudsoft AMP command line tool (named `br` - the name
      comes from Apache Brooklyn, on which AMP is built).

      1. Download from http://developers-origin.cloudsoftcorp.com/amp-cli/5.2.0/

      2. Make the file executable, and add it to your path. For example:

         ```bash
         chmod u+x br
         mkdir ~/bin/
         mv br ~/bin/
         echo "export PATH=$PATH:~/bin/" >> ~/.bashrc
         source ~/.bashrc
         ```
   2. Use `br` to login to the Cloudsoft AMP server:

      ```bash
      br login http://localhost:8081 admin password
      ```

   3. Add the DPOD application building blocks to the Cloudsoft AMP catalog:

      ```bash
      br catalog add http://hackathon:rightPonyCellPaperclip@developers-origin.cloudsoftcorp.com/gemalto-hackathon/dpod-1.1.0-SNAPSHOT.jar
      ```

   4. (Optional) You can deploy to a public or private cloud (or alternatively skip this step,
      and use a pre-existing target machine).

      Create a *location* with details of that cloud. For detailed instructions and
      background information, see https://docs.cloudsoft.io/locations/.

      As an example, see [samples/location.bom](samples/location.bom) in your local copy
      of the repository. A wide range of clouds are supported, including AWS, GCE and Azure.
      You can modify this to add your Cloud credentials ('identity' is the AWS Access Key id,
      and 'credential' is the secret key), the name of the AWS keypair to use, and a reference
      to your AWS keypair file (see 1.3.1).

      To add this location to the catalog, run:

      ```bash
      br catalog add samples/location.bom
      ```

6. Add the jar-signing demo to the Cloudsoft AMP catalog:

   ```bash
   br catalog add dpod-jar-signer/
   ```

   This command bundles up the contents of the directory and adds it to the Cloudsoft AMP catalog.

7. Go back to DPOD web-console (http://localhost:8080/) and refresh the page.

   You should now see a new marketplace tile for the "DPOD Jar Signer".

8. Deploy this service by clicking on the tile, and filling out the options:

   * _Service Name_: the name you want to give your service, being created in DPOD.
   * _Target Environment_: whether provisioning a new Cloud VM, or configuring an existing server.
   * If using an existing server:
     * _Connection Type_: ssh key or password
     * _Host_: hostname or IP
     * _User_: username to use when ssh'ing
     * _Private key_: ssh private key to use when ssh'ing
     * _Password_: password to use when ssh'ing
   * If provisioning automatically in a cloud:
     * _Location_: the location id within Cloudsoft AMP, such as 'hackathon-cloud' (see step 5.4)
   * _Service Type_: the type of DPOD service (e.g. 'digital_signing', 'tde_database', etc)
   * _Initialize_: whether to create a new partition (true/false)
   * _Partition Label_: any label (minimum length 4 characters)
   * _Partition Domain_: your choice of domain name (minimum length 4 characters)
   * _Security Officer password_: (minimum 10 characters)
   * _Crypto Officer Password_: (minimum 10 characters)

    Once deployed, refresh the page to see the service, and to see
    the JAR Signer Service VM address (once available).

9. (Optional) Watch the progress in Cloudsoft AMP.

   Click on the 'App Inspector' tile (or choose it from the top-right dropdown) to
   then see a list of apps. Click on you app in the list, and expand it to see its
   structure. Select the 'Activities' tab to see the tasks being executed.

   To investigate problems, see the [Troubleshooting](#troubleshooting) section.


## Customizing the Automation

The [Setup and Running](#setup-and-running) steps above used the "DPOD Jar Signer" as an example.
You can use this example as a starting point for your use-case.

The file structure is:
```
catalog.bom
custom-server.bom
scripts/launch.sh
scripts/sign-jar.sh
scripts/install.sh
scripts/checkRunning.sh
icons/gemalto-padlock.png
```

Let's start with the scripts. These are executed when setting up the VM in the
cloud. You can replace these scripts with your own commands.

There is a 'blueprint' that defines how and when these scripts should be executed.
The `custom-server.bom` file is a Cloudsoft AMP blueprint. It's basic structure is:
* starts with `brooklyn.catalog`, because it is defining an item to be added to the
  catalog rather than a blueprint being used to provisioning machines immediately.
* contains metadata about the catalog item.
* defines the actual catalog item: its type and its configuration.

However, `custom-server.bom` assumes that the DPOD Luna Client has already been installed.
This is the job of the main `catalog.bom`. Here is a brief overview of its structure:
* You'll see at the very end of that file, there is a reference to `jar-signer-server`
  (which is the catalog item id declared in `custom-server.bom`).
* The file also references `gemalto-dpod-client`, which has the code to install the
  DPOD Luna Client.
* Both of these are 'children' of a `SameServerEntity`. This is the entity that will
  cause the VM to be provisioned (where it provisions the VM is not declared here;
  that will depend on which location is used during the actual deployment).
* The `dpod-service` entity makes the REST api calls to create the DPOD partition.
  To do that, it needs to be configured with an access token.
* The `dpod-token-manager` entity does the oauth authentication to get the access
  token.


## Other Docker Commands

Other useful docker commands include:

```bash
# List the running containers
docker ps

# View the logs from the containers
docker-compose logs | less

# Shutdown the containers, which were launched by docker-compose
docker-compose down
```


## Cloudsoft AMP: Under the Covers

### Apache Brooklyn

Cloudsoft AMP is built on the open source project Apache Brooklyn.

Blueprints written in Cloudsoft AMP can also be run in Apache Brooklyn (though
some blueprints rely on other catalog items that are shipped with Cloudsoft AMP but
are not in Brooklyn).

Useful links include:
* [Apache Brooklyn](https://brooklyn.apache.org/)
* [Cloudsoft AMP](https://cloudsoft.io/platform/amp/)
* [Cloudsoft AMP docs](https://docs.cloudsoft.io/)


### Web Console

Cloudsoft AMP has a web-console (e.g. at http://localhost:8081). This has a number
of modules (shown as tiles on the welcome page). The main two we will focus on are
the 'App Inspector' to view your apps, and the 'Blueprint Composer' to write new
graphical blueprints.

#### App Inspector

Click on the 'App Inspector' tile (or the top-right dropdown) to see a list of apps.
Click on you app in the list, and expand it to see its structure. The tabs give more
detail for the selected entity, including:

* 'Sensors' for metrics about the entity.
* 'Effectors' to invoke operations on the entity.
* 'Activities' to see task details.

The 'kilt diagram' in the 'Activities' view gives a visual representation of the
hierarchy and sequence of tasks being that are executed. Failed tasks are coloured
bright red. Click on a failed task to drill into its details.

#### Blueprint Composer

Click on the 'Blueprint Composer' tile (or the top-right dropdown) to graphically create
a new blueprint.

For more information, see https://docs.cloudsoft.io/tutorials/tutorial-3-ui-3tier.html


### Catalog

When we run the command `br catalog add dpod-jar-signer/`, it bundles up the contents
of the directory and pushes it to the Cloudsoft AMP catalog. By convention, it will look
for a `catalog.bom` at the root of the bundle, and all its items (including other
`.bom` files that it links to).

Catalog items can have tags. Here we use a special tag 'gemalto-dpod-tile'. When
the DPOD marketplace is being populated, it queries Cloudsoft AMP (using its
REST api, and filters for only those catalog items with this tag).

Catalog bundles and items are versioned. However, if the version suffix ends in
'snapshot', then you can overwrite it (without requiring the 'force' parameter).


### Deploying Applications

So far, we have just talked about adding things to the catalog.

One can deploy a blueprint, saying which catalog item(s) to deploy and
which location(s) to deploy to.

There is a simple example of a blueprint in your local copy of the repository:
[samples/vanilla-server.yaml](samples/vanilla-server.yaml).

```yaml
location: hackathon-cloud
services:
  - type: server
```

You can deploy this app by running:

```bash
br deploy samples/vanilla-server.yaml
```

When you use the marketplace tile to deploy, it automatically creates a YAML file
(following the same principles as the simple example above), and sends a POST request
to the Cloudsoft AMP rest API, which deploys that app.

An example of the auto-generated YAML from the marketplace tile is at
[samples/app-jar-signer.yaml](samples/app-jar-signer.yaml). You can also deploy this
directly to your AMP server:

```bash
br deploy samples/app-jar-signer.yaml
```


### Locations

Locations (see [docs](https://docs.cloudsoft.io/locations/)) are the environments
to which AMP deploys applications. If using a cloud, you'll need to provide your
cloud credentials. You should also specify the instance type you want
(i.e. size of VM), and the choice of VM image.


### Cloudsoft AMP Glossary

There is a [glossary](https://docs.cloudsoft.io/start/concept-quickstart.html)
in the main Cloudsoft AMP docs.


### Troubleshooting

For more troubleshooting advice, see the
[Troubleshooting section of the AMP docs](https://docs.cloudsoft.io/operations/troubleshooting/).
A few pointers are also given below.


#### AMP Logs

View the AMP log file in `docker/amp/log/` (this directory on your local machine
is mounted in the AMP container).
