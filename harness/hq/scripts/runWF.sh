#!/bin/sh

fn_run_query () {
curl -s \
-H 'x-api-key: '$HARNESS_API_KEY \
-X POST \
-H 'Content-Type: application/json' \
--data @- \
'https://app.harness.io/gateway/api/graphql?accountId='$HARNESS_ACCOUNT_ID 
}

APPNAME="K8S"
WFNAME="helm-deploy"
SVCNAME=mychart

#appName="Basic"
#wfName="k8s-rolling"
SVCNAME="gs-spring-boot"

APP_ID=$(hq id/App.hql $APPNAME)
WF_ID=$(hq id/Workflow.hql $WFNAME $APP_ID)

cat <<_EOF_ | fn_run_query
{"query":"
  mutation(\$startExecution: StartExecutionInput\u0021){
    startExecution(input: \$startExecution){
      clientMutationId
      execution {
         notes
         status
         id
      }
   }
}",
 "variables":{
  "startExecution": {
    "notes": "Test GraphQL using runWF script",
    "executionType": "WORKFLOW",
    "applicationId": "$APP_ID",
    "entityId": "$WF_ID",
    "serviceInputs": {
      	"name": "$SVCNAME",
      "artifactValueInput": {
        "valueType": "BUILD_NUMBER",
        "buildNumber": {
          "buildNumber": "latest",
          "artifactSourceName": "my-jfrog-registry"
        }
      }
    },
    "variableInputs": [{
      "name": "Environment",
      "variableValue": {
        "type": "NAME",
        "value": "DEV"
      }
    },
      {
        "name": "InfraDefinition_KUBERNETES",
        "variableValue": {
          "type": "NAME",
          "value": "k3s-cluster2"
        }
      },
      {
        "name": "chartName",
        "variableValue": {
          "type": "NAME",
          "value": "$1"
        }
      },
      {
        "name": "Service",
        "variableValue": {
          "type": "NAME",
          "value": "$SVCNAME"
        }
      }
    ]
   }
  }
}
_EOF_
