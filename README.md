# Gemalto DPOD Automation Examples

See slides at XXXX.

## Setup and Running

0. Clone this gihub repository:

    git clone https://github.com/cloudsoft/gemalto-dpod-examples.git

1. Customize the endpoints for your own environment:

   a. Modify `docker/amp/etc/brooklyn.cfg` to set the URIs, username and password
      for your DPOD login.

   b. Modify `docker-compose.yaml` to set the URIs for your DPOD login 
      (i.e. environment variables `UAA_URL` and `API_URL`).

   c. Add to `docker/amp/ssh/` any ssh keys that you will need later.

      i.  (Optional) See 5a for creating a location, such as AWS which uses a keypair .pem file.

      ii. (Optional) Replace the id_rsa files, which are used when setting up a user on a newly provisioned VM.

           ssh-keygen -t rsa -N "" -f docker/amp/ssh/id_rsa

2. Launch the DPOD UI+AMP automation local server:

    docker-compose up -d

   Other useful commands include:

    # List the containers
    docker ps

    # View the logs from the containers
    docker-compose logs | less

    # Shutdown the containers
    docker-compose down

3. Go to the DPOD web-console (i.e. http://localhost:8080/).

   You will be redirected to the login page; once you login, you will be redirected back to localhost:8080.

4. Open Cloudsoft AMP (e.g. if the above setup is used, with http://localhost:8081 with admin:password).

   Wait for Cloudsoft AMP to start up (i.e. as reported in the AMP web-console).

5. Populate the Cloudsoft AMP catalog:

   a. Download the `br` command line tool.

      FIXME: add instructions.

   b. (Optional) You can deploy to a public or private cloud. Create a *location* with details of that cloud.

      For detailed instructions, see https://docs.cloudsoft.io/locations/
      
      As an example, see `samples/location.bom`. You can modify this to add your Cloud credentials,
      and a reference to your AWS keypair file (see 1.c.i). Other clouds, including GCE and Azure, are also 
      supported.

      To add this location the the catalog, run:

          br login http://localhost:8081 admin password
          br catalog add samples/location.bom

   c. Add the DPOD application building blocks to the Cloudsoft AMP catalog:

          br catalog add http://hackathon:rightPonyCellPaperclip@developers-origin.cloudsoftcorp.com/gemalto-hackathon/dpod-1.1.0-SNAPSHOT.jar


6. (Optional) Test the above location by deploying a simple app, which provisions a VM:

   Create a file (e.g. samples/vanilla-server.yaml) containing:
    
    location: hackathon-cloud
    services:
      - type: server

   Deploy this app:

    br deploy samples/simple-server.yaml

   If you prefer to use the graphical web-console rather than the CLI, you can use the Blueprint Composer
   to write such blueprints graphically. For more information, see 
   https://docs.cloudsoft.io/tutorials/tutorial-3-ui-3tier.html

7. Add the jar-signing demo to the Cloudsoft AMP catalog:

    br catalog add dpod-jar-signer/

   This command bundles up the contents of the directory, and adds it to the Cloudsoft AMP catalog.

8. Go back to DPOD web-console (http://localhost:8080/) and refresh the page.

   You should now see a new marketplace tile for the "DPOD Jar Signer".

9. Deploy this service:

   a. Click on the tile, and fill out the options:

      FIXME: describe the options.

10. Once deployed, see JAR Signer Service VM info back in DPOD

11. (Optional) Watch the progess in Cloudsoft AMP.

    a. See the activity in the "App Inspector" view, by clicking on the entity in the tree, and selecting the 'Activities' tab.

    b. Debug any problems by clicking on the failed activity in the 'kilt diagram', in the activity view.

    c. View the AMP log file by running `docker-compose logs | less`.

