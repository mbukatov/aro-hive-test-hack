# ARO Hive Test Hack

Testing scripts for ARO Hive use cases. This is a hack, don't use it outside
of a testing environment.

## Example of usage

We have an ARO cluster deployed via Hive:

```
$ oc get cd -n aro-c2bcaa83-2ad3-4ab1-8d1b-40da2e7ac85c
NAME      INFRAID                 PLATFORM   REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      42h
```

So that we can create a template based on this cluster:

```
$ ./ahth-make-template.sh -n aro-c2bcaa83-2ad3-4ab1-8d1b-40da2e7ac85c -c cluster > aro.template.json
```

Then, we can create a single `ClusterDeployment` in a new namespace
`aroqe-0001` referencing the same ARO cluster based on the template we just
created:

```
$ ./ahth-create-cd.sh -n aroqe-00001 -t aro.template.json
```

If this seems to work:

```
$ oc get cd -n aroqe-00001
NAME      INFRAID                 PLATFORM   REGION   VERSION   CLUSTERTYPE   PROVISIONSTATUS   POWERSTATE   AGE
cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2m5s
```

We can go on and create as many such clusters as necessary for our testing:

```
$ ./ahth-create-cd.sh -n aroqe -t aro.template.json -s 2 -e 100
```

In our case, we will end up with 100 testing clusters:

```
$ oc get cd --all-namespaces | grep aroqe | head
aroqe-00001                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      1h
aroqe-00002                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2h
aroqe-00003                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2h
aroqe-00004                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2h
aroqe-00005                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2h
aroqe-00006                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2h
aroqe-00007                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2h
aroqe-00008                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2h
aroqe-00009                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2h
aroqe-00010                                cluster   mbukatov-debug2-r2d23   azure      eastus   4.11.26                 Provisioned       Running      2h
$ oc get cd --all-namespaces | grep aroqe | wc -l
100
```

## License

Distributed under the terms of the *Apache License 2.0*.
