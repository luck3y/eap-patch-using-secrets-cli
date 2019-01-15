EAP S2I One-off Patch Example using the embedded-cli:
===============

Note, this example illustrates a means to apply a one-off patch to EAP, for more complicated patching, the source image should be built with the patches already applied.

Basic instuctions: 

- Create a Secret that contains the patch:

  ```$ oc create secret generic jbeap-16108 --from-file=jbeap-16108.zip=jbeap-16108.zip```

- Update extensions/patch.cli to install the required patch.
   - for multiple patches, seperate .cli files for each patch application could be created, and applied in any required order from extensions/postconfigure.sh

- The project should have a .s2i/environment with the following contents:
    
    ```CUSTOM_INSTALL_DIRECTORIES=extensions```
  
  (Alternatively, this may be provided to oc new-app with -e CUSTOM_INSTALL_DIRECTORIES, but easy to forget :) )

- The application template or existing deployment config may now be modified to mount the secret containing the patch and the application rebuilt, see: https://github.com/luck3y/hello-world-war/blob/patching/eap71-basic-s2i-patching.json#L344 and https://github.com/luck3y/hello-world-war/blob/patching/eap71-basic-s2i-patching.json#L433 for the required mount configuration. 

- The volume name should match the secret created in the initial Secret creation (jbeap-16108.zip, in this example.) 

- install / replace the template: 
   ``` $ oc -n openshift replace --force -f eap71-basic-s2i-patching.json ```

- create / recreate the application:
     ``` $ oc new-app --template=eap71-basic-s2i-patching \
       -p SOURCE_REPOSITORY_URL="https://github.com/luck3y/hello-world-war.git" \
       -p SOURCE_REPOSITORY_REF="master" \
       -p CONTEXT_DIR="" \
       -p APPLICATION_NAME="eap-patching-demo" ```
- Alternativly, the deployment controller configurtion can be modified to add the required volumes. Modification of the deployment controller is similar to the template configuration changes (use ```oc edit dc/eap-app-name```, or edit the yaml in the OpenShift console).

- When the server boots, you should see something similar to:
    > 03:19:08,195 INFO  [org.jboss.as.patching] (MSC service thread 1-2) WFLYPAT0050: JBoss EAP cumulative patch ID is: jboss-eap-7.1.5.CP, one-off patches include: eap-715-jbeap-16108
