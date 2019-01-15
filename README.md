EAP S2I patching example using jboss-cli.sh
============================================================

Note: this example illustrates a general method to apply a one-off patch to EAP, for more complicated patching, the source image should be built with patches already applied during the container build process.

Basic instructions: 

- Create a secret for each patch that will be applied:that contains the patch:

  ```$ oc create secret generic jbeap-16108 --from-file=jbeap-16108.zip=jbeap-16108.zip```

- Update extensions/patch-build.cli to install the required patch(es).

- The project should have a .s2i/environment with the following contents:
    
    ```CUSTOM_INSTALL_DIRECTORIES=extensions```
  
  (Alternatively, this may be provided to oc new-app with -e CUSTOM_INSTALL_DIRECTORIES, but this is easy to forget :) )

- The application template or existing build configuration may now be modified to refer to the secret(s) containing the patch(es) and then the application rebuilt, 
see: https://github.com/luck3y/eap-patch-using-secrets-cli/blob/master/eap71-basic-s2i-patching.json#L243 for the necessary build configuration change to refer to 
the secret during the build. This change may be made by editing and replacing the existing application template, or ``` $ oc edit bc/app-name ```. 

- install / replace the updated template:
    ``` 
    $ oc -n openshift replace --force -f eap71-basic-s2i-patching.json

- create / recreate the application:
     ```
     $ oc new-app --template=eap71-basic-s2i-patching \
       -p SOURCE_REPOSITORY_URL="https://github.com/luck3y/eap-patch-using-secrets-cli.git" \
       -p SOURCE_REPOSITORY_REF="master" \
       -p CONTEXT_DIR="" \
       -p APPLICATION_NAME="eap-patching-demo" 

- Alternatively, the build controller configuration can be modified to add the needed secret in a similar way (or edit the build config yaml the OpenShift console.)
    ```
    oc edit bc/eap-app-name

- At the end of s2i build a message may be observed indicating patching was successful: 
    ```
    Running /home/jboss/install.sh
  - echo 'Running /home/jboss/install.sh'
  - injected_dir=/tmp/src/extensions
  - cp -rf /tmp/src/extensions /opt/eap/extensions
  - echo 'Executing patch-build.cli'
  - /opt/eap/bin/jboss-cli.sh --file=/opt/eap/extensions/patch-build.cli
    Executing patch-build.cli
    {
      "outcome" : "success",
      "result" : {}
    }

- When the server pod is created a message similar to the following should be logged during boot:
    ``` 
        03:19:08,195 INFO  [org.jboss.as.patching] (MSC service thread 1-2) WFLYPAT0050: JBoss EAP cumulative patch ID is: jboss-eap-7.1.5.CP, one-off patches include: eap-715-jbeap-16108

#### Additional Notes

- As an alternative to using secrets, the patch file may be included in git / scm and referred to directly from install.sh, the patch would be available in the local extensions directory structure in the build pod.
- Curl and maven may also be using from install.sh to fetch the file containing the patch, so those could also be alternatives to using a secret.
