object template datastore_ceph;

include 'components/opennebula/schema';

bind "/metaconfig/contents/datastore/ceph" = opennebula_datastore;

"/metaconfig/module" = "datastore";

prefix "/metaconfig/contents/datastore/ceph";
"bridge_list" = list("hyp004.cubone.os");
"ceph_host" = list("ceph001.cubone.os","ceph002.cubone.os","ceph003.cubone.os");
"ceph_secret" = "35b161e7-a3bc-440f-b007-cb98ac042646";
"ceph_user" = "libvirt";
"ceph_user_key" = "dummydummycephuserkey";
"datastore_capacity_check" = true;
"pool_name" = "one";
"type" = "IMAGE_DS";
"rbd_format" = 2;
"labels" = list("quattor", "quattor/ceph");
