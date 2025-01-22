# paragon-assignment

There proposed solution for generating grafana users upon the Grafana helm chart installation is by utilizing the official chart using the extraObjects directive to create a job that runs once and executes an Ansible playbook to create the users.

## Testing the solution

### Add the Grafana repo
```console
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```
### Optional: build the docker image
This step build a docker images based on the alpine/ansible image, copies the required Ansible playbook into it and modifies the execution command.

Change the tag to push to a repo.

```console
docker buildx build -t demo/grafana-users-runner .
docker push demo/grafana-users-runner
```

### Install the chart

The following method does not require building a docker image and is self contained.
```console
helm install grafana grafana/grafana --values values-test.yaml
```

To test with the built docker image you will need to modify the [values.yaml](./values.yaml:49) line 49 with the matching image name and tag

```console
helm install grafana grafana/grafana --values values.yaml
```

### Inspect the job logs
```console
kubectl get pods

NAME                         READY   STATUS      RESTARTS   AGE
create-grafana-users-h8jqq   0/1     Completed   0          46m
grafana-67567f8446-z2lcv     1/1     Running     0          46m

kubectl logs create-grafana-users-h8jqq

Defaulted container "ansible" out of: ansible, init-service (init)
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that
the implicit localhost does not match 'all'

PLAY [Create Grafana organization users] ***************************************

TASK [Create the users] ********************************************************
changed: [localhost] => (item={'key': 'admin_user', 'value': {'email': 'admin_user@acme.com', 'name': 'Admin user', 'org_id': '1', 'password': 'admin_password', 'role': 'admin'}})
changed: [localhost] => (item={'key': 'editor_user', 'value': {'email': 'editor_user@acme.com', 'name': 'Editor user', 'org_id': '1', 'password': 'editor_password', 'role': 'editor'}})
changed: [localhost] => (item={'key': 'viewer_user', 'value': {'email': 'viewer_user@acme.com', 'name': 'Viewer user', 'org_id': '1', 'password': 'viewer_password', 'role': 'viewer'}})

TASK [Apply the organization roles to the users] *******************************
changed: [localhost] => (item={'key': 'admin_user', 'value': {'email': 'admin_user@acme.com', 'name': 'Admin user', 'org_id': '1', 'password': 'admin_password', 'role': 'admin'}})
changed: [localhost] => (item={'key': 'editor_user', 'value': {'email': 'editor_user@acme.com', 'name': 'Editor user', 'org_id': '1', 'password': 'editor_password', 'role': 'editor'}})
ok: [localhost] => (item={'key': 'viewer_user', 'value': {'email': 'viewer_user@acme.com', 'name': 'Viewer user', 'org_id': '1', 'password': 'viewer_password', 'role': 'viewer'}})

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

