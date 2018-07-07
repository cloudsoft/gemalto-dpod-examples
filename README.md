# Gemalto DPOD Automation Examples

## Contents

* [Introduction](#introduction)
* [Prerequisites](#prerequisites)
* [Before the Hackathon](#before-the-hackathon)
* [Setup and Running](#setup-and-running)
* [Other Useful Commands](#other-useful-commands)
* [Customizing the Automation](#customizing-the-automation)
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
   docker login -u _json_key --password-stdin https://gcr.io < docker/creds/gemalto-hackathon-603254e71c34.json
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
   ```

1. Customize the endpoints for your own environment.

   (These configuration values will subsequent be used _inside_ the docker containers,
   by a combination of passing environment variables, and mounting files/directories from
   your local disk into the container).

   1. Modify `docker/amp/etc/brooklyn.cfg` to set the URIs, username and password
      for your DPOD login (using the 'application owner' account).

   2. Modify `docker-compose.yaml` to set the URIs for your DPOD login
      (i.e. environment variables `UAA_URL` and `API_URL`).

   3. (Optional) Add to `docker/amp/ssh/` any ssh keys that you will need later.

      1. (Optional) See 5.2 for creating a location, such as AWS which uses a keypair .pem file.

      2. (Optional) Replace the id_rsa files, which are used when setting up a user on a newly provisioned VM.
         If you skip this step, the default id_rsa key from this repo will be used.

         ```bash
         ssh-keygen -t rsa -N "" -f docker/amp/ssh/id_rsa
         ```

2. Launch the local docker containers for the DPOD UI, and for Cloudsoft AMP automation server:

   1. First you'll need to set up credentials to access the Docker Repository:

      ```bash
      docker login -u _json_key --password-stdin https://gcr.io < docker/creds/gemalto-hackathon-603254e71c34.json
      ```

   2. Then use [Docker Compose](https://docs.docker.com/compose/) to run the
      multi-container application:

      ```bash
      docker-compose up -d
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

   2. Add the DPOD application building blocks to the Cloudsoft AMP catalog:

      ```bash
      br catalog add http://hackathon:rightPonyCellPaperclip@developers-origin.cloudsoftcorp.com/gemalto-hackathon/dpod-1.1.0-SNAPSHOT.jar
      ```

   3. (Optional) You can deploy to a public or private cloud (or alternatively skip this step,
      and use a pre-existing target machine).

      Create a *location* with details of that cloud. For detailed instructions,
      see https://docs.cloudsoft.io/locations/

      As an example, see [samples/location.bom](samples/location.bom). You can modify this to add your Cloud credentials,
      the name of the AWS keypair to use, and a reference to your AWS keypair file (see 1.3.1). Other clouds, including
      GCE and Azure, are also supported.

      To add this location to the catalog, run:

      ```bash
      br catalog add samples/location.bom
      ```

6. (Optional) Test the above location by deploying a simple app, which provisions a VM:

   Create a file (e.g. [samples/vanilla-server.yaml](samples/vanilla-server.yaml)) containing:

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

   * _Service Name_: the name you want to give your service, being created in DPOD.
   * _Target Environment_: whether provisioning a new Cloud VM, or configuring an existing server.
   * If using an existing server:
     * _Connection Type_: ssh key or password
     * _Host_: hostname or IP
     * _User_: username to use when ssh'ing
     * _Private key_: ssh private key to use when ssh'ing
     * _Password_: password to use when ssh'ing
   * If provisioning automatically in a cloud:
     * _Location_: the location id within Cloudsoft AMP, such as 'hackathon-cloud' (see step 5.2)
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

    b. To investigate problems, see the [Troubleshooting](#troubleshooting) section.


## Other Useful Commands

Other useful docker commands include:

```bash
# List the running containers
docker ps

# View the logs from the containers
docker-compose logs | less

# Shutdown the containers, which were launched by docker-compose
docker-compose down
```


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

One can deploy a blueprint, which says which catalog item(s) to deploy and
which location(s) to deploy to.

There was an optional step of testing this (step 6 of the [Setup and Run](#setup-and-run)):

```yaml
location: hackathon-cloud
services:
  - type: server
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


### Cloudsoft AMP Glossary

There is a [glossary](https://docs.cloudsoft.io/start/concept-quickstart.html)
in the main Cloudsoft AMP docs.


### Troubleshooting

For more troubleshooting advice, see the
[Troubleshooting section of the AMP docs](https://docs.cloudsoft.io/operations/troubleshooting/).
A few pointers are also given below.

#### Web Console

The activity and state of each entity in the application can be viewed in the AMP
web console (e.g. at http://localhost:8081). Go to the "App Inspector", click on the
entity in the tree, and select the 'Activities' tab.

The 'kilt diagram' gives a visual representation of the hierarchy and sequence of
tasks being that are executed. Failed tasks are coloured bright red. Click on a
failed task to drill into its details.

#### AMP Logs

View the AMP log file in `docker/amp/log/` (this directory on your local machine
is mounted in the AMP container).
