# add your credentials here or pass them via env
# export ALICLOUD_ACCESS_KEY="????????????????????"
# export ALICLOUD_SECRET_KEY="????????????????????"
# e.g : ./aliyun-key.sh
provider "alicloud" {
  # access_key = "????????????????????"
  # secret_key = "????????????????????"
}

# use 10.10.10.0/24 cidr block as demo network
resource "alicloud_vpc" "vpc" {
  vpc_name   = "pigsty-demo-network"
  cidr_block = "10.10.10.0/24"
}

# add virtual switch for pigsty demo network
resource "alicloud_vswitch" "vsw" {
  vpc_id     = "${alicloud_vpc.vpc.id}"
  cidr_block = "10.10.10.0/24"
  zone_id    = "cn-beijing-k"
}

# add default security group and allow all tcp traffic
resource "alicloud_security_group" "default" {
  name   = "default"
  vpc_id = "${alicloud_vpc.vpc.id}"
}
resource "alicloud_security_group_rule" "allow_all_tcp" {
  ip_protocol       = "tcp"
  type              = "ingress"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = "${alicloud_security_group.default.id}"
  cidr_ip           = "0.0.0.0/0"
}

# pg-meta: 1c2G x1
# pg-test: 1c1G x3

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance
resource "alicloud_instance" "pg-meta-1" {
  instance_name              = "pg-meta-1"
  host_name                  = "pg-meta-1"
  instance_type              = "ecs.s6-c1m2.small"
  vswitch_id                 = "${alicloud_vswitch.vsw.id}"
  security_groups            = ["${alicloud_security_group.default.id}"]
  image_id                   = "centos_7_8_x64_20G_alibase_20200914.vhd"
  password                   = "PigstyDemo4"
  private_ip                 = "10.10.10.10"
  internet_max_bandwidth_out = 40 # 40Mbps , alloc a public IP
}

resource "alicloud_instance" "pg-test-1" {
  instance_name   = "pg-test-1"
  host_name       = "pg-test-1"
  instance_type   = "ecs.s6-c1m1.small"
  vswitch_id      = "${alicloud_vswitch.vsw.id}"
  security_groups = ["${alicloud_security_group.default.id}"]
  image_id        = "centos_7_8_x64_20G_alibase_20200914.vhd"
  password        = "PigstyDemo4"
  private_ip      = "10.10.10.11"
}

resource "alicloud_instance" "pg-test-2" {
  instance_name   = "pg-test-2"
  host_name       = "pg-test-2"
  instance_type   = "ecs.s6-c1m1.small"
  vswitch_id      = "${alicloud_vswitch.vsw.id}"
  security_groups = ["${alicloud_security_group.default.id}"]
  image_id        = "centos_7_8_x64_20G_alibase_20200914.vhd"
  password        = "PigstyDemo4"
  private_ip      = "10.10.10.12"
}

resource "alicloud_instance" "pg-test-3" {
  instance_name   = "pg-test-3"
  host_name       = "pg-test-3"
  instance_type   = "ecs.s6-c1m1.small"
  vswitch_id      = "${alicloud_vswitch.vsw.id}"
  security_groups = ["${alicloud_security_group.default.id}"]
  image_id        = "centos_7_8_x64_20G_alibase_20200914.vhd"
  password        = "PigstyDemo4"
  private_ip      = "10.10.10.13"
}


output "meta_ip" {
  value = "${alicloud_instance.pg-meta-1.public_ip}"
}

