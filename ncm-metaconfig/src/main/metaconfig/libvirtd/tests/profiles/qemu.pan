object template qemu;

include 'metaconfig/libvirtd/qemu';

prefix "/software/components/metaconfig/services/{/etc/libvirt/qemu.conf}/contents";
"vnc_listen" = "0.0.0.0";
"vnc_auto_unix_socket" = true;
"vnc_tls" = true;
"vnc_tls_x509_cert_dir" = "/etc/pki/libvirt-vnc";
"vnc_tls_x509_verify" = true;
"vnc_password" = "XYZ12345";
"vnc_sasl" = true;
"vnc_sasl_dir" = "/some/directory/sasl2";
"vnc_allow_host_audio" = false;
"spice_listen" = "0.0.0.0";
"spice_tls" = true;
"spice_tls_x509_cert_dir" = "/etc/pki/libvirt-spice";
"spice_password" = "XYZ12345";
"spice_sasl" = true;
"spice_sasl_dir" = "/some/directory/sasl2";
"nographics_allow_host_audio" = true;
"remote_display_port_min" = 5900;
"remote_display_port_max" = 65535;
"remote_websocket_port_min" = 5700;
"remote_websocket_port_max" = 65535;
"security_driver" = "selinux";
"security_default_confined" = true;
"security_require_confined" = true;
"user" = "qemu";
"group" ="kvm";
"dynamic_ownership" = true;
"cgroup_controllers" = list("cpu", "devices", "memory", "blkio", "cpuset", "cpuacct");
"cgroup_device_acl" = list("/dev/null", "/dev/full", "/dev/urandom", "/dev/vfio/vfio");
"save_image_format" = "raw";
"dump_image_format" = "raw";
"snapshot_image_format" = "raw";
"auto_dump_path" = "/var/lib/libvirt/qemu/dump";
"auto_dump_bypass_cache" = false;
"auto_start_bypass_cache" = false;
"hugetlbfs_mount" = list("/dev/hugepages2M", "/dev/hugepages1G");
"bridge_helper" = "/usr/lib/qemu/qemu-bridge-helper";
"clear_emulator_capabilities" = true;
"set_process_name" = true;
"max_processes" = false;
"max_files" = false;
"mac_filter" = true;
"relaxed_acs_check" = true;
"allow_disk_format_probing" = true;
"lock_manager" = "lockd";
"max_queued" = 0;
"keepalive_interval" = 5;
"keepalive_count" = 5;
"seccomp_sandbox" = "1";
"migration_address" = "0.0.0.0";
"migration_host" = "host.example.com";
"migration_port_min" = 49152;
"migration_port_max" = 49215;
"log_timestamp" = false;
"nvram" = list("/usr/share/OVMF/OVMF_CODE.fd:/usr/share/OVMF/OVMF_VARS.fd");
