#!/bin/sh

cd ..

for u in $(find . -type l);
 do rm $u;
done

echo  "=================================================="
echo  "create link common on deployment on all k8s or k3s"
echo  "=================================================="

    for u in $(ls ../../../shared-operators/k8s-common/*.yml  | sed -r 's/^.+\///');
        do
            echo "create link ${u}"
            ln -s  ../../../shared-operators/k8s-common/${u} ${u} ;
        done;
echo  "=================================================="
echo "create link common on deployment on same k8s or k3s"
echo  "=================================================="
for dir in "${depls}"  ;
do
    for u in $(ls ../../../shared-operators/k8s-common/${dir}/*.yml  | sed -r 's/^.+\///');
        do
            echo "create link ${u}"
            ln -s  ../../../shared-operators/k8s-common/${dir}/${u} ${u} ;
        done;
    echo "look for profile or iaastype";
    if [[ "${fixedprofile}" != "" ]]
    then
        for profile in $(find ../../../shared-operators/k8s-common/${dir} -type d | cut -d"/" -f6); do
        if [[ "${profile}" == "${fixedprofile}" ]]
        then
            echo "processing fixe profile ${profile}";

            for u in $(ls ../../../shared-operators/k8s-common/${dir}/${profile}/*.yml  | sed -r 's/^.+\///');
                do
                    echo "create link ${u} for profile ${profile}"
                    ln -s  ../../../shared-operators/k8s-common/${dir}/${profile}/${u} ${u};
                done;
        else
            echo "ignore profile ${profile}";
        fi;

        done;

    else
        for profile in $(find ../../../shared-operators/k8s-common/${dir} -type d | cut -d"/" -f8); do
                echo "find dir :${profile} "
                if [[ "${profile}" == "tools" ]]
                then
                   echo "ignore tools directory:${profile}";
                else
                    echo "processing profile ${profile}";

                    mkdir -p ${profile};
                    ls -als ${profile};
                    for file in $(find ./${profile} -type l);
                        do
                            rm ./${profile}/${file};
                        done
                    for u in $(ls ../../../shared-operators/k8s-common/${dir}/${profile}/*.yml  | sed -r 's/^.+\///');
                        do
                            echo "create link ${u} for profile ${profile}"
                            ln -s  ../../../../shared-operators/k8s-common/${dir}/${profile}/${u} ${profile}/${u};
                        done;
                fi;
                done;
    fi;
done;

echo  "=================================================="
echo "create link specific to deployment "
echo  "=================================================="

for dir in "${deploy}" ;
do
    for u in $(ls ../../../shared-operators/${dir}/*.yml  | sed -r 's/^.+\///');
        do
            echo "create link ${u}"
            ln -s  ../../../shared-operators/${dir}/${u} ${u} ;
        done;
    echo "look for profile or iaastype";
    if [[ "${fixedprofile}" != "" ]]
    then
        for profile in $(find ../../../shared-operators/${dir} -type d | cut -d"/" -f6); do
        if [[ "${profile}" == "${fixedprofile}" ]]
        then
            echo "processing fixe profile ${profile}";

            for u in $(ls ../../../shared-operators/${dir}/${profile}/*.yml  | sed -r 's/^.+\///');
                do
                    echo "create link ${u} for profile ${profile}"
                    ln -s  ../../../shared-operators/${dir}/${profile}/${u} ${u};
                done;
        else
            echo "ignore profile ${profile}";
        fi;

        done;

    else
        for profile in $(find ../../../shared-operators/${dir} -type d | cut -d"/" -f6); do
                echo "find dir :${profile} "
                if [[ "${profile}" == "tools" ]]
                then
                   echo "ignore tools directory:${profile}";
                else
                    echo "processing profile ${profile}";

                    mkdir -p ${profile};
                    ls -als ${profile};
                    for file in $(find ./${profile} -type l);
                        do
                            rm ./${profile}/${file};
                        done
                    for u in $(ls ../../../shared-operators/${dir}/${profile}/*.yml  | sed -r 's/^.+\///');
                        do
                            echo "create link ${u} for profile ${profile}"
                            ln -s  ../../../../shared-operators/${dir}/${profile}/${u} ${profile}/${u};
                        done;
                fi;
                done;
    fi;
done;
mv deploy-tpl.yml ${final_name}-tpl.yml