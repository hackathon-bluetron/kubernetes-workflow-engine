#!/bin/bash

#=====================================================================================#
#title           :init_acyclic_step_workflow.sh                                       #
#description     :This script will call the kubernetes worrkflow engine               #
#author		 :Pravat B                                                            #
#date            :20200905                                                            #
#version         :0.4                                                                 #
#usage		 :bash init_acyclic_step_workflow.sh -i <<name-of-file-to-process>>   #
#notes           :N/A                                                                 #
#bash_version    :4.1.5(1)-release                                                    #
#=====================================================================================#



while getopts "i:" opt
do
        case "$opt" in
                i | -input ) INPUT="$OPTARG" ;;
                ? | -help ) helpFunction ;;
        esac
done

helpFunction ()
{
        echo ""
        echo "Usage: $0 -i <<name-of-file-to-process>>"
        exit 1
}

if [[ -z "$INPUT" ]];
then
        echo "ERROR: Some or all of the parameters are empty";
        helpFunction
fi


FNAME=$(basename -- "$INPUT")
EXT="${FNAME##*.}"
IN_PATH="${FNAME%.*}"
INORBIT="/mnt/data/input/$INPUT"
export INORBIT

# loop throughto get the number of files in dirctory
#COUNT=$(ls -l $FILES | wc -l) && echo "\""$INORBIT"\" dirctory has "$COUNT" files" || :
COUNT=$(python3 -c "import os, xlrd; xls=os.environ['INORBIT']; print(len(xlrd.open_workbook(xls, on_demand=True).sheet_names()))")

COUNT=$(expr $COUNT - 1)
HEADER=(-H "Content-Type: application/json" -H "Authorization: Bearer $BLUETRON_TOKEN")
CHAR_SIZE=$(echo "$IN_PATH" | tr '[:upper:]' '[:lower:]' | sed 's/_/-/g' | wc -c)
OBJ_NAME=$(echo "$IN_PATH" | tr '[:upper:]' '[:lower:]' | sed 's/_/-/g')

if [ ${#OBJ_NAME} -le 27 ];
then echo "Object name is accurate"
else
OBJ_NAME=${OBJ_NAME::27}
echo "Object name is: \""$OBJ_NAME"\""
fi


init_acyclic_step_workflow_engine () {

EVIDENT="{\"apiVersion\":\"argoproj.io/v1alpha1\",\"kind\":\"Workflow\",\"metadata\":{\"generateName\":\"bluetron-processor-"$OBJ_NAME"-wf-\","
EVIDENT+="\"labels\":{\"workflows.argoproj.io/archive-strategy\":\"false\"},\"namespace\":\"bluetron\"},\"spec\":{\"entrypoint\":\"acyclic-processor\","
EVIDENT+="\"templates\":[{\"dag\":{\"tasks\":[{\"name\":\"data-validator\",\"template\":\"data-validation-processor\"},{\"dependencies\":[\"data-validator\"],"
EVIDENT+="\"name\":\"parallal-processing-counter\",\"template\":\"parallal-processor\"},{\"dependencies\":[\"parallal-processing-counter\"],"
EVIDENT+="\"name\":\"merge-processor\",\"template\":\"data-merge-processor\"}]},\"name\":\"acyclic-processor\"},{\"name\":\"parallal-processor\","
EVIDENT+="\"steps\":[[{\"arguments\":{\"parameters\":[{\"name\":\"msg\",\"value\":\"{{item}}\"}]},\"name\":\"step\",\"template\":\"steps-processor\","
EVIDENT+="\"withSequence\":{\"end\":\""$COUNT"\",\"start\":\"0\"}}]]},{\"container\":{\"args\":[\"-c\",\"python3 workbook_csv_data_processor.py -i "$INPUT" -s {{inputs.parameters.msg}}\"],"
EVIDENT+="\"command\":[\"/bin/bash\"],\"env\":[{\"name\":\"BLUETRON_TOKEN\",\"valueFrom\":{\"secretKeyRef\":{\"key\":\"token\",\"name\":\"bluetron-admin-token-xc28r\"}}},"
EVIDENT+="{\"name\":\"BLUETRON_CERT\",\"valueFrom\":{\"secretKeyRef\":{\"key\":\"ca.crt\",\"name\":\"bluetron-admin-token-xc28r\"}}}],\"image\":\"bluetron/hackathon:dataprocessor\","
EVIDENT+="\"imagePullPolicy\":\"Always\",\"volumeMounts\":[{\"mountPath\":\"/mnt/data\",\"name\":\"hostvolume\"}]},\"inputs\":{\"parameters\":[{\"name\":\"msg\"}]},"
EVIDENT+="\"name\":\"steps-processor\",\"retryStrategy\":{\"limit\":10,\"retryPolicy\":\"Always\"}},{\"container\":{\"args\":[\"python3\",\"workbook_validator.py -i "$INPUT"\"],"
EVIDENT+="\"env\":[{\"name\":\"BLUETRON_TOKEN\",\"valueFrom\":{\"secretKeyRef\":{\"key\":\"token\",\"name\":\"bluetron-admin-token-xc28r\"}}},"
EVIDENT+="{\"name\":\"BLUETRON_CERT\",\"valueFrom\":{\"secretKeyRef\":{\"key\":\"ca.crt\",\"name\":\"bluetron-admin-token-xc28r\"}}}],\"image\":\"bluetron/hackathon:datavalidator\","
EVIDENT+="\"imagePullPolicy\":\"Always\",\"volumeMounts\":[{\"mountPath\":\"/mnt/data\",\"name\":\"hostvolume\"}]},\"name\":\"data-validation-processor\","
EVIDENT+="\"retryStrategy\":{\"limit\":10,\"retryPolicy\":\"Always\"}},{\"container\":{\"args\":[\"-c\",\"python3 data_merger.py -i "$INPUT"\"],"
EVIDENT+="\"command\":[\"/bin/bash\"],\"env\":[{\"name\":\"BLUETRON_TOKEN\",\"valueFrom\":{\"secretKeyRef\":{\"key\":\"token\",\"name\":\"bluetron-admin-token-xc28r\"}}},"
EVIDENT+="{\"name\":\"BLUETRON_CERT\",\"valueFrom\":{\"secretKeyRef\":{\"key\":\"ca.crt\",\"name\":\"bluetron-admin-token-xc28r\"}}}],\"image\":\"bluetron/hackathon:datamerger\","
EVIDENT+="\"imagePullPolicy\":\"Always\",\"volumeMounts\":[{\"mountPath\":\"/mnt/data\",\"name\":\"hostvolume\"}]},\"name\":\"data-merge-processor\","
EVIDENT+="\"retryStrategy\":{\"limit\":10,\"retryPolicy\":\"Always\"}}],\"volumes\":[{\"name\":\"hostvolume\",\"persistentVolumeClaim\":{\"claimName\":\"local-hostpath-pvc\"}}]}}"


echo \'"$EVIDENT"\'

#               curl -s -k -XPOST "${HEADER[@]}" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/argoproj.io/v1alpha1/namespaces/bluetron/workflows -d "$EVIDENT" > /dev/null
                curl -s -k -XPOST "${HEADER[@]}" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/argoproj.io/v1alpha1/namespaces/bluetron/workflows -d "$EVIDENT"

sleep 2

}

init_acyclic_step_workflow_engine
