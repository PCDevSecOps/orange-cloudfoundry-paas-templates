# documentation

## content
```
└── test
    ├── 1.model
    │   └── model.lst
    ├── 2.instances
    │   └── instances.lst
    ├── 3.assertions
    │   └── assertions.lst
    └── test.md
```


## model
model directory holds the model description (it is the target model which is processed by the migration script). It is made of two columns : 
```
D|/tmp/coab-depls/cf-mysql
F|/tmp/coab-depls/cf-mysql/deployment-dependencies.yml
D|/tmp/coab-depls/cf-mysql/template
F|/tmp/coab-depls/cf-mysql/template/cf-mysql.yml
F|/tmp/coab-depls/cf-mysql/template/new-operators.yml
F|/tmp/coab-depls/cf-mysql/template/coab-vars.yml
D|/tmp/coab-depls/cf-mysql/template/vsphere
F|/tmp/coab-depls/cf-mysql/template/vsphere/vsphere-operators.yml
D|/tmp/coab-depls/cf-mysql/template/openstack-hws
F|/tmp/coab-depls/cf-mysql/template/openstack-hws/openstack-hws-operators.yml
D|/tmp/coab-depls/cf-mysql/template/new-profile
F|/tmp/coab-depls/cf-mysql/template/new-profile/new-profile-operators.yml
T|/tmp/coab-depls/cf-mysql
```
- First column is the action
    - D means directory creation 
    - F means file creation
    - T means tree command execution (friendly display)
- Second column is the path

## instances
instances directory holds the instances description before the migration
```
D||/tmp/coab-depls/y_1
L|../cf-mysql/deployment-dependencies.yml|deployment-dependencies.yml
D||/tmp/coab-depls/y_1/template
L|../../cf-mysql/template/cf-mysql.yml|y_1.yml
F||/tmp/coab-depls/y_1/template/coab-vars.yml
L||/tmp/coab-depls/y_1/template/old-operators.yml
D||/tmp/coab-depls/y_1/template/vsphere
L|../../../cf-mysql/template/vsphere/vsphere-operators.yml|vsphere-operators.yml
D||/tmp/coab-depls/y_1/template/openstack-hws
L|../../../cf-mysql/template/openstack-hws/openstack-hws-operators.yml|openstack-hws-operators.yml
D||/tmp/coab-depls/y_1/template/old-profile
L||../../cf-mysql/template/old-profile/old-profile-operators.yml
T||/tmp/coab-depls/y_1
```
- First column is the action
    - D means directory creation 
    - L means link creation
    - F means file creation with # caracter inside
    - T means tree command execution (friendly display)
- Second column is the relative source path
- Third column is the target path

## assertions
assertions directory holds the assertions
```
T|/tmp/coab-depls
L|/tmp/coab-depls/y_1/deployment-dependencies.yml
L|/tmp/coab-depls/y_1/template/y_1.yml
F|/tmp/coab-depls/y_1/template/coab-vars.yml
L|/tmp/coab-depls/y_1/template/vsphere/vsphere-operators.yml
L|/tmp/coab-depls/y_1/template/openstack-hws/openstack-hws-operators.yml
L|/tmp/coab-depls/y_1/template/new-operators.yml
!L|/tmp/coab-depls/y_1/template/old-operators.yml
!D|/tmp/coab-depls/y_1/template/old-profile
!L|/tmp/coab-depls/y_1/template/old-profile/old-profile-operators.yml
D|/tmp/coab-depls/y_1/template/new-profile
L|/tmp/coab-depls/y_1/template/new-profile/new-profile-operators.yml
```
- First column is the assertion to check
    - L means "link is present" assertion
    - !L means "link is not present" assertion    
    - D means "directory is present" assertion
    - !D means "directory is not present" assertion    
    - F means file assertion
    - T means tree command execution (friendly display)

- Second column is the assertion path